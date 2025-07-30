import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/app_state.dart';
import '../services/wallet_service.dart';
import '../models/app_models.dart';
import '../screens/payment_screen.dart';
import '../screens/call_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/expert_navigation.dart';
import '../screens/main_navigation.dart';
import '../widgets/review_dialog.dart';
import '../widgets/call_status_bar.dart';

class ChatScreen extends StatefulWidget {
  final Expert? expert;
  final PaymentType? paymentType;
  final String? expertId;
  final String? clientName;
  final String? clientImage;
  final bool viewOnly;
  final ConsultationSession? session;
  final bool isTeamChat;
  final String? teamMemberName;

  const ChatScreen({
    super.key,
    this.expert,
    this.paymentType,
    this.expertId,
    this.clientName,
    this.clientImage,
    this.viewOnly = false,
    this.session,
    this.isTeamChat = false,
    this.teamMemberName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _sessionTimer;
  int _timerSeconds = 0;
  bool _isRecording = false;
  double _totalCost = 0.0;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (!widget.viewOnly) {
      await _startSessionTimer();
    } else {
      // For view-only mode, load dummy chat messages
      _loadViewOnlyMessages();
    }

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSessionTimer() async {
    // Don't start timer for team chats
    if (widget.isTeamChat) return;

    final appState = context.read<AppState>();
    final paymentType = widget.paymentType ?? PaymentType.perMinute;
    final selectedSessionConfig = appState.selectedSessionConfig;
    final isClient = appState.currentUser?.userType == UserType.client;
    final isExpert = appState.currentUser?.userType == UserType.expert;

    // Check if there's already an active session with existing timer
    if (appState.isInSession && appState.sessionTimer > 0) {
      // Use existing timer - don't reset it
      _timerSeconds = appState.sessionTimer;
      if (paymentType == PaymentType.perSession &&
          selectedSessionConfig != null) {
        _totalCost = selectedSessionConfig.price;
      } else if (paymentType == PaymentType.perSession) {
        _totalCost = widget.expert?.pricePerSession ?? 80.0;
      } else {
        _totalCost =
            (_timerSeconds / 60.0) * (widget.expert?.pricePerMinute ?? 50.0);
      }
    } else if (isClient) {
      // Only clients can start new sessions and control timer
      if (paymentType == PaymentType.perSession &&
          selectedSessionConfig != null) {
        // Use selected session config duration and price
        _timerSeconds = selectedSessionConfig.durationMinutes * 60;
        _totalCost = selectedSessionConfig.price;
      } else if (paymentType == PaymentType.perSession) {
        // For per session without config, start countdown from 20 minutes (1200 seconds)
        _timerSeconds = 1200;
        _totalCost = widget.expert?.pricePerSession ?? 80.0;
      } else {
        // For per minute, start from 0 and count up
        _timerSeconds = 0;
        _totalCost = 0.0;
      }

      // Start the session in app state
      // For chat screen, credits are usually already deducted in payment screen
      // so we don't need to pass wallet service here
      final success = await appState.startSession(
        widget.expert?.id ?? widget.expertId ?? 'expert1',
        SessionType.chat,
        paymentType == PaymentType.perMinute,
      );

      if (!success) {
        // This shouldn't happen if credits were already deducted, but handle it just in case
        Navigator.of(context).pop();
        return;
      }
    } else if (isExpert) {
      // Experts join existing sessions without resetting timer
      if (appState.activeSession != null) {
        _timerSeconds = appState.sessionTimer;
        if (paymentType == PaymentType.perSession &&
            selectedSessionConfig != null) {
          _totalCost = selectedSessionConfig.price;
        } else if (paymentType == PaymentType.perSession) {
          _totalCost = widget.expert?.pricePerSession ?? 80.0;
        } else {
          _totalCost =
              (_timerSeconds / 60.0) * (widget.expert?.pricePerMinute ?? 50.0);
        }
      } else {
        // No active session for expert to join
        return;
      }
    }

    // Only client controls the timer
    if (isClient) {
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (paymentType == PaymentType.perSession) {
            _timerSeconds--;

            // Show warning when 2 minutes remaining
            if (_timerSeconds == 120 && !_showWarning) {
              _showWarning = true;
              _showSessionWarning();
            }

            // End session when time runs out
            if (_timerSeconds <= 0) {
              _endSession();
            }

            // Total cost remains fixed for session payment
            if (selectedSessionConfig != null) {
              _totalCost = selectedSessionConfig.price;
            }
          } else {
            _timerSeconds++;
            // Calculate cost per minute
            _totalCost = (_timerSeconds / 60.0) *
                (widget.expert?.pricePerMinute ?? 50.0);
          }
        });
        appState.updateSessionTimer(_timerSeconds);
      });
    } else if (isExpert) {
      // Expert just syncs with existing timer, doesn't control it
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentTimer = appState.sessionTimer;
        if (currentTimer != _timerSeconds) {
          setState(() {
            _timerSeconds = currentTimer;
            if (paymentType == PaymentType.perSession &&
                selectedSessionConfig != null) {
              _totalCost = selectedSessionConfig.price;
            } else if (paymentType == PaymentType.perSession) {
              _totalCost = widget.expert?.pricePerSession ?? 80.0;
            } else {
              _totalCost = (_timerSeconds / 60.0) *
                  (widget.expert?.pricePerMinute ?? 50.0);
            }

            // Check if session ended by client
            if (_timerSeconds <= 0 && paymentType == PaymentType.perSession) {
              _endSession();
            }
          });
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _initiateCall(bool isVideoCall) {
    final appState = context.read<AppState>();
    final sessionType = isVideoCall ? SessionType.video : SessionType.voice;

    if (widget.isTeamChat) {
      // For team chat, create a dummy expert with team member info
      final teamExpert = Expert(
        id: 'team_${widget.teamMemberName?.replaceAll(' ', '_') ?? 'member'}',
        name: widget.teamMemberName ?? 'Team Member',
        email: 'team@chatpro.com',
        bio: 'Team Member',
        category: ExpertCategory.businessConsultant,
        subcategories: ['Team Communication'],
        languages: ['English'],
        rating: 5.0,
        totalReviews: 0,
        pricePerMinute: 0.0,
        pricePerSession: 0.0,
        isAvailable: true,
        isVerified: true,
        joinedAt: DateTime.now(),
        regions: ['All'],
      );

      // Set call status in app state with team member
      appState.startCall(teamExpert.id, sessionType);

      // Navigate to call screen with team member
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            expert: teamExpert,
            sessionType: sessionType,
            isTeamCall: true,
          ),
        ),
      );
    } else if (widget.expert != null) {
      // Set call status in app state
      appState.startCall(widget.expert!.id, sessionType);

      // Pause the chat timer when going to call
      _sessionTimer?.cancel();

      // Navigate to call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            expert: widget.expert!,
            sessionType: sessionType,
          ),
        ),
      ).then((_) {
        // Note: Don't automatically end call status here since the user might
        // just be navigating back to chat while call is still active

        // Resume the chat timer when returning from call
        if (mounted) {
          _resumeSessionTimer();
        }
      });
    }
  }

  void _resumeSessionTimer() {
    // Don't resume timer for team chats
    if (widget.isTeamChat) return;

    final appState = context.read<AppState>();
    final paymentType = widget.paymentType ?? PaymentType.perMinute;
    final isClient = appState.currentUser?.userType == UserType.client;
    final isExpert = appState.currentUser?.userType == UserType.expert;

    // Get the updated timer from app state
    _timerSeconds = appState.sessionTimer;

    // Resume the timer - only client controls it
    if (isClient) {
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (paymentType == PaymentType.perSession) {
            _timerSeconds--;

            // Show warning when 2 minutes remaining
            if (_timerSeconds == 120 && !_showWarning) {
              _showWarning = true;
              _showSessionWarning();
            }

            // End session when time runs out
            if (_timerSeconds <= 0) {
              _endSession();
            }
          } else {
            _timerSeconds++;
            // Calculate cost per minute
            _totalCost = (_timerSeconds / 60.0) *
                (widget.expert?.pricePerMinute ?? 50.0);
          }
        });
        appState.updateSessionTimer(_timerSeconds);
      });
    } else if (isExpert) {
      // Expert just syncs with existing timer, doesn't control it
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentTimer = appState.sessionTimer;
        if (currentTimer != _timerSeconds) {
          setState(() {
            _timerSeconds = currentTimer;
            if (paymentType == PaymentType.perSession) {
              _totalCost = widget.expert?.pricePerSession ?? 80.0;
            } else {
              _totalCost = (_timerSeconds / 60.0) *
                  (widget.expert?.pricePerMinute ?? 50.0);
            }

            // Check if session ended by client
            if (_timerSeconds <= 0 && paymentType == PaymentType.perSession) {
              _endSession();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog for paid sessions only
        if (_shouldShowExitConfirmation(appState)) {
          return await _showExitConfirmationDialog(context, theme, appState);
        }
        return true; // Allow exit for free communication
      },
      child: Scaffold(
        appBar: _buildAppBar(appState, theme),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const CallStatusBar(),
                if (!widget.viewOnly) _buildSessionHeader(appState, theme),
                if (widget.viewOnly) _buildViewOnlyHeader(appState, theme),
                Expanded(
                  child: _buildMessagesList(appState, theme),
                ),
                if (widget.viewOnly)
                  _buildExpertRequestBar(appState, theme)
                else if (appState.activeSession?.status == SessionStatus.ended)
                  _buildSessionEndedBar(appState, theme)
                else
                  _buildMessageInput(appState, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppState appState, ThemeData theme) {
    final isClient = appState.currentUser?.userType == UserType.client;

    return AppBar(
      leading: isClient && !widget.viewOnly
          ? Container(
              margin: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () => _endSessionNow(appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'End Now',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: widget.clientImage != null
                ? NetworkImage(widget.clientImage!)
                : (widget.expert?.profileImage != null
                    ? NetworkImage(widget.expert!.profileImage!)
                    : null),
            child: (widget.clientImage == null &&
                    widget.expert?.profileImage == null)
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isTeamChat
                      ? (widget.teamMemberName ?? 'Team Member')
                      : (widget.clientName ?? widget.expert?.name ?? 'Expert'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isTeamChat
                      ? 'Team Chat'
                      : (widget.expert?.isAvailable == true
                          ? 'Online'
                          : 'Offline'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.isTeamChat
                        ? theme.colorScheme.primary
                        : (widget.expert?.isAvailable == true
                            ? Colors.green
                            : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.expert != null || widget.isTeamChat) ...[
          IconButton(
            onPressed: () => _initiateCall(false),
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
          ),
          IconButton(
            onPressed: () => _initiateCall(true),
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
          ),
        ],
        const SizedBox(width: 8),
      ],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(AppState appState, ThemeData theme) {
    if (widget.isTeamChat) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.group,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Team Chat - Free Communication',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final paymentType = widget.paymentType ?? PaymentType.perMinute;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            paymentType == PaymentType.perSession
                ? Icons.hourglass_bottom
                : Icons.timer,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            paymentType == PaymentType.perSession
                ? 'Time Remaining: ${_formatTime(_timerSeconds)}'
                : 'Session Time: ${_formatTime(_timerSeconds)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Text(
                'Total Cost: ${appState.convertAndFormatPrice(_totalCost, 'USD')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(AppState appState, ThemeData theme) {
    final messages = appState.currentChatMessages;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start your conversation',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUserMessage = message.senderId == appState.currentUser?.id;

        return _buildMessageBubble(message, isUserMessage, theme, appState);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isUserMessage,
      ThemeData theme, AppState appState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: widget.expert?.profileImage != null
                  ? NetworkImage(widget.expert!.profileImage!)
                  : null,
              child: widget.expert?.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUserMessage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: isUserMessage
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isUserMessage
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.text) ...[
                        Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUserMessage
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ] else if (message.type == MessageType.image) ...[
                        Container(
                          height: 150,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://pixabay.com/get/gaf3f21d1565b75696858a571405084f0ab547a051072b6b56d2c9d36bde0cdf21596eec57bf8a3c9e17fcc19d39cbae539917232e2288c928bf43dffb6f5625c_1280.jpg",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ] else if (message.type == MessageType.audio) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: isUserMessage
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Audio message',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ] else if (message.type == MessageType.document) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description,
                              color: isUserMessage
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Document',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isUserMessage
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: appState.currentUser?.profileImage != null
                  ? NetworkImage(appState.currentUser!.profileImage!)
                  : null,
              child: appState.currentUser?.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Media buttons
          IconButton(
            onPressed: () => _showMediaOptions(appState, theme),
            icon: Icon(
              Icons.add,
              color: theme.colorScheme.primary,
            ),
          ),
          // Message input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: appState.translate('type_message'),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice record button
          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopRecording(appState),
            onTapCancel: () => _cancelRecording(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isRecording ? Colors.red : theme.colorScheme.primary)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          IconButton(
            onPressed: () => _sendMessage(appState),
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions(AppState appState, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(
                    'Camera',
                    Icons.camera_alt,
                    theme.colorScheme.primary,
                    () => _sendMediaMessage(MessageType.image, appState),
                    theme,
                  ),
                  _buildMediaOption(
                    'Gallery',
                    Icons.photo_library,
                    theme.colorScheme.secondary,
                    () => _sendMediaMessage(MessageType.image, appState),
                    theme,
                  ),
                  _buildMediaOption(
                    'Document',
                    Icons.description,
                    theme.colorScheme.tertiary,
                    () => _sendMediaMessage(MessageType.document, appState),
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaOption(String label, IconData icon, Color color,
      VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AppState appState) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      appState.sendMessage(message, MessageType.text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _sendMediaMessage(MessageType type, AppState appState) {
    String content = '';
    switch (type) {
      case MessageType.image:
        content = 'Image shared';
        break;
      case MessageType.audio:
        content = 'Audio message';
        break;
      case MessageType.document:
        content = 'Document shared';
        break;
      case MessageType.text:
        content = 'Text message';
        break;
    }

    appState.sendMessage(content, type);
    _scrollToBottom();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording(AppState appState) {
    setState(() {
      _isRecording = false;
    });
    _sendMediaMessage(MessageType.audio, appState);
  }

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _showEndSessionDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('end_session')),
        content: Text(appState.translate('end_session_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              _sessionTimer?.cancel();
              Navigator.pop(context); // Close dialog

              // Show review dialog before ending session
              _showReviewDialog(appState);
            },
            child: Text(appState.translate('end_session')),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showSessionWarning() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(appState.translate('session_warning')),
          ],
        ),
        content: Text(appState.translate('session_time_remaining')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _endSession() {
    _sessionTimer?.cancel();
    final appState = context.read<AppState>();

    // Show review dialog before ending session (only for clients)
    if (appState.currentUser?.userType == UserType.client) {
      _showReviewDialog(appState);
    } else {
      // For experts, just navigate away since they don't control session ending
      _finalizeSessionEnd(appState);
    }
  }

  void _showReviewDialog(AppState appState) {
    if (widget.expert == null) {
      _finalizeSessionEnd(appState);
      return;
    }

    final duration = _timerSeconds ~/ 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewDialog(
        expert: widget.expert!,
        sessionId: appState.activeSession?.id,
        sessionCost: _totalCost,
        sessionDuration: duration,
        onReviewSubmitted: () => _finalizeSessionEnd(appState),
      ),
    );
  }

  void _finalizeSessionEnd(AppState appState) {
    appState.endSession();
    appState.endCall(); // Also end any active call status

    // Navigate based on user type
    if (appState.currentUser?.userType == UserType.expert) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ExpertNavigation(initialIndex: 1),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 1),
        ),
      );
    }
  }

  void _endSessionNow(AppState appState) {
    _showEndSessionDialog(appState);
  }

  Widget _buildViewOnlyHeader(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            appState.isRTL ? 'وضع العرض فقط' : 'View Only Mode',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.lock,
            color: theme.colorScheme.secondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildExpertRequestBar(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              appState.isRTL
                  ? 'هل تريد التواصل مع العميل؟'
                  : 'Would you like to chat with this client?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _sendExpertChatRequest(appState),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(appState.translate('request_chat')),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _sendExpertChatRequest(AppState appState) {
    final currentUser = appState.currentUser;
    if (currentUser == null || widget.clientName == null) return;

    // Find the client ID from the session history
    final clientId = widget.expertId ?? 'client_default';
    final clientName = widget.clientName ?? 'Client';

    appState.sendExpertChatRequest(
      clientId,
      clientName,
      currentUser.id,
      currentUser.name,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.translate('request_sent_success'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSessionEndedBar(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appState.isRTL
                  ? 'انتهت الجلسة - لا يمكن إرسال رسائل جديدة'
                  : 'Session ended - No new messages can be sent',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.lock,
            color: theme.colorScheme.error,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _loadViewOnlyMessages() {
    // Load dummy chat messages for view-only mode
    final appState = context.read<AppState>();
    appState.loadViewOnlyMessages();
  }

  // Check if we should show exit confirmation dialog
  bool _shouldShowExitConfirmation(AppState appState) {
    // Don't show confirmation for free communication
    if (widget.viewOnly) return false;
    if (widget.isTeamChat) return false;

    // Show confirmation for paid sessions
    final isClient = appState.currentUser?.userType == UserType.client;
    final isExpert = appState.currentUser?.userType == UserType.expert;

    // Show confirmation for:
    // 1. Client to Expert communication
    // 2. Expert to Client communication
    // 3. Expert to Expert (outside same business) communication
    if (isClient && widget.expert != null) return true;
    if (isExpert && widget.clientName != null) return true;
    if (isExpert && widget.expert != null) {
      // Expert to Expert - check if they're from different businesses
      final currentExpert = appState.currentUser;
      if (currentExpert != null && widget.expert != null) {
        // If both are experts but from different businesses, show confirmation
        return currentExpert.id != widget.expert!.id;
      }
    }

    return false;
  }

  // Show exit confirmation dialog
  Future<bool> _showExitConfirmationDialog(
      BuildContext context, ThemeData theme, AppState appState) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appState.isRTL ? 'تأكيد الخروج' : 'Exit Chat',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                appState.isRTL
                    ? 'هل أنت متأكد من أنك تريد الخروج من المحادثة؟ سيتم إنهاء الجلسة الحالية.'
                    : 'Are you sure you want to exit the chat? The current session will be ended.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    appState.isRTL ? 'إلغاء' : 'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // End the session and exit
                    if (appState.activeSession != null) {
                      appState.endSession();
                    }
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    appState.isRTL ? 'خروج' : 'Exit',
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
