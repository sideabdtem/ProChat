import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/navigation_manager.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/auth_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NavigationManager _navigationManager = NavigationManager();

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

    // Check if user is authenticated
    if (appState.currentUser == null) {
      return _buildUnauthenticatedView(appState, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile_settings')),
        backgroundColor: theme.colorScheme.surface,
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
          _buildProfileTab(appState, theme),
          _buildSettingsTab(appState, theme),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView(AppState appState, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('profile_settings')),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              appState.translate('sign_in_required'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appState.translate('sign_in_to_access_profile'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _navigationManager.navigateToAuthScreen(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(appState.translate('sign_in')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(AppState appState, ThemeData theme) {
    final user = appState.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.primary,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.userType == UserType.expert 
                              ? appState.translate('expert')
                              : appState.translate('client'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Actions
          Text(
            appState.translate('profile_actions'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            appState,
            theme,
            icon: Icons.edit_outlined,
            title: appState.translate('edit_profile'),
            subtitle: appState.translate('update_your_information'),
            onTap: () {
              _navigationManager.navigateToInnerPage(
                context,
                const EditProfileScreen(),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            appState,
            theme,
            icon: Icons.payment_outlined,
            title: appState.translate('payment_methods'),
            subtitle: appState.translate('manage_payment_options'),
            onTap: () {
              _navigationManager.navigateToInnerPage(
                context,
                const PaymentMethodsScreen(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.translate('app_settings'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Theme Settings
          _buildSettingsSection(
            context,
            appState,
            theme,
            title: appState.translate('appearance'),
            children: [
              _buildSwitchTile(
                context,
                appState,
                theme,
                icon: Icons.dark_mode_outlined,
                title: appState.translate('dark_mode'),
                subtitle: appState.translate('use_dark_theme'),
                value: appState.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  appState.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Language Settings
          _buildSettingsSection(
            context,
            appState,
            theme,
            title: appState.translate('language'),
            children: [
              _buildListTile(
                context,
                appState,
                theme,
                icon: Icons.language_outlined,
                title: appState.translate('language'),
                subtitle: appState.translate('select_language'),
                onTap: () {
                  // TODO: Implement language selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appState.translate('coming_soon'))),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Settings
          _buildSettingsSection(
            context,
            appState,
            theme,
            title: appState.translate('account'),
            children: [
              _buildListTile(
                context,
                appState,
                theme,
                icon: Icons.logout_outlined,
                title: appState.translate('logout'),
                subtitle: appState.translate('sign_out_of_account'),
                onTap: () {
                  _showLogoutDialog(context, appState, theme);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AppState appState,
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    AppState appState,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    AppState appState,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    AppState appState,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('logout')),
        content: Text(appState.translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigationManager.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('logout')),
          ),
        ],
      ),
    );
  }
}