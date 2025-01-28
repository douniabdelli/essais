import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import '../models/user.dart';

class Auth extends ChangeNotifier {
  late bool? _isLoggedIn = false;
  late bool? _isNotFirstTime = false;
  late String? _token = null;
  late User? _user = null;
  late bool _isLocally = false;

  final storage = new FlutterSecureStorage();

  bool? get isLoggedIn => _isLoggedIn;
  bool? get isNotFirstTime => _isNotFirstTime;
  User? get user => _user;

  bool get isLocally => _isLocally;
  set setIsLocally(bool value) {
    _isLocally = value;
  }

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
      await storeCredentials(credentials);
      String? isNotFirstTime = await storage.read(key: 'isNotFirstTime');
      String? isLocally = await storage.read(key: 'isLocally');
      if(isNotFirstTime != null && isNotFirstTime == 'isNotFirstTime' && (isLocally == 'true')){
        List<User> users = (await VisitePreliminaireDatabase.instance.getUser()).cast<User>();
        // check if user exists && check verify password then store logged user
        if(users.length >= 1) {
          final bool checkedPassword = BCrypt.checkpw(credentials['password'], users.first.password);
          if(checkedPassword) {
            _user = users.first;
            await storeUser(user: users.first);
            await storeToken(token: 'token');
            // ok pass
            return 201;
          }
          else
            return 401;
        }
        else
          return 404;
      }
      else {
        var status = await getApiToken(credentials);
        String? token = await storage.read(key: 'token');
        String? userString = await storage.read(key: 'user');
        if(userString != null) {
          User user = User.deserialize(userString);
          _user = user;
        }
        else
          return status;
        await VisitePreliminaireDatabase.instance.dropUsers(user?.structure);
        Dio.Response responseUser = await dio()
            .get(
            '/visite-preleminaire/users',
            options: Dio.Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Charset': 'utf-8'
              },
            )
        );
        await VisitePreliminaireDatabase.instance.createUsers(responseUser.data.map((data) => User.fromJson(data)).toList());
        return 200;
      }
    } catch(e){
      print(e);
    }
  }

  getApiToken(credentials) async {
    print('****************** ${credentials}');
    try{
      Dio.Response response = await dio()
          .post(
          '/token',
          data: credentials
      );
      String token = response.data.toString();
      await tryToken(token: token);
    } on Dio.DioError catch(e){
      return e.response!.statusCode;
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
            '',
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
      _user = user;
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