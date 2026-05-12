import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/risk_badge.dart';
import '../../../shared/widgets/data_score_indicator.dart';
import '../providers/matches_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  final int matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: match.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (m) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text(m.league.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(m.sportSlug.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: Text(m.homeTeam.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                        const Text('VS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        Expanded(child: Text(m.awayTeam.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy • HH:mm').format(m.matchDate.toLocal()),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scores
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistical Overview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 14),
                    DataScoreIndicator(score: m.dataScore),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Risk Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        RiskBadge(riskLevel: m.riskLevel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Last 5 form
              if (m.stats != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Form (Last 5)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 12),
                      _FormRow(label: m.homeTeam.name, form: m.stats!.homeLastFive),
                      const SizedBox(height: 8),
                      _FormRow(label: m.awayTeam.name, form: m.stats!.awayLastFive),
                      const SizedBox(height: 14),
                      _StatRow('Avg Score (Home)', m.stats!.homeAverageScore.toStringAsFixed(1)),
                      _StatRow('Avg Score (Away)', m.stats!.awayAverageScore.toStringAsFixed(1)),
                      _StatRow('Defense Avg (Home)', m.stats!.homeDefenseAverage.toStringAsFixed(1)),
                      _StatRow('Defense Avg (Away)', m.stats!.awayDefenseAverage.toStringAsFixed(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Performance notes
              if (m.stats != null && (m.stats!.homePerformanceNote.isNotEmpty || m.stats!.awayPerformanceNote.isNotEmpty))
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Performance Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 10),
                      if (m.stats!.homePerformanceNote.isNotEmpty)
                        _NoteRow(team: m.homeTeam.name, note: m.stats!.homePerformanceNote),
                      if (m.stats!.awayPerformanceNote.isNotEmpty)
                        _NoteRow(team: m.awayTeam.name, note: m.stats!.awayPerformanceNote),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Premium report CTA
              if (m.hasPremiumReport)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.15), AppColors.accent.withOpacity(0.08)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock, color: AppColors.accent, size: 32),
                      const SizedBox(height: 8),
                      const Text('Premium Analysis Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Unlock the full statistical evaluation including scenario analysis, positive/negative factors, and data confidence level.',
                          textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.analytics_rounded, size: 18),
                          label: const Text('View Premium Analysis'),
                          onPressed: () => context.go('/report/$matchId'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final String form;
  const _FormRow({required this.label, required this.form});

  @override
  Widget build(BuildContext context) {
    final results = form.split(',');
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ...results.map((r) => _FormChip(result: r.trim())),
      ],
    );
  }
}

class _FormChip extends StatelessWidget {
  final String result;
  const _FormChip({required this.result});

  Color get _color => switch (result) {
        'W' => AppColors.riskLow,
        'L' => AppColors.riskHigh,
        _ => AppColors.riskUncertain,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 24, height: 24,
      decoration: BoxDecoration(color: _color.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: _color, width: 1)),
      child: Center(child: Text(result, style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.bold))),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String team;
  final String note;
  const _NoteRow({required this.team, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(team, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(note, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
