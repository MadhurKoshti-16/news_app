import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../provides/settings_provider.dart';
import '../../../news/data/repositories/news_repository_impl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance'),

          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _themeLabel(settings.themeMode),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) notifier.setThemeMode(mode);
              },
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(title: 'Reading'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.text_fields, color: ext.brandPrimary),
                const SizedBox(width: 16),
                const Expanded(child: Text('Font Size')),
                Text(
                  '${settings.fontSize.round()}sp',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: ext.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 22.0,
                    divisions: 10,
                    activeColor: ext.brandPrimary,
                    label: '${settings.fontSize.round()}sp',
                    onChanged: (value) => notifier.setFontSize(value),
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'This is how your article text will look at the selected size.',
              style: theme.textTheme.bodyMedium!.copyWith(
                fontSize: settings.fontSize,
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(title: 'Storage'),

          _SettingsTile(
            icon: Icons.storage_outlined,
            title: 'Clear Cache',
            subtitle: 'Remove all cached articles (bookmarks kept)',
            trailing: TextButton(
              onPressed: () => _showClearCacheDialog(context, ref),
              child: Text(
                'Clear',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(title: 'About'),

          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached articles. '
          'Bookmarks will not be affected. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await ref.read(newsRepositoryProvider).clearCache();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.failure != null
                  ? 'Failed to clear cache'
                  : 'Cache cleared successfully',
            ),
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: ext.brandPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return ListTile(
      leading: Icon(icon, color: ext.brandPrimary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
    );
  }
}
