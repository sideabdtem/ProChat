import 'package:flutter/material.dart';
import '../screens/main_app_screen.dart';
import '../screens/expert_navigation.dart';
import '../screens/main_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/auth_screen.dart';

class NavigationService {
  static void navigateToMainApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainAppScreen()),
    );
  }

  static void navigateToExpertNavigation(BuildContext context, {int initialIndex = 0}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExpertNavigation(initialIndex: initialIndex),
      ),
    );
  }

  static void navigateToMainNavigation(BuildContext context, {int initialIndex = 0}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(initialIndex: initialIndex),
      ),
    );
  }

  static void navigateToGuestNavigation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GuestMainNavigation()),
    );
  }

  static void navigateToAuth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  static void clearNavigationStack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainAppScreen()),
      (route) => false,
    );
  }

  static void executePendingAction(BuildContext context) {
    // This method can be used to execute any pending navigation actions
    // after the user state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Any pending navigation logic can be added here
    });
  }
}