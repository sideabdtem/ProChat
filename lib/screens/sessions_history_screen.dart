import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/chat_screen.dart';
import '../screens/expert_profile_screen.dart';
import 'package:intl/intl.dart';


class SessionsHistoryScreen extends StatefulWidget {
  const SessionsHistoryScreen({super.key}); // Enhanced session cards

  @override
  State<SessionsHistoryScreen> createState() => _SessionsHistoryScreenState();
}

class _SessionsHistoryScreenState extends State<SessionsHistoryScreen> {
  String _selectedFilter = 'all'; // For clients: all, chat, clients. For experts: ongoing, ended
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isRTL = appState.isRTL;
    final isExpertView = appState.currentUser?.userType == UserType.expert;
    
    // Set default filter based on user type
    if (_selectedFilter == 'all' && isExpertView) {
      _selectedFilter = 'ongoing';
    }
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          isRTL ? 'تاريخ الجلسات' : 'Sessions History',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Options
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isExpertView) ...[
                  // Expert view: Ongoing and Ended tabs
                  Expanded(
                    child: _buildFilterChip(
                      'ongoing',
                      isRTL ? 'جارية' : 'Ongoing',
                      theme,
                      isRTL,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'ended',
                      isRTL ? 'منتهية' : 'Ended',
                      theme,
                      isRTL,
                    ),
                  ),
                ] else ...[
                  // Client view: All, Chats, Experts tabs
                  Expanded(
                    child: _buildFilterChip(
                      'all',
                      isRTL ? 'الكل' : 'All',
                      theme,
                      isRTL,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'chat',
                      isRTL ? 'المحادثات' : 'Chats',
                      theme,
                      isRTL,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'experts',
                      isRTL ? 'الخبراء' : 'Experts',
                      theme,
                      isRTL,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Sessions List
          Expanded(
            child: _buildSessionsList(theme, isRTL),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String filterValue, String label, ThemeData theme, bool isRTL) {
    final isSelected = _selectedFilter == filterValue;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity( 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildSessionsList(ThemeData theme, bool isRTL) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getFilteredSessions().length,
      itemBuilder: (context, index) {
        final session = _getFilteredSessions()[index];
        return _buildSessionCard(session, theme, isRTL);
      },
    );
  }
  
  Widget _buildSessionCard(SessionHistoryItem session, ThemeData theme, bool isRTL) {
    final appState = context.read<AppState>();
    final isExpertView = appState.currentUser?.userType == UserType.expert;
    
    return GestureDetector(
      onTap: () {
        if (session.isTeamChat) {
          // Team chat navigation
          final isViewOnly = session.sessionStatus == SessionStatus.ended;
          
          // Find the actual session in app state if it's active
          ConsultationSession? actualSession;
          if (session.sessionStatus == SessionStatus.active) {
            final appState = context.read<AppState>();
            actualSession = appState.sessionHistory.firstWhere(
              (s) => s.id == session.id,
              orElse: () => ConsultationSession(
                id: session.id,
                clientId: appState.currentUser?.id ?? '',
                expertId: '',
                type: SessionType.teamChat,
                status: session.sessionStatus,
                startTime: session.sessionDate,
                totalCost: 0.0,
                durationMinutes: int.tryParse(session.duration.replaceAll(' min', '')) ?? 0,
                isPaidPerMinute: false,
                isTeamChat: true,
                teamMemberName: session.teamMemberName,
              ),
            );
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                viewOnly: isViewOnly,
                session: actualSession,
                isTeamChat: true,
                teamMemberName: session.teamMemberName,
              ),
            ),
          );
        } else if (isExpertView) {
          // Expert view - navigate to chat window
          // Only view-only for ended sessions, interactive for ongoing
          final isViewOnly = session.sessionStatus == SessionStatus.ended;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                viewOnly: isViewOnly,
                clientName: session.clientName,
                clientImage: session.clientImage,
                expertId: session.expertId,
                paymentType: session.paymentType,
              ),
            ),
          );
        } else {
          // Client view - navigate to chat window
          // Only view-only for ended sessions, interactive for ongoing
          final expert = appState.getExpertById(session.expertId);
          if (expert != null) {
            final isViewOnly = session.sessionStatus == SessionStatus.ended;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  expert: expert,
                  viewOnly: isViewOnly,
                  paymentType: session.paymentType,
                ),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity( 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity( 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with expert info and download button
              Row(
                children: [
                  // Profile Avatar (Expert or Client based on view)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      isExpertView ? session.clientImage : session.expertImage
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Profile details (Expert or Client based on view)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.isTeamChat 
                            ? (session.teamMemberName ?? 'Team Member')
                            : (isExpertView ? session.clientName : session.expertName),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (session.category != null && (!isExpertView || session.isTeamChat))
                          Text(
                            session.isTeamChat ? 'Team' : session.category!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (isExpertView)
                          Text(
                            isRTL ? 'عميل' : 'Client',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Rating display (more prominent)
                            if (session.rating != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity( 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${session.rating!.toStringAsFixed(1)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Session status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(session.sessionStatus).withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(session.sessionStatus, isRTL),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(session.sessionStatus),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Download PDF button (visible for clients only)
                  if (!isExpertView)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.download,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          _downloadSessionReport(session);
                        },
                        tooltip: isRTL ? 'تحميل الفاتورة' : 'Download Receipt',
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Session details row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity( 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Session type and date (enhanced)
                    Row(
                      children: [
                        // Session type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getSessionTypeColor(session.type).withOpacity( 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getSessionTypeColor(session.type).withOpacity( 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSessionIcon(session.type),
                                size: 14,
                                color: _getSessionTypeColor(session.type),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getSessionTypeText(session.type, isRTL),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getSessionTypeColor(session.type),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Date badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity( 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: theme.colorScheme.onSurface.withOpacity( 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatSessionDate(session.sessionDate, isRTL),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity( 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Duration and payment type
                    Row(
                      children: [
                        // Duration info
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity( 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.duration,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Payment type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: session.paymentType == PaymentType.perSession 
                                ? Colors.green.withOpacity( 0.15)
                                : Colors.blue.withOpacity( 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: session.paymentType == PaymentType.perSession 
                                  ? Colors.green.withOpacity( 0.3)
                                  : Colors.blue.withOpacity( 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.paymentType == PaymentType.perSession 
                                    ? Icons.credit_card : Icons.timer,
                                size: 12,
                                color: session.paymentType == PaymentType.perSession 
                                    ? Colors.green[700] : Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.paymentType == PaymentType.perSession 
                                    ? (isRTL ? 'جلسة كاملة' : 'Per Session')
                                    : (isRTL ? 'بالدقيقة' : 'Per Minute'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: session.paymentType == PaymentType.perSession 
                                      ? Colors.green[700] : Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Total cost (enhanced display)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity( 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity( 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRTL ? 'التكلفة الإجمالية:' : 'Total Cost:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity( 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '\$${session.sessionCost.toStringAsFixed(2)} USD',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              // Price breakdown for per-minute sessions (clients only)
                              if (!isExpertView && session.paymentType == PaymentType.perMinute && session.pricePerMinute != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '(\$${session.pricePerMinute!.toStringAsFixed(2)}/min)',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity( 0.6),
                                      fontSize: 10,
                                    ),
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
              
              const SizedBox(height: 12),
              
              // Last message
              if (session.lastMessage.isNotEmpty) ...[
                Text(
                  isRTL ? 'آخر رسالة:' : 'Last Message:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity( 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.lastMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity( 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Unread indicator and action buttons
              Row(
                children: [
                  // Unread indicator
                  if (session.hasUnread)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${session.unreadCount} ${isRTL ? 'رسائل غير مقروءة' : 'unread messages'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Action buttons for team chats
                  if (session.isTeamChat) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (session.sessionStatus == SessionStatus.active) ...[
                          // End Chat button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () => _endTeamChat(session),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                isRTL ? 'إنهاء المحادثة' : 'End Chat',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Delete button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () => _deleteTeamChat(session),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              isRTL ? 'حذف' : 'Delete',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return Colors.green;
      case SessionStatus.ended:
        return Colors.blue;
      case SessionStatus.pending:
        return Colors.orange;
    }
  }
  
  String _getStatusText(SessionStatus status, bool isRTL) {
    switch (status) {
      case SessionStatus.active:
        return isRTL ? 'نشط' : 'Active';
      case SessionStatus.ended:
        return isRTL ? 'منتهية' : 'Ended';
      case SessionStatus.pending:
        return isRTL ? 'معلقة' : 'Pending';
    }
  }
  
  IconData _getSessionIcon(SessionType type) {
    switch (type) {
      case SessionType.chat:
        return Icons.chat;
      case SessionType.voice:
        return Icons.call;
      case SessionType.video:
        return Icons.videocam;
      case SessionType.teamChat:
        return Icons.group;
    }
  }
  
  String _getSessionTypeText(SessionType type, bool isRTL) {
    switch (type) {
      case SessionType.chat:
        return isRTL ? 'محادثة' : 'Chat';
      case SessionType.voice:
        return isRTL ? 'مكالمة صوتية' : 'Voice Call';
      case SessionType.video:
        return isRTL ? 'مكالمة فيديو' : 'Video Call';
      case SessionType.teamChat:
        return isRTL ? 'محادثة الفريق' : 'Team Chat';
    }
  }
  
  Color _getSessionTypeColor(SessionType type) {
    switch (type) {
      case SessionType.chat:
        return Colors.blue;
      case SessionType.voice:
        return Colors.green;
      case SessionType.video:
        return Colors.purple;
      case SessionType.teamChat:
        return Colors.orange;
    }
  }
  
  String _formatSessionDate(DateTime date, bool isRTL) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (difference.inDays == 1) {
      return isRTL ? 'أمس' : 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${isRTL ? 'أيام مضت' : 'days ago'}';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
  
  void _downloadSessionReport(SessionHistoryItem session) {
    final appState = context.read<AppState>();
    final isExpertView = appState.currentUser?.userType == UserType.expert;
    final isRTL = appState.isRTL;
    
    // Implement PDF download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isExpertView 
            ? (isRTL ? 'جاري تحميل تقرير الجلسة...' : 'Downloading session report...')
            : (isRTL ? 'جاري تحميل فاتورة الجلسة...' : 'Downloading session receipt...')
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Here you would typically:
    // 1. Generate PDF receipt/report with session details, payment info, ratings
    // 2. Include expert details, session duration, cost breakdown
    // 3. Save to device storage
    // 4. Show success/failure message
  }
  
  List<SessionHistoryItem> _getFilteredSessions() {
    final appState = context.read<AppState>();
    final isExpertView = appState.currentUser?.userType == UserType.expert;
    final allSessions = _getDummySessionHistory();
    
    if (isExpertView) {
      // Expert filters: ongoing vs ended
      if (_selectedFilter == 'ongoing') {
        return allSessions.where((session) => 
          session.sessionStatus == SessionStatus.active || 
          session.sessionStatus == SessionStatus.pending
        ).toList();
      } else if (_selectedFilter == 'ended') {
        return allSessions.where((session) => 
          session.sessionStatus == SessionStatus.ended
        ).toList();
      }
    } else {
      // Client filters: all, chat, experts
      if (_selectedFilter == 'all') {
        return allSessions;
      } else if (_selectedFilter == 'chat') {
        return allSessions.where((session) => 
          session.type == SessionType.chat || session.type == SessionType.teamChat
        ).toList();
      } else if (_selectedFilter == 'experts') {
        return allSessions.where((session) => 
          session.type != SessionType.chat && session.type != SessionType.teamChat
        ).toList();
      }
    }
    
    return allSessions;
  }
  
  List<SessionHistoryItem> _getDummySessionHistory() {
    final appState = context.read<AppState>();
    List<SessionHistoryItem> sessions = [];
    
    // Add real team chat sessions from app state
    for (final session in appState.sessionHistory) {
      if (session.isTeamChat) {
        sessions.add(SessionHistoryItem(
          id: session.id,
          clientName: session.teamMemberName ?? 'Team Member',
          clientImage: "https://images.unsplash.com/photo-1648662199460-34b7597ba771?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTF8&ixlib=rb-4.1.0&q=80&w=1080",
          lastMessage: 'Team discussion...',
          timeAgo: _getTimeAgo(session.startTime),
          duration: '${session.durationMinutes} min',
          type: session.type,
          hasUnread: false,
          unreadCount: 0,
          expertId: '',
          expertName: '',
          expertImage: '',
          paymentType: PaymentType.perSession,
          sessionCost: 0.0,
          sessionDate: session.startTime,
          sessionStatus: session.status,
          rating: null,
          category: 'Team',
          isTeamChat: true,
          teamMemberName: session.teamMemberName,
        ));
      }
    }
    
    // Add dummy regular sessions
    sessions.addAll([
      SessionHistoryItem(
        id: '1',
        clientName: 'Sarah Johnson',
        clientImage: "https://images.unsplash.com/photo-1648662199460-34b7597ba771?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTF8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'Thank you for your help with the anxiety management techniques!',
        timeAgo: '2m ago',
        duration: '45 min',
        type: SessionType.chat,
        hasUnread: true,
        unreadCount: 3,
        expertId: 'expert1',
        expertName: 'Dr. Emily Rodriguez',
        expertImage: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perMinute,
        sessionCost: 67.50,
        pricePerMinute: 1.50,
        sessionDate: DateTime.now().subtract(const Duration(hours: 2)),
        sessionStatus: SessionStatus.active,
        rating: 4.8,
        category: 'Therapist',
      ),
      SessionHistoryItem(
        id: '2',
        clientName: 'Michael Chen',
        clientImage: "https://images.unsplash.com/photo-1599132972297-823e09453a12?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTJ8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'The business strategy recommendations were excellent!',
        timeAgo: '1h ago',
        duration: '30 min',
        type: SessionType.voice,
        hasUnread: false,
        unreadCount: 0,
        expertId: 'expert2',
        expertName: 'Mark Thompson',
        expertImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perSession,
        sessionCost: 150.00,
        sessionDate: DateTime.now().subtract(const Duration(hours: 5)),
        sessionStatus: SessionStatus.pending,
        rating: 4.9,
        category: 'Business Consultant',
      ),
      SessionHistoryItem(
        id: '3',
        clientName: 'Emma Wilson',
        clientImage: "https://images.unsplash.com/photo-1667890786333-ddb32e7e0d6e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTJ8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'The legal advice was very clear and helpful.',
        timeAgo: '3h ago',
        duration: '25 min',
        type: SessionType.chat,
        hasUnread: false,
        unreadCount: 0,
        expertId: 'expert3',
        expertName: 'Sarah Mitchell',
        expertImage: "https://images.unsplash.com/photo-1594736797933-d0e501ba2fe6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perMinute,
        sessionCost: 50.00,
        pricePerMinute: 2.00,
        sessionDate: DateTime.now().subtract(const Duration(hours: 8)),
        sessionStatus: SessionStatus.ended,
        rating: 4.7,
        category: 'Lawyer',
      ),
      SessionHistoryItem(
        id: '4',
        clientName: 'David Rodriguez',
        clientImage: "https://images.unsplash.com/photo-1661639022755-12cdc90d9d31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTN8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'Great session, the health plan is perfect for me!',
        timeAgo: '5h ago',
        duration: '50 min',
        type: SessionType.video,
        hasUnread: false,
        unreadCount: 0,
        expertId: 'expert4',
        expertName: 'Dr. Ahmed Hassan',
        expertImage: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perSession,
        sessionCost: 200.00,
        sessionDate: DateTime.now().subtract(const Duration(days: 1)),
        sessionStatus: SessionStatus.ended,
        rating: 4.6,
        category: 'Doctor',
      ),
      SessionHistoryItem(
        id: '5',
        clientName: 'Lisa Anderson',
        clientImage: "https://images.unsplash.com/photo-1689193502399-b9490ee1c80e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTN8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'Really appreciate your guidance on career development.',
        timeAgo: '1d ago',
        duration: '35 min',
        type: SessionType.chat,
        hasUnread: true,
        unreadCount: 1,
        expertId: 'expert5',
        expertName: 'Jennifer Clark',
        expertImage: "https://images.unsplash.com/photo-1580489944761-15a19d654956?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perMinute,
        sessionCost: 52.50,
        pricePerMinute: 1.50,
        sessionDate: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        sessionStatus: SessionStatus.ended,
        rating: 4.9,
        category: 'Life Coach',
      ),
      SessionHistoryItem(
        id: '6',
        clientName: 'James Miller',
        clientImage: "https://images.unsplash.com/photo-1545370192-c7c68d09f668?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        lastMessage: 'Perfect solution for my technical issue, thank you!',
        timeAgo: '2d ago',
        duration: '40 min',
        type: SessionType.voice,
        hasUnread: false,
        unreadCount: 0,
        expertId: 'expert6',
        expertName: 'Robert Kim',
        expertImage: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NTYyMTR8&ixlib=rb-4.1.0&q=80&w=1080",
        paymentType: PaymentType.perSession,
        sessionCost: 120.00,
        sessionDate: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        sessionStatus: SessionStatus.ended,
        rating: 4.8,
        category: 'Technician',
      ),
    ]);
    
    return sessions;
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _endTeamChat(SessionHistoryItem session) {
    final appState = context.read<AppState>();
    
    // End the session if it's currently active
    if (appState.activeSession?.id == session.id) {
      appState.endSession();
    }
    
    // Update the session status in history
    final sessionIndex = appState.sessionHistory.indexWhere((s) => s.id == session.id);
    if (sessionIndex != -1) {
      final updatedSession = appState.sessionHistory[sessionIndex].copyWith(
        status: SessionStatus.ended,
        endTime: DateTime.now(),
      );
      appState.sessionHistory[sessionIndex] = updatedSession;
    }
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Team chat with ${session.teamMemberName} has been ended'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteTeamChat(SessionHistoryItem session) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('delete_team_chat')),
        content: Text('Are you sure you want to delete the chat with ${session.teamMemberName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final appState = context.read<AppState>();
              
              // Remove from session history
              appState.sessionHistory.removeWhere((s) => s.id == session.id);
              
              // End the session if it's currently active
              if (appState.activeSession?.id == session.id) {
                appState.endSession();
              }
              
              Navigator.of(context).pop();
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Team chat with ${session.teamMemberName} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('delete')),
          ),
        ],
      ),
    );
  }
}

class SessionHistoryItem {
  final String id;
  final String clientName;
  final String clientImage;
  final String lastMessage;
  final String timeAgo;
  final String duration;
  final SessionType type;
  final bool hasUnread;
  final int unreadCount;
  final String expertId;
  final String expertName;
  final String expertImage;
  final PaymentType paymentType;
  final double sessionCost;
  final double? pricePerMinute;
  final DateTime sessionDate;
  final SessionStatus sessionStatus;
  final double? rating;
  final String? category;
  final bool isTeamChat;
  final String? teamMemberName;
  
  SessionHistoryItem({
    required this.id,
    required this.clientName,
    required this.clientImage,
    required this.lastMessage,
    required this.timeAgo,
    required this.duration,
    required this.type,
    required this.hasUnread,
    required this.unreadCount,
    required this.expertId,
    required this.expertName,
    required this.expertImage,
    required this.paymentType,
    required this.sessionCost,
    this.pricePerMinute,
    required this.sessionDate,
    required this.sessionStatus,
    this.rating,
    this.category,
    this.isTeamChat = false,
    this.teamMemberName,
  });
}