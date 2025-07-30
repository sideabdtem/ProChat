import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../services/b2b_service.dart';
import '../services/app_state.dart';

class ExpertBusinessLinkingScreen extends StatefulWidget {
  const ExpertBusinessLinkingScreen({super.key});

  @override
  State<ExpertBusinessLinkingScreen> createState() =>
      _ExpertBusinessLinkingScreenState();
}

class _ExpertBusinessLinkingScreenState
    extends State<ExpertBusinessLinkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessEmailController = TextEditingController();
  ExpertCategory _selectedCategory = ExpertCategory.doctor;
  bool _isLoading = false;

  @override
  void dispose() {
    _businessEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final b2bService = context.watch<B2BService>();
    final theme = Theme.of(context);

    final currentUser = appState.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
            child: Text(appState.translate('login_required_business_linking'))),
      );
    }

    // Get pending invites for current expert
    final pendingInvites = b2bService.getExpertPendingInvites(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.isRTL ? 'ربط الأعمال' : 'Business Linking'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Invitations Section
            if (pendingInvites.isNotEmpty) ...[
              _buildPendingInvitationsSection(pendingInvites, theme, appState),
              const SizedBox(height: 24),
            ],

            // Link to Business Section
            _buildLinkToBusinessSection(theme, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInvitationsSection(
    List<BusinessLinkRequest> pendingInvites,
    ThemeData theme,
    AppState appState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  appState.isRTL ? 'دعوات معلقة' : 'Pending Invitations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...pendingInvites
              .map((invite) => _buildInvitationCard(invite, theme, appState)),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(
    BusinessLinkRequest invite,
    ThemeData theme,
    AppState appState,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  invite.businessName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
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
                      appState.isRTL
                          ? 'دعوة من ${invite.businessName}'
                          : '${appState.translate('invitation_from')} ${invite.businessName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invite.businessEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (invite.message != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                invite.message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _rejectInvitation(invite.id),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(appState.isRTL ? 'رفض' : 'Reject'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _acceptInvitation(invite.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(appState.isRTL
                    ? 'قبول وإعداد الملف الشخصي'
                    : appState.translate('accept_setup_profile')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkToBusinessSection(ThemeData theme, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.link_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  appState.isRTL ? 'ربط بالأعمال' : 'Link to Business',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.isRTL
                        ? 'أدخل بريد الشركة الإلكتروني أو الرقم التعريفي لإرسال طلب الربط:'
                        : appState.translate('enter_business_email_id'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Business Email Field
                  TextFormField(
                    controller: _businessEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: appState.isRTL
                          ? 'البريد الإلكتروني للشركة'
                          : appState.translate('business_email'),
                      hintText: appState.isRTL
                          ? 'admin@company.com'
                          : 'admin@company.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appState.isRTL
                            ? 'الرجاء إدخال البريد الإلكتروني'
                            : appState.translate('please_enter_business_email');
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return appState.isRTL
                            ? 'البريد الإلكتروني غير صحيح'
                            : appState.translate('invalid_email_format');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  Text(
                    appState.isRTL
                        ? 'اختر فئة الخبرة:'
                        : appState.translate('select_expertise_category'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExpertCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: ExpertCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryName(category, appState.isRTL)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitLinkRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              appState.isRTL
                                  ? 'ربط الأعمال'
                                  : appState.translate('link_to_business'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ExpertCategory category, bool isRTL) {
    switch (category) {
      case ExpertCategory.doctor:
        return isRTL ? 'طبيب' : 'Doctor';
      case ExpertCategory.lawyer:
        return isRTL ? 'محامي' : 'Lawyer';
      case ExpertCategory.lifeCoach:
        return isRTL ? 'مدرب حياة' : 'Life Coach';
      case ExpertCategory.businessConsultant:
        return isRTL ? 'مستشار أعمال' : 'Business Consultant';
      case ExpertCategory.therapist:
        return isRTL ? 'معالج' : 'Therapist';
      case ExpertCategory.technician:
        return isRTL ? 'فني' : 'Technician';
      case ExpertCategory.religion:
        return isRTL ? 'مستشار ديني' : 'Religious Counselor';
    }
  }

  void _submitLinkRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    final b2bService = context.read<B2BService>();
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      _showMessage('Please login to send link request', appState.isRTL);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final success = b2bService.requestToLinkWithBusiness(
        currentUser.id,
        _businessEmailController.text.trim(),
        _selectedCategory,
      );

      if (success) {
        _showMessage(
          appState.isRTL
              ? 'تم إرسال طلب الربط بنجاح!'
              : appState.translate('link_request_sent_successfully'),
          appState.isRTL,
        );
        _businessEmailController.clear();
      } else {
        _showMessage(
          appState.isRTL
              ? 'فشل في إرسال طلب الربط. تأكد من البريد الإلكتروني.'
              : appState.translate('failed_send_link_request'),
          appState.isRTL,
        );
      }
    } catch (e) {
      _showMessage(
        appState.isRTL
            ? 'حدث خطأ أثناء إرسال الطلب'
            : appState.translate('error_sending_request'),
        appState.isRTL,
      );
    }

    setState(() => _isLoading = false);
  }

  void _acceptInvitation(String requestId) async {
    final b2bService = context.read<B2BService>();
    final appState = context.read<AppState>();

    final success = b2bService.acceptBusinessInvitation(requestId);

    if (success) {
      _showMessage(
        appState.isRTL
            ? 'تم قبول الدعوة بنجاح!'
            : appState.translate('invitation_accepted_successfully'),
        appState.isRTL,
      );
    } else {
      _showMessage(
        appState.isRTL
            ? 'فشل في قبول الدعوة'
            : appState.translate('failed_accept_invitation'),
        appState.isRTL,
      );
    }
  }

  void _rejectInvitation(String requestId) async {
    final b2bService = context.read<B2BService>();
    final appState = context.read<AppState>();

    final success = b2bService.rejectBusinessLink(requestId);

    if (success) {
      _showMessage(
        appState.isRTL
            ? 'تم رفض الدعوة'
            : appState.translate('invitation_rejected'),
        appState.isRTL,
      );
    } else {
      _showMessage(
        appState.isRTL
            ? 'فشل في رفض الدعوة'
            : appState.translate('failed_reject_invitation'),
        appState.isRTL,
      );
    }
  }

  void _showMessage(String message, bool isRTL) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
