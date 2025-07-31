// lib/main.dart - Updated main entry point
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/b2b_service.dart';
import 'services/wallet_service.dart';
import 'services/firebase_service.dart';
import 'models/app_models.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Migrate dummy data to Firebase (only run once)
  try {
    await FirebaseService.migrateDummyDataToFirestore();
    print('✅ Migration completed successfully!');
  } catch (e) {
    print('⚠️ Migration failed: $e');
    print('App will continue with dummy data as fallback');
  }

  // Hide overflow indicators globally
  if (kDebugMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('RenderFlex overflow')) {
        return Container();
      }
      return ErrorWidget(details.exception);
    };
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            try {
              return AppState();
            } catch (e) {
              print('Error creating AppState: $e');
              return AppState();
            }
          },
        ),
        ChangeNotifierProvider(create: (context) => B2BService()),
        ChangeNotifierProvider(create: (context) => WalletService()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Chat Pro',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appState.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            home: const SplashScreen(), // Always start with splash
            debugShowCheckedModeBanner: false,
            debugShowMaterialGrid: false,
            builder: (context, child) {
              return Directionality(
                textDirection: appState.isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
