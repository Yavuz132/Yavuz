import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/risk_badge.dart';
import '../../../shared/widgets/data_score_indicator.dart';
import '../../../shared/models/report_model.dart';
import '../providers/reports_provider.dart';

class PremiumReportScreen extends ConsumerWidget {
  final int matchId;
  const PremiumReportScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportProvider(matchId));
    final unlockState = ref.watch(unlockNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Analysis')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (report) => report.locked
            ? _LockedView(matchId: matchId, report: report, unlockState: unlockState, ref: ref)
            : _UnlockedView(report: report),
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  final int matchId;
  final PremiumReport report;
  final AsyncValue<PremiumReport?> unlockState;
  final WidgetRef ref;

  const _LockedView({required this.matchId, required this.report, required this.unlockState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isLoading = unlockState is AsyncLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Icon(Icons.lock, size: 48, color: AppColors.accent),
                const SizedBox(height: 12),
                Text(report.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                const Text('Unlock this premium analysis to access the full statistical evaluation.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DataScoreIndicator(score: report.dataScore),
                  ],
                ),
                const SizedBox(height: 8),
                RiskBadge(riskLevel: report.riskLevel),
                const SizedBox(height: 24),
                if (unlockState is AsyncError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.riskHigh.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${(unlockState as AsyncError).error}', style: const TextStyle(color: AppColors.riskHigh, fontSize: 13)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.lock_open, size: 18),
                    label: const Text('Unlock with 1 Credit or Subscription'),
                    onPressed: isLoading ? null : () async {
                      final unlocked = await ref.read(unlockNotifierProvider.notifier).unlock(matchId);
                      if (unlocked != null) {
                        ref.invalidate(reportProvider(matchId));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedView extends StatelessWidget {
  final PremiumReport report;
  const _UnlockedView({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(report.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          // Scores row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                DataScoreIndicator(score: report.dataScore),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Risk Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    RiskBadge(riskLevel: report.riskLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Data Confidence', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    _ConfidenceBadge(level: report.confidenceLevel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Summary
          if (report.summary != null) _Section(title: 'Match Summary', child: Text(report.summary!, style: const TextStyle(color: AppColors.textSecondary, height: 1.6))),

          // Positive factors
          if (report.positiveFactors.isNotEmpty)
            _Section(
              title: 'Positive Factors',
              child: Column(
                children: report.positiveFactors.map((f) => _FactorRow(text: f, positive: true)).toList(),
              ),
            ),

          // Negative factors
          if (report.negativeFactors.isNotEmpty)
            _Section(
              title: 'Negative Factors',
              child: Column(
                children: report.negativeFactors.map((f) => _FactorRow(text: f, positive: false)).toList(),
              ),
            ),

          // Scenario
          if (report.scenarioText != null)
            _Section(
              title: 'Match Scenario',
              child: Text(report.scenarioText!, style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontStyle: FontStyle.italic)),
            ),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.disclaimerText.isEmpty ? AppConstants.disclaimer : report.disclaimerText,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  final String text;
  final bool positive;
  const _FactorRow({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.riskLow : AppColors.riskHigh;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(positive ? Icons.check_circle_outline : Icons.cancel_outlined, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String level;
  const _ConfidenceBadge({required this.level});

  Color get _color => switch (level.toUpperCase()) {
        'HIGH' => AppColors.riskLow,
        'MEDIUM' => AppColors.riskMedium,
        _ => AppColors.riskHigh,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Text('$level Confidence', style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
