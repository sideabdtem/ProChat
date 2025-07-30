import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/translation_service.dart';

class TranslationTestScreen extends StatefulWidget {
  const TranslationTestScreen({super.key});

  @override
  State<TranslationTestScreen> createState() => _TranslationTestScreenState();
}

class _TranslationTestScreenState extends State<TranslationTestScreen> {
  String _currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() {
                _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
                appState.setLanguage(_currentLanguage);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language: ${TranslationService.getLanguageName(_currentLanguage)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentLanguage = 'en';
                              appState.setLanguage(_currentLanguage);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentLanguage == 'en'
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          child: const Text('English'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentLanguage = 'ar';
                              appState.setLanguage(_currentLanguage);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentLanguage == 'ar'
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          child: const Text('العربية'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App General Translations
            _buildTranslationSection(
              theme,
              'App General',
              [
                'app_title',
                'welcome',
                'loading',
                'error',
                'success',
                'cancel',
                'confirm',
                'save',
                'delete',
                'edit',
                'close',
                'back',
                'next',
                'previous',
                'done',
                'skip',
                'retry',
                'refresh',
                'search',
                'filter',
                'sort',
                'clear',
                'apply',
                'reset',
              ],
            ),

            // Authentication Translations
            _buildTranslationSection(
              theme,
              'Authentication',
              [
                'login',
                'signup',
                'sign_in',
                'sign_out',
                'logout',
                'email',
                'password',
                'confirm_password',
                'name',
                'phone',
                'forgot_password',
                'reset_password',
                'create_account',
                'already_have_account',
                'dont_have_account',
                'invalid_email',
                'password_too_short',
                'passwords_dont_match',
                'login_failed',
                'signup_failed',
                'network_error',
              ],
            ),

            // User Types
            _buildTranslationSection(
              theme,
              'User Types',
              [
                'client',
                'expert',
                'business',
                'business_owner',
                'business_team',
              ],
            ),

            // Navigation
            _buildTranslationSection(
              theme,
              'Navigation',
              [
                'home',
                'dashboard',
                'profile',
                'settings',
                'notifications',
                'messages',
                'calls',
                'sessions',
                'appointments',
                'history',
                'session_history',
              ],
            ),

            // Home Screen
            _buildTranslationSection(
              theme,
              'Home Screen',
              [
                'find_experts',
                'popular_categories',
                'recent_experts',
                'trending_experts',
                'view_all',
                'show_all',
                'no_experts_found',
                'search_experts',
                'filter_experts',
                'sort_by',
                'rating',
                'price',
                'availability',
                'verified',
                'online',
                'offline',
              ],
            ),

            // Expert Profile
            _buildTranslationSection(
              theme,
              'Expert Profile',
              [
                'expert_profile',
                'about',
                'experience',
                'qualifications',
                'languages',
                'specialties',
                'reviews',
                'total_reviews',
                'average_rating',
                'session_price',
                'per_minute',
                'per_session',
                'book_session',
                'start_chat',
                'call_expert',
                'video_call',
                'voice_call',
                'send_message',
                'contact_expert',
              ],
            ),

            // Categories
            _buildTranslationSection(
              theme,
              'Categories',
              [
                'categories',
                'all_categories',
                'select_category',
                'subcategories',
                'select_subcategory',
                'doctors',
                'lawyers',
                'life_coaches',
                'business_consultants',
                'therapists',
                'technicians',
                'religion',
                'technology',
                'health',
                'education',
                'creative',
                'legal',
                'finance',
              ],
            ),

            // Session Management
            _buildTranslationSection(
              theme,
              'Session Management',
              [
                'session',
                'sessions',
                'active_session',
                'session_timer',
                'session_duration',
                'session_cost',
                'total_cost',
                'start_session',
                'end_session',
                'join_session',
                'leave_session',
                'session_ended',
                'session_cancelled',
                'session_completed',
                'session_failed',
                'session_timeout',
                'session_loading',
                'session_connecting',
                'session_disconnected',
                'session_reconnecting',
              ],
            ),

            // Chat
            _buildTranslationSection(
              theme,
              'Chat',
              [
                'chat',
                'messages',
                'type_message',
                'send',
                'message_sent',
                'message_failed',
                'typing',
                'online',
                'last_seen',
                'unread_messages',
                'mark_as_read',
                'delete_message',
                'copy_message',
                'forward_message',
              ],
            ),

            // Calls
            _buildTranslationSection(
              theme,
              'Calls',
              [
                'call',
                'calls',
                'incoming_call',
                'outgoing_call',
                'missed_call',
                'call_ended',
                'call_duration',
                'call_quality',
                'mute',
                'unmute',
                'speaker',
                'switch_camera',
                'end_call',
                'answer_call',
                'decline_call',
                'call_busy',
                'call_unavailable',
              ],
            ),

            // Payments
            _buildTranslationSection(
              theme,
              'Payments',
              [
                'payment',
                'payments',
                'payment_method',
                'payment_methods',
                'add_payment_method',
                'remove_payment_method',
                'payment_successful',
                'payment_failed',
                'payment_pending',
                'payment_cancelled',
                'payment_refunded',
                'payment_amount',
                'payment_date',
                'payment_status',
                'payment_history',
                'payment_receipt',
                'payment_invoice',
              ],
            ),

            // Reviews
            _buildTranslationSection(
              theme,
              'Reviews',
              [
                'review',
                'reviews',
                'rate_expert',
                'add_review',
                'edit_review',
                'delete_review',
                'review_submitted',
                'review_error',
                'review_success',
                'review_failed',
                'review_updated',
                'review_deleted',
                'add_comment',
                'share_experience',
                'submit_review',
                'review_helpful',
                'review_not_helpful',
              ],
            ),

            // Time & Duration
            _buildTranslationSection(
              theme,
              'Time & Duration',
              [
                'hours',
                'minutes',
                'seconds',
                'duration',
                'start_time',
                'end_time',
                'remaining_time',
                'elapsed_time',
              ],
            ),

            // Settings
            _buildTranslationSection(
              theme,
              'Settings',
              [
                'language',
                'dark_mode',
                'light_mode',
                'notifications_enabled',
                'sound_enabled',
                'vibration_enabled',
                'auto_play',
                'data_usage',
                'privacy_settings',
                'account_settings',
                'security_settings',
                'about_app',
                'version',
                'terms_of_service',
                'privacy_policy',
                'help_support',
                'contact_us',
                'feedback',
                'rate_app',
                'share_app',
              ],
            ),

            // Expert Dashboard
            _buildTranslationSection(
              theme,
              'Expert Dashboard',
              [
                'expert_dashboard',
                'my_sessions',
                'my_earnings',
                'my_schedule',
                'my_clients',
                'my_reviews',
                'my_availability',
                'my_profile',
                'my_settings',
                'expert_home',
                'expert_network',
                'expert_connections',
                'expert_interactions',
                'expert_recommendations',
              ],
            ),

            // Business Dashboard
            _buildTranslationSection(
              theme,
              'Business Dashboard',
              [
                'business_dashboard',
                'business_home',
                'business_profile',
                'business_settings',
                'business_analytics',
                'business_reports',
                'business_insights',
                'business_strategy',
                'business_growth',
                'business_optimization',
                'business_expansion',
                'business_management',
                'business_operations',
                'business_finance',
                'business_marketing',
                'business_sales',
                'business_customer_service',
                'business_support',
              ],
            ),

            // Admin Dashboard
            _buildTranslationSection(
              theme,
              'Admin Dashboard',
              [
                'admin_dashboard',
                'admin_home',
                'admin_panel',
                'admin_control',
                'admin_management',
                'admin_system',
                'admin_platform',
                'admin_application',
                'admin_service',
                'admin_tools',
                'admin_resources',
                'admin_support',
                'admin_help',
                'admin_guide',
                'admin_documentation',
                'admin_tutorial',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationSection(
    ThemeData theme,
    String sectionTitle,
    List<String> translationKeys,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...translationKeys.map((key) {
              final appState = context.read<AppState>();
              final translation = appState.translate(key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        translation,
                        style: theme.textTheme.bodyMedium,
                        textDirection: appState.isRTL
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
