// lib/screens/expert_navigation.dart - Expert navigation with 5 tabs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/home_screen.dart';
import '../screens/expert_dashboard.dart';
import '../screens/sessions_history_screen.dart';
import '../screens/business_linking_screen.dart';
import '../screens/expert_settings_screen.dart';
import '../widgets/call_status_bar.dart';

class ExpertNavigation extends StatefulWidget {
  final int initialIndex;

  const ExpertNavigation({super.key, this.initialIndex = 0});

  @override
  State<ExpertNavigation> createState() => _ExpertNavigationState();
}

class _ExpertNavigationState extends State<ExpertNavigation>
    with TickerProviderStateMixin {
  late NavigationManager _navigationManager;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // The 5 main screens for expert navigation
  static const List<Widget> _screens = [
    HomeScreen(key: ValueKey('expert_home')), // Experts can browse other experts
    ExpertDashboard(key: ValueKey('dashboard')),
    SessionsHistoryScreen(key: ValueKey('sessions')),
    BusinessLinkingScreen(key: ValueKey('business')),
    ExpertSettings(key: ValueKey('settings')),
  ];

  @override
  void initState() {
    super.initState();
    _navigationManager = NavigationManager();
    
    // Set user type and initial tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationManager.setUserType(UserType.expert);
      _navigationManager.setTabIndex(widget.initialIndex);
    });

    // Setup animations
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

  void _onItemTapped(int index) {
    _navigationManager.setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => _navigationManager.handleBackButton(context),
      child: ChangeNotifierProvider.value(
        value: _navigationManager,
        child: Consumer<NavigationManager>(
          builder: (context, navManager, child) {
            return Scaffold(
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
                      child: IndexedStack(
                        index: navManager.currentTabIndex,
                        children: _screens,
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: appState.translate('home'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: appState.translate('dashboard'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history_outlined),
                    activeIcon: const Icon(Icons.history),
                    label: appState.translate('sessions'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.business_outlined),
                    activeIcon: const Icon(Icons.business),
                    label: appState.translate('business'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings),
                    label: appState.translate('settings'),
                  ),
                ],
                currentIndex: navManager.currentTabIndex.clamp(0, 4),
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: theme.colorScheme.surface,
                selectedFontSize: 12,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                elevation: 8,
              ),
            );
          },
        ),
      ),
    );
  }
}
