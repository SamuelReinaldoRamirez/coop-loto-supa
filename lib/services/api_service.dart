import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  ApiService._(this._dio);

  factory ApiService() {
    final baseUrl = _computeBaseUrl();
    final dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: Duration(milliseconds: 5000)));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          print('[Api] REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) print('[Api] REQUEST DATA: ${options.data}');
        } catch (_) {}
        handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          print('[Api] RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
          print('[Api] RESPONSE DATA: ${response.data}');
        } catch (_) {}
        handler.next(response);
      },
      onError: (DioError e, handler) {
        try {
          print('[Api] ERROR: ${e.message}');
          if (e.response != null) {
            print('[Api] ERROR RESPONSE: ${e.response?.statusCode} ${e.response?.data}');
          }
        } catch (_) {}
        handler.next(e);
      },
    ));

    return ApiService._(dio);
  }

  static String _computeBaseUrl() {
    // Android emulator uses 10.0.2.2 to reach host machine
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<List<dynamic>> fetchGroups() async {
    print('[Api] fetchGroups -> GET /groups');
    final resp = await _dio.get('/groups');
    print('[Api] fetchGroups response status=${resp.statusCode}');
    return resp.data as List<dynamic>;
  }

  Future<List<dynamic>> fetchMembers() async {
    print('[Api] fetchMembers -> GET /members');
    final resp = await _dio.get('/members');
    print('[Api] fetchMembers response status=${resp.statusCode}');
    return resp.data as List<dynamic>;
  }
}