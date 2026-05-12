import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

final subscriptionPackagesProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/subscriptions/packages');
  return res.data as List;
});

final mySubscriptionProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/users/me/subscription');
  return res.data;
});

class SubscribeNotifier extends StateNotifier<AsyncValue<Map?>> {
  final Dio _dio;
  final Ref _ref;
  SubscribeNotifier(this._dio, this._ref) : super(const AsyncData(null));

  Future<bool> mockActivate(String packageId) async {
    state = const AsyncLoading();
    try {
      final res = await _dio.post('/subscriptions/mock-activate', data: {'packageId': packageId});
      state = AsyncData(res.data);
      _ref.invalidate(mySubscriptionProvider);
      return true;
    } on DioException catch (e) {
      state = AsyncError(e.response?.data?['message'] ?? 'Activation failed', StackTrace.current);
      return false;
    }
  }
}

final subscribeProvider = StateNotifierProvider<SubscribeNotifier, AsyncValue<Map?>>((ref) {
  return SubscribeNotifier(ref.watch(dioProvider), ref);
});
