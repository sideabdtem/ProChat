import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/home_screen.dart';
import '../screens/sessions_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/category_details_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/team_page_screen.dart';
import '../screens/chat_screen.dart';
import '../widgets/call_status_bar.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Set role to client in NavigationManager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationManager = context.read<NavigationManager>();
      navigationManager.setRole('client');
      navigationManager.setTabIndex(_currentIndex);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getCurrentScreen(AppState appState, ThemeData theme, NavigationManager navigationManager) {
    // If there's an inner page, show it
    if (!navigationManager.isOnMainTab && navigationManager.currentInnerPage != null) {
      return navigationManager.currentInnerPage!;
    }

    // Show main tab screens
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          onNavigateToExpert: (expert) {
            navigationManager.navigateToInnerPage(
              ExpertProfileScreen(expert: expert),
              '/client/expert_profile',
            );
          },
          onNavigateToCategory: (category) {
            navigationManager.navigateToInnerPage(
              CategoryDetailsScreen(category: category),
              '/client/category_details',
            );
          },
          onNavigateToBooking: (expert) {
            navigationManager.navigateToInnerPage(
              AppointmentBookingScreen(expert: expert),
              '/client/appointment_booking',
            );
          },
          onNavigateToTeam: (expert) {
            navigationManager.navigateToInnerPage(
              TeamPageScreen(teamExpert: expert),
              '/client/team_page',
            );
          },
          onNavigateToChat: (expert) {
            navigationManager.navigateToInnerPage(
              ChatScreen(expert: expert),
              '/client/chat',
            );
          },
        );
      case 1:
        return const SessionsHistoryScreen(key: ValueKey('sessions'));
      case 2:
        return const NotificationsScreen(key: ValueKey('notifications'));
      case 3:
        return const ProfileSettingsScreen(key: ValueKey('profile_settings'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final navigationManager = context.watch<NavigationManager>();
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => navigationManager.handleBackButton(context),
      child: Scaffold(
        body: Column(
          children: [
            const CallStatusBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _getCurrentScreen(appState, theme, navigationManager),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(appState, theme, navigationManager),
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppState appState, ThemeData theme, NavigationManager navigationManager) {
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
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            _animationController.reset();
            _animationController.forward();
            setState(() {
              _currentIndex = index;
            });
            navigationManager.setTabIndex(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
            label: appState.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.history_outlined, Icons.history, 1),
            label: appState.translate('sessions'),
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(appState, 2),
            label: appState.translate('notifications'),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person_outlined, Icons.person, 3),
            label: appState.translate('profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outlineIcon, IconData filledIcon, int index) {
    final isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Icon(
        isSelected ? filledIcon : outlineIcon,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationIcon(AppState appState, int index) {
    final isSelected = _currentIndex == index;
    final hasNotifications = appState.pendingNotifications.isNotEmpty;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Stack(
        children: [
          Icon(
            isSelected ? Icons.notifications : Icons.notifications_outlined,
            size: 24,
          ),
          if (hasNotifications)
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
    );
  }
}
