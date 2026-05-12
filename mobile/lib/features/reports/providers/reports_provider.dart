import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/report_model.dart';

final reportProvider = FutureProvider.family<PremiumReport, int>((ref, matchId) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/reports/$matchId');
  return PremiumReport.fromJson(res.data);
});

final unlockedReportsProvider = FutureProvider<List<PremiumReport>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/reports/unlocked');
  return (res.data as List).map((e) => PremiumReport.fromJson(e)).toList();
});

class UnlockNotifier extends StateNotifier<AsyncValue<PremiumReport?>> {
  final Dio _dio;
  UnlockNotifier(this._dio) : super(const AsyncData(null));

  Future<PremiumReport?> unlock(int matchId) async {
    state = const AsyncLoading();
    try {
      final res = await _dio.post('/reports/$matchId/unlock');
      final report = PremiumReport.fromJson(res.data);
      state = AsyncData(report);
      return report;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to unlock report';
      state = AsyncError(msg, StackTrace.current);
      return null;
    }
  }
}

final unlockNotifierProvider = StateNotifierProvider<UnlockNotifier, AsyncValue<PremiumReport?>>((ref) {
  return UnlockNotifier(ref.watch(dioProvider));
});
