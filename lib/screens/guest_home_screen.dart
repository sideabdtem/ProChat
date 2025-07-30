import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../screens/category_details_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/chat_screen.dart';
import '../widgets/expert_filter_toggle.dart';
import '../screens/call_screen.dart';

import '../screens/admin_dashboard_page.dart';

class CategoryItem {
  final ExpertCategory category;
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getLocalizedText(String key, AppState appState) {
    final isArabic = appState.settings.language == 'ar';
    final texts = {
      'welcome': isArabic ? 'أهلاً وسهلاً في Chat Pro' : 'Welcome to Chat Pro',
      'find_expert': isArabic ? 'اعثر على خبيرك' : 'Find Your Expert',
      'browse_info': isArabic
          ? 'تصفح الفئات والخبراء دون تسجيل الدخول. سجل دخولك عندما تكون مستعداً للدردشة!'
          : 'Browse categories and experts without signing in. Sign in when you\'re ready to chat!',
      'categories': isArabic ? 'الفئات' : 'Categories',
      'featured_experts': isArabic ? 'الخبراء المميزون' : 'Featured Experts',
      'sign_in': isArabic ? 'تسجيل الدخول' : 'Sign In/Up',
      'experts': isArabic ? 'خبراء' : 'experts',
      'start_chat': isArabic ? 'بدء المحادثة' : 'Start Chat',
      'call_now': isArabic ? 'اتصل الآن' : 'Call Now',
      'sign_in_to_chat': isArabic
          ? 'سجل دخولك لبدء المحادثة مع'
          : 'Sign in to start chatting with',
      'about': isArabic ? 'نبذة' : 'About',
      'languages': isArabic ? 'اللغات' : 'Languages',
      'home': isArabic ? 'الرئيسية' : 'Home',
      'profile': isArabic ? 'الملف الشخصي' : 'Profile',
      'settings': isArabic ? 'الإعدادات' : 'Settings',
      'dark_mode': isArabic ? 'الوضع المظلم' : 'Dark Mode',
      'light_mode': isArabic ? 'الوضع الفاتح' : 'Light Mode',
      'language': isArabic ? 'اللغة' : 'Language',
      'region': isArabic ? 'المنطقة' : 'Regions',
      'all_regions': isArabic ? 'جميع المناطق' : 'All Regions',
      'search': isArabic ? 'بحث' : 'Search',
      'search_experts': isArabic
          ? 'البحث عن الخبراء والفئات والتخصصات...'
          : 'Search experts, categories, specializations...',
      'search_results': isArabic ? 'نتائج البحث' : 'Search Results',
      'no_results': isArabic ? 'لا توجد نتائج' : 'No results found',
      'ai_suggestion': isArabic ? 'اقتراح الذكي الاصطناعي' : 'AI Suggestion',
      'ok': isArabic ? 'موافق' : 'OK',
    };
    return texts[key] ?? key;
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
              theme.colorScheme.primary.withAlpha(25),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildGuestHomeContent(context, appState, theme),
        ),
      ),
    );
  }

  Widget _buildGuestHomeContent(
      BuildContext context, AppState appState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(context, appState, theme),
          const SizedBox(height: 16),

          // Search bar when expanded
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchExpanded ? 60 : 0,
            child: _isSearchExpanded
                ? _buildSearchBar(appState, theme)
                : const SizedBox.shrink(),
          ),
          if (_isSearchExpanded && _searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSearchResults(appState, theme),
          ] else if (_isSearchExpanded &&
              _searchController.text.isNotEmpty &&
              _searchResults.isEmpty &&
              !_isSearching) ...[
            const SizedBox(height: 16),
            _buildNoResults(appState, theme),
          ] else if (!_isSearchExpanded) ...[
            const SizedBox(height: 32),
            // Categories section
            _buildCategoriesSection(context, appState, theme),
            const SizedBox(height: 32),

            // Featured experts section
            _buildFeaturedExpertsSection(context, appState, theme),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  List<CategoryItem> _getCategories() {
    final appState = context.read<AppState>();
    return ExpertCategory.values.map((category) {
      final categoryData = _getCategoryData(category, appState);
      return CategoryItem(
        category: category,
        name: categoryData['name'],
        icon: categoryData['icon'],
        color: categoryData['color'],
      );
    }).toList();
  }

  Map<String, dynamic> _getCategoryData(
      ExpertCategory category, AppState appState) {
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

  Widget _buildHeaderSection(
      BuildContext context, AppState appState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top navigation row with language, regions, and light/dark mode buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Language dropdown
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                              fontSize: 11,
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
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                      size: 14,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                        String displayText = value == 'All' ? 'Regions' : value;
                        return Center(
                          child: Text(
                            displayText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
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
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                      size: 14,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                  fontSize: 11,
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
                                  fontSize: 11,
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
                      size: 14,
                    ),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Welcome text
        Text(
          _getLocalizedText('welcome', appState),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getLocalizedText('browse_info', appState),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, AppState appState, ThemeData theme) {
    final categories = _getCategories();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth > 600 ? 4 : 3; // 4 columns on larger screens, 3 on smaller

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedText('categories', appState),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2, // Rectangular compact design
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryDetailsScreen(category: category.category),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: category.color.withAlpha(51),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: category.color.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        size: 14,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedExpertsSection(
      BuildContext context, AppState appState, ThemeData theme) {
    final featuredExperts = appState.experts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getLocalizedText('featured_experts', appState),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const ExpertFilterToggle(),
          ],
        ),
        const SizedBox(height: 16),
        ...featuredExperts
            .map((expert) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpertProfileScreen(expert: expert),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: expert.profileImage != null
                                ? NetworkImage(expert.profileImage!)
                                : null,
                            child: expert.profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.settings.language == 'ar'
                                      ? (expert.nameArabic ?? expert.name)
                                      : expert.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appState.settings.language == 'ar'
                                      ? expert.categoryNameArabic
                                      : expert.categoryName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                // Show first 2 specializations if available
                                if (expert.subcategories.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: expert.subcategories
                                        .take(2)
                                        .map((specialization) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.3),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          appState.settings.language == 'ar' &&
                                                  expert.subcategoriesArabic !=
                                                      null &&
                                                  expert.subcategoriesArabic!
                                                          .length >
                                                      expert.subcategories
                                                          .indexOf(
                                                              specialization)
                                              ? expert.subcategoriesArabic![
                                                  expert.subcategories
                                                      .indexOf(specialization)]
                                              : specialization,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      expert.rating.toStringAsFixed(1),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Consumer<AppState>(
                                builder: (context, appState, child) => Text(
                                  '${appState.convertAndFormatPrice(expert.pricePerMinute, 'USD')}/min',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Session offerings info
                              _buildSessionOfferings(expert, theme),
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: expert.isAvailable
                                      ? Colors.green
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildSignInCTA(
      BuildContext context, AppState appState, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('find_expert', appState),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedText('sign_in_to_chat', appState),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              _getLocalizedText('sign_in', appState),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
      final categoryData = _getCategoryData(category, appState);
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

    // AI suggestions based on query (simplified for guests)
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

  String _getCategoryName(ExpertCategory category) {
    final appState = context.read<AppState>();
    final isArabic = appState.settings.language == 'ar';

    switch (category) {
      case ExpertCategory.doctor:
        return isArabic ? 'طبيب' : 'Doctor';
      case ExpertCategory.lawyer:
        return isArabic ? 'محامي' : 'Lawyer';
      case ExpertCategory.lifeCoach:
        return isArabic ? 'مدرب حياة' : 'Life Coach';
      case ExpertCategory.businessConsultant:
        return isArabic ? 'استشاري أعمال' : 'Business';
      case ExpertCategory.therapist:
        return isArabic ? 'معالج نفسي' : 'Therapist';
      case ExpertCategory.technician:
        return isArabic ? 'تقني' : 'Technician';
      case ExpertCategory.religion:
        return isArabic ? 'شؤون دينية' : 'Religion';
    }
  }

  IconData _getCategoryIcon(ExpertCategory category) {
    switch (category) {
      case ExpertCategory.doctor:
        return Icons.medical_services_outlined;
      case ExpertCategory.lawyer:
        return Icons.gavel_outlined;
      case ExpertCategory.lifeCoach:
        return Icons.psychology_outlined;
      case ExpertCategory.businessConsultant:
        return Icons.business_outlined;
      case ExpertCategory.therapist:
        return Icons.favorite_outline;
      case ExpertCategory.technician:
        return Icons.build_outlined;
      case ExpertCategory.religion:
        return Icons.church_outlined;
    }
  }

  Color _getCategoryColor(ExpertCategory category) {
    switch (category) {
      case ExpertCategory.doctor:
        return const Color(0xFF2E7D32);
      case ExpertCategory.lawyer:
        return const Color(0xFF1565C0);
      case ExpertCategory.lifeCoach:
        return const Color(0xFF7B1FA2);
      case ExpertCategory.businessConsultant:
        return const Color(0xFFE65100);
      case ExpertCategory.therapist:
        return const Color(0xFFC2185B);
      case ExpertCategory.technician:
        return const Color(0xFF5D4037);
      case ExpertCategory.religion:
        return const Color(0xFF424242);
    }
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result['title']),
            content: Text(result['subtitle']),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_getLocalizedText('ok', appState)),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget _buildSessionOfferings(Expert expert, ThemeData theme) {
    // If expert has custom sessions configured, show the first active session
    if (expert.sessionConfigs.isNotEmpty) {
      final activeConfigs =
          expert.sessionConfigs.where((config) => config.isActive).toList();
      if (activeConfigs.isNotEmpty) {
        final firstSession = activeConfigs.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AppState>(
              builder: (context, appState, child) => Text(
                'Session: ${firstSession.durationMinutes}min / ${appState.convertAndFormatPrice(firstSession.price, 'USD')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ),
          ],
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
  }
}
