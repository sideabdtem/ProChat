import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'auth_service.dart';
import '../models/app_models.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/auth_screen.dart';

class NavigationManager extends ChangeNotifier {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  int _currentTabIndex = 0;
  bool _isInInnerPage = false;
  String _currentRoute = '';
  UserType? _currentUserType;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  bool get isInInnerPage => _isInInnerPage;
  String get currentRoute => _currentRoute;
  UserType? get currentUserType => _currentUserType;

  // Set current user type
  void setCurrentUserType(UserType? userType) {
    _currentUserType = userType;
    notifyListeners();
  }

  // Set current tab index
  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Set inner page state
  void setInnerPageState(bool isInInnerPage) {
    _isInInnerPage = isInInnerPage;
    notifyListeners();
  }

  // Set current route
  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  // Navigate to inner page
  void navigateToInnerPage(BuildContext context, Widget screen) {
    setInnerPageState(true);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    ).then((_) {
      setInnerPageState(false);
    });
  }

  // Handle back button press
  Future<bool> handleBackButton(BuildContext context) async {
    final appState = context.read<AppState>();
    
    // If in inner page, do normal back navigation
    if (_isInInnerPage) {
      return false; // Let system handle back
    }

    // If on main tab (index 0), show exit dialog
    if (_currentTabIndex == 0) {
      return await _showExitDialog(context);
    }

    // If on other main tabs, navigate to home tab
    setCurrentTabIndex(0);
    return true; // Prevent default back behavior
  }

  // Show exit dialog
  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
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
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // Exit the app
      SystemNavigator.pop();
      return true;
    }
    
    return false;
  }

  // Navigate to role-based home after authentication
  void navigateToRoleBasedHome(BuildContext context, AppUser user) {
    final appState = context.read<AppState>();
    appState.setCurrentUser(user);
    setCurrentUserType(user.userType);
    
    Widget targetScreen;
    switch (user.userType) {
      case UserType.expert:
        targetScreen = const ExpertNavigation(initialIndex: 0);
        break;
      case UserType.client:
        targetScreen = const MainNavigation(initialIndex: 0);
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => targetScreen),
      (route) => false,
    );
  }

  // Navigate to guest navigation
  void navigateToGuestNavigation(BuildContext context) {
    setCurrentUserType(null);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GuestMainNavigation()),
      (route) => false,
    );
  }

  // Navigate to auth screen
  void navigateToAuthScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  // Logout and navigate to guest
  void logout(BuildContext context) async {
    final appState = context.read<AppState>();
    
    // Clear user session
    await AuthService.clearUserSession();
    appState.setCurrentUser(null);
    setCurrentUserType(null);
    
    // Navigate to guest navigation
    navigateToGuestNavigation(context);
  }

  // Get appropriate navigation screen based on user type
  Widget getNavigationScreenForUserType(UserType? userType, {int initialIndex = 0}) {
    switch (userType) {
      case UserType.expert:
        return ExpertNavigation(initialIndex: initialIndex);
      case UserType.client:
        return MainNavigation(initialIndex: initialIndex);
      case null:
      default:
        return const GuestMainNavigation();
    }
  }

  // Reset navigation state
  void resetState() {
    _currentTabIndex = 0;
    _isInInnerPage = false;
    _currentRoute = '';
    _currentUserType = null;
    notifyListeners();
  }
}