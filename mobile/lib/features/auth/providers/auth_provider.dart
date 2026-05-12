import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  const AuthState({this.user, this.isLoading = false, this.error});
  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) =>
      AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  AuthNotifier(this._dio) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      await saveToken(res.data['accessToken']);
      await fetchMe();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.response?.data?['message'] ?? 'Login failed');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dio.post('/auth/register', data: {'name': name, 'email': email, 'password': password});
      await saveToken(res.data['accessToken']);
      await fetchMe();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.response?.data?['message'] ?? 'Registration failed');
      return false;
    }
  }

  Future<void> fetchMe() async {
    try {
      final res = await _dio.get('/auth/me');
      state = state.copyWith(user: UserModel.fromJson(res.data), isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await deleteToken();
    state = const AuthState();
  }

  Future<void> tryRestoreSession() async {
    final token = await getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    await fetchMe();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(dioProvider));
});
