import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String riskLevel;
  const RiskBadge({super.key, required this.riskLevel});

  Color get _color => switch (riskLevel.toUpperCase()) {
        'LOW' => AppColors.riskLow,
        'MEDIUM' => AppColors.riskMedium,
        'HIGH' => AppColors.riskHigh,
        _ => AppColors.riskUncertain,
      };

  String get _label => switch (riskLevel.toUpperCase()) {
        'LOW' => 'Low Risk',
        'MEDIUM' => 'Medium Risk',
        'HIGH' => 'High Risk',
        _ => 'Uncertain',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(_label, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
