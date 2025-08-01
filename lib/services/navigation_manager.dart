import 'package:flutter/material.dart';

/// A centralized helper class that encapsulates common navigation and back-button
/// behaviour across the application.
///
/// This class is **stateless** – it does not keep an internal navigation stack
/// but instead receives the current tab index and a setter callback from the
/// caller.  This keeps the API extremely simple while still allowing all
/// navigation wrappers (guest / client / expert) to share identical back-button
/// logic.
///
/// Usage inside a `StatefulWidget` that owns a `_currentIndex` variable:
/// ```dart
/// return WillPopScope(
///   onWillPop: () => NavigationManager.handleWillPop(
///     context: context,
///     currentTabIndex: _currentIndex,
///     setTabIndex: (index) => setState(() => _currentIndex = index),
///   ),
///   child: Scaffold(
///     // ...
///   ),
/// );
/// ```
class NavigationManager {
  NavigationManager._(); // No instances

  /// Handles the system back-button press.
  ///
  /// Behaviour matrix (matches the spec):
  ///   • If the current `Navigator` can pop (i.e. we are on an *inner page*),
  ///     let it handle the pop (return `true`).
  ///   • Else if the user is on a **non-home** bottom-navigation tab, switch to
  ///     the home tab (index 0) and **prevent** the pop (return `false`).
  ///   • Else (home tab, root route) – ask for confirmation and exit the app if
  ///     the user agrees.
  static Future<bool> handleWillPop({
    required BuildContext context,
    required int currentTabIndex,
    required ValueSetter<int> setTabIndex,
  }) async {
    final navigator = Navigator.of(context);

    // 1️⃣ Inner page? → pop the route
    if (navigator.canPop()) {
      return true; // Allow pop
    }

    // 2️⃣ Not on home tab? → switch to home
    if (currentTabIndex != 0) {
      setTabIndex(0);
      return false; // Prevent app from closing
    }

    // 3️⃣ Home tab root → confirm exit
    final shouldExit = await _showExitDialog(context);
    return shouldExit ?? false;
  }

  /// Displays a simple material dialog asking the user to confirm app exit.
  static Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
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
  }
}