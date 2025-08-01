// lib/screens/profile_settings_screen.dart - Combined profile and settings screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'guest_main_navigation.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final currentUser = appState.currentUser;

    // If user is not authenticated, show sign-in prompt
    if (currentUser == null) {
      return _buildUnauthenticatedView(context, appState, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile_settings')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: appState.translate('profile'),
            ),
            Tab(
              icon: const Icon(Icons.settings),
              text: appState.translate('settings'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(context, appState, theme, currentUser),
          _buildSettingsTab(context, appState, theme),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView(
      BuildContext context, AppState appState, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                appState.translate('sign_in_required'),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                appState.translate('please_sign_in_to_view_profile'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationManager()
                      .navigateToGuestNavigation(context);
                },
                icon: const Icon(Icons.login),
                label: Text(appState.translate('sign_in')),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, AppState appState,
      ThemeData theme, AppUser currentUser) {
    final navigationManager = NavigationManager();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    currentUser.name.isNotEmpty
                        ? currentUser.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser.name,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    currentUser.userType == UserType.expert
                        ? appState.translate('expert')
                        : appState.translate('client'),
                  ),
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Options
          _buildListTile(
            context,
            title: appState.translate('edit_profile'),
            subtitle: appState.translate('update_your_information'),
            icon: Icons.edit,
            onTap: () {
              navigationManager.navigateToInnerPage(
                context,
                const EditProfileScreen(),
                routeName: '/edit-profile',
              );
            },
          ),
          _buildListTile(
            context,
            title: appState.translate('payment_methods'),
            subtitle: appState.translate('manage_payment_options'),
            icon: Icons.payment,
            onTap: () {
              navigationManager.navigateToInnerPage(
                context,
                const PaymentMethodsScreen(),
                routeName: '/payment-methods',
              );
            },
          ),
          if (currentUser.userType == UserType.client)
            _buildListTile(
              context,
              title: appState.translate('become_expert'),
              subtitle: appState.translate('share_your_expertise'),
              icon: Icons.verified_user,
              onTap: () {
                // Navigate to expert signup
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appState.translate('feature_coming_soon')),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(
      BuildContext context, AppState appState, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App Settings
        _buildSectionHeader(appState.translate('app_settings'), theme),
        _buildListTile(
          context,
          title: appState.translate('language'),
          subtitle: _getLanguageName(appState.currentLanguage, appState),
          icon: Icons.language,
          onTap: () => _showLanguageDialog(context, appState),
        ),
        _buildListTile(
          context,
          title: appState.translate('theme'),
          subtitle: _getThemeName(appState.themeMode, appState),
          icon: Icons.palette,
          onTap: () => _showThemeDialog(context, appState),
        ),
        SwitchListTile(
          title: Text(appState.translate('notifications')),
          subtitle: Text(appState.translate('enable_push_notifications')),
          secondary: const Icon(Icons.notifications),
          value: appState.notificationsEnabled,
          onChanged: (value) {
            appState.setNotificationsEnabled(value);
          },
        ),

        const SizedBox(height: 24),

        // Account Settings
        _buildSectionHeader(appState.translate('account'), theme),
        _buildListTile(
          context,
          title: appState.translate('privacy_policy'),
          icon: Icons.privacy_tip,
          onTap: () {
            // Open privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appState.translate('opening_privacy_policy')),
              ),
            );
          },
        ),
        _buildListTile(
          context,
          title: appState.translate('terms_of_service'),
          icon: Icons.description,
          onTap: () {
            // Open terms of service
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appState.translate('opening_terms')),
              ),
            );
          },
        ),
        _buildListTile(
          context,
          title: appState.translate('help_support'),
          icon: Icons.help,
          onTap: () {
            // Open help & support
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appState.translate('opening_support')),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Logout Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => _handleLogout(context, appState),
            icon: const Icon(Icons.logout),
            label: Text(appState.translate('logout')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageName(String languageCode, AppState appState) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return languageCode;
    }
  }

  String _getThemeName(ThemeMode mode, AppState appState) {
    switch (mode) {
      case ThemeMode.light:
        return appState.translate('light');
      case ThemeMode.dark:
        return appState.translate('dark');
      case ThemeMode.system:
        return appState.translate('system');
    }
  }

  void _showLanguageDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'en', 'English', appState),
            _buildLanguageOption(context, 'ar', 'العربية', appState),
            _buildLanguageOption(context, 'hi', 'हिन्दी', appState),
            _buildLanguageOption(context, 'id', 'Bahasa Indonesia', appState),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode,
      String languageName, AppState appState) {
    return ListTile(
      title: Text(languageName),
      trailing: appState.currentLanguage == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        appState.setLanguage(languageCode);
        Navigator.pop(context);
      },
    );
  }

  void _showThemeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('select_theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
                context, ThemeMode.light, appState.translate('light'), appState),
            _buildThemeOption(
                context, ThemeMode.dark, appState.translate('dark'), appState),
            _buildThemeOption(
                context, ThemeMode.system, appState.translate('system'), appState),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode,
      String themeName, AppState appState) {
    return ListTile(
      title: Text(themeName),
      trailing: appState.themeMode == mode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        appState.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _handleLogout(BuildContext context, AppState appState) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('logout')),
        content: Text(appState.translate('are_you_sure_logout')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appState.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              appState.translate('logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear user session
      await AuthService.clearUserSession();
      await appState.logout();

      // Navigate to guest navigation
      if (context.mounted) {
        NavigationManager().navigateToGuestNavigation(context);
      }
    }
  }
}