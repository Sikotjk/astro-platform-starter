import 'package:dio/dio.dart';

import '../../models/kyc.dart';

abstract class KycRepository {
  Future<String> status();
  Future<KycSession> startSession();
}

class DioKycRepository implements KycRepository {
  DioKycRepository(this._dio);

  final Dio _dio;

  @override
  Future<String> status() async {
    final res = await _dio.get<Map<String, dynamic>>('/kyc/status');
    return res.data?['status'] as String? ?? 'NOT_STARTED';
  }

  @override
  Future<KycSession> startSession() async {
    final res = await _dio.post<Map<String, dynamic>>('/kyc/session');
    return KycSession.fromJson(res.data!);
  }
}
