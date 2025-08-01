import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/expert_dashboard.dart';
import '../screens/expert_settings_screen.dart';
import '../screens/expert_own_profile_screen.dart';
import '../screens/sessions_history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/business_linking_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/category_details_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/team_page_screen.dart';
import '../widgets/call_status_bar.dart';

class ExpertNavigation extends StatefulWidget {
  final int initialIndex;

  const ExpertNavigation({super.key, this.initialIndex = 0});

  @override
  State<ExpertNavigation> createState() => _ExpertNavigationState();
}

class _ExpertNavigationState extends State<ExpertNavigation>
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
    
    // Set role to expert in NavigationManager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationManager = context.read<NavigationManager>();
      navigationManager.setRole('expert');
      navigationManager.setTabIndex(_currentIndex);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to navigate to screens while maintaining expert navigation
  void navigateToScreen(Widget screen) {
    final navigationManager = context.read<NavigationManager>();
    navigationManager.navigateToInnerPage(screen, '/expert/inner_page');
  }

  void closeOverlay() {
    final navigationManager = context.read<NavigationManager>();
    navigationManager.goBackToMainTab();
  }



  Widget _getCurrentScreen(AppState appState, ThemeData theme, NavigationManager navigationManager) {
    // If there's an inner page, show it
    if (!navigationManager.isOnMainTab && navigationManager.currentInnerPage != null) {
      return navigationManager.currentInnerPage!;
    }

    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          onNavigateToExpert: (expert) {
            navigationManager.navigateToInnerPage(
              ExpertProfileScreen(expert: expert),
              '/expert/expert_profile',
            );
          },
          onNavigateToCategory: (category) {
            navigationManager.navigateToInnerPage(
              CategoryDetailsScreen(category: category),
              '/expert/category_details',
            );
          },
          onNavigateToBooking: (expert) {
            navigationManager.navigateToInnerPage(
              AppointmentBookingScreen(expert: expert),
              '/expert/appointment_booking',
            );
          },
          onNavigateToTeam: (expert) {
            navigationManager.navigateToInnerPage(
              TeamPageScreen(teamExpert: expert),
              '/expert/team_page',
            );
          },
          onNavigateToChat: (expert) {
            navigationManager.navigateToInnerPage(
              ChatScreen(expert: expert),
              '/expert/chat',
            );
          },
        );
      case 1:
        return const ExpertDashboard(key: ValueKey('dashboard'));
      case 2:
        return const SessionsHistoryScreen(key: ValueKey('sessions'));
      case 3:
        return const BusinessLinkingScreen(key: ValueKey('business_linking'));
      case 4:
        return const ExpertSettings(key: ValueKey('settings'));
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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
              navigationManager.setTabIndex(index);
              _animationController.reset();
              _animationController.forward();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
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
}
