import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/match_card.dart';
import '../providers/matches_provider.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  int? _selectedSportId;
  int? _selectedLeagueId;

  @override
  Widget build(BuildContext context) {
    final filters = {'sportId': _selectedSportId, 'leagueId': _selectedLeagueId};
    final matches = ref.watch(allMatchesProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: matches.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No matches found', style: TextStyle(color: AppColors.textSecondary)))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(allMatchesProvider(filters)),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: list.length,
                  itemBuilder: (_, i) => MatchCard(match: list[i], onTap: () => context.go('/match/${list[i].id}')),
                ),
              ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Matches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('All Sports'),
              onTap: () { setState(() { _selectedSportId = null; _selectedLeagueId = null; }); Navigator.pop(context); },
            ),
            ListTile(
              title: const Text('Football'),
              onTap: () { setState(() { _selectedSportId = 1; _selectedLeagueId = null; }); Navigator.pop(context); },
            ),
            ListTile(
              title: const Text('Basketball'),
              onTap: () { setState(() { _selectedSportId = 2; _selectedLeagueId = null; }); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}
