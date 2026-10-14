
import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService._(this._dio);

  static final ApiService _instance = (() {
    final baseUrl = _computeBaseUrl();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: 5000),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            print(
              '[Api] REQUEST: ${options.method} ${options.uri}',
            );

            if (options.data != null) {
              print('[Api] REQUEST DATA: ${options.data}');
            }

            try {
              final auth = options.headers['Authorization'];
              print('[Api] REQUEST HEADERS: ${options.headers}');
              print('[Api] Authorization: $auth');
            } catch (_) {}
          } catch (_) {}

          handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            print(
              '[Api] RESPONSE: ${response.statusCode} '
              '${response.requestOptions.method} '
              '${response.requestOptions.uri}',
            );

            print('[Api] RESPONSE DATA: ${response.data}');
          } catch (_) {}

          handler.next(response);
        },
        onError: (DioError e, handler) {
          try {
            print('[Api] ERROR: ${e.message}');

            if (e.response != null) {
              print(
                '[Api] ERROR RESPONSE: '
                '${e.response?.statusCode} '
                '${e.response?.data}',
              );
            }
          } catch (_) {}

          handler.next(e);
        },
      ),
    );

    return ApiService._(dio);
  })();

  factory ApiService() => _instance;

  // ---------------------------------------------------------------------------
  // Configuration de l'URL du backend
  // ---------------------------------------------------------------------------

  static String _computeBaseUrl() {
    const bool railwayOrLocal = false;
    // true : Railway
    // false : backend local

    const baseUrl =
        'https://backendcooploto-production.up.railway.app';

    if (railwayOrLocal) {
      print('[Api] Using Railway base URL: $baseUrl');
      return baseUrl;
    } else {
      if (Platform.isAndroid) {
        print(
          '[Api] Using Android emulator base URL: '
          'http://10.0.2.2:8000',
        );

        return 'http://10.0.2.2:8000';
      }

      print(
        '[Api] Using default base URL: http://127.0.0.1:8000',
      );

      return 'http://127.0.0.1:8000';
    }
  }

  // ---------------------------------------------------------------------------
  // Profil utilisateur
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> fetchMe() async {
    print('[Api] fetchMe -> GET /me');

    final resp = await _dio.get('/me');

    print('[Api] fetchMe status=${resp.statusCode}');
    print(resp.data);

    return Map<String, dynamic>.from(resp.data as Map);
  }

  // ---------------------------------------------------------------------------
  // Groupes et membres
  // ---------------------------------------------------------------------------

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

  Future<List<dynamic>> fetchGroupMembers(int groupId) async {
    print(
      '[Api] fetchGroupMembers -> GET /groups/$groupId/members',
    );

    final resp = await _dio.get('/groups/$groupId/members');

    print(
      '[Api] fetchGroupMembers status=${resp.statusCode}',
    );

    final data = resp.data as Map<String, dynamic>;

    return data['members'] as List<dynamic>;
  }

  Future<List<dynamic>> fetchMyGroups() async {
    print('[Api] fetchMyGroups -> GET /my_groups');

    final resp = await _dio.get('/my_groups');

    print('[Api] fetchMyGroups status=${resp.statusCode}');

    final data = resp.data as Map<String, dynamic>;

    return data['groups'] as List<dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Authentification
  // ---------------------------------------------------------------------------

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';

    // Ne pas afficher le token complet dans les logs.
    print('[Api] TOKEN SET');
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');

    print('[Api] TOKEN CLEARED');
  }

  Future<Map<String, dynamic>> login(
    String pseudo,
    String password,
  ) async {
    final resp = await _dio.post(
      '/login',
      data: {
        'pseudo': pseudo,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(resp.data as Map);
  }

  // ---------------------------------------------------------------------------
  // EuroMillions : tirages
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> fetchEuromillionsDraws() async {
    final resp = await _dio.get('/euromillions/draws');

    return resp.data as List<dynamic>;
  }

  /// Supprime un tirage EuroMillions.
  ///
  /// Endpoint : DELETE /euromillions/draws/{drawId}
  ///
  /// Le backend vérifie lui-même que l'utilisateur est super-administrateur.
  /// En cas d'erreur HTTP, le détail renvoyé par FastAPI est propagé à la page.
  Future<void> deleteEuromillionsDraw(int drawId) async {
    print(
      '[Api] deleteEuromillionsDraw '
      '-> DELETE /euromillions/draws/$drawId',
    );

    try {
      final response = await _dio.delete(
        '/euromillions/draws/$drawId',
      );

      print(
        '[Api] deleteEuromillionsDraw '
        'status=${response.statusCode}',
      );

      print(
        '[Api] deleteEuromillionsDraw '
        'response=${response.data}',
      );

      final data = response.data;

      if (data is Map && data['success'] == false) {
        throw Exception(
          data['message']?.toString() ??
              'La suppression du tirage a échoué.',
        );
      }
    } on DioError catch (e) {
      final responseData = e.response?.data;

      String? detail;

      if (responseData is Map) {
        detail = responseData['detail']?.toString();
      }

      if (detail != null && detail.isNotEmpty) {
        throw Exception(detail);
      }

      if (e.response?.statusCode == 403) {
        throw Exception(
          'Accès réservé aux super-administrateurs.',
        );
      }

      if (e.response?.statusCode == 404) {
        throw Exception('Tirage introuvable.');
      }

      if (e.response?.statusCode == 409) {
        throw Exception(
          'Des données liées empêchent la suppression.',
        );
      }

      if (e.response == null) {
        throw Exception(
          'Impossible de contacter le serveur. '
          'Vérifie ta connexion.',
        );
      }

      throw Exception(
        'Erreur HTTP ${e.response?.statusCode}. '
        'La suppression a échoué.',
      );
    }
  }

  Future<Map<String, dynamic>> fetchDrawStats(
    int drawId,
    int nbDraws,
  ) async {
    final resp = await _dio.get(
      '/euromillions/draws/$drawId/stats$nbDraws',
    );

    return Map<String, dynamic>.from(resp.data);
  }

  // ---------------------------------------------------------------------------
  // EuroMillions : collecte
  // ---------------------------------------------------------------------------

  Future<String> collectEuromillions() async {
    final response = await _dio.post(
      '/collect/euromillions/latest',
    );

    final draw = response.data['draw'];
    final message = response.data['message'] as String;

    return '$message\n\n'
        '${draw['draw_date']} : \n'
        '${draw['n1']} - ${draw['n2']} - '
        '${draw['n3']} - ${draw['n4']} - ${draw['n5']}'
        ' + '
        '${draw['e1']} - ${draw['e2']}\n'
        'Jackpot : ${draw['jackpot']} €\n'
        'Gagnants : ${draw['winners']}';
  }

  Future<List<DateTime>> fetchCollectedEuromillionsDates() async {
    final response = await _dio.get(
      '/collect/euromillions/dates',
    );

    final dates = response.data as List;

    return dates.map((date) {
      return DateTime.parse(date as String);
    }).toList();
  }

  Future<String> collectEuromillionsPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _dio.post(
      '/collect/euromillions/period',
      data: {
        'start_date': _formatDateForApi(startDate),
        'end_date': _formatDateForApi(endDate),
      },
    );

    final data = response.data;

    return data['message'] as String;
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // EuroMillions : statistiques
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>>
      fetchCurrentEuromillionsStats() async {
    final response = await _dio.get(
      '/euromillions/stats/current',
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>>
      fetchAllEuromillionsStats() async {
    final response = await _dio.get(
      '/euromillions/stats',
    );

    return response.data as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Grilles des groupes
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> createGroupGrid({
    required int groupId,
    required List<int> numbers,
    required List<int> stars,
    required DateTime drawDate,
  }) async {
    print(
      '[Api] createGroupGrid -> POST /groups/$groupId/grids',
    );

    final response = await _dio.post(
      '/groups/$groupId/grids',
      data: {
        'numbers': numbers,
        'stars': stars,
        'draw_date': _formatDateForApi(drawDate),
      },
    );

    print('[Api] createGroupGrid status=${response.statusCode}');
    print('[Api] createGroupGrid response=${response.data}');

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> fetchGroupGridsNextDraw(
    int groupId,
  ) async {
    print(
      '[Api] fetchGroupGridsNextDraw '
      '-> GET /groups/$groupId/grids/next-draw',
    );

    final response = await _dio.get(
      '/groups/$groupId/grids/next-draw',
    );

    print(
      '[Api] fetchGroupGridsNextDraw '
      'status=${response.statusCode}',
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    final grids = data['grids'];

    if (grids is! List) {
      throw Exception(
        'La réponse du serveur ne contient pas '
        'de liste de grilles valide.',
      );
    }

    print('[Api] fetchGroupGridsNextDraw count=${grids.length}');

    return grids;
  }

  Future<List<dynamic>> fetchGroupGrids(int groupId) async {
    print(
      '[Api] fetchGroupGrids -> GET /groups/$groupId/grids',
    );

    final response = await _dio.get(
      '/groups/$groupId/grids',
    );

    print('[Api] fetchGroupGrids status=${response.statusCode}');

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    final grids = data['grids'];

    if (grids is! List) {
      throw Exception(
        'La réponse du serveur ne contient pas '
        'de liste de grilles valide.',
      );
    }

    print('[Api] fetchGroupGrids count=${grids.length}');

    return grids;
  }
}


// import 'dart:io';

// import 'package:dio/dio.dart';

// class ApiService {
//   final Dio _dio;
//   ApiService._(this._dio);

//   static final ApiService _instance = (() {
//     final baseUrl = _computeBaseUrl();
//     final dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: Duration(milliseconds: 5000)));

//     dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) {
//         try {
//           print('[Api] REQUEST: ${options.method} ${options.uri}');
//           if (options.data != null) print('[Api] REQUEST DATA: ${options.data}');
//           try {
//             final auth = options.headers['Authorization'];
//             print('[Api] REQUEST HEADERS: ${options.headers}');
//             print('[Api] Authorization: ${auth}');
//           } catch (_) {}
//         } catch (_) {}
//         handler.next(options);
//       },
//       onResponse: (response, handler) {
//         try {
//           print('[Api] RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
//           print('[Api] RESPONSE DATA: ${response.data}');
//         } catch (_) {}
//         handler.next(response);
//       },
//       onError: (DioError e, handler) {
//         try {
//           print('[Api] ERROR: ${e.message}');
//           if (e.response != null) {
//             print('[Api] ERROR RESPONSE: ${e.response?.statusCode} ${e.response?.data}');
//           }
//         } catch (_) {}
//         handler.next(e);
//       },
//     ));

//     return ApiService._(dio);
//   })();

//   factory ApiService() => _instance;


//   static String _computeBaseUrl() {
//     const bool railwayOrLocal = false; //true for railway, false for local
//     const baseUrl = 'https://backendcooploto-production.up.railway.app';
//     if(railwayOrLocal){
//       print('[Api] Using Railway base URL: $baseUrl');
//       return baseUrl;
//     }else{
//       if (Platform.isAndroid) {
//         print('[Api] Using Android emulator base URL: http://10.0.2.2:8000');
//         return 'http://10.0.2.2:8000';
//       }
//       print('[Api] Using default base URL: http://127.0.0.1:8000');
//       return 'http://127.0.0.1:8000';
//     }
//   }

//   // static String _computeBaseUrl() {
//   //   // Android emulator uses 10.0.2.2 to reach host machine
//   //   if (Platform.isAndroid) {
//   //     print('[Api] Using Android emulator base URL: http://10.0.2.2:8000');
//   //     return 'http://10.0.2.2:8000';
//   //   }
//   //   print('[Api] Using default base URL: http://127.0.0.1:8000');
//   //   return 'http://127.0.0.1:8000';
//   // }

//   Future<Map<String, dynamic>> fetchMe() async {
//   print('[Api] fetchMe -> GET /me');

//   final resp = await _dio.get('/me');

//   print('[Api] fetchMe status=${resp.statusCode}');
//   print(resp.data);
//   return Map<String, dynamic>.from(resp.data as Map);
// }

//   Future<List<dynamic>> fetchGroups() async {
//     print('[Api] fetchGroups -> GET /groups');
//     final resp = await _dio.get('/groups');
//     print('[Api] fetchGroups response status=${resp.statusCode}');
//     return resp.data as List<dynamic>;
//   }

//   Future<List<dynamic>> fetchMembers() async {
//     print('[Api] fetchMembers -> GET /members');
//     final resp = await _dio.get('/members');
//     print('[Api] fetchMembers response status=${resp.statusCode}');
//     return resp.data as List<dynamic>;
//   }

//   Future<List<dynamic>> fetchGroupMembers(int groupId) async {
//     print('[Api] fetchGroupMembers -> GET /groups/$groupId/members');

//     final resp = await _dio.get('/groups/$groupId/members');

//     print(
//       '[Api] fetchGroupMembers status=${resp.statusCode}',
//     );

//     final data = resp.data as Map<String, dynamic>;

//     return data['members'] as List<dynamic>;
//   }

//   void setToken(String token) {
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     print('[Api] TOKEN SET: $token');
//   }
//   void clearToken() {
//     _dio.options.headers.remove('Authorization');
//     print('[Api] TOKEN CLEARED');
//   }

//   Future<Map<String, dynamic>> login(String pseudo, String password) async {
//     final resp = await _dio.post('/login', data: {'pseudo': pseudo, 'password': password});
//     return Map<String, dynamic>.from(resp.data as Map);
//   }

//   Future<List<dynamic>> fetchMyGroups() async {
//     print('[Api] fetchMyGroups -> GET /my_groups');
//     final resp = await _dio.get('/my_groups');
//     print('[Api] fetchMyGroups status=${resp.statusCode}');
//     final data = resp.data as Map<String, dynamic>;
//     return data['groups'] as List<dynamic>;
//   }

//   Future<List<dynamic>> fetchEuromillionsDraws() async {
//     final resp = await _dio.get('/euromillions/draws');
//     return resp.data as List<dynamic>;
//   }

//   Future<Map<String, dynamic>> fetchDrawStats(int drawId, int nbDraws) async {
//     final resp = await _dio.get(
//       '/euromillions/draws/$drawId/stats$nbDraws',
//     );
//     return Map<String, dynamic>.from(resp.data);
//   }

//   // Future<String> collectEuromillions() async {
//   //   final response = await _dio.post('/euromillions/collect');

//   //   return response.data['message'];
//   // }

//  Future<String> collectEuromillions() async {
//   final response = await _dio.post('/collect/euromillions/latest');

//   final draw = response.data['draw'];

//   final message = response.data['message'] as String;

//   return '$message\n\n'
//       '${draw['draw_date']} : \n'
//       '${draw['n1']} - ${draw['n2']} - ${draw['n3']} - ${draw['n4']} - ${draw['n5']}'
//       ' + '
//       '${draw['e1']} - ${draw['e2']}\n'
//       'Jackpot : ${draw['jackpot']} €\n'
//       'Gagnants : ${draw['winners']}';
//   }


//   Future<List<DateTime>> fetchCollectedEuromillionsDates() async {
//     final response = await _dio.get(
//       '/collect/euromillions/dates',
//     );

//     final dates = response.data as List;

//     return dates.map((date) {
//       return DateTime.parse(date as String);
//     }).toList();
//   }


//   Future<String> collectEuromillionsPeriod(
//     DateTime startDate,
//     DateTime endDate,
//   ) async {
//     final response = await _dio.post(
//       '/collect/euromillions/period',
//       data: {
//         'start_date': _formatDateForApi(startDate),
//         'end_date': _formatDateForApi(endDate),
//       },
//     );

//     final data = response.data;

//     return data['message'] as String;
//   }

//   String _formatDateForApi(DateTime date) {
//     return '${date.year.toString().padLeft(4, '0')}-'
//         '${date.month.toString().padLeft(2, '0')}-'
//         '${date.day.toString().padLeft(2, '0')}';
//   }

//   Future<Map<String, dynamic>> fetchCurrentEuromillionsStats() async {
//     final response = await _dio.get(
//       '/euromillions/stats/current',
//     );

//     return response.data as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> fetchAllEuromillionsStats(
//   ) async {
//     final response = await _dio.get(
//       '/euromillions/stats',
//     );

//     return response.data as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> createGroupGrid({
//     required int groupId,
//     required List<int> numbers,
//     required List<int> stars,
//     required DateTime drawDate,
//   }) async {
//     print('[Api] createGroupGrid -> POST /groups/$groupId/grids');

//     final response = await _dio.post(
//       '/groups/$groupId/grids',
//       data: {
//         'numbers': numbers,
//         'stars': stars,
//         'draw_date': _formatDateForApi(drawDate),
//       },
//     );

//     print('[Api] createGroupGrid status=${response.statusCode}');
//     print('[Api] createGroupGrid response=${response.data}');

//     return Map<String, dynamic>.from(response.data as Map);
//   }


//   Future<List<dynamic>> fetchGroupGridsNextDraw(int groupId) async {
//     print('[Api] fetchGroupGridsNextDraw -> GET /groups/$groupId/grids/next-draw');

//     final response = await _dio.get('/groups/$groupId/grids/next-draw');

//     print('[Api] fetchGroupGridsNextDraw status=${response.statusCode}');

//     final data = Map<String, dynamic>.from(
//       response.data as Map,
//     );

//     final grids = data['grids'];

//     if (grids is! List) {
//       throw Exception(
//         'La réponse du serveur ne contient pas de liste de grilles valide.',
//       );
//     }

//     print('[Api] fetchGroupGridsNextDraw count=${grids.length}');

//     return grids;
//   }


//   Future<List<dynamic>> fetchGroupGrids(int groupId) async {
//     print('[Api] fetchGroupGrids -> GET /groups/$groupId/grids');

//     final response = await _dio.get('/groups/$groupId/grids');

//     print('[Api] fetchGroupGrids status=${response.statusCode}');

//     final data = Map<String, dynamic>.from(
//       response.data as Map,
//     );

//     final grids = data['grids'];

//     if (grids is! List) {
//       throw Exception(
//         'La réponse du serveur ne contient pas de liste de grilles valide.',
//       );
//     }

//     print('[Api] fetchGroupGrids count=${grids.length}');

//     return grids;
//   }


// }