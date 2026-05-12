import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscriptions_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final mySub = ref.watch(mySubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(height: 10),
                Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Credit balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.token, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Credit Balance', style: TextStyle(color: AppColors.textSecondary))),
                Text('${user?.creditBalance ?? 0} credits',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Subscription
          mySub.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (sub) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(sub != null && sub['status'] == 'ACTIVE' ? Icons.star : Icons.star_border,
                      color: sub != null && sub['status'] == 'ACTIVE' ? AppColors.accent : AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Subscription', style: const TextStyle(color: AppColors.textSecondary))),
                  Text(sub != null && sub['status'] == 'ACTIVE' ? sub['packageName'] : 'Free',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sub != null && sub['status'] == 'ACTIVE' ? AppColors.accent : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _MenuItem(icon: Icons.lock_open, label: 'Unlocked Reports', onTap: () => context.go('/unlocked-reports')),
          _MenuItem(icon: Icons.token, label: 'Buy Credits', onTap: () => context.go('/credits')),
          _MenuItem(icon: Icons.star, label: 'Subscription Plans', onTap: () => context.go('/subscription')),
          const Divider(height: 32),
          _MenuItem(
            icon: Icons.logout,
            label: 'Sign Out',
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c)),
      trailing: color == null ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
