import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import '../models/user.dart';
import 'package:collection/collection.dart'; 

class Auth extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  User? _user;
  bool _isLocally = false;
  final storage = FlutterSecureStorage();
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  bool get isLocally => _isLocally;

  set setIsLocally(bool value) {
    _isLocally = value;
    notifyListeners();
  }

  
  Future<void> checkLoggedUser() async {
    try {
      final status = await storage.read(key: 'isLoggedIn');
      final token = await storage.read(key: 'token');
      final userData = await storage.read(key: 'user');

      _isLoggedIn = (status == 'loggedIn' && token != null && userData != null);

      if (_isLoggedIn) {
        _token = token;
        _user = User.deserialize(userData!);
      }
    } catch (e) {
      print('Erreur checkLoggedUser: $e');
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  
  Future<int> login({required Map credentials}) async {
    try {
      print('Tentative de connexion: $credentials');
      await storeCredentials(credentials);
      final isNotFirstTime = await storage.read(key: 'isNotFirstTime');
      final isLocallyFlag = await storage.read(key: 'isLocally');
      final useLocalAuth = (isNotFirstTime == 'isNotFirstTime' && isLocallyFlag == 'true');
      if (useLocalAuth) {
        return await _handleLocalLogin(credentials);
      }
      final apiStatus = await _handleApiLogin(credentials);
      if (apiStatus != 200) {
       return await _handleLocalLogin(credentials);
      }
      return apiStatus;
    } catch (e) {
      print('Erreur login: $e');
      return await _handleLocalLogin(credentials);
    }
  }

  
  Future<int> _handleLocalLogin(Map credentials) async {
    try {
      final List<User> users = await LocalDatabase.instance.getUser();

      if (users.isEmpty) {
        print('Aucun utilisateur trouvé en base locale');
        return 404;
      }

      final String inputMatricule = (credentials['Matricule'] ?? '').toString().trim();
      final User? localUser = users.firstWhereOrNull(
            (u) => u.matricule?.toString().trim() == inputMatricule,
      );

      if (localUser == null) {
        print('Utilisateur non trouvé dans la base locale');
        return 401;
      }

      final bool isPasswordValid = BCrypt.checkpw(
        credentials['password']?.toString() ?? '',
        localUser.password,
      );

      if (!isPasswordValid) {
        print('Mot de passe incorrect');
        return 401;
      }

      await _setUserLoggedIn(localUser, 'local_token');
      print('Connexion offline réussie pour ${localUser.matricule}');
      return 200;

    } catch (e) {
      print('Erreur connexion locale: $e');
      return 500;
    }
  }

  
  Future<int> _handleApiLogin(Map credentials) async {
    try {
      final statusCode = await _getApiToken(credentials);
      print(' connexion API:');
      if (statusCode != 200) return statusCode;
      return await _fetchUserData();
    } catch (e) {
      print('Erreur connexion API: $e');
      return 500;
    }
  }

  
  Future<int> _getApiToken(Map credentials) async {
    try {
      final response = await dio().post(
        '/login',
        data: credentials,
        options: Dio.Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final String token = response.data['token'] ??
            response.data['access_token'] ??
            response.data.toString();

        _token = token;
        await storage.write(key: 'token', value: token);
        return 200;
      } else {
        return response.statusCode ?? 401;
      }
    } on Dio.DioError catch (e) {
      print('Erreur Dio: ${e.response?.statusCode} - ${e.message}');
      return 500;
    }
  }

Future<int> _fetchUserData() async {
  final String? matricule = await storage.read(key: 'matricule');
  try {
    if (_token == null) return 401;

    final response = await dio().get(
      '/prelevements/users',
      queryParameters: {'matricule': matricule},
      options: Dio.Options(headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      }),
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      
      final Map<String, dynamic> data = response.data;
      final User connectedUser = User.fromJson(data);
      print("Utilisateur récupéré: ${connectedUser.matricule}");
      await LocalDatabase.instance.dropUsers(connectedUser.structure);
      await LocalDatabase.instance.createUsers([connectedUser]);
      await _setUserLoggedIn(connectedUser, _token!);
      return 200;
    }
    return response.statusCode ?? 401;
  } catch (e) {
    print('Erreur fetchUserData: $e');
    return 500;
  }
}

  
  Future<void> _setUserLoggedIn(User user, String token) async {
    _user = user;
    _token = token;
    _isLoggedIn = true;
    await storage.write(key: 'user', value: User.serialize(user));
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'isLoggedIn', value: 'loggedIn');

    notifyListeners();
  }

  
  Future<void> storeCredentials(Map credentials) async {
    try {
      await storage.write(key: 'matricule', value: credentials['Matricule']?.toString() ?? '');
      await storage.write(key: 'password', value: credentials['password']?.toString() ?? '');
    } catch (e) {
      print('Erreur storeCredentials: $e');
    }
  }

  
  Future<void> logout() async {
    try {
      await _cleanUp();
      notifyListeners();
    } catch (e) {
      print('Erreur logout: $e');
    }
  }

  
  Future<void> _cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;

    try {
      await storage.deleteAll();
    } catch (e) {
      print('Erreur cleanUp: $e');
    }
  }
}
