import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';

class Affaires extends ChangeNotifier {
  late List _affaires = [];
  late List _foundAffaires = [];

  List get affaires => _affaires;
  List get foundAffaires => _foundAffaires;

  set setfoundAffaires(codeAffaire) {
      _foundAffaires = _affaires.where((element) => element.Code_Affaire.contains(codeAffaire)).toList();
      notifyListeners();
  }

  getAffaires ({required String token}) async {
    try {
      final storage = new FlutterSecureStorage();
      String? _isNotFirstTime = await storage.read(key: 'isNotFirstTime');
      print('isNotFirstTime : ${_isNotFirstTime}');
        if(_isNotFirstTime != null && _isNotFirstTime == 'isNotFirstTime'){
        // todo: get data from local database
        _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
      } else {
        // todo: get data from api
        Dio.Response response = await dio()
            .get(
            '/affaires',
            options: Dio.Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Charset': 'utf-8'
              },
            )
        );
        _affaires = response.data.map((data) => Affaire.fromJson(data)).toList();
        await VisitePreliminaireDatabase.instance.createAffaires(response.data.map((data) => Affaire.fromJson(data)).toList());
      }
      _foundAffaires = _affaires;
    } catch (e) {
      print(e);
    }
  }

}