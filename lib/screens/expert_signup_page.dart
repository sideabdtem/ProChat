import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../screens/main_app_screen.dart';

class ExpertSignUpPage extends StatefulWidget {
  const ExpertSignUpPage({super.key});

  @override
  State<ExpertSignUpPage> createState() => _ExpertSignUpPageState();
}

class _ExpertSignUpPageState extends State<ExpertSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _bioArabicController = TextEditingController();
  final _experienceController = TextEditingController();

  ExpertCategory _selectedCategory = ExpertCategory.doctor;
  String _selectedCountry = 'All';
  bool _isLoading = false;

  final List<ExpertCategory> _categories = ExpertCategory.values;
  @override
  void initState() {
    super.initState();
    _bioController.addListener(() {
      setState(() {});
    });
    _bioArabicController.addListener(() {
      setState(() {});
    });
  }

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
    'Sweden',
    'Norway',
    'Denmark',
    'Finland',
    'Switzerland',
    'Austria',
    'Belgium',
    'Portugal',
    'Ireland',
    'UAE',
    'Saudi Arabia',
    'Qatar',
    'Kuwait',
    'Bahrain',
    'Oman',
    'Jordan',
    'Lebanon',
    'Egypt',
    'Morocco',
    'Tunisia',
    'Algeria',
    'Libya',
    'Sudan',
    'Iraq',
    'Yemen',
    'Syria',
    'Palestine',
    'India',
    'Pakistan',
    'Bangladesh',
    'Sri Lanka',
    'Nepal',
    'Bhutan',
    'Maldives',
    'China',
    'Japan',
    'South Korea',
    'Thailand',
    'Malaysia',
    'Singapore',
    'Indonesia',
    'Philippines',
    'Vietnam',
    'Cambodia',
    'Laos',
    'Myanmar',
    'Brunei',
    'Mexico',
    'Brazil',
    'Argentina',
    'Chile',
    'Peru',
    'Colombia',
    'Venezuela',
    'Ecuador',
    'Bolivia',
    'Paraguay',
    'Uruguay',
    'Guyana',
    'Suriname',
    'French Guiana',
    'South Africa',
    'Nigeria',
    'Kenya',
    'Ghana',
    'Tanzania',
    'Uganda',
    'Ethiopia',
    'Zimbabwe',
    'Botswana',
    'Namibia',
    'Zambia',
    'Malawi',
    'Mozambique',
    'Madagascar',
    'Mauritius',
    'Seychelles',
    'Russia',
    'Ukraine',
    'Poland',
    'Romania',
    'Hungary',
    'Czech Republic',
    'Slovakia',
    'Slovenia',
    'Croatia',
    'Serbia',
    'Bosnia and Herzegovina',
    'Montenegro',
    'North Macedonia',
    'Albania',
    'Bulgaria',
    'Greece',
    'Turkey',
    'Cyprus',
    'Malta',
    'Iceland',
    'Luxembourg',
    'Monaco',
    'Liechtenstein',
    'San Marino',
    'Vatican City',
    'Andorra',
    'New Zealand',
    'Fiji',
    'Papua New Guinea',
    'Solomon Islands',
    'Vanuatu',
    'Samoa',
    'Tonga',
    'Tuvalu',
    'Kiribati',
    'Nauru',
    'Palau',
    'Marshall Islands',
    'Micronesia'
  ];

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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new expert profile
      final newExpert = Expert(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        nameArabic: _nameArabicController.text.trim().isNotEmpty
            ? _nameArabicController.text.trim()
            : null,
        email: _emailController.text.trim(),
        profileImage:
            await "https://pixabay.com/get/g84af0af30d70a3f0c70088a2243184f7d38088909c44928fab4ef73d71f9d5e5b2d056598717b05b79d1f2c4282861f8f054064da0b614b1910a9ece3cde0266_1280.jpg",
        bio: _bioController.text.trim(),
        bioArabic: _bioArabicController.text.trim().isNotEmpty
            ? _bioArabicController.text.trim()
            : null,
        category: _selectedCategory,
        subcategories: [],
        languages: ['English'],
        rating: 0.0,
        totalReviews: 0,
        pricePerMinute: 2.50,
        pricePerSession: 75.00,
        isAvailable: true,
        isVerified: false, // Start as unverified
        joinedAt: DateTime.now(),
        regions: [_selectedCountry],
        todaySessionCount: 0,
        todayOnlineMinutes: 0,
        todayEarnings: 0.0,
        avgSessionRating: 0.0,
      );

      // Add to experts list
      appState.addExpert(newExpert);

      // Create AppUser for authentication
      final user = AppUser(
        id: newExpert.id,
        name: newExpert.name,
        email: newExpert.email,
        userType: UserType.expert,
        language: 'en',
        createdAt: DateTime.now(),
      );

      // Save user session
      await AuthService.saveUserSession(user);
      appState.setCurrentUser(user);

      // Navigate to main app screen and let it handle routing to expert dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainAppScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${appState.translate('sign_up_failed')}: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArabicController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _bioArabicController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.95),
              theme.colorScheme.secondary.withOpacity(0.85),
              theme.colorScheme.primaryContainer.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      appState.translate('sign_up_as_expert'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            appState.translate('join_as_expert'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share your expertise and help others while earning money',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Full Name (English)
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name (English)',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Full Name (Arabic) - Optional
                          _buildTextField(
                            controller: _nameArabicController,
                            label: 'Full Name (Arabic) - Optional',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category
                          _buildDropdown<ExpertCategory>(
                            label: 'Choose Category',
                            value: _selectedCategory,
                            items: _categories
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                          _getCategoryDisplayName(category)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                            icon: Icons.category_outlined,
                          ),
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
                            icon: Icons.public_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Years of Experience
                          _buildTextField(
                            controller: _experienceController,
                            label: 'Years of Experience',
                            icon: Icons.work_outline,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your years of experience';
                              }
                              final years = int.tryParse(value);
                              if (years == null || years < 0) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Bio (English)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: _bioController,
                                label: 'Short Bio (English)',
                                icon: Icons.description_outlined,
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a short bio';
                                  }
                                  if (value.length < 20) {
                                    return 'Bio must be at least 20 characters';
                                  }
                                  if (value.length > 100) {
                                    return 'Bio cannot exceed 100 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${_bioController.text.length}/100 characters',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _bioController.text.length < 20
                                        ? Colors.red.shade400
                                        : _bioController.text.length > 100
                                            ? Colors.red.shade400
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Bio (Arabic) - Optional
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: _bioArabicController,
                                label: 'Short Bio (Arabic) - Optional',
                                icon: Icons.description_outlined,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${_bioArabicController.text.length}/100 characters',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      'Create Expert Account',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Terms
                          Text(
                            'By signing up, you agree to our Terms of Service and Privacy Policy. Your account will be reviewed for verification.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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
}
