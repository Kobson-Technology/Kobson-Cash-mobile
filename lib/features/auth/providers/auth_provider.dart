import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiClient _apiClient;

  @override
  AuthState build() {
    _apiClient = ref.watch(apiClientProvider);
    Future.microtask(() => checkAuthStatus());
    return AuthState();
  }

  Future<void> checkAuthStatus() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      state = state.copyWith(isAuthenticated: false);
      return;
    }

    try {
      final res = await _apiClient.get('/api/v1/members/me');
      final user = UserModel(
        id: res['id'] ?? '',
        fullName: '${res['firstName'] ?? ''} ${res['lastName'] ?? ''}'.trim(),
        email: res['email'] ?? '',
        phoneNumber: res['phoneNumber'] ?? '',
        referralCode: res['referralCode'] ?? '',
        hasActiveMembership: res['hasActiveMembership'] == true,
        photo: res['photo'],
      );
      state = state.copyWith(isAuthenticated: true, user: user);
    } catch (_) {
      await TokenStorage.clearTokens();
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _apiClient.post(
        '/api/v1/auth/login',
        body: {'identifier': identifier, 'password': password},
        requiresAuth: false,
      );

      final accessToken = res['accessToken'] as String;
      final refreshToken = res['refreshToken'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await TokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      final user = UserModel.fromJson(userData);

      state = state.copyWith(isLoading: false, isAuthenticated: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String? referralCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _apiClient.post(
        '/api/v1/auth/register',
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'referralCode': referralCode?.trim().isEmpty == true ? null : referralCode?.trim(),
        },
        requiresAuth: false,
      );

      final accessToken = res['accessToken'] as String;
      final refreshToken = res['refreshToken'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await TokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      final user = UserModel.fromJson(userData);

      state = state.copyWith(isLoading: false, isAuthenticated: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(
        '/api/v1/auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        requiresAuth: true,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfilePhoto(String base64Photo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.put(
        '/api/v1/members/me/photo',
        body: {'photo': base64Photo},
      );
      if (state.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: state.user!.copyWith(photo: base64Photo),
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post('/api/v1/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (_) {}
    await TokenStorage.clearTokens();
    state = AuthState();
  }
}


final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
