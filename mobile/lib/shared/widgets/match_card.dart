import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../models/match_model.dart';
import 'risk_badge.dart';
import 'data_score_indicator.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd MMM • HH:mm').format(match.matchDate.toLocal());
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(match.league.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            // Teams
            Row(
              children: [
                Expanded(
                  child: Text(match.homeTeam.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('vs', style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(
                  child: Text(match.awayTeam.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DataScoreIndicator(score: match.dataScore),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RiskBadge(riskLevel: match.riskLevel),
                if (match.hasPremiumReport)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_open, size: 12, color: AppColors.accent),
                        SizedBox(width: 4),
                        Text('Premium Analysis', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
