import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/reports_provider.dart';

class UnlockedReportsScreen extends ConsumerWidget {
  const UnlockedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(unlockedReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Unlocked Reports')),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text('No unlocked reports yet', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final r = list[i];
                  final matchId = r.matchId;
                  return GestureDetector(
                    onTap: () => context.go('/report/$matchId'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(Icons.analytics_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text('Data Score: ${r.dataScore}/100', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
