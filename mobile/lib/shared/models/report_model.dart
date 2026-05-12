class PremiumReport {
  final int id;
  final int matchId;
  final String title;
  final String? summary;
  final int dataScore;
  final String riskLevel;
  final String confidenceLevel;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final String? scenarioText;
  final String disclaimerText;
  final bool locked;

  const PremiumReport({
    required this.id,
    required this.matchId,
    required this.title,
    this.summary,
    required this.dataScore,
    required this.riskLevel,
    required this.confidenceLevel,
    required this.positiveFactors,
    required this.negativeFactors,
    this.scenarioText,
    required this.disclaimerText,
    required this.locked,
  });

  factory PremiumReport.fromJson(Map<String, dynamic> j) => PremiumReport(
        id: j['id'],
        matchId: j['matchId'],
        title: j['title'],
        summary: j['summary'],
        dataScore: j['dataScore'] ?? 0,
        riskLevel: j['riskLevel'] ?? 'UNCERTAIN',
        confidenceLevel: j['confidenceLevel'] ?? 'MEDIUM',
        positiveFactors: (j['positiveFactors'] as List?)?.cast<String>() ?? [],
        negativeFactors: (j['negativeFactors'] as List?)?.cast<String>() ?? [],
        scenarioText: j['scenarioText'],
        disclaimerText: j['disclaimerText'] ?? '',
        locked: j['locked'] ?? true,
      );
}
