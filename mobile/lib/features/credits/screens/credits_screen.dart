import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/credits_provider.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final packages = ref.watch(creditPackagesProvider);
    final history = ref.watch(creditHistoryProvider);
    final purchaseState = ref.watch(creditPurchaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Credits')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Your Credit Balance', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('${user?.creditBalance ?? 0}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Text('credits', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Purchase Credits', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            if (purchaseState is AsyncError)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AppColors.riskHigh.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${(purchaseState as AsyncError).error}', style: const TextStyle(color: AppColors.riskHigh, fontSize: 13)),
              ),
            packages.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('$e'),
              data: (list) => Column(
                children: list.map<Widget>((pkg) => _CreditPackageCard(
                  pkg: pkg,
                  isLoading: purchaseState is AsyncLoading,
                  onBuy: () async {
                    final ok = await ref.read(creditPurchaseProvider.notifier).mockPurchase(pkg['id']);
                    if (ok) {
                      ref.read(authProvider.notifier).fetchMe();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${pkg['credits']} credits added!'), backgroundColor: AppColors.primary),
                        );
                      }
                    }
                  },
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            history.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('$e'),
              data: (list) => list.isEmpty
                  ? const Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary))
                  : Column(children: list.map<Widget>((t) => _TransactionRow(t: t)).toList()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditPackageCard extends StatelessWidget {
  final Map pkg;
  final bool isLoading;
  final VoidCallback onBuy;
  const _CreditPackageCard({required this.pkg, required this.isLoading, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.token, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg['label'], style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('\$${pkg['price']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onBuy,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Map t;
  const _TransactionRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final amount = t['amount'] as int;
    final isPositive = amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isPositive ? AppColors.riskLow : AppColors.riskHigh, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(t['description'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Text('${isPositive ? '+' : ''}$amount',
              style: TextStyle(color: isPositive ? AppColors.riskLow : AppColors.riskHigh, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
