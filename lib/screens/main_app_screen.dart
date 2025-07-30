import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/b2b_service.dart';
import '../models/app_models.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/guest_main_navigation.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  @override
  void initState() {
    super.initState();
    // Execute any pending actions after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      final b2bService = context.read<B2BService>();

      // Initialize B2BService with dummy data
      b2bService.initializeDummyData();

      if (appState.currentUser != null) {
        NavigationService.executePendingAction(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // If user is logged in, show appropriate navigation
        if (appState.currentUser != null) {
          switch (appState.currentUser!.userType) {
            case UserType.expert:
              return const ExpertNavigation();
            case UserType.client:
              return const MainNavigation();
            case UserType.businessOwner:
              return Scaffold(
                  body: Center(
                      child: Text(appState
                          .translate('business_dashboard_coming_soon'))));
            case UserType.businessTeam:
              return Scaffold(
                  body: Center(
                      child: Text(appState
                          .translate('business_dashboard_coming_soon'))));
          }
        }

        // If user is not logged in, show guest home screen
        return const GuestMainNavigation();
      },
    );
  }
}
