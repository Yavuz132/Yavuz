import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

final creditHistoryProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/credits/history');
  return res.data as List;
});

final creditPackagesProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/credits/packages');
  return res.data as List;
});

class CreditPurchaseNotifier extends StateNotifier<AsyncValue<Map?>> {
  final Dio _dio;
  final Ref _ref;
  CreditPurchaseNotifier(this._dio, this._ref) : super(const AsyncData(null));

  Future<bool> mockPurchase(String packageId) async {
    state = const AsyncLoading();
    try {
      final res = await _dio.post('/credits/mock-purchase', data: {'packageId': packageId});
      state = AsyncData(res.data);
      _ref.invalidate(creditHistoryProvider);
      return true;
    } on DioException catch (e) {
      state = AsyncError(e.response?.data?['message'] ?? 'Purchase failed', StackTrace.current);
      return false;
    }
  }
}

final creditPurchaseProvider = StateNotifierProvider<CreditPurchaseNotifier, AsyncValue<Map?>>((ref) {
  return CreditPurchaseNotifier(ref.watch(dioProvider), ref);
});
