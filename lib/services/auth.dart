import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import '../models/user.dart';

class Auth extends ChangeNotifier {
  late bool? _isLoggedIn = false;
  late bool? _isNotFirstTime = false;
  late String? _token = null;
  late User? _user = null;

  final storage = new FlutterSecureStorage();

  bool? get isLoggedIn => _isLoggedIn;
  bool? get isNotFirstTime => _isNotFirstTime;
  User? get user => _user;

  checkLoggedUser() async {
    try {
      String? status = await storage.read(key: 'isLoggedIn');
      String? token = await storage.read(key: 'token');
      _isLoggedIn = ((status != null) && (status == 'isLoggedIn')) ? true : false;
      if((_isLoggedIn != null) && (_isLoggedIn == true)){
        await tryToken(token: token ?? '');
      }
    } catch(e){
      print(e);
    }
  }

  login({required Map credentials}) async {
    try {
      Dio.Response response = await dio()
          .post(
            '/token',
            data: credentials
          );
      String token = response.data.toString();
      await tryToken(token: token);
      await storeCredentials(credentials);
      return token;
    } catch(e){
      print(e);
    }
  }

  storeCredentials(credentials) async {
    await storage.write(key: 'matricule', value: credentials['matricule']);
    await storage.write(key: 'password', value: credentials['password']);
  }

  tryToken({required String token}) async {
    if(token == null)
      return;
    else {
      try {
        Dio.Response response = await dio()
            .get(
              '/user',
              options: Dio.Options(
                  headers: {
                    'Authorization': 'Bearer $token'
                  }
              )
            );
        _isLoggedIn = true;
        _user = User.fromJson(response.data);
        _token = token;
        await storeToken(token: token);
        await storeUser(user: _user);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  storeToken({required String? token}) async {
    await storage.write(key: 'token', value: token);
  }

  storeUser({required User? user}) async {
    if(user != null) {
      await storage.write(key: 'user', value: User.serialize(user));
      await storage.write(key: 'isLoggedIn', value: 'loggedIn');
    }
  }

  logout() async {
    try {
      await cleanUp();
      notifyListeners();
    } catch(e) {
      print(e);
    }
  }

  cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;
    await storage.delete(key: 'isLoggedIn');
    await storage.delete(key: 'user');
    await storage.delete(key: 'token');
  }

}