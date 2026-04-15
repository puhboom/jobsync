import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/sources/local_storage.dart';
import '../../../data/sources/api_client.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/api_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorage storage;
  final ApiClient _apiClient = ApiClient();

  AuthBloc({required this.storage}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthOAuthCallback>(_onAuthOAuthCallback);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final token = await storage.getToken();
      if (token == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      _apiClient.setAuthToken(token);
      final response = await _apiClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        emit(AuthAuthenticated(user: user));
      } else {
        await storage.clearToken();
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      await storage.clearToken();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _apiClient.get(
        ApiConstants.oauthUrl,
        queryParameters: {'provider': event.provider},
      );

      final authUrl = response.data['authorization_url'] as String?;
      if (authUrl != null && authUrl.isNotEmpty) {
        final uri = Uri.parse(authUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(const AuthError(message: 'Failed to get authorization URL'));
      }
    } catch (e) {
      emit(AuthError(message: 'OAuth error: $e'));
    }
  }

  Future<void> _onAuthOAuthCallback(
    AuthOAuthCallback event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _apiClient.post(
        ApiConstants.oauthCallback,
        data: {
          'code': event.code,
          'provider': event.provider,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        await storage.saveToken(token);
        _apiClient.setAuthToken(token);

        final userResponse = await _apiClient.get(ApiConstants.authMe);
        final user = UserModel.fromJson(userResponse.data);
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Authentication failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {}

    await storage.clearToken();
    _apiClient.clearAuthToken();
    emit(const AuthUnauthenticated());
  }
}
