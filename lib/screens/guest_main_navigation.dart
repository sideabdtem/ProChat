import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_service.dart';
import '../screens/guest_home_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/main_app_screen.dart';

class GuestMainNavigation extends StatefulWidget {
  const GuestMainNavigation({super.key});

  @override
  State<GuestMainNavigation> createState() => _GuestMainNavigationState();
}

class _GuestMainNavigationState extends State<GuestMainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    GuestHomeScreenContent(),
    GuestHomeScreenContent(), // Placeholder - navigation will handle auth screen
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user is now authenticated and redirect if needed
    final appState = context.read<AppState>();
    if (appState.currentUser != null) {
      // If user is now authenticated, redirect to main app screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationService.navigateToMainApp(context);
      });
    }
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
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    // If user is authenticated, show loading while redirecting
    if (appState.currentUser != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
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
        currentIndex:
            _selectedIndex > 1 ? 0 : _selectedIndex, // Ensure index is valid
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedFontSize: 12,
        unselectedFontSize: 10,
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
