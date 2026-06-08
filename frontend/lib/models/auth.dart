/// Antwort von POST /auth/login bzw. /auth/register.
class AuthSession {
  const AuthSession({required this.accessToken, required this.userId});

  final String accessToken;
  final String userId;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      userId: json['userId'] as String,
    );
  }
}

/// Profil von GET /me.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.preferredLocale,
    required this.kycStatus,
    required this.ratingAvg,
    required this.ratingCount,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String preferredLocale;
  final String kycStatus;
  final double ratingAvg;
  final int ratingCount;

  bool get isKycVerified => kycStatus == 'VERIFIED';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'SENDER',
      preferredLocale: json['preferredLocale'] as String? ?? 'de',
      kycStatus: json['kycStatus'] as String? ?? 'NOT_STARTED',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
    );
  }
}
