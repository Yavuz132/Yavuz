import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SettingsSection(title: 'App'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About MatchIQ',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: '1.0.0',
              children: [const Text(AppConstants.disclaimer)],
            ),
          ),
          const Divider(height: 24),
          const _SettingsSection(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Disclaimer',
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Disclaimer'),
                content: const Text(AppConstants.disclaimer, style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
              ),
            ),
          ),
          const Divider(height: 24),
          const _SettingsSection(title: 'Account'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            color: AppColors.riskHigh,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 20),
      title: Text(title, style: TextStyle(color: c)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
