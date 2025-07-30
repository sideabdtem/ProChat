import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/wallet_service.dart';
import '../models/app_models.dart';
import '../screens/chat_screen.dart';
import '../screens/main_navigation.dart';

class PaymentScreen extends StatefulWidget {
  final Expert expert;
  final bool isForAppointment;
  final Map<String, dynamic>? appointmentDetails;

  const PaymentScreen({
    super.key,
    required this.expert,
    this.isForAppointment = false,
    this.appointmentDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PaymentType? _selectedPaymentType;
  SessionConfig? _selectedSessionConfig;
  bool _isProcessing = false;
  String _paymentMethod = 'personal'; // 'personal' or 'business'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set default payment method for business users
    final appState = context.read<AppState>();
    if (_isBusinessUser(appState)) {
      _paymentMethod = 'business';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isBusinessUser(AppState appState) {
    return appState.currentUser?.userType == UserType.businessOwner ||
        appState.currentUser?.userType == UserType.businessTeam;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isForAppointment
              ? appState.translate('appointment_payment')
              : appState.translate('payment_options'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildExpertHeader(theme),
                  const SizedBox(height: 24),
                  if (widget.isForAppointment) _buildAppointmentSummary(theme),
                  if (widget.isForAppointment) const SizedBox(height: 24),
                  widget.isForAppointment
                      ? _buildAppointmentPaymentOptions(theme, appState)
                      : _buildPaymentOptions(theme, appState),
                  const SizedBox(height: 24),
                  if (_isBusinessUser(appState))
                    _buildPaymentMethodToggle(theme, appState),
                  const Spacer(),
                  _buildPaymentButton(theme, appState),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(widget.expert.profileImage ??
                "https://pixabay.com/get/g0b9e67536f622e2f5d3afdc31b9520ef1bd79bf3409dee0a2029a5099d6a5acb05822f0a24ae143e18a2cd816987b2d926fe86dc2c85cd51cf5fbbd425acca3b_1280.jpg"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expert.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.expert.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.expert.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(ThemeData theme, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.translate('choose_payment_method'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<AppState>(
          builder: (context, appState, child) => _buildPaymentOption(
            theme: theme,
            title: appState.translate('pay_per_minute'),
            subtitle: appState.translate('charged_based_on_duration'),
            price:
                '${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}${appState.translate('per_minute')}',
            type: PaymentType.perMinute,
            icon: Icons.timer,
          ),
        ),
        const SizedBox(height: 12),
        // Show session packages if expert has them configured
        if (widget.expert.sessionConfigs.isNotEmpty)
          ...widget.expert.sessionConfigs
              .where((config) => config.isActive)
              .map((sessionConfig) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Consumer<AppState>(
                builder: (context, appState, child) =>
                    _buildSessionPackageOption(
                  theme: theme,
                  sessionConfig: sessionConfig,
                  appState: appState,
                ),
              ),
            );
          }).toList()
        else
          Consumer<AppState>(
            builder: (context, appState, child) => _buildPaymentOption(
              theme: theme,
              title: appState.translate('pay_per_session'),
              subtitle: appState.translate('fixed_price_session'),
              price:
                  '${appState.convertAndFormatPrice(widget.expert.pricePerSession, 'USD')}/20${appState.translate('per_minute')}',
              type: PaymentType.perSession,
              icon: Icons.schedule,
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String price,
    required PaymentType type,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type;
          if (type == PaymentType.perMinute) {
            _selectedSessionConfig = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionPackageOption({
    required ThemeData theme,
    required SessionConfig sessionConfig,
    required AppState appState,
  }) {
    final isSelected = _selectedPaymentType == PaymentType.perSession &&
        _selectedSessionConfig?.id == sessionConfig.id;
    final pricePerMinute = sessionConfig.durationMinutes > 0
        ? sessionConfig.price / sessionConfig.durationMinutes
        : 0.0;
    final savings = sessionConfig.durationMinutes > 0
        ? (widget.expert.pricePerMinute * sessionConfig.durationMinutes) -
            sessionConfig.price
        : 0.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = PaymentType.perSession;
          _selectedSessionConfig = sessionConfig;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sessionConfig.durationMinutes} ${appState.translate('minutes_session')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    savings > 0
                        ? '${appState.translate('save_amount')} ${appState.convertAndFormatPrice(savings, 'USD')} ${appState.translate('bullet_point')} (${appState.convertAndFormatPrice(pricePerMinute, 'USD')}/${appState.translate('minutes_short')})'
                        : '${appState.convertAndFormatPrice(pricePerMinute, 'USD')}/${appState.translate('minutes_short')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: savings > 0
                          ? Colors.green
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight:
                          savings > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              appState.convertAndFormatPrice(sessionConfig.price, 'USD'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSummary(ThemeData theme) {
    if (widget.appointmentDetails == null) return const SizedBox();

    final scheduledTime =
        widget.appointmentDetails!['scheduledTime'] as DateTime;
    final durationMinutes =
        widget.appointmentDetails!['durationMinutes'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            theme: theme,
            icon: Icons.calendar_today,
            label: 'Date',
            value:
                '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            theme: theme,
            icon: Icons.access_time,
            label: 'Time',
            value:
                '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            theme: theme,
            icon: Icons.timer,
            label: 'Duration',
            value: '${durationMinutes} minutes',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ':',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodToggle(ThemeData theme, AppState appState) {
    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        final businessId = appState.currentUser?.businessId ?? 'business_1';
        final wallet = walletService.getWallet(businessId);
        final walletBalance = wallet?.balance ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.translate('payment_method'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Business Wallet Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _paymentMethod = 'business';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _paymentMethod == 'business'
                      ? Colors.green.withOpacity(0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _paymentMethod == 'business'
                        ? Colors.green
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: _paymentMethod == 'business' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'business'
                            ? Colors.green
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: _paymentMethod == 'business'
                            ? Colors.white
                            : Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.translate('deduct_from_business_wallet'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _paymentMethod == 'business'
                                  ? Colors.green
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appState.translate('company_credits')}: ${appState.getCurrencySymbol()}${walletBalance.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_paymentMethod == 'business')
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Personal Payment Option (greyed out for business users)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: theme.colorScheme.outline,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Payment',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Not available for business users',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.block,
                    color: theme.colorScheme.outline,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentPaymentOptions(ThemeData theme, AppState appState) {
    if (widget.appointmentDetails == null) return const SizedBox();

    final paymentType =
        widget.appointmentDetails!['paymentType'] as PaymentType;
    final durationMinutes =
        widget.appointmentDetails!['durationMinutes'] as int;

    // Set the payment type from appointment details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedPaymentType == null) {
        setState(() {
          _selectedPaymentType = paymentType;
        });
      }
    });

    final totalCost = paymentType == PaymentType.perSession
        ? widget.expert.pricePerSession
        : widget.expert.pricePerMinute * durationMinutes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.translate('payment_summary'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appState.translate('payment_type')}:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                paymentType == PaymentType.perSession
                    ? appState.translate('per_session')
                    : appState.translate('per_minute'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appState.translate('rate')}:',
                style: theme.textTheme.bodyMedium,
              ),
              Consumer<AppState>(
                builder: (context, appState, child) => Text(
                  paymentType == PaymentType.perSession
                      ? '${appState.convertAndFormatPrice(widget.expert.pricePerSession, 'USD')}/${appState.translate('session_short')}'
                      : '${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}/${appState.translate('minutes_short')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appState.translate('total_cost')}:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<AppState>(
                builder: (context, appState, child) => Text(
                  appState.convertAndFormatPrice(totalCost, 'USD'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(ThemeData theme, AppState appState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedPaymentType != null && !_isProcessing
                ? () => _processPayment(appState)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    widget.isForAppointment
                        ? appState.translate('confirm_book_appointment')
                        : appState.translate('confirm_payment'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            appState.translate('cancel'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  void _processPayment(AppState appState) async {
    if (_selectedPaymentType == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, always success
    bool paymentSuccess = true;

    if (paymentSuccess) {
      if (widget.isForAppointment && widget.appointmentDetails != null) {
        // Book the appointment
        final scheduledTime =
            widget.appointmentDetails!['scheduledTime'] as DateTime;
        final durationMinutes =
            widget.appointmentDetails!['durationMinutes'] as int;
        final paymentType =
            widget.appointmentDetails!['paymentType'] as PaymentType;

        final totalCost = paymentType == PaymentType.perSession
            ? widget.expert.pricePerSession
            : widget.expert.pricePerMinute * durationMinutes;

        final success = await appState.bookAppointment(
          expertId: widget.expert.id,
          scheduledTime: scheduledTime,
          durationMinutes: durationMinutes,
          totalCost: totalCost,
          title: 'Consultation with ${widget.expert.name}',
          description:
              'Scheduled appointment for ${widget.expert.categoryName}',
          paymentType: paymentType,
        );

        if (success) {
          // Show success dialog and navigate back to expert profile
          _showAppointmentSuccessDialog();
        } else {
          _showPaymentErrorDialog();
        }
      } else {
        // Set payment type and selected session config in app state
        appState.setPaymentType(_selectedPaymentType!);
        appState.setSelectedSessionConfig(_selectedSessionConfig);

        // Start the session properly
        final isPaidPerMinute = _selectedPaymentType == PaymentType.perMinute;
        final walletService = context.read<WalletService>();

        bool success = false;

        if (_isBusinessUser(appState) && _paymentMethod == 'business') {
          // Business wallet payment
          final businessId = appState.currentUser?.businessId ?? 'business_1';
          success = await appState.startSession(
            widget.expert.id,
            SessionType.chat,
            isPaidPerMinute,
            walletService: walletService,
            businessId: businessId,
            teamMemberId: appState.currentUser?.id ?? 'member_1',
            teamMemberName: appState.currentUser?.name ?? 'Current User',
          );
        } else {
          // Regular client payment (without business wallet deduction)
          success = await appState.startSession(
            widget.expert.id,
            SessionType.chat,
            isPaidPerMinute,
          );
        }

        if (success) {
          // Navigate to chat screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                expert: widget.expert,
                paymentType: _selectedPaymentType!,
              ),
            ),
          );
        } else {
          // Show insufficient credits dialog
          _showInsufficientCreditsDialog();
        }
      }
    } else {
      // Show error dialog
      _showPaymentErrorDialog();
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _showPaymentErrorDialog() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('payment_failed')),
        content: Text(appState.translate('unable_to_process_payment')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _showAppointmentSuccessDialog() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(appState.translate('appointment_booked')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appState.translate('appointment_success_message')),
            const SizedBox(height: 16),
            Text(appState.translate('confirmation_email')),
            const SizedBox(height: 16),
            Text(appState.translate('expert_calendar_note')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to booking screen
              Navigator.of(context).pop(); // Go back to expert profile
              // Navigate to home screen to see upcoming appointments
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigation(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            child: Text(appState.translate('back_to_home')),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCreditsDialog() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(appState.translate('insufficient_credits')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appState.translate('business_wallet_insufficient')),
            const SizedBox(height: 16),
            Text(appState.translate('ask_owner_top_up')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only business owners can add credits to the wallet.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('ok')),
          ),
        ],
      ),
    );
  }
}
