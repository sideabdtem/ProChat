import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/b2b_service.dart';
import '../models/app_models.dart';
import '../screens/auth_screen.dart';
import '../screens/expert_business_linking_screen.dart';


class ExpertOwnProfile extends StatefulWidget {
  const ExpertOwnProfile({super.key});

  @override
  State<ExpertOwnProfile> createState() => _ExpertOwnProfileState();
}

class _ExpertOwnProfileState extends State<ExpertOwnProfile> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  
  String _profileImageUrl = '';
  bool _isEditing = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadProfileData();
  }

  void _loadProfileData() {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = '+1 234 567 8900'; // Mock data
      _bioController.text = 'Experienced professional dedicated to helping clients achieve their goals through personalized guidance and support. Passionate about making a positive impact in people\'s lives.';
      _specialtyController.text = 'Life Coach & Therapist';
      _experienceController.text = '10+ years';
      _hourlyRateController.text = '\$50/hour';
      _profileImageUrl = user.profileImage ?? "https://pixabay.com/get/g3a52bc1fd75adb0e162c832e0e888de7ddfbdb4a34672de4cb39592b09f7ab1ef40645e223245d01ef47fc7ad39c112deb7bf12d148f883ded0f95e7f39d6d5a_1280.jpg";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isRTL = appState.isRTL;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, isRTL),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(theme, isRTL),
              const SizedBox(height: 16),
              _buildQuickStats(theme, isRTL),
              const SizedBox(height: 16),
              _buildProfileDetails(theme, isRTL),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isRTL) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      title: Text(
        isRTL ? 'الملف الشخصي' : 'My Profile',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit_rounded,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => _showSignOutDialog(theme, isRTL),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: isRTL ? 'تسجيل الخروج' : 'Sign Out',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isRTL) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'profile-image',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                      child: _profileImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _nameController.text,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _specialtyController.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRTL ? 'موثق' : 'Verified',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    _hourlyRateController.text,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, bool isRTL) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                title: isRTL ? 'الجلسات' : 'Sessions',
                value: '342',
                icon: Icons.chat_bubble_outline_rounded,
                color: Colors.blue,
                theme: theme,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
              child: _buildStatItem(
                title: isRTL ? 'التقييم' : 'Rating',
                value: '4.9',
                icon: Icons.star_rounded,
                color: Colors.amber,
                theme: theme,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
              child: _buildStatItem(
                title: isRTL ? 'الأرباح' : 'Earnings',
                value: '\$12.4K',
                icon: Icons.trending_up_rounded,
                color: Colors.green,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(ThemeData theme, bool isRTL) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isRTL ? 'تفاصيل الملف الشخصي' : 'Profile Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              label: isRTL ? 'الاسم' : 'Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
              theme: theme,
            ),
            _buildDetailItem(
              label: isRTL ? 'البريد الإلكتروني' : 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              theme: theme,
              enabled: false,
            ),
            _buildDetailItem(
              label: isRTL ? 'رقم الهاتف' : 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              theme: theme,
            ),
            _buildDetailItem(
              label: isRTL ? 'التخصص' : 'Specialty',
              controller: _specialtyController,
              icon: Icons.work_outline_rounded,
              theme: theme,
            ),
            _buildDetailItem(
              label: isRTL ? 'الخبرة' : 'Experience',
              controller: _experienceController,
              icon: Icons.timeline_rounded,
              theme: theme,
            ),
            _buildDetailItem(
              label: isRTL ? 'النبذة' : 'Bio',
              controller: _bioController,
              icon: Icons.description_rounded,
              theme: theme,
              maxLines: 3,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    bool enabled = true,
    int maxLines = 1,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditing && enabled
                        ? theme.colorScheme.surface
                        : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: _isEditing && enabled
                        ? Border.all(color: theme.colorScheme.outline.withOpacity(0.3))
                        : null,
                  ),
                  child: _isEditing && enabled
                      ? TextField(
                          controller: controller,
                          maxLines: maxLines,
                          style: theme.textTheme.bodyMedium,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        )
                      : Text(
                          controller.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: enabled
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showSignOutDialog(ThemeData theme, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRTL ? 'تسجيل الخروج' : 'Sign Out',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRTL ? 'هل أنت متأكد من رغبتك في تسجيل الخروج؟' : 'Are you sure you want to sign out?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _performSignOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isRTL ? 'تسجيل الخروج' : 'Sign Out',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSignOut() async {
    setState(() {
      _isLoading = true;
    });
    
    // Show loading indicator
    Navigator.of(context).pop(); // Close dialog
    
    // Simulate logout process
    await Future.delayed(const Duration(milliseconds: 500));
    
    final appState = context.read<AppState>();
    appState.logout();
    
    // Navigate to auth screen
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }
  }
}