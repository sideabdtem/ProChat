import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/auth_screen.dart';

/// A reusable navigation wrapper that provides consistent bottom navigation
/// across all screens in the app for logged-in users
class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int? selectedIndex;
  final bool showCallToAction;
  
  const NavigationWrapper({
    super.key,
    required this.child,
    this.selectedIndex,
    this.showCallToAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(appState, theme, context),
    );
  }

  Widget _buildBottomNavigationBar(AppState appState, ThemeData theme, BuildContext context) {
    final currentUser = appState.currentUser;
    final isExpert = currentUser?.userType == UserType.expert;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex ?? 0,
        onTap: (index) {
          _handleNavigationTap(index, appState, isExpert, context);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity( 0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: _buildNavigationItems(appState, theme, isExpert),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(AppState appState, ThemeData theme, bool isExpert) {
    if (appState.currentUser == null) {
      // Guest user navigation
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: appState.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.login_outlined),
          activeIcon: const Icon(Icons.login),
          label: 'Sign In/Up',
        ),
      ];
    } else if (isExpert) {
      // Expert navigation
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: appState.translate('dashboard'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: appState.translate('settings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: appState.translate('profile'),
        ),
      ];
    } else {
      // Regular user navigation
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: appState.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history_outlined),
          activeIcon: const Icon(Icons.history),
          label: appState.translate('session_history'),
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (appState.pendingNotifications.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${appState.pendingNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          activeIcon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (appState.pendingNotifications.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${appState.pendingNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: appState.isRTL ? 'الإشعارات' : 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: appState.translate('profile'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: appState.translate('settings'),
        ),
      ];
    }
  }

  void _handleNavigationTap(int index, AppState appState, bool isExpert, BuildContext context) {
    
    if (appState.currentUser == null) {
      // Guest user navigation
      if (index == 0) {
        // Navigate to guest home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GuestMainNavigation(),
          ),
          (route) => false,
        );
      } else if (index == 1) {
        // Navigate to auth screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
        );
      }
    } else if (isExpert) {
      // Expert navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ExpertNavigation(initialIndex: index),
        ),
        (route) => false,
      );
    } else {
      // Regular user navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigation(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }

}