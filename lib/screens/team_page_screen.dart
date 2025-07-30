import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/dummy_data.dart';
import '../screens/expert_profile_screen.dart';
import '../widgets/navigation_wrapper.dart';


class TeamPageScreen extends StatefulWidget {
  final Expert teamExpert;

  const TeamPageScreen({super.key, required this.teamExpert});

  @override
  State<TeamPageScreen> createState() => _TeamPageScreenState();
}

class _TeamPageScreenState extends State<TeamPageScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
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
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final theme = Theme.of(context);
        final allExperts = DummyDataService.getExperts();
        final teamMembers = allExperts.where((expert) => 
          widget.teamExpert.teamMemberIds.contains(expert.id)).toList();

        return NavigationWrapper(
          child: Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: CustomScrollView(
            slivers: [
              // App Bar with Team Banner
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.teamExpert.teamName ?? widget.teamExpert.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Company logo/banner background
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: widget.teamExpert.profileImage != null
                              ? Image.network(
                                  widget.teamExpert.profileImage!,
                                  fit: BoxFit.cover,
                                  color: Colors.black.withOpacity(0.3),
                                  colorBlendMode: BlendMode.darken,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      'https://pixabay.com/get/g07155b7039b2a87b8a837c20c642f3f22bcb7c304d442a9b6d06f40da5f460a836bd518828ff048a83b5957e258dc43d0fc9959431cce91202f687e73fb67659_1280.png',
                                      fit: BoxFit.cover,
                                      color: Colors.black.withOpacity(0.3),
                                      colorBlendMode: BlendMode.darken,
                                    );
                                  },
                                )
                              : Image.network(
                                  'https://pixabay.com/get/g07155b7039b2a87b8a837c20c642f3f22bcb7c304d442a9b6d06f40da5f460a836bd518828ff048a83b5957e258dc43d0fc9959431cce91202f687e73fb67659_1280.png',
                                  fit: BoxFit.cover,
                                  color: Colors.black.withOpacity(0.3),
                                  colorBlendMode: BlendMode.darken,
                                ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Edit button for business owner (bottom right)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Consumer<AppState>(
                            builder: (context, appState, child) {
                              // Only show edit button if current user is the business owner
                              final currentUser = appState.currentUser;
                              final isBusinessOwner = currentUser != null && 
                                  currentUser.userType == UserType.expert && 
                                  currentUser.id == widget.teamExpert.id;
                              
                              if (!isBusinessOwner) return const SizedBox.shrink();
                              
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _showEditImageDialog(context, theme, appState);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Team Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTeamHeader(theme, appState),
                        _buildTeamLeaderSection(theme, appState),
                        _buildTeamMembersSection(teamMembers, theme, appState),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildTeamHeader(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appState.isRTL ? 'شركة' : 'COMPANY',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          
          // Company Name
          Text(
            widget.teamExpert.teamName ?? widget.teamExpert.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          
          // Category
          Row(
            children: [
              Icon(
                widget.teamExpert.categoryIcon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.teamExpert.categoryName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Company Description
          if (widget.teamExpert.teamDescription != null) ...[
            Text(
              appState.isRTL ? 'نبذة عن الشركة:' : 'About the Company:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.teamExpert.teamDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Rating and Reviews
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.teamExpert.rating.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.teamExpert.totalReviews} ${appState.isRTL ? 'تقييم' : 'reviews'})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (widget.teamExpert.isVerified) ...[
                Icon(
                  Icons.verified,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  appState.isRTL ? 'موثق' : 'Verified',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLeaderSection(ThemeData theme, AppState appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: _buildExpertCard(widget.teamExpert, theme, appState, isLeader: true),
    );
  }

  Widget _buildTeamMembersSection(List<Expert> teamMembers, ThemeData theme, AppState appState) {
    if (teamMembers.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          ...teamMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 150)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildExpertCard(member, theme, appState),
                    ),
                  ),
                );
              },
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Expert expert, ThemeData theme, AppState appState, {bool isLeader = false}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isLeader ? Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => 
                    ExpertProfileScreen(expert: expert),
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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
                        if (isLeader)
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
                                Icons.star,
                                color: theme.colorScheme.onSecondary,
                                size: 16,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: expert.isAvailable ? Colors.green : Colors.grey,
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
                                  expert.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (expert.isVerified) ...[
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
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                expert.categoryName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
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
                                expert.rating.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${expert.totalReviews})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const Spacer(),
                              
                              // Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Consumer<AppState>(
                                    builder: (context, appState, child) => Text(
                                      appState.convertAndFormatPrice(expert.pricePerMinute, 'USD'),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    appState.translate('per_minute'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                
                // Bio snippet
                if (expert.bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expert.bio.length > 100 
                          ? '${expert.bio.substring(0, 100)}...'
                          : expert.bio,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                
                // Action prompt
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appState.isRTL ? 'انقر لعرض الملف الشخصي' : 'Tap to view profile',
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
            ),
          ),
        ),
      ),
    );
  }

  void _showEditImageDialog(BuildContext context, ThemeData theme, AppState appState) {
    final TextEditingController imageUrlController = TextEditingController(
      text: widget.teamExpert.profileImage ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          appState.isRTL ? 'تعديل صورة الشركة' : 'Edit Company Image',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appState.isRTL 
                  ? 'أدخل رابط صورة الشركة الجديدة'
                  : 'Enter the new company image URL',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: appState.isRTL ? 'رابط الصورة' : 'Image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              appState.isRTL ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update the expert's profile image
              final updatedExpert = Expert(
                id: widget.teamExpert.id,
                name: widget.teamExpert.name,
                email: widget.teamExpert.email,
                category: widget.teamExpert.category,
                rating: widget.teamExpert.rating,
                totalReviews: widget.teamExpert.totalReviews,
                pricePerMinute: widget.teamExpert.pricePerMinute,
                pricePerSession: widget.teamExpert.pricePerSession,
                bio: widget.teamExpert.bio,
                isAvailable: widget.teamExpert.isAvailable,
                isVerified: widget.teamExpert.isVerified,
                joinedAt: widget.teamExpert.joinedAt,
                regions: widget.teamExpert.regions,
                profileImage: imageUrlController.text.trim().isEmpty 
                    ? null 
                    : imageUrlController.text.trim(),
                qualifications: widget.teamExpert.qualifications,
                workExperience: widget.teamExpert.workExperience,
                verificationAttachments: widget.teamExpert.verificationAttachments,
                subcategories: widget.teamExpert.subcategories,
                languages: widget.teamExpert.languages,
                teamName: widget.teamExpert.teamName,
                teamDescription: widget.teamExpert.teamDescription,
                teamMemberIds: widget.teamExpert.teamMemberIds,
              );
              
              // Here you would typically update the expert in your backend/database
              // For now, we'll just close the dialog and show a success message
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appState.isRTL 
                        ? 'تم تحديث صورة الشركة بنجاح'
                        : 'Company image updated successfully',
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              
              // Refresh the page
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(appState.isRTL ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
}