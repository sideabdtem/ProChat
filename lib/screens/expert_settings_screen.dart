import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/category_subcategory_data.dart';
import 'expert_availability_screen.dart';
import 'expert_own_profile_screen.dart';

import 'dart:math' as math;

class ExpertSettings extends StatefulWidget {
  const ExpertSettings({super.key});

  @override
  State<ExpertSettings> createState() => _ExpertSettingsState();
}

class _ExpertSettingsState extends State<ExpertSettings> {
  bool _notificationsEnabled = true;
  bool _videoCallEnabled = true;
  bool _voiceCallEnabled = true;
  bool _scheduleBookingsEnabled = true;
  String _selectedLanguage = 'en';
  List<String> _blockedUsers = [];
  double _hourlyRate = 50.0;
  double _sessionRate = 80.0;

  // New pricing configuration
  bool _customTimeEnabled = false;
  bool _customPriceEnabled = false;
  List<SessionConfig> _sessionConfigs = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final appState = context.read<AppState>();
    setState(() {
      _selectedLanguage = appState.settings.language;

      // Synchronize session configs with availability settings
      final expert = appState.getCurrentExpert();
      final availability = expert?.availability ?? const ExpertAvailability();

      if (_sessionConfigs.isEmpty) {
        // Generate session configs based on allowed durations from availability settings
        _sessionConfigs = availability.allowedDurations.map((duration) {
          final durationMinutes = duration.minutes;
          final basePrice =
              durationMinutes == 30 ? 50.0 : (durationMinutes / 30) * 50.0;

          return SessionConfig(
            id: duration.name,
            name: duration.displayName == '1 hour'
                ? '1 hour Session'
                : '${durationMinutes} min Session',
            durationMinutes: durationMinutes,
            price: basePrice,
          );
        }).toList();

        // If no allowed durations, create default 30-min session
        if (_sessionConfigs.isEmpty) {
          _sessionConfigs = [
            SessionConfig(
              id: '1',
              name: '30 min Session',
              durationMinutes: 30,
              price: 50.0,
            ),
          ];
        }
      }
    });
  }

  void _refreshSessionConfigs() {
    final appState = context.read<AppState>();
    final expert = appState.getCurrentExpert();
    final availability = expert?.availability ?? const ExpertAvailability();

    setState(() {
      // Get existing prices for durations that already exist
      final existingPrices = <int, double>{};
      for (final config in _sessionConfigs) {
        existingPrices[config.durationMinutes] = config.price;
      }

      // Generate new session configs based on current allowed durations
      _sessionConfigs = availability.allowedDurations.map((duration) {
        final durationMinutes = duration.minutes;
        // Preserve existing price if available, otherwise use base price
        final price = existingPrices[durationMinutes] ??
            (durationMinutes == 30 ? 50.0 : (durationMinutes / 30) * 50.0);

        return SessionConfig(
          id: duration.name,
          name: duration.displayName == '1 hour'
              ? '1 hour Session'
              : '${durationMinutes} min Session',
          durationMinutes: durationMinutes,
          price: price,
        );
      }).toList();

      // If no allowed durations, create default 30-min session
      if (_sessionConfigs.isEmpty) {
        _sessionConfigs = [
          SessionConfig(
            id: '1',
            name: '30 min Session',
            durationMinutes: 30,
            price: 50.0,
          ),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isRTL = appState.isRTL;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          appState.translate('settings'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings Section
            _buildSectionHeader(
              appState.translate('general_settings'),
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              theme,
              isRTL,
              children: [
                _buildToggleItem(
                  title: isRTL ? 'الإشعارات' : 'Notifications',
                  subtitle: isRTL
                      ? 'تلقي إشعارات الرسائل والمكالمات'
                      : 'Receive message and call notifications',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  icon: Icons.notifications_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                const Divider(height: 1),
                _buildToggleItem(
                  title: isRTL ? 'الوضع المظلم' : 'Dark Mode',
                  subtitle:
                      isRTL ? 'تغيير مظهر التطبيق' : 'Change app appearance',
                  value: appState.settings.isDarkMode,
                  onChanged: (value) {
                    try {
                      appState.updateSettings(
                        appState.settings.copyWith(isDarkMode: value),
                      );
                    } catch (e) {
                      print('Error updating dark mode: $e');
                    }
                  },
                  icon: Icons.dark_mode_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                const Divider(height: 1),
                _buildLanguageSelector(theme, isRTL, appState),
                const Divider(height: 1),
                _buildRegionSelector(appState, theme, isRTL),
                const Divider(height: 1),
                _buildCurrencySelector(appState, theme, isRTL),
              ],
            ),

            const SizedBox(height: 24),

            // Category & Specialization Section
            _buildSectionHeader(
              isRTL ? 'الفئة والتخصصات' : 'Category & Specializations',
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildCategoryAndSubcategoryCard(theme, isRTL, appState),

            const SizedBox(height: 24),

            // Call Settings Section
            _buildSectionHeader(
              isRTL ? 'إعدادات المكالمات' : 'Call Settings',
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              theme,
              isRTL,
              children: [
                _buildToggleItem(
                  title: isRTL ? 'مكالمات الفيديو' : 'Video Calls',
                  subtitle:
                      isRTL ? 'السماح بمكالمات الفيديو' : 'Allow video calls',
                  value: _videoCallEnabled,
                  onChanged: (value) {
                    setState(() {
                      _videoCallEnabled = value;
                    });
                  },
                  icon: Icons.videocam_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                const Divider(height: 1),
                _buildToggleItem(
                  title: isRTL ? 'المكالمات الصوتية' : 'Voice Calls',
                  subtitle:
                      isRTL ? 'السماح بالمكالمات الصوتية' : 'Allow voice calls',
                  value: _voiceCallEnabled,
                  onChanged: (value) {
                    setState(() {
                      _voiceCallEnabled = value;
                    });
                  },
                  icon: Icons.phone_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pricing Settings Section
            _buildSectionHeader(
              isRTL ? 'إعدادات الأسعار' : 'Pricing Settings',
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              theme,
              isRTL,
              children: [
                _buildToggleItem(
                  title: isRTL ? 'تخصيص الأوقات' : 'Custom Time',
                  subtitle: isRTL
                      ? 'تحديد أوقات الجلسات حسب الرغبة'
                      : 'Set custom session durations',
                  value: _customTimeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _customTimeEnabled = value;
                    });
                  },
                  icon: Icons.schedule_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                const Divider(height: 1),
                _buildToggleItem(
                  title: isRTL ? 'تخصيص الأسعار' : 'Custom Price',
                  subtitle: isRTL
                      ? 'تحديد أسعار الجلسات حسب الرغبة'
                      : 'Set custom session prices',
                  value: _customPriceEnabled,
                  onChanged: (value) {
                    setState(() {
                      _customPriceEnabled = value;
                    });
                  },
                  icon: Icons.attach_money_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                if (!_customTimeEnabled && !_customPriceEnabled) ...[
                  const Divider(height: 1),
                  Consumer<AppState>(
                    builder: (context, appState, child) => _buildRateSelector(
                      title: isRTL ? 'السعر بالدقيقة' : 'Per Minute Rate',
                      value: _hourlyRate,
                      currency: appState.getCurrencySymbol(),
                      onChanged: (value) {
                        setState(() {
                          _hourlyRate = value;
                        });
                      },
                      theme: theme,
                      isRTL: isRTL,
                    ),
                  ),
                  const Divider(height: 1),
                  Consumer<AppState>(
                    builder: (context, appState, child) => _buildRateSelector(
                      title: isRTL ? 'سعر الجلسة' : 'Session Rate',
                      value: _sessionRate,
                      currency: appState.getCurrencySymbol(),
                      onChanged: (value) {
                        setState(() {
                          _sessionRate = value;
                        });
                      },
                      theme: theme,
                      isRTL: isRTL,
                    ),
                  ),
                ],
                const Divider(height: 1),
                _buildToggleItem(
                  title: isRTL ? 'جدولة الحجوزات' : 'Schedule Bookings',
                  subtitle: isRTL
                      ? 'السماح للعملاء بجدولة الحجوزات'
                      : 'Allow clients to schedule bookings',
                  value: _scheduleBookingsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _scheduleBookingsEnabled = value;
                    });
                  },
                  icon: Icons.calendar_today_outlined,
                  theme: theme,
                  isRTL: isRTL,
                ),
                if (_scheduleBookingsEnabled) ...[
                  const Divider(height: 1),
                  _buildActionItem(
                    title: isRTL ? 'إدارة المواعيد' : 'Manage Availability',
                    subtitle: isRTL
                        ? 'تحديد أوقات العمل وجدولة المواعيد'
                        : 'Set working hours and availability schedule',
                    icon: Icons.event_available_outlined,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ExpertAvailabilityScreen(),
                        ),
                      );
                      // Refresh session configs when returning from availability settings
                      _refreshSessionConfigs();
                    },
                    theme: theme,
                    isRTL: isRTL,
                  ),
                ],
              ],
            ),

            // Custom Sessions Section
            if (_customTimeEnabled || _customPriceEnabled) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(
                isRTL ? 'جلسات مخصصة' : 'Custom Sessions',
                theme,
                isRTL,
              ),
              const SizedBox(height: 12),
              _buildSessionConfigsCard(theme, isRTL),
            ],

            const SizedBox(height: 24),

            // Privacy Settings Section
            _buildSectionHeader(
              isRTL ? 'الخصوصية والأمان' : 'Privacy & Security',
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              theme,
              isRTL,
              children: [
                _buildActionItem(
                  title: isRTL ? 'قائمة المحظورين' : 'Block List',
                  subtitle: isRTL
                      ? 'إدارة المستخدمين المحظورين'
                      : 'Manage blocked users',
                  icon: Icons.block_outlined,
                  onTap: () => _showBlockListDialog(context, theme, isRTL),
                  theme: theme,
                  isRTL: isRTL,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(
              appState.translate('account'),
              theme,
              isRTL,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              theme,
              isRTL,
              children: [
                _buildActionItem(
                  title: appState.translate('profile'),
                  subtitle: appState.translate('manage_profile_info'),
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpertOwnProfile(),
                      ),
                    );
                  },
                  theme: theme,
                  isRTL: isRTL,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, bool isRTL) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, bool isRTL,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required ThemeData theme,
    required bool isRTL,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isRTL,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildRateSelector({
    required String title,
    required double value,
    required String currency,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
    required bool isRTL,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.attach_money_outlined,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$currency${value.toStringAsFixed(0)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Container(
        width: 120,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (value > 10) {
                  onChanged(value - 5);
                }
              },
              icon: Icon(
                Icons.remove_circle_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            Text(
              '$currency${value.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () {
                if (value < 200) {
                  onChanged(value + 5);
                }
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildLanguageSelector(
      ThemeData theme, bool isRTL, AppState appState) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language_outlined,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        isRTL ? 'اللغة' : 'Language',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _selectedLanguage == 'en'
            ? (isRTL ? 'الإنجليزية' : 'English')
            : (isRTL ? 'العربية' : 'Arabic'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: Container(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Text('العربية'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedLanguage = value;
            });
            appState.updateSettings(
              appState.settings.copyWith(language: value),
            );
          }
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSessionConfigsCard(ThemeData theme, bool isRTL) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Session configs list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sessionConfigs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final config = _sessionConfigs[index];
              return _buildSessionConfigTile(config, index, theme, isRTL);
            },
          ),

          // Add new session button
          if (_sessionConfigs.length < 3) ...[
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                isRTL ? 'إضافة جلسة جديدة' : 'Add New Session',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              subtitle: Text(
                isRTL
                    ? 'يمكنك إضافة حتى 3 جلسات'
                    : 'You can add up to 3 sessions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              onTap: () => _addNewSessionConfig(theme, isRTL),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionConfigTile(
      SessionConfig config, int index, ThemeData theme, bool isRTL) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.schedule_outlined,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        config.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Consumer<AppState>(
        builder: (context, appState, child) => Text(
          '${config.durationMinutes} ${isRTL ? 'دقيقة' : 'min'} • ${appState.convertAndFormatPrice(config.price, 'USD')}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => _editSessionConfig(config, index, theme, isRTL),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: () => _deleteSessionConfig(index),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _addNewSessionConfig(ThemeData theme, bool isRTL) {
    _showSessionConfigDialog(
      context: context,
      theme: theme,
      isRTL: isRTL,
      isEdit: false,
    );
  }

  void _editSessionConfig(
      SessionConfig config, int index, ThemeData theme, bool isRTL) {
    _showSessionConfigDialog(
      context: context,
      theme: theme,
      isRTL: isRTL,
      isEdit: true,
      config: config,
      index: index,
    );
  }

  void _deleteSessionConfig(int index) {
    setState(() {
      _sessionConfigs.removeAt(index);
    });
  }

  void _showSessionConfigDialog({
    required BuildContext context,
    required ThemeData theme,
    required bool isRTL,
    required bool isEdit,
    SessionConfig? config,
    int? index,
  }) {
    final nameController = TextEditingController(text: config?.name ?? '');
    final durationController =
        TextEditingController(text: config?.durationMinutes.toString() ?? '30');
    final priceController =
        TextEditingController(text: config?.price.toString() ?? '50');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit
              ? (isRTL ? 'تعديل الجلسة' : 'Edit Session')
              : (isRTL ? 'إضافة جلسة جديدة' : 'Add New Session'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: isRTL ? 'اسم الجلسة' : 'Session Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_customTimeEnabled)
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      isRTL ? 'مدة الجلسة (بالدقائق)' : 'Duration (minutes)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (_customTimeEnabled) const SizedBox(height: 16),
            if (_customPriceEnabled)
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isRTL ? 'السعر (\$)' : 'Price (\$)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isRTL ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final duration = int.tryParse(durationController.text) ?? 30;
              final price = double.tryParse(priceController.text) ?? 50.0;

              if (name.isNotEmpty) {
                final newConfig = SessionConfig(
                  id: config?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  durationMinutes: _customTimeEnabled ? duration : 30,
                  price: _customPriceEnabled ? price : _sessionRate,
                );

                setState(() {
                  if (isEdit && index != null) {
                    _sessionConfigs[index] = newConfig;
                  } else {
                    _sessionConfigs.add(newConfig);
                  }
                });

                Navigator.of(context).pop();
              }
            },
            child: Text(isRTL ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showBlockListDialog(BuildContext context, ThemeData theme, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isRTL ? 'قائمة المحظورين' : 'Block List',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: _blockedUsers.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRTL ? 'لا يوجد مستخدمين محظورين' : 'No blocked users',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _blockedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user[0].toUpperCase()),
                      ),
                      title: Text(user),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _blockedUsers.removeAt(index);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isRTL ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionSelector(AppState appState, ThemeData theme, bool isRTL) {
    final currentExpert = appState.getCurrentExpert();
    final availableRegions = appState.getAvailableRegions();

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.public,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        isRTL ? 'المناطق المتاحة' : 'Available Regions',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${currentExpert?.regions.length ?? 0} ${isRTL ? 'من' : 'of'} ${availableRegions.length} ${isRTL ? 'مناطق مختارة' : 'regions selected'}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_drop_down,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: () => _showRegionSelector(context, appState, theme, isRTL),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showRegionSelector(
      BuildContext context, AppState appState, ThemeData theme, bool isRTL) {
    final currentExpert = appState.getCurrentExpert();
    final availableRegions = appState.getAvailableRegions();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isRTL ? 'اختر المناطق النشطة' : 'Select Active Regions',
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
                isRTL
                    ? 'اختر المناطق التي تريد تقديم خدماتك فيها (افتراضي: جميع المناطق):'
                    : 'Select regions where you want to provide services (Default: All Regions):',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              ...availableRegions
                  .map((region) => _buildRegionCandyBarToggle(
                      region, _getRegionFlag(region), appState, theme, isRTL))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isRTL ? 'إغلاق' : 'Done'),
          ),
        ],
      ),
    );
  }

  String _getRegionFlag(String region) {
    switch (region) {
      case 'All':
        return '🌍';
      case 'UAE':
        return '🇦🇪';
      case 'UK':
        return '🇬🇧';
      case 'USA':
        return '🇺🇸';
      case 'Canada':
        return '🇨🇦';
      case 'Australia':
        return '🇦🇺';
      default:
        return '🌍';
    }
  }

  Widget _buildRegionCandyBarToggle(String region, String flag,
      AppState appState, ThemeData theme, bool isRTL) {
    final currentExpert = appState.getCurrentExpert();
    final isSelected = currentExpert?.regions.contains(region) ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (currentExpert != null) {
              appState.toggleExpertRegion(currentExpert.id, region);

              // Show feedback to user with error handling
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isSelected
                        ? '${isRTL ? 'تم الإزالة من منطقة' : 'Removed from'} $region ${isRTL ? '' : 'region'}'
                        : '${isRTL ? 'تم الإضافة إلى منطقة' : 'Added to'} $region ${isRTL ? '' : 'region'}'),
                    duration: const Duration(seconds: 2),
                    backgroundColor:
                        isSelected ? Colors.orange : theme.colorScheme.primary,
                  ),
                );
              } catch (e) {
                // Handle case where Scaffold context is not available
                print('Could not show snackbar: $e');
              }
            }
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.secondary.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isSelected ? null : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    region,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(isSelected),
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: isSelected ? 24 : 2,
                          top: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(
      AppState appState, ThemeData theme, bool isRTL) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.monetization_on_outlined,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        isRTL ? 'العملة' : 'Currency',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        isRTL
            ? '${appState.getCurrencySymbol()} (${appState.getCurrencyName(isArabic: true)})'
            : '${appState.getCurrencySymbol()} (${appState.settings.currency})',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: DropdownButton<String>(
        value: appState.settings.currency,
        underline: Container(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        items: appState
            .getAvailableCurrencies()
            .map(
              (currency) => DropdownMenuItem(
                value: currency,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(appState.getCurrencySymbol(currencyCode: currency)),
                    const SizedBox(width: 8),
                    Text(isRTL
                        ? appState.getCurrencyName(
                            currencyCode: currency, isArabic: true)
                        : currency),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            appState.changeCurrency(value);
          }
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildCategoryAndSubcategoryCard(
      ThemeData theme, bool isRTL, AppState appState) {
    final currentExpert = appState.getCurrentExpert();
    if (currentExpert == null) return const SizedBox();

    return _buildSettingsCard(
      theme,
      isRTL,
      children: [
        _buildActionItem(
          title: isRTL ? 'الفئة الرئيسية' : 'Main Category',
          subtitle: CategorySubcategoryData.getCategoryDisplayName(
              currentExpert.category),
          icon: currentExpert.categoryIcon,
          onTap: () {
            // Category is fixed, show info dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  isRTL ? 'الفئة الرئيسية' : 'Main Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  isRTL
                      ? 'لا يمكن تغيير الفئة الرئيسية بعد إنشاء الحساب. يمكنك اختيار التخصصات الفرعية أدناه.'
                      : 'Main category cannot be changed after account creation. You can select subcategories below.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isRTL ? 'حسناً' : 'OK'),
                  ),
                ],
              ),
            );
          },
          theme: theme,
          isRTL: isRTL,
        ),
        const Divider(height: 1),
        _buildActionItem(
          title: isRTL ? 'التخصصات الفرعية' : 'Subcategories',
          subtitle: currentExpert.subcategories.isEmpty
              ? (isRTL
                  ? 'لم يتم اختيار تخصصات فرعية'
                  : 'No subcategories selected')
              : '${currentExpert.subcategories.length} ${isRTL ? 'تخصصات مختارة' : 'selected'}',
          icon: Icons.category_outlined,
          onTap: () =>
              _showSubcategorySelector(context, appState, theme, isRTL),
          theme: theme,
          isRTL: isRTL,
        ),
      ],
    );
  }

  void _showSubcategorySelector(
      BuildContext context, AppState appState, ThemeData theme, bool isRTL) {
    final currentExpert = appState.getCurrentExpert();
    if (currentExpert == null) return;

    final availableSubcategories =
        CategorySubcategoryData.getSubcategoriesForCategory(
            currentExpert.category);
    final selectedSubcategories =
        List<String>.from(currentExpert.subcategories);
    final parentContext = context; // Store parent context for ScaffoldMessenger

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            isRTL ? 'اختر التخصصات الفرعية' : 'Select Subcategories',
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
                  isRTL
                      ? 'اختر التخصصات الفرعية التي تريد تقديم خدماتك فيها (اختياري):'
                      : 'Select the subcategories you want to provide services in (Optional):',
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
                  '${selectedSubcategories.length} ${isRTL ? 'تخصصات مختارة' : 'subcategories selected'}',
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
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update expert subcategories
                appState.updateExpertSubcategories(
                    currentExpert.id, selectedSubcategories);

                // Show success message using parent context
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL
                          ? 'تم تحديث التخصصات الفرعية بنجاح'
                          : 'Subcategories updated successfully',
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );

                Navigator.of(context).pop();
              },
              child: Text(isRTL ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
