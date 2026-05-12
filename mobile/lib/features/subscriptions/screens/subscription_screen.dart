import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/subscriptions_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(subscriptionPackagesProvider);
    final mySub = ref.watch(mySubscriptionProvider);
    final subscribeState = ref.watch(subscribeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current subscription
            mySub.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (sub) => sub != null && sub['status'] == 'ACTIVE'
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active: ${sub['packageName']}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                              Text('Expires: ${sub['endDate']?.toString().split('T')[0]}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),

            const Text('Choose a Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 4),
            const Text('Unlock unlimited premium analyses with a subscription.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),

            if (subscribeState is AsyncError)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AppColors.riskHigh.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${(subscribeState as AsyncError).error}', style: const TextStyle(color: AppColors.riskHigh, fontSize: 13)),
              ),

            packages.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('$e'),
              data: (list) => Column(
                children: list.map<Widget>((pkg) => _PackageCard(
                  pkg: pkg,
                  isLoading: subscribeState is AsyncLoading,
                  onSelect: pkg['id'] == 'free' ? null : () async {
                    final ok = await ref.read(subscribeProvider.notifier).mockActivate(pkg['id']);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${pkg['name']} activated!'), backgroundColor: AppColors.primary),
                      );
                    }
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Map pkg;
  final bool isLoading;
  final VoidCallback? onSelect;
  const _PackageCard({required this.pkg, required this.isLoading, this.onSelect});

  bool get _isElite => pkg['id'] == 'elite';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isElite ? AppColors.primary.withOpacity(0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isElite ? AppColors.primary : AppColors.divider, width: _isElite ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(pkg['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isElite ? AppColors.primary : AppColors.textPrimary)),
              Text(pkg['price'] == 0 ? 'Free' : '\$${pkg['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 4),
          Text(pkg['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          if (onSelect != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSelect,
                child: Text('Select ${pkg['name']}'),
              ),
            ),
        ],
      ),
    );
  }
}
