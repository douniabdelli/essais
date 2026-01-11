import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/third_person.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _controlleur = '';
  late String _projet = '';
  late String _adresse = '';
  late String _nom_direction = '';
  late String _code_agence = '';
  late String _nom_agence = '';
  late String _tel = '';
  late String _fax = '';
  late String _email = '';
  late int _currentIndex = 1;
  late DateTime _dateVisite = DateTime.now();
  late int _stepIndex = 0;
  late DateTime _selectedDate = DateTime.now();
 String? pe_id;
  void setCode(String code) {
    pe_id = code;
    notifyListeners();
  }

 

  late List _personnesTierces = [];
  TextEditingController _localisationInputController = TextEditingController();
  List get personnesTierces  {
    return _personnesTierces;
  }
  void addPersonnesTierces(thirdPerson, fullName){
    _personnesTierces.add(ThirdPerson(thirdPerson: thirdPerson, fullName: fullName));
    notifyListeners();
  }
  void removePersonnesTierces(index){
    _personnesTierces.removeAt(index);
    notifyListeners();
  }

  String get screenTitle => _screenTitle;
  set setScreenTitle(value) {
    _screenTitle = value;
    notifyListeners();
  }

  DateTime get dateVisite => _dateVisite;
  set setDateVisite(value) {
    _dateVisite = value;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
  set setCurrentIndex(value) {
    _currentIndex = value;
    notifyListeners();
  }

  int get stepIndex => _stepIndex;
  set setStepIndex(value) {
    _stepIndex = value;
    notifyListeners();
  }

  DateTime get selectedDate => _selectedDate;
  set setSelectedDate(value) {
    _selectedDate = value;
    notifyListeners();
  }

  get controlleur => _controlleur;
  get projet => _projet;
  get adresse => _adresse;
  get code_agence => _code_agence;
  get nom_direction => _nom_direction;
  get nom_agence => _nom_agence;
  get tel => _tel;
  get fax => _fax;
  get email => _email;

  bool isJSON(str) {
    try {
      jsonDecode(str);
    } catch (e) {
      return false;
    }
    return true;
  }
  TextEditingController get localisationInputController => _localisationInputController;

  bool _isSyncing = false;
  int _syncCompleted = 0;
  int _syncTotal = 0;

  bool get isSyncing => _isSyncing;
  int get syncCompleted => _syncCompleted;
  int get syncTotal => _syncTotal;

  void startSync(int total) {
    _isSyncing = true;
    _syncCompleted = 0;
    _syncTotal = total;
    notifyListeners();
  }

  void updateSyncProgress(int completed, int total) {
    _isSyncing = true;
    _syncCompleted = completed;
    _syncTotal = total;
    notifyListeners();
  }

  void finishSync() {
    _isSyncing = false;
    notifyListeners();
  }
}
