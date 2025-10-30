
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/document_annexe.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/user.dart';

import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
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

  List get affaires => _affaires;
  List get foundAffaires => _foundAffaires;
  int selectedAffaireIndex(value) {
    return _foundAffaires.indexWhere((e) => e.Code_Affaire == value);
  }


  Future<void> filterAffaires(String filter) async {

    List<Affaire> temp = [];
if (filter == null || filter.isEmpty || filter == 'Toutes les affaires') {
  temp = _affaires.cast<Affaire>();
} else if (filter == 'Visitées') {
  temp = _affaires.where((affaire) {
    return _visites.any((visite) =>
      visite.Code_Affaire == affaire.Code_Affaire &&
      visite.ValidCRVPIng == '1');
  }).cast<Affaire>().toList();
} else if (filter == 'Brouillons') {
  temp = _affaires.where((affaire) {
    return _visites.any((visite) =>
      visite.Code_Affaire == affaire.Code_Affaire &&
      visite.ValidCRVPIng == '0');
  }).cast<Affaire>().toList();
} else if (filter == 'Non visitées') {
  temp = _affaires.where((affaire) {
    // Aucune visite OU visites ni validées ni brouillons
    final visitesAffaire = _visites.where((v) => v.Code_Affaire == affaire.Code_Affaire).toList();
    return visitesAffaire.isEmpty || 
          visitesAffaire.any((v) => v.ValidCRVPIng != '1' && v.ValidCRVPIng != '0');
  }).cast<Affaire>().toList();
}
    if (_search.isNotEmpty) {
      temp = temp.where((element) =>
      element.Code_Affaire.toString().toLowerCase().contains(_search.toLowerCase()) ||
          element.Code_Site.toString().toLowerCase().contains(_search.toLowerCase()) ||
          element.IntituleAffaire.toString().toLowerCase().contains(_search.toLowerCase())
      ).toList();
    }

    _foundAffaires = temp;
    notifyListeners();
  }

  set setfoundAffaires(String value) {
    _search = value;
    filterAffaires(_filter);
    notifyListeners();
  }

  set setFilterAffaires(String value) {
    _filter = value;
    _foundAffaires = _affaires;
    filterAffaires(_filter);
    notifyListeners();
  }
  Future<void> refreshAffaires() async {

  filterAffaires(_filter);
  print('freeeeeeeeeeeeeeeeeeeech');
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
      String? userString = (await storage.read(key: 'user')) as String?;
      var structureExists = true;
      if(userString != null) {
        User _user = User.deserialize(userString);
        structureExists = await VisitePreliminaireDatabase.instance.checkStructure(_user.structure);
      }
      if(_isNotFirstTime != null && _isNotFirstTime == 'isNotFirstTime' && structureExists){
        _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
        _sites = await VisitePreliminaireDatabase.instance.getSites();


      }
      else {
        await storage.write(key: 'isNotFirstTime', value: 'isNotFirstTime');

        await fetchUsers(token: token);
        await fetchAffaires(token: token);
        print("b5555");
        await fetchSites(token: token);
        print("b1");


        await fetchImages(token: token);
        print("b3");
     
        print("b4");
      }
      _foundAffaires = _affaires;
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
    String jsonFormatted = jsonEncode(responseAffaire.data);
    print("responseAffaire : $jsonFormatted");
    await VisitePreliminaireDatabase.instance.createAffaires(
        responseAffaire.data.map((data) => Affaire.fromJson(data)).toList()
    );
    print("Affaires créées avec succès dans la base de données");
    _affaires = await VisitePreliminaireDatabase.instance.getAffaires();
    _codes_affaires = responseAffaire.data.map((e) => e['Code_Affaire'].toString()).toList();
    print("Codes des affaires : $_codes_affaires");


  }
 Future<List<TypeIntervention>> fetchTypeInterventions(String token) async {
  
 

  try {
    final response = await http.get(
      Uri.parse('http://192.168.108.2:56/api/essais/interventions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> interventionsData = [];
      if (data.containsKey('typeInterventions')) {
        interventionsData = data['typeInterventions'];
        print("✅ Types d'interventions chargés avec succès");
      } else {
        interventionsData = data['data'] ?? [];
        print("ℹ️ Utilisation des données de 'data' au lieu de 'typeInterventions'");
      }

      return interventionsData
          .map((json) => TypeIntervention.fromJson(json))
          .where((intervention) => !intervention.inactive)
          .toList();
    } else {
      debugPrint("Erreur HTTP ${response.statusCode}: ${response.body}");
      throw Exception("Erreur lors du chargement: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Erreur: $e");
    throw Exception("Erreur de connexion: $e");
  }
}
Future<void> fetchSites({required String token}) async {
  print('🔍 IDs envoyés à /visite-preleminaire/sites : $_codes_affaires'); // Log des IDs

  Dio.Response responseSite = await dio().post(
    '/visite-preleminaire/sites',
    data: {
      'ids': _codes_affaires,
    },
    options: Dio.Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      },
    ),
  );

  print('Réponse de /visite-preleminaire/sites : ${responseSite.data}'); // Log de la réponse

  await VisitePreliminaireDatabase.instance.createSites(
    responseSite.data.map((data) => Site.fromJson(data)).toList(),
  );
  _sites = await VisitePreliminaireDatabase.instance.getSites();
  _codes_affaires_sites = responseSite.data.map((e) {
    return {
      'Code_Affaire': e['Code_Affaire'],
      'Code_site': e['Code_site'],
    };
  }).toList();
print('🔍 IDs des affaires et sites après traitement : ${jsonEncode(_codes_affaires_sites)}');
// Log des IDs après traitement
logToFile(jsonEncode(_codes_affaires_sites));
}
// Future<void> fetchVisites({required String token}) async {
//   try {
//     final responseVisite = await dio().get(
//       '/visite-preleminaire/visites',
//       data: {
//         'ids': _codes_affaires_sites, // Liste des affaires et sites
//       },
//       options: Dio.Options(
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Charset': 'utf-8',
//         },
//       ),
//     );

