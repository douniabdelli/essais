import 'package:flutter/material.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _selectedAffaire = '';
  late int _currentIndex = 1;

  String get screenTitle => _screenTitle;
  set setScreenTitle(screenTitle) {
    _screenTitle = screenTitle;
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