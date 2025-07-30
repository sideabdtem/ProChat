import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/payment_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isRTL = appState.isRTL;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          isRTL ? 'الإشعارات' : 'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildNotificationsList(appState, theme, isRTL),
    );
  }

  Widget _buildNotificationsList(AppState appState, ThemeData theme, bool isRTL) {
    final notifications = appState.userNotifications;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا توجد إشعارات' : 'No notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, appState, theme, isRTL);
      },
    );
  }

  Widget _buildNotificationCard(
    ChatNotification notification,
    AppState appState,
    ThemeData theme,
    bool isRTL,
  ) {
    final isUnread = notification.status == NotificationStatus.sent;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            notification.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatNotificationTime(notification.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (isUnread) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isRTL ? 'جديد' : 'New',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (notification.type == NotificationType.expertRequest &&
                  (notification.status == NotificationStatus.sent ||
                      notification.status == NotificationStatus.viewed)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectRequest(notification, appState),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                        child: Text(isRTL ? 'رفض' : 'Decline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptRequest(notification, appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isRTL ? 'قبول' : 'Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          onTap: () {
            if (isUnread) {
              appState.markNotificationAsViewed(notification.id);
            }
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.expertRequest:
        return Icons.person_add;
      case NotificationType.paymentReminder:
        return Icons.payment;
      case NotificationType.sessionStart:
        return Icons.play_arrow;
      case NotificationType.sessionEnd:
        return Icons.stop;
      case NotificationType.general:
        return Icons.info;
    }
  }

  String _formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _rejectRequest(ChatNotification notification, AppState appState) {
    appState.rejectExpertChatRequest(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.isRTL 
            ? 'تم رفض طلب المحادثة'
            : 'Chat request declined',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _acceptRequest(ChatNotification notification, AppState appState) {
    appState.acceptExpertChatRequest(notification.id);
    
    // Navigate to expert profile screen for payment
    final expertId = notification.metadata?['expertId'];
    final expert = appState.getExpertById(expertId);
    
    if (expert != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpertProfileScreen(expert: expert),
        ),
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.isRTL 
            ? 'تم قبول طلب المحادثة. يرجى إكمال الدفع.'
            : 'Chat request accepted. Please complete payment.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}