//     final data = responseVisite.data;
// print('Données : $data');
//     // ✅ Récupérer les données et logs séparément
//     final visitesData = data['data'];
//     final logs = data['logs'];

//     // ✅ Afficher les logs Laravel
//     if (logs != null && logs is List) {
//       print("🔍 LOGS Laravel reçus :");
//       for (var log in logs) {
//         print("➡️ $log");
//       }
//     }

//     // ✅ Sauvegarde des données dans la base locale
//     await VisitePreliminaireDatabase.instance.createVisites(
//       (visitesData as List).map((data) => Visite.fromJson(data)).toList()
//     );
//     print("✅ Données sauvegardées avec succès !");

//     _visites = await VisitePreliminaireDatabase.instance.getVisites();
//   } on DioException catch (e) {
//     print('❌ Erreur Dio : ${e.message}');
//     if (e.response != null) {
//       print('Code statut : ${e.response!.statusCode}');
//       print('Données de réponse : ${e.response!.data}');
//     }
//   } catch (e) {
//     print('❌ Erreur inattendue : $e');
//   }
// }


  /*
Future<void> fetchImages({required String token}) async {
  try {
    final response = await dio().get(
      '/visite-preleminaire/images',
      data: {'ids': _codes_affaires_sites},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = response.data is List ? response.data : [response.data];

      for (var affaire in responseData) {
        final codeAffaire = affaire['codeAffaire'];
        final codeSite = affaire['codeSite'];
        final siteImages = affaire['siteImages'];

        if (siteImages != null && siteImages.isNotEmpty) {
          for (var image in siteImages) {
            final imageUrl = image['url']; // Utilisez l'URL complète ici
            final fileName = '${codeAffaire}_${codeSite}_${image['id']}.png';

            try {
              final imagePath = await downloadImage(imageUrl, fileName, token);
              final imageBytes = await File(imagePath).readAsBytes();

              await VisitePreliminaireDatabase.insertImage(
                // id: image['id'],
                // name: fileName,
                // path: imagePath,
                // imageByte: imageBytes, // Stockez les bytes de l'image
              );

              print('Image téléchargée et insérée : $fileName');
            } catch (e) {
              print('Erreur lors du téléchargement de l\'image $fileName : $e');
            }
          }
        }
      }

      _images = await VisitePreliminaireDatabase.instance.getAllImages();
      notifyListeners();
    }
  } catch (e, stackTrace) {
    print('Erreur lors de la récupération des images : $e\n$stackTrace');
  }
}*/

