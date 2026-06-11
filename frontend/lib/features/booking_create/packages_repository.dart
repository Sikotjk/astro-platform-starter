import 'package:dio/dio.dart';

import '../../models/package.dart';

abstract class PackagesRepository {
  /// Legt ein Paket an und liefert die Package-ID. Wirft bei verbotenem
  /// Inhalt (Backend antwortet mit 422).
  Future<String> create(CreatePackageRequest request);
}

class DioPackagesRepository implements PackagesRepository {
  DioPackagesRepository(this._dio);

  final Dio _dio;

  @override
  Future<String> create(CreatePackageRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/packages',
      data: request.toJson(),
    );
    final pkg = res.data!['package'] as Map<String, dynamic>;
    return pkg['id'] as String;
  }
}
