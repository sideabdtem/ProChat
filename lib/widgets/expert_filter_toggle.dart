import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ExpertFilterToggle extends StatelessWidget {
  const ExpertFilterToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity( 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity( 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            context,
            label: _getLocalizedText('all', appState),
            isSelected: !appState.showOnlineExpertsOnly,
            onTap: () => appState.setOnlineFilter(false),
          ),
          const SizedBox(width: 4),
          _buildToggleOption(
            context,
            label: _getLocalizedText('online_only', appState),
            isSelected: appState.showOnlineExpertsOnly,
            onTap: () => appState.setOnlineFilter(true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity( 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  String _getLocalizedText(String key, AppState appState) {
    final isArabic = appState.settings.language == 'ar';
    final texts = {
      'all': isArabic ? 'الكل' : 'All',
      'online_only': isArabic ? 'متصل فقط' : 'Online Only',
    };
    return texts[key] ?? key;
  }
}