
import 'package:flutter/material.dart';

import '../models/user.dart';

class Auth extends ChangeNotifier {
  late bool _isLoggedIn = false;
  late String _token;
  late User _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get user => _user;


  void login() async {

  }

  void tryToken() async {

  }

  void storeToken() async {

  }

  void logout() async {

  }

  void cleanUp() async {

  }

}