import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/auth_screen.dart';

class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool showBottomNavigation;
  final int? currentNavigationIndex;

  const NavigationWrapper({
    super.key,
    required this.child,
    this.showBottomNavigation = true,
    this.currentNavigationIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBottomNavigation) {
      return child;
    }

    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          body: child,
          bottomNavigationBar: _buildBottomNavigationBar(context, appState),
        );
      },
    );
  }

  Widget? _buildBottomNavigationBar(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final user = appState.currentUser;

    if (user == null) {
      // Guest navigation
      return _buildGuestBottomNavigationBar(context, appState, theme);
    } else if (user.userType == UserType.expert) {
      // Expert navigation
      return _buildExpertBottomNavigationBar(context, appState, theme);
    } else {
      // Regular user navigation
      return _buildUserBottomNavigationBar(context, appState, theme);
    }
  }

  Widget _buildGuestBottomNavigationBar(
      BuildContext context, AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentNavigationIndex ?? 0,
        onTap: (index) => _handleGuestNavigationTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: appState.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.login_outlined),
            activeIcon: const Icon(Icons.login),
            label: appState.translate('sign_in'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertBottomNavigationBar(
      BuildContext context, AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentNavigationIndex ?? 0,
          onTap: (index) => _handleExpertNavigationTap(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
              label: appState.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.dashboard_outlined, Icons.dashboard, 1),
              label: appState.translate('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.history_outlined, Icons.history, 2),
              label: appState.translate('sessions'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.business_outlined, Icons.business, 3),
              label: appState.translate('business'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings_outlined, Icons.settings, 4),
              label: appState.translate('settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBottomNavigationBar(
      BuildContext context, AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentNavigationIndex ?? 0,
        onTap: (index) => _handleUserNavigationTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
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
            label: appState.translate('notifications'),
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
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outlineIcon, IconData filledIcon, int index) {
    final isSelected = (currentNavigationIndex ?? 0) == index;
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Icon(
            isSelected ? filledIcon : outlineIcon,
            size: 24,
          ),
        );
      },
    );
  }

  void _handleGuestNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GuestMainNavigation()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
        break;
    }
  }

  void _handleExpertNavigationTap(BuildContext context, int index) {
    // Find the current ExpertNavigation in the widget tree and update its index
    final expertNavState = context.findAncestorStateOfType<State<ExpertNavigation>>();
    if (expertNavState != null && expertNavState is dynamic) {
      try {
        expertNavState.updateCurrentIndex(index);
      } catch (e) {
        // If method doesn't exist, navigate to new screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertNavigation(initialIndex: index),
          ),
          (route) => false,
        );
      }
    } else {
      // Fallback: Navigate to new ExpertNavigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ExpertNavigation(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }

  void _handleUserNavigationTap(BuildContext context, int index) {
    // Find the current MainNavigation in the widget tree and update its index
    final mainNavState = context.findAncestorStateOfType<State<MainNavigation>>();
    if (mainNavState != null && mainNavState is dynamic) {
      try {
        mainNavState.updateCurrentIndex(index);
      } catch (e) {
        // If method doesn't exist, navigate to new screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(initialIndex: index),
          ),
          (route) => false,
        );
      }
    } else {
      // Fallback: Navigate to new MainNavigation
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