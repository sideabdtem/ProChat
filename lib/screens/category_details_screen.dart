import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/dummy_data.dart';
import '../services/category_subcategory_data.dart';
import '../screens/expert_profile_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/expert_navigation.dart';
import '../screens/guest_main_navigation.dart';
import '../widgets/expert_filter_toggle.dart';
import '../widgets/navigation_wrapper.dart';
import '../screens/auth_screen.dart';
import '../screens/team_page_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final ExpertCategory category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? selectedSubcategory;

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

    return NavigationWrapper(
      selectedIndex: 0,
      child: Container(
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildSubcategoriesSection(appState, theme),
                          _buildExpertsSection(appState, theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        appState.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryName(widget.category, appState),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.translate('select_subcategory'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesSection(AppState appState, ThemeData theme) {
    final subcategories = appState.isRTL
        ? CategorySubcategoryData.getSubcategoriesForCategoryArabic(
            widget.category)
        : CategorySubcategoryData.getSubcategoriesForCategory(widget.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.translate('subcategories'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Show all subcategories in a smaller vertical layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              final isSelected = selectedSubcategory == subcategory;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 80)),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? _getCategoryColor(widget.category)
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? _getCategoryColor(widget.category)
                              : _getCategoryColor(widget.category)
                                  .withAlpha(77),
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(widget.category)
                                .withAlpha(isSelected ? 77 : 25),
                            blurRadius: isSelected ? 6 : 3,
                            offset: Offset(0, isSelected ? 2 : 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedSubcategory =
                                  selectedSubcategory == subcategory
                                      ? null
                                      : subcategory;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.surface.withAlpha(51)
                                      : _getCategoryColor(widget.category)
                                          .withAlpha(38),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    _getSubcategoryIcon(index),
                                    size: 16,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : _getCategoryColor(widget.category),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : _getCategoryColor(
                                                widget.category),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ) ??
                                      TextStyle(),
                                  child: Text(
                                    subcategory,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpertsSection(AppState appState, ThemeData theme) {
    List<Expert> experts = appState.getExpertsByCategory(widget.category);

    // Filter by subcategory if selected
    if (selectedSubcategory != null) {
      experts = experts
          .where((expert) => expert.subcategories.contains(selectedSubcategory))
          .toList();
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appState.translate('available_experts'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const ExpertFilterToggle(),
                  ],
                ),
                if (selectedSubcategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedSubcategory = null;
                        });
                      },
                      child: Text(
                        appState.translate('show_all'),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          experts.isEmpty
              ? Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          appState.translate('no_experts_found'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: experts.length,
                  itemBuilder: (context, index) {
                    final expert = experts[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildExpertCard(expert, appState, theme),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Expert expert, AppState appState, ThemeData theme) {
    final isBusinessExpert = expert.isBusinessExpert;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        border: isBusinessExpert
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isBusinessExpert) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TeamPageScreen(teamExpert: expert),
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 400),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = const Offset(0.0, 1.0);
                    var end = Offset.zero;
                    var curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ExpertProfileScreen(expert: expert),
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 400),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = const Offset(0.0, 1.0);
                    var end = Offset.zero;
                    var curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Expert Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          backgroundImage: expert.profileImage != null
                              ? NetworkImage(expert.profileImage!)
                              : null,
                          child: expert.profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        // Team indicator for business experts
                        if (isBusinessExpert)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.business,
                                color: theme.colorScheme.onSecondary,
                                size: 16,
                              ),
                            ),
                          )
                        else
                          // Availability indicator for individual experts
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: expert.isAvailable
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Expert Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  appState.isRTL && expert.nameArabic != null
                                      ? expert.nameArabic!
                                      : expert.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isBusinessExpert)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    appState.isRTL ? 'شركة' : 'COMPANY',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              if (expert.isVerified && !isBusinessExpert) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                expert.categoryIcon,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                appState.isRTL
                                    ? appState.translate(
                                        expert.category.name.toLowerCase())
                                    : expert.categoryName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          // Show first 2 specializations if available
                          if (expert.subcategories.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: (appState.isRTL &&
                                          expert.subcategoriesArabic != null
                                      ? expert.subcategoriesArabic!
                                      : expert.subcategories)
                                  .take(2)
                                  .map((specialization) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    specialization,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 8),

                          // Rating and Reviews
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                expert.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              const Spacer(),

                              // Price and session info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Consumer<AppState>(
                                    builder: (context, appState, child) => Text(
                                      '${appState.convertAndFormatPrice(expert.pricePerMinute, 'USD')}/min',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
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
                        ],
                      ),
                    ),
                  ],
                ),
                if (isBusinessExpert && expert.teamMemberIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appState.isRTL
                              ? 'انقر لعرض فريق الشركة'
                              : 'Tap to view company team',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                                  fontWeight: FontWeight.w600,
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
            child: Text(appState.isRTL ? 'إغلاق' : 'Close'),
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
            child: Text(appState.isRTL ? 'عرض الملف الشخصي' : 'View Profile'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ExpertCategory category, AppState appState) {
    switch (category) {
      case ExpertCategory.doctor:
        return appState.translate('doctors');
      case ExpertCategory.lawyer:
        return appState.translate('lawyers');
      case ExpertCategory.lifeCoach:
        return appState.translate('life_coaches');
      case ExpertCategory.businessConsultant:
        return appState.translate('business_consultants');
      case ExpertCategory.therapist:
        return appState.translate('therapists');
      case ExpertCategory.technician:
        return appState.translate('technicians');
      case ExpertCategory.religion:
        return appState.translate('religion');
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

  IconData _getSubcategoryIcon(int index) {
    // Get category-specific icons
    switch (widget.category) {
      case ExpertCategory.doctor:
        const icons = [
          Icons.medical_services,
          Icons.favorite,
          Icons.child_care,
          Icons.face,
          Icons.accessibility,
        ];
        return icons[index % icons.length];
      case ExpertCategory.lawyer:
        const icons = [
          Icons.business,
          Icons.home,
          Icons.gavel,
          Icons.location_city,
          Icons.flight_takeoff,
        ];
        return icons[index % icons.length];
      case ExpertCategory.therapist:
        const icons = [
          Icons.psychology,
          Icons.favorite,
          Icons.child_friendly,
          Icons.healing,
          Icons.local_pharmacy,
        ];
        return icons[index % icons.length];
      case ExpertCategory.businessConsultant:
        const icons = [
          Icons.trending_up,
          Icons.attach_money,
          Icons.campaign,
          Icons.settings,
          Icons.rocket_launch,
        ];
        return icons[index % icons.length];
      case ExpertCategory.lifeCoach:
        const icons = [
          Icons.work,
          Icons.people,
          Icons.fitness_center,
          Icons.self_improvement,
          Icons.flag,
        ];
        return icons[index % icons.length];
      case ExpertCategory.technician:
        const icons = [
          Icons.support_agent,
          Icons.router,
          Icons.install_desktop,
          Icons.build,
          Icons.settings_system_daydream,
        ];
        return icons[index % icons.length];
      case ExpertCategory.religion:
        const icons = [
          Icons.mosque,
          Icons.church,
          Icons.star,
          Icons.self_improvement,
          Icons.festival,
        ];
        return icons[index % icons.length];
      default:
        const icons = [
          Icons.circle,
          Icons.circle_outlined,
          Icons.radio_button_checked,
          Icons.radio_button_unchecked,
          Icons.lens,
        ];
        return icons[index % icons.length];
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
