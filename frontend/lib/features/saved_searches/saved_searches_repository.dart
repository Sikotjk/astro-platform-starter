import 'package:dio/dio.dart';

import '../../models/saved_search.dart';

abstract class SavedSearchesRepository {
  Future<List<SavedSearch>> list();

  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  });

  Future<void> remove(String id);
}

class DioSavedSearchesRepository implements SavedSearchesRepository {
  DioSavedSearchesRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<SavedSearch>> list() async {
    final res = await _dio.get<List<dynamic>>('/saved-searches');
    return (res.data ?? const [])
        .map((e) => SavedSearch.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) async {
    final data = <String, dynamic>{};
    if (originAirport != null && originAirport.isNotEmpty) {
      data['originAirport'] = originAirport.toUpperCase();
    }
    if (destinationAirport != null && destinationAirport.isNotEmpty) {
      data['destinationAirport'] = destinationAirport.toUpperCase();
    }
    if (minFreeKg != null) data['minFreeKg'] = minFreeKg;
    final res = await _dio.post<Map<String, dynamic>>(
      '/saved-searches',
      data: data,
    );
    return SavedSearch.fromJson(res.data!);
  }

  @override
  Future<void> remove(String id) async {
    await _dio.delete<void>('/saved-searches/$id');
  }
}
