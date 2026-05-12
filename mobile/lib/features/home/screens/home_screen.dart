import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/match_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matches/providers/matches_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.sports_soccer), text: 'Football'),
            Tab(icon: Icon(Icons.sports_basketball), text: 'Basketball'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MatchListTab(sportSlug: 'football'),
          _MatchListTab(sportSlug: 'basketball'),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _MatchListTab extends ConsumerWidget {
  final String sportSlug;
  const _MatchListTab({required this.sportSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayMatchesProvider(sportSlug));
    final popular = ref.watch(popularMatchesProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(todayMatchesProvider(sportSlug));
        ref.invalidate(popularMatchesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          _SectionHeader(title: "Today's Matches"),
          today.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primary))),
            error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.riskHigh))),
            data: (matches) => matches.isEmpty
                ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No matches today', style: TextStyle(color: AppColors.textSecondary))))
                : Column(
                    children: matches.map((m) => MatchCard(match: m, onTap: () => context.go('/match/${m.id}'))).toList(),
                  ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'High Data Alignment Matches'),
          popular.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => const SizedBox(),
            data: (matches) => Column(
              children: matches
                  .where((m) => m.sportSlug == sportSlug && m.dataScore >= 60)
                  .take(5)
                  .map((m) => MatchCard(match: m, onTap: () => context.go('/match/${m.id}')))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/home'); break;
          case 1: context.go('/matches'); break;
          case 2: context.go('/credits'); break;
          case 3: context.go('/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), activeIcon: Icon(Icons.wallet), label: 'Credits'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