Future<void> fetchImages({required String token}) async {
    try {
      final response = await dio().get(
        '/visite-preleminaire/images',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> data = responseData['data'];

        for (var affaire in data) {
          final codeAffaire = affaire['codeAffaire'].toString();
          final codeSite = affaire['codeSite'].toString();
          final siteImages = affaire['siteImages'] as List;

          for (var image in siteImages) {
            final imageId = image['id'].toString();
            final imagePath = image['path'] as String;

            // Construction de l'URL avec vérification du chemin
final baseUrl = dio().options.baseUrl.replaceAll(RegExp(r'/api/mobile$'), '');
final imageUrl = imagePath.startsWith('http')
    ? imagePath
    : '$baseUrl/${imagePath.replaceAll(RegExp(r'^/?(api|mobile)/?'), '')}';
// Nom de fichier avec codeAffaire et codeSite
            final fileName = '${codeAffaire}_${codeSite}_${DateTime.now().millisecondsSinceEpoch}.png';

            try {
              print('Tentative de téléchargement: $fileName');
              print('Depuis URL: $imageUrl');

              final localPath = await downloadImage(imageUrl, fileName, token);

              if (localPath != null) {
                await VisitePreliminaireDatabase.insertImage(localPath, fileName);
                print('Fichier sauvegardé avec succès: $fileName');
              }
            } catch (e) {
              print('Échec du traitement de l\'image $fileName: $e');
              // Tentative avec l'URL alternative si disponible
              if (image['url'] != null) {
                try {
                  final altUrl = image['url'] as String;
                  print('Tentative avec URL alternative: $altUrl');
                  final localPath = await downloadImage(altUrl, fileName, token);
                  if (localPath != null) {
                    await VisitePreliminaireDatabase.insertImage(localPath, fileName);
                  }
                } catch (e) {
                  print('Échec avec URL alternative: $e');
                }
              }
            }
          }
        }


        notifyListeners();
      }
    } catch (e) {
      print('Erreur dans fetchImages: $e');
      rethrow;
    }
  }

  Future<String?> downloadImage(String imageUrl, String fileName, String token) async {
    try {
      // Encodage complet de l'URL pour éviter les caractères spéciaux invalides
      final cleanedUrl = Uri.encodeFull(imageUrl);

      final response = await dio().get(
        cleanedUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'image/png,image/jpeg,image/jpg,*/*', // Ajout du header Accept
          },
          // Autorise tous les statuts < 500 pour capturer proprement les erreurs du serveur
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        print('Échec du téléchargement. Code statut: ${response.statusCode}');
        print('Réponse serveur : ${response.data}');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Création du dossier si inexistant
      if (!file.parent.existsSync()) {
        await file.parent.create(recursive: true);
      }

      // Vérifie et écrit les données
      if (response.data != null && (response.data as List).isNotEmpty) {
        await file.writeAsBytes(response.data as List<int>);
        return filePath;
      } else {
        print('Aucune donnée à écrire (données d\'image vides).');
        return null;
      }
    } on DioException catch (e) {
      print('Erreur Dio lors du téléchargement $fileName: ${e.message}');
      if (e.response != null) {
        print('Code statut: ${e.response!.statusCode}');
        print('Données de réponse: ${e.response!.data}');
      }
      return null;
    } catch (e) {
      print('Erreur lors du téléchargement $fileName: $e');
      return null;
    }
  }
 

}