import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/sessions_history_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../widgets/call_status_bar.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the current index based on the available navigation items
    final appState = context.read<AppState>();
    final maxIndex = _getMaxNavigationIndex(appState);
    _currentIndex = widget.initialIndex <= maxIndex ? widget.initialIndex : 0;
  }

  int _getMaxNavigationIndex(AppState appState) {
    if (appState.currentUser == null) {
      // Guest navigation: Home + Sign In/Up = 2 items (indices 0-1)
      return 1;
    } else {
      // Logged-in navigation: Home + Session History + Notifications + Profile/Settings = 4 items (indices 0-3)
      return 3;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getCurrentScreen(AppState appState, ThemeData theme) {
    // For guests (non-logged-in users), adjust the index since session history is not shown
    if (appState.currentUser == null) {
      switch (_currentIndex) {
        case 0:
          return const HomeScreen(key: ValueKey('home'));
        case 1:
          return Container(
            key: const ValueKey('auth'),
            child: const AuthScreen(),
          );
        default:
          return const HomeScreen(key: ValueKey('home'));
      }
    }

    // For logged-in users, use the original logic
    switch (_currentIndex) {
      case 0:
        return const HomeScreen(key: ValueKey('home'));
      case 1:
        return Container(
          key: const ValueKey('history'),
          child: _buildSessionHistoryScreen(appState, theme),
        );
      case 2:
        return Container(
          key: const ValueKey('notifications'),
          child: const NotificationsScreen(),
        );
      case 3:
        return Container(
          key: const ValueKey('profile'),
          child: const ProfileSettingsScreen(),
        );

      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final navigationManager = context.read<NavigationManager>();
    final theme = Theme.of(context);

    // Ensure currentIndex is always within bounds
    final maxIndex = _getMaxNavigationIndex(appState);
    if (_currentIndex > maxIndex) {
      _currentIndex = 0;
    }

    // Update navigation manager state
    navigationManager.setCurrentTabIndex(_currentIndex);

    return WillPopScope(
      onWillPop: () async {
        return await navigationManager.handleBackButton(context);
      },
      child: Scaffold(
        body: Column(
          children: [
            const CallStatusBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _getCurrentScreen(appState, theme),
              ),
            ),
          ],
        ),
        bottomNavigationBar: appState.currentUser == null
            ? _buildGuestBottomNavigationBar(appState, theme)
            : _buildLoggedInBottomNavigationBar(appState, theme),
      ),
    );
  }

  Widget _buildGuestBottomNavigationBar(AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final maxIndex = _getMaxNavigationIndex(appState);
          if (index > maxIndex) return; // Safety check

          if (index == 1) {
            // Navigate to auth screen when Sign In/Up tab is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthScreen(),
              ),
            );
          } else if (index != _currentIndex) {
            _animationController.reset();
            _animationController.forward();
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: appState.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            activeIcon: Icon(Icons.login),
            label: 'Sign In/Up',
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInBottomNavigationBar(AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final maxIndex = _getMaxNavigationIndex(appState);
          if (index > maxIndex) return; // Safety check

          if (index != _currentIndex) {
            _animationController.reset();
            _animationController.forward();
            setState(() {
              _currentIndex = index;
            });
            context.read<NavigationManager>().setCurrentTabIndex(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: appState.translate('home'),
          ),
          // Only show session history for logged-in users
          if (appState.currentUser != null)
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: appState.translate('session_history'),
            ),
          // Only show notifications for logged-in users
          if (appState.currentUser != null)
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined),
                  if (appState.pendingNotifications.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${appState.pendingNotifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Icon(Icons.notifications),
                  if (appState.pendingNotifications.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${appState.pendingNotifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: appState.translate('notifications'),
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: appState.translate('profile_settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistoryScreen(AppState appState, ThemeData theme) {
    final sessions = appState.sessionHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appState.translate('session_history'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.translate('no_sessions_found'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(session, appState, theme);
              },
            ),
    );
  }

  Widget _buildSessionCard(
      ConsultationSession session, AppState appState, ThemeData theme) {
    final expert = appState.getExpertById(session.expertId);
    if (expert == null) return const SizedBox();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertProfileScreen(expert: expert),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: expert.profileImage != null
                        ? NetworkImage(expert.profileImage!)
                        : null,
                    child: expert.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 24,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expert.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          expert.categoryName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    session.sessionIcon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        appState.getFormattedDuration(session.durationMinutes),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cost',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '\$${session.totalCost.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (session.rating != null) ...[
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: index < session.rating!
                            ? Colors.amber
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      session.rating!.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }





}
