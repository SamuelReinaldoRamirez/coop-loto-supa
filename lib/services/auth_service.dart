
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  // Singleton
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  factory AuthService() => instance;

  static const _tokenKey = 'auth_token';
  static const _pseudoKey = 'auth_pseudo';
  static const _isSuperAdminKey = 'auth_is_super_admin';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();

  // ---------------------------------------------------------------------------
  // Lecture du stockage
  // ---------------------------------------------------------------------------

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> getPseudo() async {
    return _storage.read(key: _pseudoKey);
  }

  Future<bool> getIsSuperAdmin() async {
    final value = await _storage.read(key: _isSuperAdminKey);
    return value == 'true';
  }

  // ---------------------------------------------------------------------------
  // Écriture du stockage
  // ---------------------------------------------------------------------------

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _api.setToken(token);
  }

  Future<void> setPseudo(String pseudo) async {
    await _storage.write(key: _pseudoKey, value: pseudo);
  }

  Future<void> setIsSuperAdmin(bool isSuperAdmin) async {
    await _storage.write(
      key: _isSuperAdminKey,
      value: isSuperAdmin.toString(),
    );
  }

  // ---------------------------------------------------------------------------
  // Synchronisation du profil avec le backend
  // ---------------------------------------------------------------------------

  Future<void> refreshUserProfile() async {
    final me = await _api.fetchMe();

    final pseudo = me['pseudo'];
    if (pseudo is String) {
      await setPseudo(pseudo);
    }

    // Une valeur absente ou invalide ne doit jamais accorder les droits admin.
    final isSuperAdmin = me['isSuperAdmin'] == true;
    await setIsSuperAdmin(isSuperAdmin);
  }

  // ---------------------------------------------------------------------------
  // Déconnexion
  // ---------------------------------------------------------------------------

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _pseudoKey);
    await _storage.delete(key: _isSuperAdminKey);

    _api.clearToken();
  }

  // ---------------------------------------------------------------------------
  // Connexion automatique
  // ---------------------------------------------------------------------------

  Future<bool> tryAutoLogin() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      await clear();
      return false;
    }

    _api.setToken(token);

    try {
      await refreshUserProfile();
      return true;
    } catch (e) {
      await clear();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Connexion
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login(
    String pseudo,
    String password,
  ) async {
    final resp = await _api.login(pseudo, password);

    final token = resp['token'] as String;
    final returnedPseudo = resp['pseudo'] as String? ?? pseudo;

    await setToken(token);
    await setPseudo(returnedPseudo);

    // Le backend est la source de vérité pour les droits administrateur.
    // On récupère le profil avec le nouveau token.
    await refreshUserProfile();

    return {
      'token': token,
      'pseudo': returnedPseudo,
    };
  }
}


// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'api_service.dart';

// class AuthService {
//   // Singleton
//   AuthService._internal();
//   static final AuthService instance = AuthService._internal();
//   factory AuthService() => instance;

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
//     final token = await getToken();

//     if (token == null) return false;

//     _api.setToken(token);

//     try {
//       final me = await _api.fetchMe();
//       await setPseudo(me["pseudo"]);
//       return true;
//     } catch (_) {
//       await clear();
//       return false;
//     }
//   }

//   Future<Map<String, dynamic>> login(
//     String pseudo,
//     String password,
//   ) async {
//     final resp = await _api.login(pseudo, password);

//     final token = resp['token'] as String;
//     final returnedPseudo = resp['pseudo'] as String? ?? pseudo;

//     await setToken(token);
//     await setPseudo(returnedPseudo);

//     return {
//       'token': token,
//       'pseudo': returnedPseudo,
//     };
//   }
// }
