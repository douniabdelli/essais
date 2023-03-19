import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import '../models/user.dart';

class Auth extends ChangeNotifier {
  late bool _isLoggedIn = false;
  late String? _token = null;
  late User? _user = null;

  final storage = new FlutterSecureStorage();

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  login({required Map credentials}) async {
    try {
      print("***  * login *  ***");
      Dio.Response response = await dio()
          .post(
            '/token',
            data: credentials
          );
      String token = response.data.toString();
      print("***  * token : $token *  ***");
      await tryToken(token: token);
      return token;
    } catch(e){
      print(e);
    }
  }

  tryToken({required String token}) async {
    if(token == null)
      return;
    else {
      try {
        print("***  * tryToken : $token *  ***");
        Dio.Response response = await dio()
            .get(
              '/user',
              options: Dio.Options(
                  headers: {
                    'Authorization': 'Bearer $token'
                  }
              )
            );
        print("***  * tryToken : $response *  ***");
        _isLoggedIn = true;
        _user = User.fromJson(response.data);
        _token = token;
        await storeToken(token: token);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  storeToken({required String token}) async {
    await storage.write(key: 'token', value: token);
  }

  logout() async {
    try {
      Dio.Response response = await dio().delete(
          '/user/revoke',
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $_token'
          }
        )
      );
      cleanUp();
      notifyListeners();
    } catch(e) {
      print(e);
    }
  }

  cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;
    await storage.delete(key: 'token');
  }

}