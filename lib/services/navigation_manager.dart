// lib/services/navigation_manager.dart - Centralized navigation management
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../screens/expert_navigation.dart';
import '../screens/main_navigation.dart';
import '../screens/guest_main_navigation.dart';

class NavigationManager extends ChangeNotifier {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  // Navigation state
  int _currentTabIndex = 0;
  String _currentRoute = '/';
  final List<String> _navigationStack = [];
  bool _isInnerPage = false;
  UserType? _currentUserType;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  String get currentRoute => _currentRoute;
  bool get isInnerPage => _isInnerPage;
  UserType? get currentUserType => _currentUserType;
  List<String> get navigationStack => List.unmodifiable(_navigationStack);

  // Set current user type
  void setUserType(UserType? userType) {
    _currentUserType = userType;
    notifyListeners();
  }

  // Update current tab index
  void setTabIndex(int index) {
    _currentTabIndex = index;
    _isInnerPage = false;
    notifyListeners();
  }

  // Navigate to inner page
  void navigateToInnerPage(BuildContext context, Widget page, {String? routeName}) {
    _isInnerPage = true;
    if (routeName != null) {
      _navigationStack.add(routeName);
      _currentRoute = routeName;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      // When returning from inner page
      _isInnerPage = false;
      if (routeName != null && _navigationStack.isNotEmpty) {
        _navigationStack.removeLast();
        _currentRoute = _navigationStack.isEmpty ? '/' : _navigationStack.last;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  // Handle back button press
  Future<bool> handleBackButton(BuildContext context) async {
    // If on inner page, use normal back navigation
    if (_isInnerPage && Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }

    // If on main tab but not home (index 0), go to home
    if (_currentTabIndex != 0) {
      setTabIndex(0);
      return false;
    }

    // If on home tab (index 0), show exit dialog
    return await _showExitDialog(context);
  }

  // Show exit confirmation dialog
  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Navigate based on user role
  void navigateToRoleBasedHome(BuildContext context, UserType userType) {
    setUserType(userType);
    Widget destination;
    
    switch (userType) {
      case UserType.expert:
        destination = const ExpertNavigation(initialIndex: 0);
        break;
      case UserType.client:
        destination = const MainNavigation(initialIndex: 0);
        break;
    }
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  // Navigate to guest navigation
  void navigateToGuestNavigation(BuildContext context) {
    setUserType(null);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GuestMainNavigation()),
      (route) => false,
    );
  }

  // Reset navigation state
  void reset() {
    _currentTabIndex = 0;
    _currentRoute = '/';
    _navigationStack.clear();
    _isInnerPage = false;
    _currentUserType = null;
    notifyListeners();
  }
}