import 'package:flutter/material.dart';

class Affaires extends ChangeNotifier {
  late List _visites = [];
  late List _foundVisites = [];

  List get visites => _visites;
  List get foundVisites => _foundVisites;

  set setfoundVisites(codeAffaire) {
    _foundVisites = _visites.where((element) => element.Code_Affaire.contains(codeAffaire)).toList();
    notifyListeners();
  }

}