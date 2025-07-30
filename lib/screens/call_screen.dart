import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/app_state.dart';
import '../services/calling_service.dart';
import '../models/app_models.dart';
import '../screens/expert_navigation.dart';
import '../screens/main_navigation.dart';
import '../widgets/review_dialog.dart';

class CallScreen extends StatefulWidget {
  final Expert expert;
  final SessionType sessionType;
  final bool isTeamCall;

  const CallScreen({
    super.key,
    required this.expert,
    required this.sessionType,
    this.isTeamCall = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Call state
  Timer? _sessionTimer;
  int _timerSeconds = 0;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _isCallActive = false;
  bool _hasShownWarning = false;
  bool _isInitialized = false;

  // Calling service
  final CallingService _callingService = CallingService.instance;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      // Initialize calling service
      await _callingService.initialize();

      // Set up calling event listeners
      _callingService.callState.listen((state) {
        setState(() {
          switch (state) {
            case 'call_started':
            case 'call_answered':
              _isCallActive = true;
              _startSessionTimer();
              break;
            case 'call_ended':
              _endCall();
              break;
            case 'connected':
              _startCall();
              break;
          }
        });
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing call: $e');
      _showErrorDialog('Failed to initialize call: $e');
    }
  }

  void _startCall() async {
    try {
      final appState = context.read<AppState>();
      final callType = widget.sessionType == SessionType.video
          ? CallType.video
          : CallType.audio;
      final callId = 'call_${DateTime.now().millisecondsSinceEpoch}';

      await _callingService.startCall(callId, widget.expert.id, callType);
    } catch (e) {
      print('Error starting call: $e');
      _showErrorDialog('Failed to start call: $e');
    }
  }

  void _endCall() async {
    try {
      await _callingService.endCall();
      _sessionTimer?.cancel();

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  void _showErrorDialog(String message) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('call_error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(appState.translate('ok')),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get existing session timer from app state
    final appState = context.read<AppState>();
    _timerSeconds = appState.sessionTimer;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    final appState = context.read<AppState>();
    final paymentType = appState.currentPaymentType ?? PaymentType.perMinute;
    final selectedSessionConfig = appState.selectedSessionConfig;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (paymentType == PaymentType.perSession) {
          _timerSeconds--;

          // Show warning when 2 minutes remaining
          if (_timerSeconds == 120 && !_hasShownWarning) {
            _hasShownWarning = true;
            _showTimeWarning(_timerSeconds);
          }

          // End session when time runs out
          if (_timerSeconds <= 0) {
            _endSessionDueToTimeout(appState);
          }
        } else {
          _timerSeconds++;
        }
      });
      appState.updateSessionTimer(_timerSeconds);
    });
  }

  double _getCurrentSessionCost(AppState appState) {
    final expert = appState.getExpertById(widget.expert.id);
    if (expert == null) return 0.0;

    final paymentType = appState.currentPaymentType ?? PaymentType.perMinute;
    final selectedSessionConfig = appState.selectedSessionConfig;

    if (paymentType == PaymentType.perSession &&
        selectedSessionConfig != null) {
      return selectedSessionConfig.price;
    } else if (paymentType == PaymentType.perSession) {
      return expert.pricePerSession;
    } else {
      final minutes = _timerSeconds / 60.0;
      return minutes * expert.pricePerMinute;
    }
  }

