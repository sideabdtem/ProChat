import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/auth_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/guest_main_navigation.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with TickerProviderStateMixin {
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
    final user = appState.currentUser;

    if (user == null) {
      return _buildSignInPrompt(appState, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile_settings')),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.person_outline),
              text: appState.translate('profile'),
            ),
            Tab(
              icon: const Icon(Icons.settings_outlined),
              text: appState.translate('settings'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(user, appState, theme),
          _buildSettingsTab(user, appState, theme),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt(AppState appState, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile_settings')),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                appState.translate('sign_in_to_access_profile'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                appState.translate('sign_in_to_access_profile_subtitle'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: Text(appState.translate('sign_in')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(AppUser user, AppState appState, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.userType.toString().split('.').last.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<NavigationManager>().navigateToInnerPage(
                      EditProfileScreen(),
                      '/profile/edit',
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Profile Options
        _buildProfileOption(
          context,
          icon: Icons.payment_outlined,
          title: appState.translate('payment_methods'),
          subtitle: appState.translate('manage_payment_methods'),
          onTap: () {
            context.read<NavigationManager>().navigateToInnerPage(
              const PaymentMethodsScreen(),
              '/profile/payment_methods',
            );
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.history_outlined,
          title: appState.translate('session_history'),
          subtitle: appState.translate('view_past_sessions'),
          onTap: () {
            // Navigate to sessions tab
            context.read<NavigationManager>().setTabIndex(1);
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.notifications_outlined,
          title: appState.translate('notifications'),
          subtitle: appState.translate('manage_notifications'),
          onTap: () {
            // Navigate to notifications tab
            context.read<NavigationManager>().setTabIndex(2);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTab(AppUser user, AppState appState, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App Settings
        Text(
          appState.translate('app_settings'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsOption(
          context,
          icon: Icons.language_outlined,
          title: appState.translate('language'),
          subtitle: appState.translate('current_language'),
          onTap: () {
            _showLanguageSelector(context, appState);
          },
        ),
        _buildSettingsOption(
          context,
          icon: Icons.dark_mode_outlined,
          title: appState.translate('theme'),
          subtitle: _getThemeModeText(appState),
          trailing: Switch(
            value: appState.themeMode == ThemeMode.dark,
            onChanged: (value) {
              appState.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        _buildSettingsOption(
          context,
          icon: Icons.translate_outlined,
          title: appState.translate('rtl_support'),
          subtitle: appState.translate('right_to_left_layout'),
          trailing: Switch(
            value: appState.isRTL,
            onChanged: (value) {
              appState.setRTL(value);
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Account Settings
        Text(
          appState.translate('account_settings'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsOption(
          context,
          icon: Icons.privacy_tip_outlined,
          title: appState.translate('privacy_policy'),
          subtitle: appState.translate('view_privacy_policy'),
          onTap: () {
            // TODO: Navigate to privacy policy
          },
        ),
        _buildSettingsOption(
          context,
          icon: Icons.help_outline,
          title: appState.translate('help_support'),
          subtitle: appState.translate('get_help_support'),
          onTap: () {
            // TODO: Navigate to help & support
          },
        ),
        
        const SizedBox(height: 24),
        
        // Logout Button
        Card(
          color: theme.colorScheme.errorContainer.withOpacity(0.3),
          child: ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              appState.translate('logout'),
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              appState.translate('logout_subtitle'),
              style: TextStyle(
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
            ),
            onTap: () => _showLogoutDialog(context, appState),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
        onTap: onTap,
      ),
    );
  }

  String _getThemeModeText(AppState appState) {
    switch (appState.themeMode) {
      case ThemeMode.dark:
        return appState.translate('dark_theme');
      case ThemeMode.light:
        return appState.translate('light_theme');
      case ThemeMode.system:
        return appState.translate('system_theme');
    }
  }

  void _showLanguageSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appState.translate('select_language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('English'),
                leading: const Text('🇺🇸'),
                onTap: () {
                  appState.setLanguage('en');
                  Navigator.pop(context);
                },
                selected: appState.currentLanguage == 'en',
              ),
              ListTile(
                title: const Text('العربية'),
                leading: const Text('🇸🇦'),
                onTap: () {
                  appState.setLanguage('ar');
                  Navigator.pop(context);
                },
                selected: appState.currentLanguage == 'ar',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('logout')),
        content: Text(appState.translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Clear user session
              await AuthService.signOut();
              appState.setCurrentUser(null);
              
              // Clear navigation state
              context.read<NavigationManager>().clearNavigationState();
              
              // Navigate to guest navigation
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const GuestMainNavigation(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(appState.translate('logout')),
          ),
        ],
      ),
    );
  }
}