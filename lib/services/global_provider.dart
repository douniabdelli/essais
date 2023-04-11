import 'package:flutter/material.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _selectedAffaire = '';
  late int _currentIndex = 1;
  late DateTime _dateVisite = DateTime.now();

  String get screenTitle => _screenTitle;
  set setScreenTitle(screenTitle) {
    _screenTitle = screenTitle;
    notifyListeners();
  }

  DateTime get dateVisite => _dateVisite;
  set setDateVisite(dateVisite) {
    _dateVisite = dateVisite;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
  set setCurrentIndex(currentIndex) {
    _currentIndex = currentIndex;
    notifyListeners();
  }

  String get selectedAffaire => _selectedAffaire;
  set setSelectedAffaire(selectedAffaire) {
    _selectedAffaire = selectedAffaire;
    notifyListeners();
  }

}