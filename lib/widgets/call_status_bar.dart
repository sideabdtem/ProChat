import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/call_screen.dart';

class CallStatusBar extends StatelessWidget {
  const CallStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Only show if there's an active call
        if (!appState.isCallActive) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final expert = appState.getExpertById(appState.activeCallExpertId ?? '');
        final callType = appState.activeCallType;
        
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: callType == SessionType.video 
                ? theme.colorScheme.primary.withOpacity( 0.9)
                : theme.colorScheme.secondary.withOpacity( 0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Call type icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    callType == SessionType.video ? Icons.videocam : Icons.call,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Call info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callType == SessionType.video ? 'Video Call' : 'Audio Call',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (expert != null)
                        Text(
                          'with ${expert.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity( 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Call duration
                Text(
                  appState.getFormattedTimer(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Return to call button
                GestureDetector(
                  onTap: () => _returnToCall(context, appState),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Return',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _returnToCall(BuildContext context, AppState appState) {
    final expert = appState.getExpertById(appState.activeCallExpertId ?? '');
    if (expert != null && appState.activeCallType != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            expert: expert,
            sessionType: appState.activeCallType!,
          ),
        ),
      );
    }
  }
}