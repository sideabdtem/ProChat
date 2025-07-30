import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/app_state.dart';
import '../services/b2b_service.dart';
import '../models/app_models.dart';
import 'chat_screen.dart';

class BusinessLinkingScreen extends StatefulWidget {
  const BusinessLinkingScreen({super.key});

  @override
  State<BusinessLinkingScreen> createState() => _BusinessLinkingScreenState();
}

class _BusinessLinkingScreenState extends State<BusinessLinkingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Join business tab controllers
  final _businessCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isJoinedToBusiness = false;
  String? _joinedBusinessName;
  List<String> _businessMembers = [];

  // Starting a business controllers
  final _startBusinessNameController = TextEditingController();
  final _startBusinessEmailController = TextEditingController();
  final _startBusinessBioController = TextEditingController();
  List<String> _selectedBusinessCategories = [];
  List<String> _selectedBusinessSubcategories = [];
  String _businessType = 'business'; // 'business' or 'team'

  // Business verification status
  VerificationStatus _businessVerificationStatus =
      VerificationStatus.unverified;
  String? _ownedBusinessCode;
  String? _ownedBusinessInviteLink;
  List<String> _ownedBusinessMembers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessCodeController.dispose();
    _startBusinessNameController.dispose();
    _startBusinessEmailController.dispose();
    _startBusinessBioController.dispose();
    super.dispose();
  }

  void _joinBusiness() async {
    final input = _businessCodeController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a business code or invite link';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final b2bService = context.read<B2BService>();
      final appState = context.read<AppState>();

      // Extract business code from input
      final businessCode = b2bService.extractBusinessCode(input);

      if (businessCode == null) {
        setState(() {
          _errorMessage = 'Invalid business code or invite link';
          _isLoading = false;
        });
        return;
      }

      // Find business by code
      final business = b2bService.findBusinessByCode(businessCode);

      if (business == null) {
        setState(() {
          _errorMessage =
              'Business not found. Please check the code and try again.';
          _isLoading = false;
        });
        return;
      }

      // Link expert to business (in a real app, this would update the database)
      // For now, we'll just show success message and simulate joining

      setState(() {
        _isLoading = false;
        _isJoinedToBusiness = true;
        _joinedBusinessName = business.name;
        _businessMembers = [
          'John Doe',
          'Jane Smith',
          'Mike Johnson',
          'You'
        ]; // Simulated members
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully linked to ${business.name}'),
            backgroundColor: Colors.green,
          ),
        );
        _businessCodeController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appState.isRTL ? 'ربط الأعمال' : 'Business Linking',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(
              text:
                  appState.isRTL ? 'عضو فريق الأعمال' : 'Team Business Member',
              icon: const Icon(Icons.group),
            ),
            Tab(
              text: appState.isRTL
                  ? 'بدء / مالك فريق الأعمال'
                  : 'Start / Owner Team Business',
              icon: const Icon(Icons.business_center),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinBusinessTab(appState, theme),
          _buildStartBusinessTab(appState, theme),
        ],
      ),
    );
  }

  Widget _buildJoinBusinessTab(AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.group,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  appState.isRTL
                      ? 'انضم إلى فريق الأعمال'
                      : 'Join a Business Team',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.isRTL
                      ? 'استخدم رمز الأعمال أو رابط الدعوة للانضمام إلى فريق الأعمال'
                      : 'Use a business code or invite link to join a business team',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (!_isJoinedToBusiness)
            ..._buildJoinBusinessForm(appState, theme)
          else
            ..._buildJoinedBusinessView(appState, theme),
        ],
      ),
    );
  }

  List<Widget> _buildJoinBusinessForm(AppState appState, ThemeData theme) {
    return [
      // Business Code Input
      Text(
        appState.isRTL
            ? 'رمز الأعمال أو رابط الدعوة'
            : 'Business Code or Invite Link',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _businessCodeController,
        decoration: InputDecoration(
          hintText: appState.isRTL
              ? 'أدخل رمز الأعمال (مثل: TECH123) أو رابط الدعوة الكامل'
              : 'Enter business code (e.g., TECH123) or full invite link',
          prefixIcon: const Icon(Icons.code),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        textCapitalization: TextCapitalization.characters,
        onChanged: (value) {
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
      const SizedBox(height: 8),

      // Helper text
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appState.isRTL
                    ? 'يمكنك إدخال رمز الأعمال مباشرة أو رابط الدعوة الكامل'
                    : 'You can enter the business code directly or paste the full invite link',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),

      if (_errorMessage != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 24),

      // Join Button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _joinBusiness,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  appState.isRTL ? 'انضم إلى الأعمال' : 'Join Business',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),

      const SizedBox(height: 32),

      // Examples section
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.isRTL ? 'أمثلة:' : 'Examples:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildExampleItem(
                'TECH123', appState.isRTL ? 'رمز الأعمال' : 'Business Code'),
            _buildExampleItem(
                'LAW456', appState.isRTL ? 'رمز الأعمال' : 'Business Code'),
            _buildExampleItem('https://yourapp.com/join?code=TECH123',
                appState.isRTL ? 'رابط الدعوة' : 'Invite Link'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildJoinedBusinessView(AppState appState, ThemeData theme) {
    return [
      // Success message
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appState.isRTL
                        ? 'تم الانضمام بنجاح!'
                        : 'Successfully Joined!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appState.isRTL
                  ? 'أنت الآن عضو في $_joinedBusinessName'
                  : 'You are now a member of $_joinedBusinessName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // Team members list
      Text(
        appState.isRTL ? 'أعضاء الفريق' : 'Team Members',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),

      Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: _businessMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLastItem = index == _businessMembers.length - 1;
            final isCurrentUser = member == 'You';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLastItem
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCurrentUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    child: Text(
                      member[0],
                      style: TextStyle(
                        color: isCurrentUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isCurrentUser)
                          Text(
                            appState.isRTL ? '(أنت)' : '(You)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isCurrentUser)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            _startTeamChat(context, member, appState),
                        icon: const Icon(Icons.chat,
                            color: Colors.white, size: 20),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  if (isCurrentUser)
                    Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 24),

      // Leave business button
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _leaveBusiness,
          icon: const Icon(Icons.exit_to_app, color: Colors.red),
          label: Text(
            appState.isRTL ? 'مغادرة الأعمال' : 'Leave Business',
            style: const TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ];
  }

  void _leaveBusiness() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('leave_business')),
        content: Text('Are you sure you want to leave $_joinedBusinessName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isJoinedToBusiness = false;
                _joinedBusinessName = null;
                _businessMembers.clear();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have left the business'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('leave')),
          ),
        ],
      ),
    );
  }

  Widget _buildStartBusinessTab(AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_businessVerificationStatus == VerificationStatus.verified) ...[
            // Show verified business view (type selectors are hidden after approval)
            ..._buildVerifiedBusinessView(appState, theme),
          ] else ...[
            // Starting a Business Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_center,
                    size: 32,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    appState.isRTL ? 'بدء الأعمال' : 'Start a Business',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.isRTL
                        ? 'أنشئ ملف تعريف الأعمال الخاص بك على منصتنا واحصل على التحقق لدعوة أعضاء الفريق'
                        : 'Create your business profile on our platform and get verified to invite team members',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Type selector
            Row(
              children: [
                Expanded(
                  child: _buildTypeSelector(
                    'business',
                    appState.isRTL ? 'الأعمال' : 'Business',
                    Icons.business,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeSelector(
                    'team',
                    appState.isRTL ? 'الفريق' : 'Team',
                    Icons.group,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business verification status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBusinessVerificationColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBusinessVerificationColor().withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.isRTL
                        ? 'حالة التحقق من الأعمال'
                        : 'Business Verification Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getBusinessVerificationText(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _getBusinessVerificationColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_businessVerificationStatus ==
                      VerificationStatus.rejected) ...[
                    const SizedBox(height: 8),
                    Text(
                      appState.isRTL
                          ? 'يرجى مراجعة معلومات الأعمال الخاصة بك وإعادة التقديم للتحقق'
                          : 'Please review your business information and resubmit for verification',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Business form fields
            _buildTextField(
              controller: _startBusinessNameController,
              label: appState.isRTL
                  ? 'اسم ${_businessType == 'business' ? 'الأعمال' : 'الفريق'}'
                  : '${_businessType == 'business' ? 'Business' : 'Team'} Name',
              icon: _businessType == 'business' ? Icons.business : Icons.group,
              hintText: appState.isRTL
                  ? 'أدخل اسم ${_businessType == 'business' ? 'الأعمال' : 'الفريق'}'
                  : 'Enter your ${_businessType} name',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _startBusinessEmailController,
              label: appState.isRTL
                  ? 'البريد الإلكتروني ل${_businessType == 'business' ? 'لأعمال' : 'لفريق'}'
                  : '${_businessType == 'business' ? 'Business' : 'Team'} Email',
              icon: Icons.email,
              hintText: appState.isRTL
                  ? 'أدخل عنوان البريد الإلكتروني ل${_businessType == 'business' ? 'لأعمال' : 'لفريق'}'
                  : 'Enter ${_businessType} email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _startBusinessBioController,
              label: appState.isRTL
                  ? 'السيرة الذاتية ل${_businessType == 'business' ? 'لأعمال' : 'لفريق'}'
                  : '${_businessType == 'business' ? 'Business' : 'Team'} Bio',
              icon: Icons.description,
              hintText: appState.isRTL
                  ? 'اوصف ${_businessType == 'business' ? 'عملك' : 'فريقك'} والخدمات'
                  : 'Describe your ${_businessType} and services',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Business Categories
            _buildBusinessCategorySection(theme, appState),
            const SizedBox(height: 16),

            // Business Subcategories
            _buildBusinessSubcategorySection(theme, appState),
            const SizedBox(height: 24),

            // Submit for business verification button
            if (_businessVerificationStatus != VerificationStatus.underReview)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitBusinessForReview,
                  icon: const Icon(Icons.verified_user),
                  label: Text(_businessVerificationStatus ==
                          VerificationStatus.rejected
                      ? (appState.isRTL
                          ? 'إعادة تقديم ${_businessType == 'business' ? 'الأعمال' : 'الفريق'} للمراجعة'
                          : 'Resubmit ${_businessType == 'business' ? 'Business' : 'Team'} for Review')
                      : (appState.isRTL
                          ? 'تقديم ${_businessType == 'business' ? 'الأعمال' : 'الفريق'} للتحقق'
                          : 'Submit ${_businessType == 'business' ? 'Business' : 'Team'} for Verification')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appState.isRTL
                            ? '${_businessType == 'business' ? 'أعمالك' : 'فريقك'} قيد المراجعة حاليًا. سنقوم بإشعارك بمجرد اكتمال المراجعة'
                            : 'Your ${_businessType} is currently under review. We\'ll notify you once the review is complete',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleItem(String example, String type) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: example,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: ' ($type)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBusinessVerificationColor() {
    switch (_businessVerificationStatus) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.underReview:
        return Colors.orange;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.unverified:
      default:
        return Colors.grey;
    }
  }

  String _getBusinessVerificationText() {
    switch (_businessVerificationStatus) {
      case VerificationStatus.verified:
        return '✅ Business Verified';
      case VerificationStatus.underReview:
        return '⏳ Business Under Review';
      case VerificationStatus.rejected:
        return '❌ Business Rejected – Please resubmit';
      case VerificationStatus.unverified:
      default:
        return '❌ Business Unverified';
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCategorySection(ThemeData theme, AppState appState) {
    final availableCategories = [
      'Technology',
      'Healthcare',
      'Finance',
      'Legal',
      'Consulting',
      'Education',
      'Real Estate',
      'Marketing',
      'Manufacturing',
      'Retail',
      'Agriculture',
      'Transportation',
      'Hospitality',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              appState.isRTL ? 'فئات الأعمال' : 'Business Categories',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          appState.isRTL
              ? 'اختر الفئات التي تصف عملك بشكل أفضل'
              : 'Select categories that best describe your business',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedBusinessCategories.isEmpty)
                Text(
                  appState.isRTL
                      ? 'لم يتم اختيار أي فئات'
                      : 'No categories selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedBusinessCategories
                      .map((category) => Chip(
                            label: Text(category),
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedBusinessCategories.remove(category);
                              });
                            },
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _showBusinessCategorySelector(
                      theme, availableCategories, appState),
                  icon: const Icon(Icons.add),
                  label: Text(
                      appState.isRTL ? 'اختر الفئات' : 'Select Categories'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessSubcategorySection(ThemeData theme, AppState appState) {
    final availableSubcategories = [
      'Software Development',
      'Web Development',
      'Mobile App Development',
      'Cloud Computing',
      'Cybersecurity',
      'Data Analytics',
      'AI/Machine Learning',
      'Healthcare Technology',
      'E-commerce',
      'Digital Marketing',
      'Financial Services',
      'Legal Services',
      'Consulting Services',
      'Education Technology',
      'Real Estate Technology',
      'Marketing Automation',
      'Project Management',
      'Quality Assurance',
      'Customer Support',
      'Business Intelligence',
      'Enterprise Software',
      'Startup Services',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.subdirectory_arrow_right,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              appState.isRTL
                  ? 'الفئات الفرعية للأعمال (اختياري)'
                  : 'Business Subcategories (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          appState.isRTL
              ? 'اختر الفئات الفرعية المحددة لوصف خدمات أعمالك بشكل أكثر تفصيلاً'
              : 'Select specific subcategories to further describe your business services',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedBusinessSubcategories.isEmpty)
                Text(
                  appState.isRTL
                      ? 'لم يتم اختيار أي فئات فرعية'
                      : 'No subcategories selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedBusinessSubcategories
                      .map((subcategory) => Chip(
                            label: Text(subcategory),
                            backgroundColor:
                                theme.colorScheme.secondary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 12,
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedBusinessSubcategories
                                    .remove(subcategory);
                              });
                            },
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _showBusinessSubcategorySelector(
                      theme, availableSubcategories, appState),
                  icon: const Icon(Icons.add),
                  label: Text(appState.isRTL
                      ? 'اختر الفئات الفرعية'
                      : 'Select Subcategories'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.secondary),
                    foregroundColor: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBusinessCategorySelector(
      ThemeData theme, List<String> availableCategories, AppState appState) {
    final selectedCategories = List<String>.from(_selectedBusinessCategories);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            appState.isRTL ? 'اختر فئات الأعمال' : 'Select Business Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.isRTL
                      ? 'اختر الفئات التي تصف عملك بشكل أفضل:'
                      : 'Select the categories that best describe your business:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: availableCategories.length,
                    itemBuilder: (context, index) {
                      final category = availableCategories[index];
                      final isSelected = selectedCategories.contains(category);

                      return CheckboxListTile(
                        title: Text(
                          category,
                          style: theme.textTheme.bodyMedium,
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedCategories.contains(category)) {
                                selectedCategories.add(category);
                              }
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.isRTL
                      ? '${selectedCategories.length} فئة محددة'
                      : '${selectedCategories.length} categories selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appState.isRTL ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _selectedBusinessCategories = selectedCategories;
                });
                Navigator.of(context).pop();
              },
              child: Text(appState.isRTL ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessSubcategorySelector(
      ThemeData theme, List<String> availableSubcategories, AppState appState) {
    final selectedSubcategories =
        List<String>.from(_selectedBusinessSubcategories);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            appState.isRTL
                ? 'اختر الفئات الفرعية للأعمال'
                : 'Select Business Subcategories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.isRTL
                      ? 'اختر الفئات الفرعية لخدمات أعمال أكثر تحديداً:'
                      : 'Select subcategories for more specific business services:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: availableSubcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = availableSubcategories[index];
                      final isSelected =
                          selectedSubcategories.contains(subcategory);

                      return CheckboxListTile(
                        title: Text(
                          subcategory,
                          style: theme.textTheme.bodyMedium,
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedSubcategories
                                  .contains(subcategory)) {
                                selectedSubcategories.add(subcategory);
                              }
                            } else {
                              selectedSubcategories.remove(subcategory);
                            }
                          });
                        },
                        activeColor: theme.colorScheme.secondary,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.isRTL
                      ? '${selectedSubcategories.length} فئة فرعية محددة'
                      : '${selectedSubcategories.length} subcategories selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appState.isRTL ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _selectedBusinessSubcategories = selectedSubcategories;
                });
                Navigator.of(context).pop();
              },
              child: Text(appState.isRTL ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitBusinessForReview() {
    if (_startBusinessNameController.text.trim().isEmpty ||
        _startBusinessEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required ${_businessType} fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _businessVerificationStatus = VerificationStatus.underReview;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_businessType == 'business' ? 'Business' : 'Team'} submitted for admin review. You will be notified once reviewed.'),
        backgroundColor: Colors.green,
      ),
    );

    // Simulate admin approval process with a delay
    Future.delayed(const Duration(seconds: 3), () {
      _simulateBusinessApproval();
    });
  }

  void _simulateBusinessApproval() {
    // Simulate admin approval - in real app this would be done by admin
    if (mounted) {
      final businessCode = _generateBusinessCode();
      final inviteLink = 'https://dreamflow.app/join?code=$businessCode';

      setState(() {
        _businessVerificationStatus = VerificationStatus.verified;
        _ownedBusinessCode = businessCode;
        _ownedBusinessInviteLink = inviteLink;
        _ownedBusinessMembers = [
          'John Doe',
          'Jane Smith',
          'Mike Johnson'
        ]; // Simulated members
      });

      _showBusinessApprovalDialog(businessCode, inviteLink);
    }
  }

  String _generateBusinessCode() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';

    String code = '';
    for (int i = 0; i < 3; i++) {
      code += letters[random.nextInt(letters.length)];
    }
    for (int i = 0; i < 3; i++) {
      code += numbers[random.nextInt(numbers.length)];
    }

    return code;
  }

  void _showBusinessApprovalDialog(String businessCode, String inviteLink) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
                '${_businessType == 'business' ? 'Business' : 'Team'} Approved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congratulations! Your ${_businessType} has been approved and verified.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, size: 20, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${_businessType == 'business' ? 'Business' : 'Team'} Code:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    businessCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.link, size: 20, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Invite Link:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    inviteLink,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this code or link with your team members to invite them to join your ${_businessType}.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: businessCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        '${_businessType == 'business' ? 'Business' : 'Team'} code copied to clipboard')),
              );
            },
            child: const Text('Copy Code'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Invite link copied to clipboard')),
              );
            },
            child: const Text('Copy Link'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(
      String type, String label, IconData icon, ThemeData theme) {
    final isSelected = _businessType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _businessType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVerifiedBusinessView(AppState appState, ThemeData theme) {
    return [
      // Business code and invite link display
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appState.isRTL
                        ? '${_businessType == 'business' ? 'الأعمال' : 'الفريق'} معتمد!'
                        : '${_businessType == 'business' ? 'Business' : 'Team'} Approved!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Business Code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, size: 20, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        appState.isRTL
                            ? 'رمز ${_businessType == 'business' ? 'الأعمال' : 'الفريق'}:'
                            : '${_businessType == 'business' ? 'Business' : 'Team'} Code:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _ownedBusinessCode!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _ownedBusinessCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(appState.isRTL
                                    ? 'تم نسخ الرمز'
                                    : 'Code copied')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: appState.isRTL ? 'نسخ الرمز' : 'Copy Code',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Invite Link
                  Row(
                    children: [
                      Icon(Icons.link, size: 20, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        appState.isRTL ? 'رابط الدعوة:' : 'Invite Link:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _ownedBusinessInviteLink!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _ownedBusinessInviteLink!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(appState.isRTL
                                    ? 'تم نسخ الرابط'
                                    : 'Link copied')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: appState.isRTL ? 'نسخ الرابط' : 'Copy Link',
                      ),
                      IconButton(
                        onPressed: () {
                          // Share functionality could be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(appState.isRTL
                                    ? 'ميزة المشاركة قريباً'
                                    : 'Share feature coming soon')),
                          );
                        },
                        icon: const Icon(Icons.share, size: 20),
                        tooltip: appState.isRTL ? 'مشاركة' : 'Share',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // Member management
      Text(
        appState.isRTL ? 'إدارة الأعضاء' : 'Member Management',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),

      Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: _ownedBusinessMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLastItem = index == _ownedBusinessMembers.length - 1;

            // Generate dummy data for each member (this should be in sync)
            // Using same logic as expert dashboard for consistency
            final memberIndex = _ownedBusinessMembers.indexOf(member);
            final sessionCount = memberIndex == 0
                ? 28
                : (15 + (member.hashCode % 20)); // First member matches expert
            final creditUsage =
                memberIndex == 0 ? 420.75 : (120.50 + (member.hashCode % 100));

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: isLastItem
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          member[0],
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.timeline,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$sessionCount sessions',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${creditUsage.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _startTeamChat(context, member, appState),
                          icon: const Icon(Icons.chat, size: 18),
                          label: Text(appState.isRTL ? 'رسالة' : 'Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showMemberHistory(
                              member, sessionCount, creditUsage),
                          icon: const Icon(Icons.history, size: 18),
                          label: Text(appState.isRTL ? 'التاريخ' : 'History'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _removeMember(member),
                          icon: const Icon(Icons.remove_circle, size: 18),
                          label: Text(appState.isRTL ? 'إزالة' : 'Remove'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  void _showMemberHistory(
      String memberName, int sessionCount, double creditUsage) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$memberName - History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$sessionCount',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          'Total Sessions',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '\$${creditUsage.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          'Credit Usage',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recent Sessions List
              Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final sessionDate =
                        DateTime.now().subtract(Duration(days: index + 1));
                    final sessionCost = 15.0 + (index * 5.0);
                    final sessionDuration = 30 + (index * 10);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.chat,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chat Session',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${sessionCost.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.timer,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sessionDuration}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${appState.translate('downloading_member_history')} $memberName...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download),
                  label: Text(appState.translate('download_history')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeMember(String memberName) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('remove_member')),
        content: Text(
            '${appState.translate('confirm_remove_member')} $memberName ${appState.translate('from_your')} ${_businessType}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ownedBusinessMembers.remove(memberName);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '$memberName ${appState.translate('has_been_removed')}'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('remove')),
          ),
        ],
      ),
    );
  }

  void _startTeamChat(
      BuildContext context, String memberName, AppState appState) {
    // Create a team chat session
    final session = ConsultationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: appState.currentUser?.id ?? '',
      expertId: '', // For team chats, expert ID is empty
      type: SessionType.teamChat,
      status: SessionStatus.active,
      startTime: DateTime.now(),
      totalCost: 0.0, // Team chats are free
      durationMinutes: 0,
      isPaidPerMinute: false,
      isTeamChat: true,
      teamMemberName: memberName,
    );

    // Add to active sessions
    appState.startTeamChat(session);

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          expert: null, // No expert for team chats
          viewOnly: false,
          session: session,
          isTeamChat: true,
          teamMemberName: memberName,
        ),
      ),
    );
  }
}
