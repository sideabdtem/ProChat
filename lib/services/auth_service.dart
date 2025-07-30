import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import '../screens/chat_screen.dart';
import '../screens/call_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/appointment_booking_screen.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Legacy SharedPreferences keys for backward compatibility
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userTypeKey = 'user_type';
  static const String _userLanguageKey = 'user_language';
  static const String _userCreatedAtKey = 'user_created_at';
  static const String _isLoggedInKey = 'is_logged_in';

  // Firebase Authentication methods
  static Future<AppUser?> signInWithEmailAndPassword(
      String email, String password, UserType userType) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Get user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final appUser = AppUser.fromJson(userData);

          // Verify user type matches
          if (appUser.userType == userType) {
            await _saveUserSessionLocally(appUser);
            return appUser;
          } else {
            throw Exception(
                'User type mismatch. Expected: $userType, Found: ${appUser.userType}');
          }
        } else {
          throw Exception('User profile not found in database');
        }
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  static Future<AppUser?> createUserWithEmailAndPassword(
      String name, String email, String password, UserType userType) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create user profile in Firestore
        final appUser = AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email,
          userType: userType,
          language: 'en',
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(appUser.toJson());

        // Save locally for backward compatibility
        await _saveUserSessionLocally(appUser);

        return appUser;
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserSessionLocally();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return AppUser.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<bool> isUserLoggedIn() async {
    try {
      return _auth.currentUser != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      await _saveUserSessionLocally(user);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  static Future<void> deleteUserAccount() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).delete();

        // Delete Firebase Auth user
        await firebaseUser.delete();

        // Clear local session
        await _clearUserSessionLocally();
      }
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }

  // Legacy methods for backward compatibility
  static Future<void> saveUserSession(AppUser user) async {
    await _saveUserSessionLocally(user);
  }

  static Future<AppUser?> getSavedUserSession() async {
    try {
      // Try Firebase Auth first
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        return currentUser;
      }

      // Fallback to SharedPreferences for backward compatibility
      return await _getUserSessionFromSharedPreferences();
    } catch (e) {
      print('Error getting saved user session: $e');
      return null;
    }
  }

  static Future<void> clearUserSession() async {
    await _clearUserSessionLocally();
  }

  static Future<bool> isLoggedIn() async {
    return await isUserLoggedIn();
  }

  // Private helper methods
  static Future<void> _saveUserSessionLocally(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userTypeKey, user.userType.toString());
    await prefs.setString(_userLanguageKey, user.language);
    await prefs.setString(_userCreatedAtKey, user.createdAt.toIso8601String());
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<AppUser?> _getUserSessionFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);
    final userTypeStr = prefs.getString(_userTypeKey);
    final userLanguage = prefs.getString(_userLanguageKey);
    final userCreatedAtStr = prefs.getString(_userCreatedAtKey);

    if (userId == null ||
        userName == null ||
        userEmail == null ||
        userTypeStr == null ||
        userLanguage == null ||
        userCreatedAtStr == null) {
      return null;
    }

    UserType userType;
    try {
      userType = UserType.values.firstWhere(
        (type) => type.toString() == userTypeStr,
      );
    } catch (e) {
      return null;
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(userCreatedAtStr);
    } catch (e) {
      return null;
    }

    return AppUser(
      id: userId,
      name: userName,
      email: userEmail,
      userType: userType,
      language: userLanguage,
      createdAt: createdAt,
    );
  }

  static Future<void> _clearUserSessionLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userLanguageKey);
    await prefs.remove(_userCreatedAtKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}

// Navigation context for storing pending actions
class PendingAction {
  final String type;
  final Map<String, dynamic> data;

  PendingAction({required this.type, required this.data});
}

class NavigationService {
  static PendingAction? _pendingAction;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void setPendingAction(PendingAction action) {
    _pendingAction = action;
  }

  static PendingAction? getPendingAction() {
    return _pendingAction;
  }

  static void clearPendingAction() {
    _pendingAction = null;
  }

  static void executePendingAction(BuildContext context) {
    if (_pendingAction == null) return;

    final action = _pendingAction!;
    clearPendingAction();

    switch (action.type) {
      case 'start_chat':
        final expert = action.data['expert'] as Expert;
        _navigateToChat(context, expert);
        break;
      case 'start_call':
        final expert = action.data['expert'] as Expert;
        final sessionType = action.data['sessionType'] as SessionType;
        _navigateToCall(context, expert, sessionType);
        break;
      case 'book_session':
        final expert = action.data['expert'] as Expert;
        _navigateToBooking(context, expert);
        break;
      case 'book_appointment':
        final expert = action.data['expert'] as Expert;
        _navigateToAppointmentBooking(context, expert);
        break;
    }
  }

  static void _navigateToChat(BuildContext context, Expert expert) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(expert: expert),
      ),
    );
  }

  static void _navigateToCall(
      BuildContext context, Expert expert, SessionType sessionType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          expert: expert,
          sessionType: sessionType,
        ),
      ),
    );
  }

  static void _navigateToBooking(BuildContext context, Expert expert) {
    // TODO: Implement booking screen if needed
    // Use the global navigator key to show snackbar safely
    try {
      if (navigatorKey.currentContext != null) {
        final scaffoldMessenger =
            ScaffoldMessenger.of(navigatorKey.currentContext!);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Booking feature coming soon!')),
        );
      } else {
        // Fallback: try to use the provided context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking feature coming soon!')),
        );
      }
    } catch (e) {
      // Last resort: print to console
      print('Could not show booking message: $e');
    }
  }

  static void _navigateToAppointmentBooking(
      BuildContext context, Expert expert) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentBookingScreen(expert: expert),
      ),
    );
  }
}
