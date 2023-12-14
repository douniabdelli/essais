import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/user.dart';
import 'package:mgtrisque_visitepreliminaire/models/visite.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';

class Affaires extends ChangeNotifier {
  final storage = new FlutterSecureStorage();
  late List _affaires = [];
  late List _foundAffaires = [];
  late List _sites = [];
  late List _foundSites = [];
  late List _visites = [];
  late List _codes_affaires = [];
  late List _codes_affaires_sites = [];

//////////////////////////////////////////////////////////////////////////////////////

  Future setHasVisite(code_affaire, code_site) async {
    var index = _affaires.indexWhere((affaire) => affaire.Code_Affaire == code_affaire && affaire.Code_Site == code_site);
    if(index > -1)
      _affaires[index] = _affaires[index].setHasVisite('1');
    index = _foundAffaires.indexWhere((affaire) => affaire.Code_Affaire == code_affaire && affaire.Code_Site == code_site);
    if(index > -1)
      _foundAffaires[index] = _foundAffaires[index].setHasVisite('1');

    await VisitePreliminaireDatabase.instance.setHasVisite(code_affaire, code_site);
    notifyListeners();
  }
  
  List get affaires => _affaires;
  List get foundAffaires => _foundAffaires;
  int selectedAffaireIndex(value) {
    return _foundAffaires.indexWhere((e) => e.Code_Affaire == value);
  }
  set setfoundAffaires(value) {
      _foundAffaires = _affaires.where((element)
        => 
          (element.Code_Affaire.toString().toLowerCase().contains(value) || element.Code_Site.toString().toLowerCase().contains(value))).toList();
      notifyListeners();
  }
  set setFilterAffaires(value) {
      if(value == 'Toutes les affaires')
        _foundAffaires = _affaires;
      else if(value == 'Visitées')
        _foundAffaires = _affaires.where((element) => element.hasVisite == '1').toList();
      else if(value == 'Non visitées')
        _foundAffaires = _affaires.where((element) => element.hasVisite != '1').toList();
      notifyListeners();
  }
//////////////////////////////////////////////////////////////////////////////////////
  List get sites => _sites;
  List get foundSites => _foundSites;

  set setfoundSites(codeAffaire) {
    _foundSites = _sites.where((element) => element.Code_Affaire == codeAffaire).toList();
    notifyListeners();
  }
//////////////////////////////////////////////////////////////////////////////////////
  getData({required String token}) async {
    try {
      String? _isNotFirstTime = await storage.read(key: 'isNotFirstTime');
      if(_isNotFirstTime != null && _isNotFirstTime == 'isNotFirstTime'){
        // get affaires from local database
        _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
        // get sites from local database
        _sites = await VisitePreliminaireDatabase.instance.getSites();
        // get visites from local database
        _visites = await VisitePreliminaireDatabase.instance.getVisites();
      }
      else {
        await storage.write(key: 'isNotFirstTime', value: 'isNotFirstTime');
        // get users from api
        await fetchUsers(token: token);
        // get affaires from api
        await fetchAffaires(token: token);
        // get sites from api
        await fetchSites(token: token);
        // get visites from api
        await fetchVisites(token: token);
      }
      _foundAffaires = _affaires;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchUsers({required String token}) async {
    Dio.Response responseUser = await dio()
        .get(
        '/visite-preleminaire/users',
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createUsers(responseUser.data.map((data) => User.fromJson(data)).toList());
  }

  Future<void> fetchAffaires({required String token}) async {
    Dio.Response responseAffaire = await dio()
        .get(
        '/visite-preleminaire/affaires',
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createAffaires(responseAffaire.data.map((data) => Affaire.fromJson(data)).toList());
    _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
    _codes_affaires = responseAffaire.data.map((e) => e['Code_Affaire'].toString()).toList();
  }

  Future<void> fetchSites ({required String token}) async {
    Dio.Response responseSite = await dio()
        .post(
        '/visite-preleminaire/sites',
        data: {
          'ids': _codes_affaires
        },
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createSites(responseSite.data.map((data) => Site.fromJson(data)).toList());
    _sites = await VisitePreliminaireDatabase.instance.getSites();
    _codes_affaires_sites = responseSite.data.map((e) {
      return {
        'Code_Affaire': e['Code_Affaire'],
        'Code_site': e['Code_site'],
      };
    }).toList();
  }

  Future<void> fetchVisites ({required String token}) async {
    Dio.Response responseVisite = await dio()
        .get(
        '/visite-preleminaire/visites',
        data: {
          'ids': _codes_affaires_sites
        },
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createVisites(responseVisite.data.map((data) => Visite.fromJson(data)).toList());
    _visites = await VisitePreliminaireDatabase.instance.getVisites();
  }

}