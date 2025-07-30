import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
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
import '../widgets/navigation_wrapper.dart';

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
  Widget? _overlayScreen;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to navigate to screens while maintaining expert navigation
  void navigateToScreen(Widget screen) {
    setState(() {
      _overlayScreen = screen;
    });
  }

  void closeOverlay() {
    setState(() {
      _overlayScreen = null;
    });
  }

  // Method to update current tab index from NavigationWrapper
  void updateCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      _overlayScreen = null; // Close any overlay when switching tabs
    });
    _animationController.reset();
    _animationController.forward();
  }

  // Method to create expert-wrapped screens that maintain navigation
  Widget _createExpertWrappedScreen(Widget screen) {
    return NavigationWrapper(
      currentNavigationIndex: _currentIndex,
      child: Scaffold(
        body: Column(
          children: [
            const CallStatusBar(),
            Expanded(child: screen),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentScreen(AppState appState, ThemeData theme) {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          onNavigateToExpert: (expert) {
            navigateToScreen(ExpertProfileScreen(expert: expert));
          },
          onNavigateToCategory: (category) {
            navigateToScreen(CategoryDetailsScreen(category: category));
          },
          onNavigateToBooking: (expert) {
            navigateToScreen(AppointmentBookingScreen(expert: expert));
          },
          onNavigateToTeam: (expert) {
            navigateToScreen(TeamPageScreen(teamExpert: expert));
          },
          onNavigateToChat: (expert) {
            navigateToScreen(ChatScreen(expert: expert));
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
    final theme = Theme.of(context);

    // If there's an overlay screen, show it with wrapped navigation
    if (_overlayScreen != null) {
      return _createExpertWrappedScreen(_overlayScreen!);
    }

    return NavigationWrapper(
      currentNavigationIndex: _currentIndex,
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
                child: _getCurrentScreen(appState, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
