import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';

class Affaires extends ChangeNotifier {
  late List _visites = [];
  late List _foundVisites = [];

  List get visites => _visites;
  List get foundVisites => _foundVisites;

  set setfoundVisites(codeAffaire) {
    _foundVisites = _visites.where((element) => element.Code_Affaire.contains(codeAffaire)).toList();
    notifyListeners();
  }

  getVisites({required String token}) async {
    try {
      Dio.Response response = await dio()
          .get(
          '/visite-preleminaire/visites',
          options: Dio.Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Charset': 'utf-8'
            },
          )
      );
      _visites = response.data.map((data) => Affaire.fromJson(data)).toList();
      _foundVisites = _visites;
    } catch (e) {
      print(e);
    }
  }

}