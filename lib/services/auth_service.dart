import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  // Singleton
  AuthService._internal();
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  static const _tokenKey = 'auth_token';
  static const _pseudoKey = 'auth_pseudo';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<String?> getPseudo() async => await _storage.read(key: _pseudoKey);

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _api.setToken(token);
  }

  Future<void> setPseudo(String pseudo) async {
    await _storage.write(key: _pseudoKey, value: pseudo);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _pseudoKey);
    _api.clearToken();
  }

  Future<bool> tryAutoLogin() async {
    final token = await getToken();

    if (token == null) return false;

    _api.setToken(token);

    try {
      final me = await _api.fetchMe();
      await setPseudo(me["pseudo"]);
      return true;
    } catch (_) {
      await clear();
      return false;
    }
  }

  Future<Map<String, dynamic>> login(
    String pseudo,
    String password,
  ) async {
    final resp = await _api.login(pseudo, password);

    final token = resp['token'] as String;
    final returnedPseudo = resp['pseudo'] as String? ?? pseudo;

    await setToken(token);
    await setPseudo(returnedPseudo);

    return {
      'token': token,
      'pseudo': returnedPseudo,
    };
  }
}

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'api_service.dart';

// class AuthService {
//   static const _tokenKey = 'auth_token';
//   static const _pseudoKey = 'auth_pseudo';

//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   final ApiService _api = ApiService();

//   Future<String?> getToken() async => await _storage.read(key: _tokenKey);
//   Future<String?> getPseudo() async => await _storage.read(key: _pseudoKey);

//   Future<void> setToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//     _api.setToken(token);
//   }

//   Future<void> setPseudo(String pseudo) async {
//     await _storage.write(key: _pseudoKey, value: pseudo);
//   }

//   Future<void> clear() async {
//     await _storage.delete(key: _tokenKey);
//     await _storage.delete(key: _pseudoKey);

//     _api.clearToken();
//   }

//   Future<bool> tryAutoLogin() async {
//   final token = await getToken();

//   if (token == null) return false;

//   _api.setToken(token);

//   try {
//     final me = await _api.fetchMe();
//     await setPseudo(me["pseudo"]);
//     return true;
//   } catch (_) {
//     await clear();
//     return false;
//   }
// }

//   Future<Map<String, dynamic>> login(String pseudo, String password) async {
//     final resp = await _api.login(pseudo, password);
//     final token = resp['token'] as String;
//     final returnedPseudo = resp['pseudo'] as String? ?? pseudo;
//     await setToken(token);
//     await setPseudo(returnedPseudo);
//     return {'token': token, 'pseudo': returnedPseudo};
//   }
// }
