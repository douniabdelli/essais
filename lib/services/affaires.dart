
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';

import 'package:mgtrisque_visitepreliminaire/models/user.dart';

import 'package:mgtrisque_visitepreliminaire/services/dio.dart';

import 'package:path_provider/path_provider.dart';
import 'package:mgtrisque_visitepreliminaire/models/TypeIntervention.dart';
class Affaires extends ChangeNotifier {
  final storage = new FlutterSecureStorage();
  late List _affaires = [];
  late List _foundAffaires = [];
  late List _sites = [];
  late List _foundSites = [];
  late List _visites = [];
  late List _codes_affaires = [];
  late List _codes_affaires_sites = [];
  late String _search = '';
  late String _filter = 'Toutes les visites';
 TypeIntervention? selectedIntervention;
  bool isLoading = true;
    List<TypeIntervention> typeInterventions = [];
  String? errorMessage;

//////////////////////////////////////////////////////////////////////////////////////
void logToFile(String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/log_ids.json');
  await file.writeAsString(content);
  print('🔍 Les IDs ont été enregistrés dans : ${file.path}');
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
      String? userString = (await storage.read(key: 'user')) as String?;
      var structureExists = true;
      if(userString != null) {
        User _user = User.deserialize(userString);
        structureExists = await LocalDatabase.instance.checkStructure(_user.structure);
      }
      if(_isNotFirstTime != null && _isNotFirstTime == 'isNotFirstTime' && structureExists){
     //   _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
     //   _sites = await VisitePreliminaireDatabase.instance.getSites();



      }
      else {
        await storage.write(key: 'isNotFirstTime', value: 'isNotFirstTime');

        await fetchUsers(token: token);

        print("b5555");

        print("b1");


        print("b3");
     
        print("b4");
      }
   
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    await LocalDatabase.instance.createUsers(responseUser.data.map((data) => User.fromJson(data)).toList());
  }


//  Future<List<TypeIntervention>> fetchTypeInterventions(String token) async {
//   try {
//     final response = await http.get(
//       Uri.parse('http://192.168.108.2:56/api/essais/interventions'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       List<dynamic> interventionsData = [];
//       if (data.containsKey('typeInterventions')) {
//         interventionsData = data['typeInterventions'];
//         print("✅ Types d'interventions chargés avec succès");
//       } else {
//         interventionsData = data['data'] ?? [];
//         print("ℹ️ Utilisation des données de 'data' au lieu de 'typeInterventions'");
//       }

//       return interventionsData
//           .map((json) => TypeIntervention.fromJson(json))
//           .where((intervention) => !intervention.inactive)
//           .toList();
//     } else {
//       debugPrint("Erreur HTTP ${response.statusCode}: ${response.body}");
//       throw Exception("Erreur lors du chargement: ${response.statusCode}");
//     }
//   } catch (e) {
//     debugPrint("Erreur: $e");
//     throw Exception("Erreur de connexion: $e");
//   }
// }


}