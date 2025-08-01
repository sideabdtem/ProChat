import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_models.dart';

class NavigationManager extends ChangeNotifier {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  // Navigation state
  int _currentTabIndex = 0;
  String _currentRoute = '';
  bool _isOnMainTab = true;
  Widget? _currentInnerPage;
  String _currentRole = 'guest'; // 'guest', 'client', 'expert'

  // Getters
  int get currentTabIndex => _currentTabIndex;
  String get currentRoute => _currentRoute;
  bool get isOnMainTab => _isOnMainTab;
  Widget? get currentInnerPage => _currentInnerPage;
  String get currentRole => _currentRole;

  // Set current role based on user type
  void setRole(String role) {
    _currentRole = role;
    notifyListeners();
  }

  // Update tab index
  void setTabIndex(int index) {
    _currentTabIndex = index;
    _isOnMainTab = true;
    _currentInnerPage = null;
    _currentRoute = _getRouteForTab(index);
    notifyListeners();
  }

  // Navigate to inner page while maintaining bottom navigation
  void navigateToInnerPage(Widget page, String routeName) {
    _currentInnerPage = page;
    _currentRoute = routeName;
    _isOnMainTab = false;
    notifyListeners();
  }

  // Go back to main tab navigation
  void goBackToMainTab() {
    _currentInnerPage = null;
    _isOnMainTab = true;
    _currentRoute = _getRouteForTab(_currentTabIndex);
    notifyListeners();
  }

  // Handle back button press
  Future<bool> handleBackButton(BuildContext context) async {
    // If we're on an inner page, go back to main tab
    if (!_isOnMainTab && _currentInnerPage != null) {
      goBackToMainTab();
      return false; // Don't exit app
    }

    // If we're on the main tab (index 0), show exit dialog
    if (_currentTabIndex == 0) {
      return await _showExitDialog(context);
    }

    // If we're on other main tabs, navigate to home tab (index 0)
    setTabIndex(0);
    return false; // Don't exit app
  }

  // Show exit confirmation dialog
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Get route name for tab index
  String _getRouteForTab(int index) {
    switch (_currentRole) {
      case 'guest':
        switch (index) {
          case 0: return '/guest/home';
          case 1: return '/guest/auth';
          default: return '/guest/home';
        }
      case 'client':
        switch (index) {
          case 0: return '/client/home';
          case 1: return '/client/sessions';
          case 2: return '/client/notifications';
          case 3: return '/client/profile_settings';
          default: return '/client/home';
        }
      case 'expert':
        switch (index) {
          case 0: return '/expert/home';
          case 1: return '/expert/dashboard';
          case 2: return '/expert/sessions';
          case 3: return '/expert/business';
          case 4: return '/expert/settings';
          default: return '/expert/home';
        }
      default:
        return '/guest/home';
    }
  }

  // Route to appropriate navigation based on user type
  static Widget getNavigationForUser(AppUser? user, {int initialIndex = 0}) {
    if (user == null) {
      NavigationManager().setRole('guest');
      return const GuestMainNavigation();
    }

    switch (user.userType) {
      case UserType.client:
        NavigationManager().setRole('client');
        return MainNavigation(initialIndex: initialIndex);
      case UserType.expert:
        NavigationManager().setRole('expert');
        return ExpertNavigation(initialIndex: initialIndex);
    }
  }

  // Clear navigation state (for logout)
  void clearNavigationState() {
    _currentTabIndex = 0;
    _currentRoute = '';
    _isOnMainTab = true;
    _currentInnerPage = null;
    _currentRole = 'guest';
    notifyListeners();
  }
}

// Import statements for navigation screens
import '../screens/guest_main_navigation.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';