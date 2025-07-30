import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../screens/chat_screen.dart';
import '../screens/call_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/sessions_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/payment_methods_screen.dart';

class ExpertProfileScreen extends StatefulWidget {
  final Expert expert;

  const ExpertProfileScreen({super.key, required this.expert});

  @override
  State<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isCurrentUserExpert =
        appState.currentUser?.userType == UserType.expert &&
            appState.currentUser?.id == widget.expert.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(theme, appState),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildQuickStats(theme),
                  const SizedBox(height: 20),
                  _buildAboutSection(theme, appState),
                  const SizedBox(height: 20),
                  _buildSpecializationsSection(theme, appState),
                  if (!isCurrentUserExpert) ...[
                    const SizedBox(height: 20),
                    _buildPricingSection(theme, appState),
                    const SizedBox(height: 20),
                    _buildActionButtons(theme, appState),
                  ],
                  const SizedBox(height: 20),
                  _buildReviewsSection(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(appState, theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, AppState appState) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.share_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => _handleShareProfile(appState),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'expert_avatar_${widget.expert.id}',
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget
                              .expert.profileImage ??
                          "https://pixabay.com/get/ga3392c369465bae7ecfecd9946af72ec1d20c7f5013b23e8525621fe96ceeb9bf3654deb735f04955fb1a96601ce96a8eba854d26318bc922011d0c34f089f98_1280.jpg"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  appState.isRTL && widget.expert.nameArabic != null
                      ? widget.expert.nameArabic!
                      : widget.expert.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    appState.isRTL
                        ? appState.translate(
                            widget.expert.category.name.toLowerCase())
                        : widget.expert.categoryName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.expert.isAvailable
                        ? Colors.green.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.expert.isAvailable
                            ? appState.translate('online')
                            : appState.translate('offline'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) => _buildStatItem(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                value: widget.expert.rating.toStringAsFixed(1),
                label: appState.translate('rating'),
                theme: theme,
              ),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) => _buildStatItem(
                icon: Icons.reviews_rounded,
                iconColor: theme.colorScheme.primary,
                value: widget.expert.totalReviews.toString(),
                label: appState.translate('reviews'),
                theme: theme,
              ),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) => _buildStatItem(
                icon: Icons.attach_money_rounded,
                iconColor: Colors.green,
                value:
                    '${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}',
                label: appState.translate('per_minute_rate'),
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appState.translate('about'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            appState.translate(widget.expert.bio),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.work_outline_rounded,
            label: appState.translate('experience'),
            value: appState.translate('experience_years'),
            theme: theme,
            appState: appState,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.school_outlined,
            label: appState.translate('education'),
            value:
                '${appState.translate('phd')} ${appState.isRTL ? appState.translate(widget.expert.category.name.toLowerCase()) : widget.expert.categoryName}',
            theme: theme,
            appState: appState,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.language_outlined,
            label: appState.translate('languages'),
            value: widget.expert.languages.join(', '),
            theme: theme,
            appState: appState,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required AppState appState,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationsSection(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_border_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appState.translate('specializations'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getSpecializationsList().map((specialization) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Consumer<AppState>(
                  builder: (context, appState, child) => Text(
                    appState.translate(specialization),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getSpecializationsList() {
    if (widget.expert.subcategories.isNotEmpty) {
      return widget.expert.subcategories;
    }
    return [widget.expert.categoryName];
  }

  Widget _buildPricingSection(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.price_check_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appState.translate('pricing_sessions'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Per-minute pricing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.translate('price_per_minute'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.translate('flexible_consultation_pricing'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<AppState>(
                  builder: (context, appState, child) => Text(
                    '${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}${appState.translate('per_minute')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Session packages
          Text(
            appState.translate('session_packages'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildSessionPackages(theme, appState),
        ],
      ),
    );
  }

  Widget _buildSessionPackages(ThemeData theme, AppState appState) {
    // If expert has custom sessions configured, show them
    if (widget.expert.sessionConfigs.isNotEmpty) {
      final activeConfigs = widget.expert.sessionConfigs
          .where((config) => config.isActive)
          .toList();
      if (activeConfigs.isNotEmpty) {
        return Column(
          children: activeConfigs.map((sessionConfig) {
            final totalPrice = sessionConfig.price;
            final pricePerMinute = sessionConfig.durationMinutes > 0
                ? totalPrice / sessionConfig.durationMinutes
                : 0.0;
            final savings = sessionConfig.durationMinutes > 0
                ? (widget.expert.pricePerMinute *
                        sessionConfig.durationMinutes) -
                    totalPrice
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sessionConfig.durationMinutes} ${appState.translate('minutes_session')}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (savings > 0) ...[
                          const SizedBox(height: 2),
                          Consumer<AppState>(
                            builder: (context, appState, child) => Text(
                              'Save ${appState.convertAndFormatPrice(savings, 'USD')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer<AppState>(
                        builder: (context, appState, child) => Text(
                          appState.convertAndFormatPrice(totalPrice, 'USD'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, child) => Text(
                          '(${appState.convertAndFormatPrice(pricePerMinute, 'USD')}${appState.translate('per_minute')})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }
    }

    // If no custom sessions, show default message
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No session packages available. Consultations are charged per minute.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primary Action Button
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _handleStartChatCall(context, appState),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              label: Text(appState.translate('start_consultation')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary Action Button
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: OutlinedButton.icon(
              onPressed: () => _handleBookAppointment(context, appState),
              icon: const Icon(Icons.calendar_today_outlined, size: 20),
              label: Text(appState.translate('book_appointment')),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide.none,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(ThemeData theme) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final reviews = appState.getExpertReviews(widget.expert.id);
        final recentReviews = reviews.take(3).toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.reviews_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appState.translate('recent_reviews'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (reviews.length > 3)
                    TextButton(
                      onPressed: () => _showAllReviews(appState, theme),
                      child: Text(
                        '${appState.translate('view_all')} (${reviews.length})',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentReviews.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.translate('no_reviews_yet'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.translate('be_first_to_review'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentReviews.asMap().entries.map((entry) {
                  final index = entry.key;
                  final review = entry.value;
                  return Column(
                    children: [
                      _buildReviewItem(
                        name: review.clientName,
                        rating: review.rating.toInt(),
                        comment: review.comment ??
                            appState.translate('no_comment_provided'),
                        date: _formatReviewDate(review.createdAt, appState),
                        theme: theme,
                      ),
                      if (index < recentReviews.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String comment,
    required String date,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: const NetworkImage(
                    "https://pixabay.com/get/g1538ebc7c0bc7e22256465ec48fceb63b957c6073c41c14269f74f4f1292a970ed22e5cb9cf0fb5c5ed5777ecc6900245c1c4ec8bc2e78ac356548fac145b70c_1280.jpg"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppState appState, ThemeData theme) {
    final isExpert = appState.currentUser?.userType == UserType.expert;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            _handleNavigationTap(index, appState, isExpert);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 0,
          items: isExpert
              ? [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: appState.translate('dashboard'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings),
                    label: appState.translate('settings'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: appState.translate('profile'),
                  ),
                ]
              : [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: appState.translate('home'),
                  ),
                  if (appState.currentUser != null) ...[
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.history_outlined),
                      activeIcon: const Icon(Icons.history),
                      label: appState.translate('session_history'),
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined),
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
                          const Icon(Icons.notifications),
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
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      label: appState.translate('profile'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_outlined),
                      activeIcon: const Icon(Icons.settings),
                      label: appState.translate('settings'),
                    ),
                  ] else
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.login_outlined),
                      activeIcon: const Icon(Icons.login),
                      label: appState.translate('sign_in'),
                    ),
                ],
        ),
      ),
    );
  }

  void _handleNavigationTap(int index, AppState appState, bool isExpert) {
    if (isExpert) {
      // Expert navigation
      switch (index) {
        case 0:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpertNavigation(),
            ),
            (route) => false,
          );
          break;
        case 1:
          // Settings - stay on current page or navigate to expert settings
          break;
        case 2:
          // Profile - navigate to expert profile
          break;
      }
    } else if (appState.currentUser == null) {
      // Guest user navigation - only Home and Sign In/Up
      if (index == 0) {
        // Navigate back to guest home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GuestMainNavigation(),
          ),
          (route) => false,
        );
      } else if (index == 1) {
        // Navigate to auth screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
        );
      }
    } else {
      // Logged-in user navigation (5 tabs: Home, Session History, Notifications, Profile, Settings)
      switch (index) {
        case 0:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(),
            ),
            (route) => false,
          );
          break;
        case 1:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 1),
            ),
            (route) => false,
          );
          break;
        case 2:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 2),
            ),
            (route) => false,
          );
          break;
        case 3:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 3),
            ),
            (route) => false,
          );
          break;
        case 4:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 4),
            ),
            (route) => false,
          );
          break;
      }
    }
  }

  void _handleShareProfile(AppState appState) {
    final shareText = '''
Check out ${widget.expert.name} - ${widget.expert.categoryName}
⭐ ${widget.expert.rating.toStringAsFixed(1)} rating with ${widget.expert.totalReviews} reviews
💰 ${appState.convertAndFormatPrice(widget.expert.pricePerMinute, 'USD')}/min
${widget.expert.isAvailable ? '✅ Available now' : '⏱️ Currently busy'}

${widget.expert.bio}

Download the app to book a consultation!
''';

    Share.share(
      shareText,
      subject: 'Expert Profile - ${widget.expert.name}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.translate('profile_shared_success')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleStartChatCall(BuildContext context, AppState appState) {
    if (appState.currentUser == null) {
      NavigationService.setPendingAction(
        PendingAction(
          type: 'start_chat',
          data: {'expert': widget.expert},
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(expert: widget.expert),
        ),
      );
    }
  }

  void _handleBookAppointment(BuildContext context, AppState appState) {
    if (appState.currentUser == null) {
      NavigationService.setPendingAction(
        PendingAction(
          type: 'book_appointment',
          data: {'expert': widget.expert},
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AppointmentBookingScreen(expert: widget.expert),
        ),
      );
    }
  }

  String _formatReviewDate(DateTime dateTime, AppState appState) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return appState.translate('just_now');
        }
        return '${difference.inMinutes} ${appState.translate('minutes_ago')}';
      }
      return '${difference.inHours} ${appState.translate('hours_ago')}';
    } else if (difference.inDays == 1) {
      return appState.translate('yesterday');
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${appState.translate('days_ago')}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks} ${appState.translate('weeks_ago')}';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months} ${appState.translate('months_ago')}';
    }
  }

  void _showAllReviews(AppState appState, ThemeData theme) {
    final reviews = appState.getExpertReviews(widget.expert.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${appState.translate('all_reviews')} (${reviews.length})',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Reviews List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Column(
                      children: [
                        _buildReviewItem(
                          name: review.clientName,
                          rating: review.rating.toInt(),
                          comment: review.comment ??
                              appState.translate('no_comment_provided'),
                          date: _formatReviewDate(review.createdAt, appState),
                          theme: theme,
                        ),
                        if (index < reviews.length - 1)
                          const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
