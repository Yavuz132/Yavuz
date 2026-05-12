import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/match_model.dart';

final todayMatchesProvider = FutureProvider.family<List<MatchModel>, String?>((ref, sportSlug) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/matches/today');
  final list = (res.data as List).map((e) => MatchModel.fromJson(e)).toList();
  if (sportSlug != null) return list.where((m) => m.sportSlug == sportSlug).toList();
  return list;
});

final popularMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/matches/popular');
  return (res.data as List).map((e) => MatchModel.fromJson(e)).toList();
});

final matchDetailProvider = FutureProvider.family<MatchModel, int>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/matches/$id');
  return MatchModel.fromJson(res.data);
});

final allMatchesProvider = FutureProvider.family<List<MatchModel>, Map<String, int?>>((ref, filters) async {
  final dio = ref.watch(dioProvider);
  final params = {
    if (filters['sportId'] != null) 'sportId': filters['sportId'].toString(),
    if (filters['leagueId'] != null) 'leagueId': filters['leagueId'].toString(),
  };
  final res = await dio.get('/matches', queryParameters: params);
  return (res.data as List).map((e) => MatchModel.fromJson(e)).toList();
});
