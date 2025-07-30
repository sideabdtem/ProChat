import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../screens/main_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/expert_signup_page.dart';
import '../screens/main_app_screen.dart';
import '../screens/admin_dashboard_page.dart';
import '../services/navigation_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String _selectedUserType = 'client'; // 'client' or 'expert'
  bool _isLogin = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.95),
              theme.colorScheme.secondary.withOpacity(0.85),
              theme.colorScheme.primaryContainer.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildAuthPage(appState, theme),
        ),
      ),
    );
  }

  Widget _buildAuthPage(AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Welcome Section
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    appState.translate('app_title'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.translate('welcome'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Client Section
          _buildClientSection(appState, theme),
          const SizedBox(height: 24),

          // Expert Section
          _buildExpertSection(appState, theme),
          const SizedBox(height: 24),

          // Admin Section (for testing)
          _buildAdminSection(appState, theme),
        ],
      ),
    );
  }

  Widget _buildClientSection(AppState appState, ThemeData theme) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Client',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUserType = 'client';
                        _isLogin = true;
                      });
                      _showAuthDialog(appState, theme, UserType.client, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(appState.translate('login')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUserType = 'client';
                        _isLogin = false;
                      });
                      _showAuthDialog(appState, theme, UserType.client, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(appState.translate('signup')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertSection(AppState appState, ThemeData theme) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Expert',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'For experts and business owners',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUserType = 'expert';
                        _isLogin = true;
                      });
                      _showAuthDialog(appState, theme, UserType.expert, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(appState.translate('login')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUserType = 'expert';
                        _isLogin = false;
                      });
                      _showAuthDialog(appState, theme, UserType.expert, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(appState.translate('signup')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection(AppState appState, ThemeData theme) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Admin (Testing)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Direct admin access for testing
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
              child: Text(appState.translate('access_admin_panel')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthDialog(
      AppState appState, ThemeData theme, UserType userType, bool isLogin) {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              userType == UserType.client ? Icons.person : Icons.psychology,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isLogin
                  ? appState.translate('login')
                  : appState.translate('signup'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: appState.translate('name'),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: appState.translate('email'),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: appState.translate('password'),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (!isLogin) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: appState.translate('confirm_password'),
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _handleAuth(userType, isLogin),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLogin
                    ? appState.translate('login')
                    : appState.translate('signup')),
          ),
        ],
      ),
    );
  }

  void _handleAuth(UserType userType, bool isLogin) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      bool success = false;

      if (isLogin) {
        // For testing, use dummy authentication
        if (_emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          // Create a dummy user for testing
          final dummyUser = AppUser(
            id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
            name: _emailController.text.split('@')[0],
            email: _emailController.text,
            userType: userType,
            language: 'en',
            createdAt: DateTime.now(),
          );

          appState.setCurrentUser(dummyUser);
          success = true;
        }
      } else {
        // For testing, use dummy signup
        if (_nameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          final dummyUser = AppUser(
            id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
            name: _nameController.text,
            email: _emailController.text,
            userType: userType,
            language: 'en',
            createdAt: DateTime.now(),
          );

          appState.setCurrentUser(dummyUser);
          success = true;
        }
      }

      if (success) {
        Navigator.pop(context); // Close dialog

        // Use navigation service to ensure clean state transition
        NavigationService.clearNavigationStack(context);
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      final appState = context.read<AppState>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appState.translate('error')}: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
