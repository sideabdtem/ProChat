import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/app_state.dart';
import '../services/b2b_service.dart';
import '../models/app_models.dart';
import '../services/category_subcategory_data.dart';
import '../screens/expert_navigation.dart';

class ExpertSettingsPage extends StatefulWidget {
  const ExpertSettingsPage({super.key});

  @override
  State<ExpertSettingsPage> createState() => _ExpertSettingsPageState();
}

class _ExpertSettingsPageState extends State<ExpertSettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Profile form controllers
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _bioArabicController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();

  // Business linking controllers
  final _businessCodeController = TextEditingController();
  final _businessEmailController = TextEditingController();

  // Starting a business controllers
  final _startBusinessNameController = TextEditingController();
  final _startBusinessEmailController = TextEditingController();
  final _startBusinessLeaderController = TextEditingController();
  final _startBusinessBioController = TextEditingController();
  List<String> _selectedBusinessCategories = [];
  List<String> _selectedBusinessSubcategories = [];

  // Business verification status
  VerificationStatus _businessVerificationStatus =
      VerificationStatus.unverified;

  String? _profileImageUrl;
  List<String> _certificationUrls = [];
  List<Map<String, String>> _certificationFiles =
      []; // For storing files/links with descriptions
  ExpertCategory _selectedCategory = ExpertCategory.doctor;
  List<String> _selectedSubcategories = [];
  String _selectedCountry = 'All';
  double _pricePerMinute = 2.50;
  double _pricePerSession = 75.00;

  // Session configurations
  List<SessionConfig> _sessionConfigs = [
    SessionConfig(
      id: 'default',
      name: 'Standard Session',
      durationMinutes: 15,
      price: 75.00,
    ),
  ];

  // Controllers for new session form
  final _newSessionNameController = TextEditingController();
  final _newSessionDurationController = TextEditingController();
  final _newSessionPriceController = TextEditingController();

  // Verification status simulation
  VerificationStatus _verificationStatus = VerificationStatus.unverified;

  // Business linking status
  bool _isLinkedToBusiness = false;
  String? _linkedBusinessName;

  final List<String> _countries = [
    'All',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Spain',
    'Italy',
    'Netherlands',
    'UAE',
    'Saudi Arabia',
    'Qatar',
    'Kuwait',
    'Bahrain',
    'India',
    'Pakistan',
    'Bangladesh',
    'China',
    'Japan',
    'Brazil',
    'Mexico',
    'Argentina'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExpertData();
  }

  void _navigateToNextTab() {
    if (_tabController.index < 2) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _loadExpertData() {
    final appState = context.read<AppState>();
    final currentUser = appState.currentUser;
    final expert = appState.experts.firstWhere(
      (e) => e.id == currentUser?.id,
      orElse: () => appState.experts.first,
    );

    setState(() {
      _nameController.text = expert.name;
      _nameArabicController.text = expert.nameArabic ?? '';
      _emailController.text = expert.email;
      _bioController.text = expert.bio;
      _bioArabicController.text = expert.bioArabic ?? '';
      _profileImageUrl = expert.profileImage;
      _selectedCategory = expert.category;
      _selectedSubcategories = List<String>.from(expert.subcategories);
      _selectedCountry =
          expert.regions.isNotEmpty ? expert.regions.first : 'All';
      _pricePerMinute = expert.pricePerMinute;
      _pricePerSession = expert.pricePerSession;
      _verificationStatus = expert.isVerified
          ? VerificationStatus.verified
          : VerificationStatus.unverified;

      // Initialize session configurations
      if (expert.sessionConfigs.isNotEmpty) {
        _sessionConfigs = List<SessionConfig>.from(expert.sessionConfigs);
      } else {
        _sessionConfigs = [
          SessionConfig(
            id: 'default',
            name: 'Standard Session',
            durationMinutes: 15,
            price: expert.pricePerSession,
          ),
        ];
      }

      // Simulate business linking
      _isLinkedToBusiness = expert.businessID != null;
      _linkedBusinessName = expert.businessName;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _nameArabicController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _bioArabicController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _businessCodeController.dispose();
    _businessEmailController.dispose();
    _startBusinessNameController.dispose();
    _startBusinessEmailController.dispose();
    _startBusinessLeaderController.dispose();
    _startBusinessBioController.dispose();
    _newSessionNameController.dispose();
    _newSessionDurationController.dispose();
    _newSessionPriceController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName(ExpertCategory category) {
    switch (category) {
      case ExpertCategory.doctor:
        return 'Doctor';
      case ExpertCategory.lawyer:
        return 'Lawyer';
      case ExpertCategory.lifeCoach:
        return 'Life Coach';
      case ExpertCategory.businessConsultant:
        return 'Business Consultant';
      case ExpertCategory.therapist:
        return 'Therapist';
      case ExpertCategory.technician:
        return 'Technician';
      case ExpertCategory.religion:
        return 'Religious Advisor';
    }
  }

  Color _getVerificationColor() {
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.underReview:
        return Colors.orange;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.unverified:
        return Colors.grey;
    }
  }

  String _getVerificationText() {
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        return '✅ Verified';
      case VerificationStatus.underReview:
        return '⏳ Under Review';
      case VerificationStatus.rejected:
        return '❌ Rejected – Please resubmit';
      case VerificationStatus.unverified:
        return '❌ Unverified';
    }
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
        return '❌ Business Unverified';
    }
  }

  Future<void> _uploadProfilePhoto() async {
    final appState = context.read<AppState>();
    try {
      final imageUrl =
          await "https://pixabay.com/get/ge21b84027457dfd2f805fe7ad4a26a2cc44115c7654984878f9ef9e7c47947b353d37ab1a81aa76f84bf563bb487fca70350b890630419f3badfaef48d5f9e07_1280.jpg";
      setState(() {
        _profileImageUrl = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(appState.translate('profile_photo_updated_successfully'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${appState.translate('failed_to_upload_photo')}: $e')),
      );
    }
  }

  Future<void> _uploadCertification() async {
    final appState = context.read<AppState>();
    try {
      final imageUrl =
          await "https://pixabay.com/get/gaf09a8bfc26693f4c9fa380b184945fa213d3e666e73f726e6fbf0a0f42ca9b2b1560ab71d879dac2d6975ac6b197af2ab1599916e9a45299adb740b8f9b478d_1280.jpg";
      setState(() {
        _certificationUrls.add(imageUrl);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                appState.translate('certification_uploaded_successfully'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${appState.translate('failed_to_upload_certification')}: $e')),
      );
    }
  }

  void _showAddCertificationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'File';

    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(appState.translate('add_certification_work_sample')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 'File',
                            child: Text(appState.translate('file'))),
                        DropdownMenuItem(
                            value: 'Image',
                            child: Text(appState.translate('image'))),
                        DropdownMenuItem(
                            value: 'Link',
                            child: Text(appState.translate('link'))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appState.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      this.setState(() {
                        _certificationFiles.add({
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'type': selectedType,
                          'url': selectedType == 'Link'
                              ? descriptionController.text
                              : 'https://example.com/${selectedType.toLowerCase()}',
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(appState.translate(
                                'certification_added_successfully'))),
                      );
                    }
                  },
                  child: Text(appState.translate('add')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitForReview() {
    setState(() {
      _verificationStatus = VerificationStatus.underReview;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Profile submitted for admin review. You will be notified once reviewed.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _linkToBusinessByCode(String input) {
    // Extract business code from input
    final appState = context.read<AppState>();
    final b2bService = context.read<B2BService>();

    final businessCode = b2bService.extractBusinessCode(input);

    if (businessCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate('invalid_business_code_link')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find business by code
    final business = b2bService.findBusinessByCode(businessCode);

    if (business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate('business_not_found_check_code')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Link expert to business
    setState(() {
      _isLinkedToBusiness = true;
      _linkedBusinessName = business.name;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${appState.translate('successfully_linked_to')} ${business.name}!'),
        backgroundColor: Colors.green,
      ),
    );

    _businessCodeController.clear();
  }

  void _linkToBusiness(String businessIdentifier, bool isCode) {
    final appState = context.read<AppState>();
    // Simulate business linking
    setState(() {
      _isLinkedToBusiness = true;
      _linkedBusinessName =
          isCode ? 'Demo Business Corp' : 'Partner Company LLC';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${appState.translate('successfully_linked_to')} ${_linkedBusinessName}!'),
        backgroundColor: Colors.green,
      ),
    );

    _businessCodeController.clear();
    _businessEmailController.clear();
  }

  void _unlinkFromBusiness() {
    final appState = context.read<AppState>();
    setState(() {
      _isLinkedToBusiness = false;
      _linkedBusinessName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(appState.translate('successfully_unlinked_from_business')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final appState = context.read<AppState>();
        return AlertDialog(
          title: Text(appState.translate('add_custom_session')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newSessionNameController,
                decoration: const InputDecoration(
                  labelText: 'Session Name',
                  hintText: 'e.g., Quick Consultation',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newSessionDurationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: '15',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Consumer<AppState>(
                builder: (context, appState, child) => TextField(
                  controller: _newSessionPriceController,
                  decoration: InputDecoration(
                    labelText: 'Price (${appState.getCurrencySymbol()})',
                    hintText: '75.00',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appState.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: _addNewSession,
              child: Text(appState.translate('add')),
            ),
          ],
        );
      },
    );
  }

  void _addNewSession() {
    final name = _newSessionNameController.text.trim();
    final duration =
        int.tryParse(_newSessionDurationController.text.trim()) ?? 15;
    final price =
        double.tryParse(_newSessionPriceController.text.trim()) ?? 75.00;

    if (name.isNotEmpty && _sessionConfigs.length < 3) {
      setState(() {
        _sessionConfigs.add(SessionConfig(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          durationMinutes: duration,
          price: price,
        ));
      });

      _newSessionNameController.clear();
      _newSessionDurationController.clear();
      _newSessionPriceController.clear();

      Navigator.pop(context);
    }
  }

  void _removeSession(SessionConfig config) {
    if (_sessionConfigs.length > 1) {
      setState(() {
        _sessionConfigs.removeWhere((s) => s.id == config.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(appState.translate('expert_settings')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
                text: appState.translate('profile'),
                icon: const Icon(Icons.person)),
            Tab(
                text: appState.translate('business'),
                icon: const Icon(Icons.business)),
            Tab(
                text: appState.translate('verification'),
                icon: const Icon(Icons.verified_user)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(theme),
          _buildBusinessTab(theme),
          _buildVerificationTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(appState, theme),
    );
  }

  Widget _buildBottomNavigationBar(AppState appState, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: 3, // Settings tab
          onTap: (index) {
            if (index != 3) {
              // Navigate to expert navigation with selected index
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ExpertNavigation(initialIndex: index),
                ),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.dashboard_outlined, Icons.dashboard, 0),
              label: appState.translate('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.history_outlined, Icons.history, 1),
              label: appState.translate('session_history'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.business_outlined, Icons.business, 2),
              label: appState.translate('business_linking'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings_outlined, Icons.settings, 3),
              label: appState.translate('settings'),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, Icons.person, 4),
              label: appState.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData outlineIcon, IconData filledIcon, int index) {
    final isSelected = 3 == index; // Settings tab is always selected
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Icon(
        isSelected ? filledIcon : outlineIcon,
        size: 24,
      ),
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    final appState = context.read<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _uploadProfilePhoto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Profile Photo',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Basic Information
          _buildSectionTitle('Basic Information', theme),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: 'Full Name (English)',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameArabicController,
            label: 'Full Name (Arabic) - Optional',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            enabled: false, // Email shouldn't be editable
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _bioController,
            label: 'Bio (English)',
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _bioArabicController,
            label: 'Bio (Arabic) - Optional',
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Category
          _buildDropdown<ExpertCategory>(
            label: 'Category',
            value: _selectedCategory,
            items: ExpertCategory.values
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                _selectedSubcategories
                    .clear(); // Clear subcategories when category changes
              });
            },
            icon: Icons.category,
          ),
          const SizedBox(height: 16),

          // Subcategories
          _buildSubcategorySection(theme),
          const SizedBox(height: 16),

          // Country/Region
          _buildDropdown<String>(
            label: 'Country / Region',
            value: _selectedCountry,
            items: _countries
                .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value!;
              });
            },
            icon: Icons.public,
          ),
          const SizedBox(height: 32),

          // Contact & Social
          _buildSectionTitle('Contact & Social Links', theme),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _locationController,
            label: 'Location',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            icon: Icons.web,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _linkedinController,
            label: 'LinkedIn',
            icon: Icons.work,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _twitterController,
            label: 'Twitter',
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _instagramController,
            label: 'Instagram',
            icon: Icons.camera_alt,
          ),
          const SizedBox(height: 32),

          // Pricing
          _buildSectionTitle('Pricing', theme),
          const SizedBox(height: 16),

          // Default session time information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Text(
              'ℹ️ Default session time is 15 minutes. You can customize session durations below if needed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) => _buildTextField(
                    controller:
                        TextEditingController(text: _pricePerMinute.toString()),
                    label:
                        '${appState.translate('price_per_minute')} (${appState.getCurrencySymbol()})',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _pricePerMinute =
                          double.tryParse(value) ?? _pricePerMinute;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) => _buildTextField(
                    controller: TextEditingController(
                        text: _pricePerSession.toString()),
                    label:
                        '${appState.translate('price_per_session')} (${appState.getCurrencySymbol()}) - 15${appState.translate('per_minute')}',
                    icon: Icons.schedule,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _pricePerSession =
                          double.tryParse(value) ?? _pricePerSession;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Session Configurations
          _buildSectionTitle('Session Configurations', theme),
          const SizedBox(height: 16),

          // Session list
          ..._sessionConfigs
              .map((config) => _buildSessionConfigCard(config, theme)),

          // Add new session button (only if less than 3 sessions)
          if (_sessionConfigs.length < 3) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddSessionDialog,
                icon: const Icon(Icons.add),
                label: Text(appState.translate('add_custom_session')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: theme.colorScheme.primary),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(appState.translate('save_profile')),
            ),
          ),
          const SizedBox(height: 16),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _navigateToNextTab,
              icon: const Icon(Icons.arrow_forward),
              label: Text(appState.translate('next_business_info')),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTab(ThemeData theme) {
    final appState = context.read<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getVerificationColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getVerificationColor().withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getVerificationText(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getVerificationColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_verificationStatus == VerificationStatus.rejected) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Please review your information and resubmit your profile for verification.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Certifications
          _buildSectionTitle('Certifications & Work Samples', theme),
          const SizedBox(height: 8),

          // Professional message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Text(
              'Upload any proof of work or credentials related to your profession, including degrees, certificates, business documentation, portfolio samples, website links, or any other relevant professional materials.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Uploaded files list
          if (_certificationFiles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No certifications uploaded yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _certificationFiles.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        file['type'] == 'Image'
                            ? Icons.image
                            : file['type'] == 'Link'
                                ? Icons.link
                                : Icons.insert_drive_file,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['title'] ?? 'Untitled',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (file['description']?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                file['description']!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              file['type'] ?? 'Unknown',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _certificationFiles.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // Upload buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _uploadCertification,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(appState.translate('upload_certificate')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _certificationFiles.length < 10
                        ? _showAddCertificationDialog
                        : null,
                    icon: const Icon(Icons.add),
                    label: Text(appState.translate('add_file_link')),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Counter text
          Text(
            '${_certificationFiles.length}/10 items uploaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Submit for Review Button
          if (_verificationStatus != VerificationStatus.underReview)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submitForReview,
                icon: const Icon(Icons.verified_user),
                label: Text(_verificationStatus == VerificationStatus.rejected
                    ? 'Resubmit for Review'
                    : 'Submit for Admin Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
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
                      'Your profile is currently under review. We\'ll notify you once the review is complete.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessTab(ThemeData theme) {
    final appState = context.read<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Business Linking to this Platform', theme),
          const SizedBox(height: 16),

          if (_isLinkedToBusiness) ...[
            // Already linked
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.green[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linked to Business',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '✅ You are now linked to $_linkedBusinessName',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _unlinkFromBusiness,
                      icon: const Icon(Icons.link_off),
                      label: Text(appState.translate('unlink_from_business')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Not linked - show linking options
            Text(
              'Link your expert profile to a business account to access additional features and manage team bookings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Simple business code input
            _buildTextField(
              controller: _businessCodeController,
              label: 'Enter Business Code or Invite Link (optional)',
              icon: Icons.business,
              hintText:
                  'Enter business code (e.g., TECH123) or full invite link',
            ),
            const SizedBox(height: 8),

            Text(
              'You can enter the business code directly or paste the full invite link here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final input = _businessCodeController.text.trim();

                  if (input.isNotEmpty) {
                    _linkToBusinessByCode(input);
                  } else {
                    // Skip if left blank
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            appState.translate('business_linking_skipped')),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.link),
                label: Text(appState.translate('link_to_business')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Optional info section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.blue[600]),
                  const SizedBox(height: 12),
                  Text(
                    'Business Linking Info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can also navigate to the Business tab in the bottom navigation to join a business team using a code or invite link.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Starting a Business Section
          _buildSectionTitle('Starting a Business', theme),
          const SizedBox(height: 16),

          Text(
            'Create your business profile on our platform and get verified to invite team members.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
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
                  'Business Verification Status',
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
                    'Please review your business information and resubmit for verification.',
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
            label: 'Business Name',
            icon: Icons.business,
            hintText: 'Enter your business name',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _startBusinessEmailController,
            label: 'Business Email',
            icon: Icons.email,
            hintText: 'Enter business email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _startBusinessBioController,
            label: 'Business Bio',
            icon: Icons.description,
            hintText: 'Describe your business and services',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Business Categories
          _buildBusinessCategorySection(theme),
          const SizedBox(height: 16),

          // Business Subcategories
          _buildBusinessSubcategorySection(theme),
          const SizedBox(height: 24),

          // Submit for business verification button
          if (_businessVerificationStatus != VerificationStatus.underReview)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submitBusinessForReview,
                icon: const Icon(Icons.verified_user),
                label: Text(
                    _businessVerificationStatus == VerificationStatus.rejected
                        ? 'Resubmit Business for Review'
                        : 'Submit Business for Verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
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
                      'Your business is currently under review. We\'ll notify you once the review is complete.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _navigateToNextTab,
              icon: const Icon(Icons.arrow_forward),
              label: Text(appState.translate('next_verification')),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSessionConfigCard(SessionConfig config, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<AppState>(
                  builder: (context, appState, child) => Text(
                    '${config.durationMinutes} min • ${appState.convertAndFormatPrice(config.price, 'USD')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (config.id != 'default') // Can't remove default session
            IconButton(
              onPressed: () => _removeSession(config),
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildSubcategorySection(ThemeData theme) {
    final appState = context.watch<AppState>();
    final availableSubcategories = appState.isRTL
        ? CategorySubcategoryData.getSubcategoriesForCategoryArabic(
            _selectedCategory)
        : CategorySubcategoryData.getSubcategoriesForCategory(
            _selectedCategory);

    if (availableSubcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Subcategories (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select specific areas of expertise within your category',
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
              if (_selectedSubcategories.isEmpty)
                Text(
                  'No subcategories selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSubcategories
                      .map((subcategory) => Chip(
                            label: Text(subcategory),
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
                                _selectedSubcategories.remove(subcategory);
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
                  onPressed: () => _showSubcategorySelector(theme),
                  icon: const Icon(Icons.add),
                  label: Text(appState.translate('select_subcategories')),
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

  void _showSubcategorySelector(ThemeData theme) {
    final appState = context.watch<AppState>();
    final availableSubcategories = appState.isRTL
        ? CategorySubcategoryData.getSubcategoriesForCategoryArabic(
            _selectedCategory)
        : CategorySubcategoryData.getSubcategoriesForCategory(
            _selectedCategory);
    final selectedSubcategories = List<String>.from(_selectedSubcategories);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Select Subcategories',
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
                  'Select the subcategories you want to provide services in (Optional):',
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
                        activeColor: theme.colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedSubcategories.length} subcategories selected',
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
              child: Text(appState.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _selectedSubcategories = selectedSubcategories;
                });
                Navigator.of(context).pop();
              },
              child: Text(appState.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCategorySection(ThemeData theme) {
    final appState = context.read<AppState>();
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
              'Business Categories',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select categories that best describe your business',
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
                  'No categories selected',
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
                  onPressed: () =>
                      _showBusinessCategorySelector(theme, availableCategories),
                  icon: const Icon(Icons.add),
                  label: Text(appState.translate('select_categories')),
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

  Widget _buildBusinessSubcategorySection(ThemeData theme) {
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
              'Business Subcategories (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select specific subcategories to further describe your business services',
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
                  'No subcategories selected',
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
                      theme, availableSubcategories),
                  icon: const Icon(Icons.add),
                  label: const Text('Select Subcategories'),
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
      ThemeData theme, List<String> availableCategories) {
    final appState = context.read<AppState>();
    final selectedCategories = List<String>.from(_selectedBusinessCategories);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Select Business Categories',
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
                  'Select the categories that best describe your business:',
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
                  '${selectedCategories.length} categories selected',
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
              child: Text(appState.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _selectedBusinessCategories = selectedCategories;
                });
                Navigator.of(context).pop();
              },
              child: Text(appState.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessSubcategorySelector(
      ThemeData theme, List<String> availableSubcategories) {
    final appState = context.read<AppState>();
    final selectedSubcategories =
        List<String>.from(_selectedBusinessSubcategories);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Select Business Subcategories',
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
                  'Select subcategories for more specific business services:',
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
                  '${selectedSubcategories.length} subcategories selected',
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
              child: Text(appState.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _selectedBusinessSubcategories = selectedSubcategories;
                });
                Navigator.of(context).pop();
              },
              child: Text(appState.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _submitBusinessForReview() {
    final appState = context.read<AppState>();
    if (_startBusinessNameController.text.trim().isEmpty ||
        _startBusinessEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate('fill_required_business_fields')),
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
        content: Text(appState.translate('business_submitted_for_review')),
        backgroundColor: Colors.green,
      ),
    );

    // Simulate admin approval process with a delay
    Future.delayed(const Duration(seconds: 3), () {
      _simulateBusinessApproval();
    });
  }

  void _simulateBusinessApproval() {
    final appState = context.read<AppState>();
    // Simulate admin approval - in real app this would be done by admin
    if (mounted) {
      final businessCode = _generateBusinessCode();
      final inviteLink = 'https://dreamflow.app/join?code=$businessCode';

      setState(() {
        _businessVerificationStatus = VerificationStatus.verified;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${appState.translate('business_verified')} Code: $businessCode'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: appState.translate('copy_link'),
            onPressed: () {
              // Copy invite link to clipboard
              Clipboard.setData(ClipboardData(text: inviteLink));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(appState.translate('invite_link_copied_clipboard')),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  String _generateBusinessCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  void _saveProfile() {
    final appState = context.read<AppState>();
    // In a real app, this would save to a backend
    // For now, we'll just show success message

    // Update default session config price if it exists
    if (_sessionConfigs.isNotEmpty && _sessionConfigs.first.id == 'default') {
      _sessionConfigs[0] = SessionConfig(
        id: 'default',
        name: 'Standard Session',
        durationMinutes: 15,
        price: _pricePerSession,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.translate('profile_pricing_saved_successfully')),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ExpertSettingsScreen extends StatelessWidget {
  const ExpertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpertSettingsPage();
  }
}
