import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
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
      _foundAffaires = _affaires;
      print('***0***   ${_affaires[0].NbrSite}   +++0+++');
    } catch (e) {
      print(e);
    }
  }

}