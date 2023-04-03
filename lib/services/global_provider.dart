import 'package:flutter/material.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _selectedAffaire = '';

  String get screenTitle => _screenTitle;
  set setScreenTitle(screenTitle) => _screenTitle = screenTitle;

  String get selectedAffaire => _selectedAffaire;
  set setSelectedAffaire(selectedAffaire) => _selectedAffaire = selectedAffaire;

}