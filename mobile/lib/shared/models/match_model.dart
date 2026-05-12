class TeamRef {
  final int id;
  final String name;
  final String? logoUrl;
  const TeamRef({required this.id, required this.name, this.logoUrl});
  factory TeamRef.fromJson(Map<String, dynamic> j) =>
      TeamRef(id: j['id'], name: j['name'], logoUrl: j['logoUrl']);
}

class LeagueRef {
  final int id;
  final String name;
  final String country;
  const LeagueRef({required this.id, required this.name, required this.country});
  factory LeagueRef.fromJson(Map<String, dynamic> j) =>
      LeagueRef(id: j['id'], name: j['name'], country: j['country']);
}

class MatchStat {
  final String homeLastFive;
  final String awayLastFive;
  final double homeAverageScore;
  final double awayAverageScore;
  final double homeDefenseAverage;
  final double awayDefenseAverage;
  final String homePerformanceNote;
  final String awayPerformanceNote;

  const MatchStat({
    required this.homeLastFive,
    required this.awayLastFive,
    required this.homeAverageScore,
    required this.awayAverageScore,
    required this.homeDefenseAverage,
    required this.awayDefenseAverage,
    required this.homePerformanceNote,
    required this.awayPerformanceNote,
  });

  factory MatchStat.fromJson(Map<String, dynamic> j) => MatchStat(
        homeLastFive: j['homeLastFive'] ?? '',
        awayLastFive: j['awayLastFive'] ?? '',
        homeAverageScore: (j['homeAverageScore'] as num).toDouble(),
        awayAverageScore: (j['awayAverageScore'] as num).toDouble(),
        homeDefenseAverage: (j['homeDefenseAverage'] as num).toDouble(),
        awayDefenseAverage: (j['awayDefenseAverage'] as num).toDouble(),
        homePerformanceNote: j['homePerformanceNote'] ?? '',
        awayPerformanceNote: j['awayPerformanceNote'] ?? '',
      );
}

class MatchModel {
  final int id;
  final TeamRef homeTeam;
  final TeamRef awayTeam;
  final LeagueRef league;
  final String sportSlug;
  final DateTime matchDate;
  final String status;
  final int dataScore;
  final int popularityScore;
  final String riskLevel;
  final bool hasPremiumReport;
  final MatchStat? stats;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.sportSlug,
    required this.matchDate,
    required this.status,
    required this.dataScore,
    required this.popularityScore,
    required this.riskLevel,
    required this.hasPremiumReport,
    this.stats,
  });

  factory MatchModel.fromJson(Map<String, dynamic> j) => MatchModel(
        id: j['id'],
        homeTeam: TeamRef.fromJson(j['homeTeam']),
        awayTeam: TeamRef.fromJson(j['awayTeam']),
        league: LeagueRef.fromJson(j['league']),
        sportSlug: j['sport']?['slug'] ?? '',
        matchDate: DateTime.parse(j['matchDate']),
        status: j['status'] ?? 'SCHEDULED',
        dataScore: j['dataScore'] ?? 0,
        popularityScore: j['popularityScore'] ?? 0,
        riskLevel: j['riskLevel'] ?? 'UNCERTAIN',
        hasPremiumReport: j['premiumReport'] != null && j['premiumReport']['isPublished'] == true,
        stats: j['stats'] != null ? MatchStat.fromJson(j['stats']) : null,
      );
}
