/// Antwort von POST /kyc/session.
class KycSession {
  const KycSession({required this.clientSecret, required this.sessionId});

  final String clientSecret;
  final String sessionId;

  factory KycSession.fromJson(Map<String, dynamic> json) {
    return KycSession(
      clientSecret: json['clientSecret'] as String,
      sessionId: json['sessionId'] as String,
    );
  }
}
