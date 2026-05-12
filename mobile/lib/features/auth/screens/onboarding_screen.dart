import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.analytics_rounded, size: 56, color: AppColors.primary),
              const SizedBox(height: 32),
              const Text('Data-Driven\nMatch Insights',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2)),
              const SizedBox(height: 16),
              const Text(
                'Access pre-match statistical evaluations for football and basketball. '
                'Understand data alignment scores, risk levels, and match scenarios.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 40),
              _FeatureItem(icon: Icons.bar_chart, label: 'Data Alignment Score'),
              _FeatureItem(icon: Icons.shield_outlined, label: 'Risk Level Assessment'),
              _FeatureItem(icon: Icons.description_outlined, label: 'Premium Analysis Reports'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign In',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
