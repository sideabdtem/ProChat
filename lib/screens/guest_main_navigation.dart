import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../screens/guest_home_screen.dart';
import '../screens/auth_screen.dart';

class GuestMainNavigation extends StatefulWidget {
  const GuestMainNavigation({super.key});

  @override
  State<GuestMainNavigation> createState() => _GuestMainNavigationState();
}

class _GuestMainNavigationState extends State<GuestMainNavigation> {
  late NavigationManager _navigationManager;

  static const List<Widget> _widgetOptions = <Widget>[
    GuestHomeScreenContent(),
    GuestHomeScreenContent(), // Placeholder - navigation will handle auth screen
  ];

  @override
  void initState() {
    super.initState();
    _navigationManager = NavigationManager();
    // Set user type to null for guest
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationManager.setUserType(null);
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to auth screen when Sign In/Up tab is tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } else {
      _navigationManager.setTabIndex(index);
    }
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
              body: IndexedStack(
                index: navManager.currentTabIndex,
                children: _widgetOptions,
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: _getLocalizedText('home', appState),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.login_outlined),
                    activeIcon: const Icon(Icons.login),
                    label: _getLocalizedText('sign_in', appState),
                  ),
                ],
                currentIndex: navManager.currentTabIndex > 1 ? 0 : navManager.currentTabIndex,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: theme.colorScheme.surface,
                selectedFontSize: 12,
                unselectedFontSize: 10,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getLocalizedText(String key, AppState appState) {
    return appState.translate(key);
  }
}

class GuestHomeScreenContent extends StatelessWidget {
  const GuestHomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const GuestHomeScreen();
  }
}
