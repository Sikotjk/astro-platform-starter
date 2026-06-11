import 'package:dio/dio.dart';

import '../../models/auth.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role,
  });

  Future<UserProfile> me();

  /// Aktualisiert das eigene Profil (PATCH /me). Nur gesetzte Felder werden
  /// übertragen. Liefert das aktualisierte Profil.
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  });

  /// Widerruft das Refresh-Token serverseitig (Logout dieses Geräts).
  Future<void> logout(String refreshToken);
}

class DioAuthRepository implements AuthRepository {
  DioAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(res.data!);
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      },
    );
    return AuthSession.fromJson(res.data!);
  }

  @override
  Future<UserProfile> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/me');
    return UserProfile.fromJson(res.data!);
  }

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (preferredLocale != null) data['preferredLocale'] = preferredLocale;
    final res = await _dio.patch<Map<String, dynamic>>('/me', data: data);
    return UserProfile.fromJson(res.data!);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
