import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DataScoreIndicator extends StatelessWidget {
  final int score;
  const DataScoreIndicator({super.key, required this.score});

  Color get _color {
    if (score >= 70) return AppColors.riskLow;
    if (score >= 40) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Data Alignment Score', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text('$score/100', style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
