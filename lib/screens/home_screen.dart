import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/dummy_data.dart';
import '../services/navigation_manager.dart';
import '../models/app_models.dart';
import '../screens/category_details_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/team_page_screen.dart';

import '../widgets/expert_filter_toggle.dart';

class HomeScreen extends StatefulWidget {
  final Function(Expert)? onNavigateToExpert;
  final Function(ExpertCategory)? onNavigateToCategory;
  final Function(Expert)? onNavigateToBooking;
  final Function(Expert)? onNavigateToTeam;
  final Function(Expert)? onNavigateToChat;

  const HomeScreen({
    super.key,
    this.onNavigateToExpert,
    this.onNavigateToCategory,
    this.onNavigateToBooking,
    this.onNavigateToTeam,
    this.onNavigateToChat,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getLocalizedText(String key, AppState appState) {
    return appState.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(appState, theme),
                  Expanded(
                    child: _buildContent(appState, theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentWidget(AppState appState, ThemeData theme) {
    final userAppointments = appState.userAppointments
        .where((apt) => apt.status == AppointmentStatus.scheduled)
        .toList();

    if (userAppointments.isEmpty) return const SizedBox.shrink();

    // Sort appointments by scheduled time
    userAppointments.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _getLocalizedText('upcoming_appointment', appState),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (userAppointments.length > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${userAppointments.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              itemCount: userAppointments.length,
              itemBuilder: (context, index) {
                final appointment = userAppointments[index];
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.title,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${_formatDateTime(appointment.scheduledTime)} • ${appointment.expertName}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (index == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getLocalizedText('next', appState),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCompactAppointmentButton(
                            appState,
                            theme,
                            _getLocalizedText('change', appState),
                            Icons.edit,
                            () =>
                                _handleChangeAppointment(appState, appointment),
                          ),
                          const SizedBox(width: 6),
                          _buildCompactAppointmentButton(
                            appState,
                            theme,
                            _getLocalizedText('cancel', appState),
                            Icons.cancel,
                            () =>
                                _handleCancelAppointment(appState, appointment),
                          ),
                          const SizedBox(width: 6),
                          _buildCompactAppointmentButton(
                            appState,
                            theme,
                            _getLocalizedText('contact', appState),
                            Icons.chat,
                            () => _handleContactExpert(appState, appointment),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (userAppointments.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_left,
                    size: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _getLocalizedText('swipe_to_view_all', appState),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentButton(
    AppState appState,
    ThemeData theme,
    String textKey,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          _getLocalizedText(textKey, appState),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAppointmentButton(
    AppState appState,
    ThemeData theme,
    String textKey,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: theme.colorScheme.primary),
              const SizedBox(width: 2),
              Text(
                _getLocalizedText(textKey, appState),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChangeAppointment(AppState appState, Appointment appointment) {
    final expert = appState.experts.firstWhere(
      (exp) => exp.id == appointment.expertId,
      orElse: () => appState.experts.first,
    );

    if (widget.onNavigateToBooking != null) {
      widget.onNavigateToBooking!(expert);
    } else {
      NavigationManager().navigateToInnerPage(
        context,
        AppointmentBookingScreen(expert: expert),
        routeName: '/booking/${expert.id}',
      );
    }
  }

  void _handleCancelAppointment(AppState appState, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedText('cancel_appointment', appState)),
        content:
            Text(_getLocalizedText('cancel_appointment_confirm', appState)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_getLocalizedText('no', appState)),
          ),
          TextButton(
            onPressed: () {
              appState.cancelAppointment(appointment.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      _getLocalizedText('appointment_cancelled', appState)),
                ),
              );
            },
            child: Text(_getLocalizedText('yes', appState)),
          ),
        ],
      ),
    );
  }

  void _handleContactExpert(AppState appState, Appointment appointment) {
    final expert = appState.experts.firstWhere(
      (exp) => exp.id == appointment.expertId,
      orElse: () => appState.experts.first,
    );

    if (widget.onNavigateToExpert != null) {
      widget.onNavigateToExpert!(expert);
    } else {
      // Use NavigationManager for inner page navigation
      NavigationManager().navigateToInnerPage(
        context,
        ExpertProfileScreen(expert: expert),
        routeName: '/expert-profile/${expert.id}',
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchResults.clear();
        _isSearching = false;
      }
    });
  }

  void _performSearch(String query, AppState appState) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _generateSearchResults(query, appState);
          _isSearching = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> _generateSearchResults(
      String query, AppState appState) {
    List<Map<String, dynamic>> results = [];
    final lowerQuery = query.toLowerCase();

    // Search experts
    for (final expert in appState.experts) {
      if (expert.name.toLowerCase().contains(lowerQuery) ||
          expert.bio.toLowerCase().contains(lowerQuery) ||
          expert.categoryName.toLowerCase().contains(lowerQuery)) {
        results.add({
          'type': 'expert',
          'title': expert.name,
          'subtitle': expert.categoryName,
          'data': expert,
          'icon': Icons.person,
          'color': Colors.blue,
        });
      }
    }

    // Search categories
    for (final category in ExpertCategory.values) {
      final categoryData = _getCategoryData(category);
      if (categoryData['name'].toLowerCase().contains(lowerQuery)) {
        results.add({
          'type': 'category',
          'title': categoryData['name'],
          'subtitle':
              '${appState.getExpertsByCategory(category).length} experts',
          'data': category,
          'icon': categoryData['icon'],
          'color': categoryData['color'],
        });
      }
    }

    // AI suggestions based on query
    if (results.isEmpty ||
        lowerQuery.contains('help') ||
        lowerQuery.contains('problem')) {
      results.add({
        'type': 'ai_suggestion',
        'title': _getLocalizedText('ai_suggestion', appState),
        'subtitle': _getAISuggestion(query, appState),
        'data': null,
        'icon': Icons.psychology,
        'color': Colors.purple,
      });
    }

    return results;
  }

  String _getAISuggestion(String query, AppState appState) {
    final lowerQuery = query.toLowerCase();
    final isArabic = appState.settings.language == 'ar';

    if (lowerQuery.contains('health') ||
        lowerQuery.contains('medical') ||
        lowerQuery.contains('sick')) {
      return isArabic
          ? 'يبدو أنك تحتاج إلى استشارة طبية. جرب فئة الأطباء.'
          : 'It seems you need medical consultation. Try the Doctor category.';
    } else if (lowerQuery.contains('legal') ||
        lowerQuery.contains('law') ||
        lowerQuery.contains('court')) {
      return isArabic
          ? 'تحتاج إلى مساعدة قانونية. تحقق من فئة المحامين.'
          : 'You need legal help. Check out the Lawyer category.';
    } else if (lowerQuery.contains('business') ||
        lowerQuery.contains('startup') ||
        lowerQuery.contains('company')) {
      return isArabic
          ? 'للاستشارات التجارية، جرب فئة استشاريي الأعمال.'
          : 'For business consultation, try Business Consultant category.';
    } else if (lowerQuery.contains('stress') ||
        lowerQuery.contains('anxiety') ||
        lowerQuery.contains('mental')) {
      return isArabic
          ? 'يبدو أنك بحاجة إلى دعم نفسي. جرب فئة المعالجين النفسيين.'
          : 'It seems you need emotional support. Try the Therapist category.';
    } else if (lowerQuery.contains('life') ||
        lowerQuery.contains('goals') ||
        lowerQuery.contains('motivation')) {
      return isArabic
          ? 'لتحسين نمط حياتك، جرب فئة مدربي الحياة.'
          : 'To improve your lifestyle, try Life Coach category.';
    } else {
      return isArabic
          ? 'دعني أساعدك في العثور على الخبير المناسب لك.'
          : 'Let me help you find the right expert for you.';
    }
  }

  Widget _buildHeader(AppState appState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top navigation row with language, regions, and dark mode buttons (clean layout)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Language dropdown
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: appState.settings.language,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          appState.changeLanguage(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Center(
                            child: Text(
                              'English',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Center(
                            child: Text(
                              'العربية',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),

              // Regions dropdown
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: appState.settings.region,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          appState.changeRegion(newValue);
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return ['All', 'UK', 'UAE'].map((String value) {
                          String displayText =
                              value == 'All' ? 'Regions' : value;
                          return Center(
                            child: Text(
                              displayText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList();
                      },
                      items: ['All', 'UK', 'UAE'].map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Center(
                            child: Text(
                              region,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }).toList(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),

              // Dark mode dropdown
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      value: appState.settings.isDarkMode,
                      onChanged: (bool? newValue) {
                        if (newValue != null &&
                            newValue != appState.settings.isDarkMode) {
                          appState.toggleDarkMode();
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: false,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.light_mode,
                                color: theme.colorScheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _getLocalizedText('light_mode', appState),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.dark_mode,
                                color: theme.colorScheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _getLocalizedText('dark_mode', appState),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Header row - User info and profile avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedText('welcome', appState),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.currentUser?.name ?? 'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Only show profile avatar when user is logged in
              if (appState.currentUser != null)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: appState.currentUser?.profileImage != null
                      ? NetworkImage(appState.currentUser!.profileImage!)
                      : null,
                  child: appState.currentUser?.profileImage == null
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 22,
                        )
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAppointmentWidget(appState, theme),

          Text(
            _getLocalizedText('find_expert', appState),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Search toggle moved below title and description
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _toggleSearch,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSearchExpanded ? Icons.close : Icons.search,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getLocalizedText('search', appState),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search bar when expanded
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchExpanded ? 60 : 0,
            child: _isSearchExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSearchBar(appState, theme),
                  )
                : const SizedBox.shrink(),
          ),
          if (_isSearchExpanded && _searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchResults(appState, theme),
            ),
          ] else if (_isSearchExpanded &&
              _searchController.text.isNotEmpty &&
              _searchResults.isEmpty &&
              !_isSearching) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildNoResults(appState, theme),
            ),
          ] else if (!_isSearchExpanded) ...[
            _buildCategoryGrid(appState, theme),
            const SizedBox(height: 24),
            _buildFeaturedExperts(appState, theme),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(AppState appState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedText('categories', appState),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: ExpertCategory.values.length,
            itemBuilder: (context, index) {
              final category = ExpertCategory.values[index];
              return _buildCategoryCard(category, appState, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      ExpertCategory category, AppState appState, ThemeData theme) {
    final categoryData = _getCategoryData(category);

    return GestureDetector(
      onTap: () {
        if (widget.onNavigateToCategory != null) {
          widget.onNavigateToCategory!(category);
        } else {
          NavigationManager().navigateToInnerPage(
            context,
            CategoryDetailsScreen(category: category),
            routeName: '/category/${category.name}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryData['color'].withAlpha(51),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryData['color'].withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: categoryData['color'].withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                categoryData['icon'],
                size: 18,
                color: categoryData['color'],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    categoryData['name'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: categoryData['color'],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${appState.getExpertsByCategory(category).length} ${_getLocalizedText('experts', appState)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(ExpertCategory category) {
    final appState = context.read<AppState>();
    final isArabic = appState.settings.language == 'ar';

    switch (category) {
      case ExpertCategory.doctor:
        return {
          'name': isArabic ? 'طبيب' : 'Doctor',
          'icon': Icons.medical_services_outlined,
          'color': const Color(0xFF2E7D32),
        };
      case ExpertCategory.lawyer:
        return {
          'name': isArabic ? 'محامي' : 'Lawyer',
          'icon': Icons.gavel_outlined,
          'color': const Color(0xFF1565C0),
        };
      case ExpertCategory.lifeCoach:
        return {
          'name': isArabic ? 'مدرب حياة' : 'Life Coach',
          'icon': Icons.psychology_outlined,
          'color': const Color(0xFF7B1FA2),
        };
      case ExpertCategory.businessConsultant:
        return {
          'name': isArabic ? 'استشاري أعمال' : 'Business',
          'icon': Icons.business_outlined,
          'color': const Color(0xFFE65100),
        };
      case ExpertCategory.therapist:
        return {
          'name': isArabic ? 'معالج نفسي' : 'Therapist',
          'icon': Icons.favorite_outline,
          'color': const Color(0xFFC2185B),
        };
      case ExpertCategory.technician:
        return {
          'name': isArabic ? 'تقني' : 'Technician',
          'icon': Icons.build_outlined,
          'color': const Color(0xFF5D4037),
        };
      case ExpertCategory.religion:
        return {
          'name': isArabic ? 'شؤون دينية' : 'Religion',
          'icon': Icons.church_outlined,
          'color': const Color(0xFF424242),
        };
    }
  }

  Widget _buildFeaturedExperts(AppState appState, ThemeData theme) {
    final featuredExperts = appState.experts.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getLocalizedText('featured_experts', appState),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const ExpertFilterToggle(),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredExperts.length,
            itemBuilder: (context, index) {
              final expert = featuredExperts[index];
              return _buildExpertCard(expert, appState, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Expert expert, AppState appState, ThemeData theme) {
    final categoryData = _getCategoryData(expert.category);
    final isBusinessExpert = expert.isBusinessExpert;

    return GestureDetector(
      onTap: () {
        if (isBusinessExpert) {
          if (widget.onNavigateToTeam != null) {
            widget.onNavigateToTeam!(expert);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TeamPageScreen(teamExpert: expert),
              ),
            );
          }
        } else {
          if (widget.onNavigateToExpert != null) {
            widget.onNavigateToExpert!(expert);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExpertProfileScreen(expert: expert),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isBusinessExpert
              ? Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(expert.profileImage ??
                          "https://images.unsplash.com/photo-1608298480907-cf20cf0baf09?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE3NDgwNjd8&ixlib=rb-4.1.0&q=80&w=1080"),
                    ),
                    if (isBusinessExpert)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group,
                            color: theme.colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expert.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isBusinessExpert)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appState.translate('team_label'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.categoryName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: categoryData['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Show subcategories if available
                      if (expert.subcategories.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children:
                              expert.subcategories.take(2).map((subcategory) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryData['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: categoryData['color'].withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                subcategory,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: categoryData['color'],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (expert.subcategories.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '+${expert.subcategories.length - 2} ${appState.translate('more_subcategories')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: categoryData['color'].withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
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
                            expert.rating.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.attach_money,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          Consumer<AppState>(
                            builder: (context, appState, child) => Text(
                              '${appState.convertAndFormatPrice(expert.pricePerMinute, 'USD')}/min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Session offerings info
                          _buildSessionOfferings(expert, theme),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isBusinessExpert
                      ? Icons.expand_more
                      : Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            if (isBusinessExpert && expert.teamMemberIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appState.isRTL
                          ? '${expert.teamMemberIds.length} أعضاء في الفريق'
                          : '${expert.teamMemberIds.length} team members',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      appState.isRTL ? 'انقر لعرض الفريق' : 'Tap to view team',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTeamDetailsDialog(
      Expert businessExpert, AppState appState, ThemeData theme) {
    final allExperts = DummyDataService.getExperts();
    final teamMembers = allExperts
        .where((expert) => businessExpert.teamMemberIds.contains(expert.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.group, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                businessExpert.teamName ?? businessExpert.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (businessExpert.teamDescription != null) ...[
                Text(
                  businessExpert.teamDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                appState.isRTL ? 'أعضاء الفريق:' : 'Team Members:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...teamMembers.map((member) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: member.profileImage != null
                              ? NetworkImage(member.profileImage!)
                              : null,
                          child: member.profileImage == null
                              ? Text(member.name[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                member.categoryName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpertProfileScreen(expert: member),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appState.translate('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ExpertProfileScreen(expert: businessExpert),
                ),
              );
            },
            child: Text(appState.translate('view_profile')),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
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
          Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _performSearch(query, appState),
              decoration: InputDecoration(
                hintText: _getLocalizedText('search_experts', appState),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (_isSearching)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AppState appState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedText('search_results', appState),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            return _buildSearchResultCard(result, appState, theme);
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(
      Map<String, dynamic> result, AppState appState, ThemeData theme) {
    return GestureDetector(
      onTap: () => _handleSearchResultTap(result, appState),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: result['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                result['icon'],
                color: result['color'],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['title'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result['subtitle'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(AppState appState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('no_results', appState),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSearchResultTap(Map<String, dynamic> result, AppState appState) {
    switch (result['type']) {
      case 'expert':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpertProfileScreen(expert: result['data']),
          ),
        );
        break;
      case 'category':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CategoryDetailsScreen(category: result['data']),
          ),
        );
        break;
      case 'ai_suggestion':
        // For now, just show a dialog with the suggestion
        final appState = context.read<AppState>();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result['title']),
            content: Text(result['subtitle']),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appState.translate('ok')),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _handleSignOut(AppState appState) async {
    appState.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }
  }

  Widget _buildSessionOfferings(Expert expert, ThemeData theme) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // If expert has custom sessions configured, show the first active session
        if (expert.sessionConfigs.isNotEmpty) {
          final activeConfigs =
              expert.sessionConfigs.where((config) => config.isActive).toList();
          if (activeConfigs.isNotEmpty) {
            final firstSession = activeConfigs.first;
            return Text(
              'Session: ${firstSession.durationMinutes}min / ${appState.convertAndFormatPrice(firstSession.price, 'USD')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
            );
          }
        }

        // If no custom sessions or not enabled, show "Session: none"
        return Text(
          'Session: none',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        );
      },
    );
  }
}
