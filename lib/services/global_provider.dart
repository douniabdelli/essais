import 'package:flutter/material.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';

  String get screenTitle => _screenTitle;
  set setScreenTitle(screenTitle) => _screenTitle = screenTitle;

}