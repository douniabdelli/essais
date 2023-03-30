import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'dart:convert';

class Affaires extends ChangeNotifier {
  late List _affaires = [];

  List get affaires => _affaires;

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
      print('*****   ${_affaires}   +++++');
    } catch (e) {
      print(e);
    }
  }

}