  void _showTimeWarning(int remainingSeconds) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(appState.translate('session_time_warning')),
          ],
        ),
        content: Text(
            '${appState.translate('session_wrap_up')} ${(remainingSeconds / 60).ceil()} ${appState.translate('minutes_short')}.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _endSessionDueToTimeout(AppState appState) {
    _sessionTimer?.cancel();
    Navigator.pop(context); // Close call screen
    _showReviewDialog(appState);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.9),
                theme.colorScheme.secondary.withOpacity(0.7),
                theme.colorScheme.tertiary.withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildCallHeader(appState, theme),
                Expanded(
                  child: widget.sessionType == SessionType.video
                      ? _buildVideoInterface(appState, theme)
                      : _buildVoiceInterface(appState, theme),
                ),
                _buildCallControls(appState, theme),
                _buildSessionInfo(appState, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallHeader(AppState appState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Chat button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Back to Chat',
          ),
          // End Now button
          TextButton(
            onPressed: () => _endNowPressed(appState),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.red.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              appState.translate('end_now'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                widget.sessionType == SessionType.video
                    ? appState.translate('video_call')
                    : appState.translate('voice_call'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isCallActive) ...[
                const SizedBox(height: 4),
                Text(
                  _formatTime(_timerSeconds),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            onPressed: () => _toggleSpeaker(),
            icon: Icon(
              _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInterface(AppState appState, ThemeData theme) {
    return Stack(
      children: [
        // Expert video (main)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(24),
          child: Stack(
            children: [
              if (widget.expert.profileImage != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(widget.expert.profileImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Video overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Expert info overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    if (!_isCallActive)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expert.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isCallActive
                              ? appState.translate('connected')
                              : appState.translate('calling'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // User video (small)
        if (_isVideoEnabled)
          Positioned(
            top: 40,
            right: 40,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://pixabay.com/get/ge62c4f6f4a3eb0080a489789f2336434d17a3e3923f4e1ae41ef7d87819c7677220b1611a22cdc30fe216dc32b906b4e77cd5b50c795b7d7e06a0a8c60b64231_1280.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.7),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceInterface(AppState appState, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expert avatar
          if (!_isCallActive)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: widget.expert.profileImage != null
                          ? NetworkImage(widget.expert.profileImage!)
                          : null,
                      child: widget.expert.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: widget.expert.profileImage != null
                    ? NetworkImage(widget.expert.profileImage!)
                    : null,
                child: widget.expert.profileImage == null
                    ? Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          const SizedBox(height: 32),

          // Expert info
          Text(
            widget.expert.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.expert.categoryName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isCallActive
                ? appState.translate('connected')
                : appState.translate('calling'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(AppState appState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.red : Colors.white.withOpacity(0.3),
            onPressed: () => _toggleMute(),
          ),

          // Video toggle (only for video calls)
          if (widget.sessionType == SessionType.video)
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color:
                  _isVideoEnabled ? Colors.white.withOpacity(0.3) : Colors.red,
              onPressed: () => _toggleVideo(),
            ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () => _endCallLegacy(),
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isLarge ? 70 : 60,
        height: isLarge ? 70 : 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isLarge ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildSessionInfo(AppState appState, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.translate('session_timer'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                _formatTime(_timerSeconds),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.translate('total_cost'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return Text(
                    appState.convertAndFormatPrice(
                        _getCurrentSessionCost(appState), 'USD'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.translate('rate'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Consumer<AppState>(
                builder: (context, appState, child) {
                  final paymentType =
                      appState.currentPaymentType ?? PaymentType.perMinute;
                  return Text(
                    paymentType == PaymentType.perMinute
                        ? '${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}/${appState.translate('per_minute')}'
                        : '${appState.convertAndFormatPrice(widget.expert.pricePerSession, 'USD')}/${appState.translate('per_session')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _endCallLegacy() {
    // When hanging up, end the call status but keep the session active
    final appState = context.read<AppState>();
    appState.endCall();
    // Go back to chat screen (don't end session)
    Navigator.pop(context);
  }

  void _endNowPressed(AppState appState) {
    _showEndNowDialog(appState);
  }

  void _showEndNowDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(appState.translate('end_session')),
        content: Text(appState.translate('end_session_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close call screen

              // Show review dialog before ending session
              _showReviewDialog(appState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('end_now')),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(AppState appState) {
    final duration = _timerSeconds ~/ 60;
    final cost = _getCurrentSessionCost(appState);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewDialog(
        expert: widget.expert,
        sessionId: appState.activeSession?.id,
        sessionCost: cost,
        sessionDuration: duration,
        onReviewSubmitted: () => _finalizeSessionEnd(appState),
      ),
    );
  }

  void _finalizeSessionEnd(AppState appState) {
    appState.endSession();
    appState.endCall(); // End call status

    // Navigate based on user type
    if (appState.currentUser?.userType == UserType.expert) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ExpertNavigation(initialIndex: 1),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 1),
        ),
        (route) => false,
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
