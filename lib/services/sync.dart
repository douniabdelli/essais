import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/interventions.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';

import 'package:mgtrisque_visitepreliminaire/services/dio.dart';

class InterventionsService {
  static final InterventionsService _instance = InterventionsService._internal();
  factory InterventionsService() => _instance;
  InterventionsService._internal();

  // ===================================================================
  // FETCH SETUP DATA (NewIntervention data)
  // ===================================================================
  Future<void> fetchAndSaveSetupData() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) return;

    try {
      print('🌐 Tentative de récupération des données de configuration (setup data)...');
      final response = await dio().get(
        '/essais/interventions_setpdataBeton/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data ?? {};
        print('fetchAndSaveSetupData: données récupérées.');

        // Helper to normalize lists
        List<dynamic> norm(dynamic raw) {
            if (raw == null) return [];
            if (raw is List) return raw;
            if (raw is Map) return raw.values.toList();
            // Handle stringified JSON if necessary (based on newIntervention.dart logic)
            if (raw is String) {
                try {
                    final d = json.decode(raw);
                    if (d is List) return d;
                    if (d is Map) return d.values.toList();
                } catch (_) {}
            }
            return [];
        }

        final referencesMap = {
            'commandes': norm(data['commandes']),
            'beton': norm(data['beton']),
            'elementPredefini': norm(data['elementPredefini']),
            'modePro': norm(data['modesProduction']),
            'carrieres': norm(data['carrieres']),
            'typeciment': norm(data['types_ciments']),
            'typeAdjuvant': norm(data['types_adjuvants']),
            'typeEprouvette': norm(data['types_eprouvettes']),
        };

        await LocalDatabase.saveReferences(referencesMap);
        print('💾 Données de configuration sauvegardées localement.');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des données de configuration: $e');
    }
  }

  // ===================================================================
  // FETCH INTERVENTION
  // ===================================================================
  Future<Interventions> fetchInterventions(String? pe_id) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final String interventionId = pe_id ?? "";

    print("FETCH INTERVENTION - ID: $interventionId");
    print("TOKEN: ${token != null ? 'Présent' : 'Absent'}");

    if (interventionId.isEmpty) {
      throw Exception("ID d'intervention manquant.");
    }

    // 1. LOCAL (OFFLINE FIRST)
    try {
      print("TENTATIVE DE CHARGEMENT LOCAL...");
      final localIntervention = await LocalDatabase.getIntervention(interventionId);

      if (localIntervention != null) {
        print("LOCAL: PV trouvé !");

        final elementsOuvrage = await _safeGetList(LocalDatabase.getElementsOuvrage(interventionId), "éléments ouvrage");
        final constituants = await _safeGetList(LocalDatabase.getConstituants(interventionId), "constituants");
        final eprouvettes = await _safeGetList(LocalDatabase.getSeriesEprouvettes(interventionId), "éprouvettes");
        final series = await _getSeriesFromLocal(interventionId);
        final commandesLocal = await _getCommandesLocal();

        final result = _buildInterventionFromLocal(
          localIntervention,
          elementsOuvrage,
          constituants,
          eprouvettes,
          series,
          commandesLocal,
          interventionId,
        );
        print("OFFLINE: Intervention chargée avec succès !");
        return result;
      } else {
        print("LOCAL: Aucune donnée pour $interventionId");
      }
    } catch (e) {
      print("ERREUR DB locale: $e");
    }

    // 2. API
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant");
    }

    try {
      print("API: Chargement...");
      final response = await dio().get(
        '/essais/getIntervention/$interventionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("API: Réponse OK - Clés: ${data.keys.join(', ')}");

    // Extract user data
final userinter = data['user'];
if (userinter != null) {
  print("USER DATA: ${userinter['Nom']} ${userinter['Prénom']}");
  // Save user data locally
  print("📌 Insertion dans interventions_recu UNIQUEMENT");
print("USER DATA: ${userinter['Nom']} ${userinter['Prénom']} - Sauvegardé avec l'intervention");
  print("USER DATA SAVED LOCALLY: ${userinter['Nom']} ${userinter['Prénom']}");
}

// Log the entire API response to debug missing fields
print("API RESPONSE: $data");
print("API RESPONSE KEYS: ${data.keys.join(', ')}");
if (!data.containsKey('date_validation_pm')) {
  print("⚠️ WARNING: 'date_validation_pm' is missing from the API response.");
} else {
  print("✅ 'date_validation_pm' is present in the API response.");
}

var dateValidationPm = data['date_validation_pm'];
print("DATE VALIDATION PM: $dateValidationPm");
if (dateValidationPm != null) {
  print("DATE VALIDATION PM: $dateValidationPm");
}

        final commandes = data['commandes'] as List<dynamic>?;

if (commandes != null && commandes.isNotEmpty) {
  final firstCommande = commandes.first;
  if (firstCommande is Map<String, dynamic>) {
    dateValidationPm = firstCommande['date_validation_pm'] as String?;
    print("EXTRACTED DATE VALIDATION PM: $dateValidationPm");
  }
} else {
  print("⚠️ No commandes found in the API response.");
}

// Save the complete intervention to the local database
        await _saveCompleteInterventionToLocalDB(interventionId, {
          ...data,
          'date_validation_pm': dateValidationPm, // Include the extracted field
        });

        print("SAUVEGARDE: PV $interventionId stocké localement");

        return _parseInterventionData(data);
      }

      
    } on DioException catch (e) {
      print("ERREUR DIO: $e");
      final fallback = await LocalDatabase.getIntervention(interventionId);
      if (fallback != null) {
        print("FALLBACK: Données locales utilisées");
        return _buildInterventionFromLocal(fallback, [], [], [], [], [], interventionId);
      }
      throw Exception("Pas de connexion et pas de données locales");
    } catch (e) {
      print("ERREUR: $e");
      rethrow;
    }

  throw Exception("Échec total");
  }
  static Map<String, dynamic> _correctInterventionData(Map<String, dynamic> data) {
  final corrected = Map<String, dynamic>.from(data);
  
  // Mapping des anciens noms vers les noms de colonnes existants
  final columnMappings = {
    'classeBeton': 'classe_beton_id',
    'catChantier': 'categorie_chantier',
    // Ajoutez d'autres mappings si nécessaire
  };
  
  columnMappings.forEach((oldKey, newKey) {
    if (corrected.containsKey(oldKey)) {
      corrected[newKey] = corrected[oldKey];
      corrected.remove(oldKey);
    }
  });
  
  return corrected;
}
 Future<List<Map<String, dynamic>>> getAllLocalInterventionsComplete() async {
    return await _getAllLocalInterventionsComplete();
  }

  Future<void> preloadAllInterventions({int batchSize = 8, void Function(int total)? onStart, void Function(int completed, int total)? onProgress, void Function()? onDone}) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      return;
    }

    List<dynamic> interventionsList = [];
    try {
      final response = await dio().get(
        '/essais/interventions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final resp = response.data;
        if (resp is List) {
          interventionsList = resp;
        } else if (resp is Map<String, dynamic>) {
          if (resp['data'] is List) {
            interventionsList = resp['data'] as List<dynamic>;
          } else if (resp['interventions'] is List) {
            interventionsList = resp['interventions'] as List<dynamic>;
          } else {
            for (final v in resp.values) {
              if (v is List) {
                interventionsList = v;
                break;
              }
            }
          }
        }
      }
    } catch (_) {}

    if (interventionsList.isEmpty) {
      return;
    }

    try {
      await LocalDatabase.saveReferences({'commandes': interventionsList});
    } catch (_) {}

    final ids = <String>[];
    for (final it in interventionsList) {
      final id = (it['pe_id'] ?? it['peId'] ?? '').toString();
      if (id.isNotEmpty) ids.add(id);
    }
    if (ids.isEmpty) {
      return;
    }

    final total = ids.length;
    onStart?.call(total);
    int completed = 0;
    int i = 0;
    while (i < ids.length) {
      final end = (i + batchSize) > ids.length ? ids.length : (i + batchSize);
      final chunk = ids.sublist(i, end);
      await Future.wait(chunk.map((id) async {
        try {
          int attempt = 0;
          const int maxRetries = 2;
          while (attempt < maxRetries) {
            try {
              await fetchInterventions(id);
              break;
            } catch (_) {
              attempt++;
              await Future.delayed(Duration(milliseconds: 300 * attempt));
              if (attempt >= maxRetries) {
                break;
              }
            }
          }
        } finally {
          completed++;
          onProgress?.call(completed, total);
        }
      }));
      i = end;
    }
    onDone?.call();
  }
Future<void> saveLocalInterventionChanges({
  required String peId,
  required Map<String, dynamic> interventionData,
  required List<Elemouvrage> elementsOuvrage,
  required List<Map<String, dynamic>> constituants,
  required List<Map<String, dynamic>> seriesEprouvettes,
  required List<String?> motifsNonPrelevement,
  required Map<String, dynamic> interventionuser,
}) async {
  try {
    await LocalDatabase.saveCompleteIntervention(
      peId: peId,
      interventionData: {
        ...interventionData,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      elementsOuvrage: elementsOuvrage,
      constituants: constituants,
      seriesEprouvettes: seriesEprouvettes,
      motifsNonPrelevement: motifsNonPrelevement,
   
    );
    print("MODIFICATIONS LOCALES: Sauvegardées pour $peId");
  } catch (e) {
    print("ERREUR sauvegarde locale: $e");
    rethrow;
  }
}

Future<void> fetchAndStoreAllInterventions(String? peId) async {
  try {
    print("🔄 DÉBUT DE LA SYNCHRONISATION DES INTERVENTIONS");

    // Lancer les deux futures en parallèle
    final results = await Future.wait([
      fetchInterventions(peId), // Récupérer une intervention spécifique
      fetchAllInterventionsComplete(), // Récupérer toutes les interventions
    ]);

    // Stocker les résultats
    final interventionDetails = results[0] as Interventions;
    final allInterventions = results[1] as List<Map<String, dynamic>>;

    print("✅ SYNCHRONISATION TERMINÉE");
    print("📥 Détails de l'intervention spécifique : ${interventionDetails.intervention}");
    print("📊 Nombre total d'interventions récupérées : ${allInterventions.length}");

    // Sauvegarder les détails de l'intervention spécifique
    await LocalDatabase.saveCompleteIntervention(
      peId: peId!,
      interventionData: interventionDetails.intervention,
      elementsOuvrage: interventionDetails.elementsouvrages,
      constituants: interventionDetails.constituants.map((c) => c.toJson()).toList(),
      seriesEprouvettes: interventionDetails.series,
 
      motifsNonPrelevement: [],
    );

    // Sauvegarder toutes les interventions
    for (final intervention in allInterventions) {
      try {
        final peId = intervention['pe_id']?.toString();
        
        // Skip si pas de peId
        if (peId == null || peId.isEmpty) {
          print("⚠️ Skipping save: pe_id manquant");
          continue;
        }

        // Skip si erreur lors du fetch
        if (intervention.containsKey('error')) {
          print("⚠️ Skipping save for $peId due to fetch error: ${intervention['error']}");
          continue;
        }

        final completeData = intervention['complete_data'] as Map<String, dynamic>?;
        
        // Skip si pas de données complètes
        if (completeData == null) {
          print("⚠️ Skipping save for $peId: complete_data missing");
          continue;
        }

        await LocalDatabase.saveCompleteIntervention(
          peId: peId,
          interventionData: completeData['intervention'],
          elementsOuvrage: completeData['elements_ouvrage'],
          constituants: completeData['constituants'],
          seriesEprouvettes: completeData['series'],
          motifsNonPrelevement: [],
        );
      } catch (e) {
        print("❌ Error saving intervention ${intervention['pe_id']}: $e");
        // Continue to next intervention instead of aborting all
      }
    }

    print("💾 SAUVEGARDE TERMINÉE POUR TOUTES LES INTERVENTIONS");
  } catch (e) {
    print("❌ ERREUR LORS DE LA SYNCHRONISATION : $e");
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> fetchAllInterventionsComplete() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  print('🌐 DÉBUT CHARGEMENT COMPLET INTERVENTIONS');

  try {
    // Récupérer la liste des interventions
    final response = await dio().get(
      '/essais/interventions',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur API: ${response.statusCode}');
    }

    List<dynamic> interventionsList = [];
    final resp = response.data;
    
    // Extraire la liste
    if (resp is List) {
      interventionsList = resp;
    } else if (resp is Map<String, dynamic>) {
      if (resp['data'] is List) {
        interventionsList = resp['data'] as List<dynamic>;
      } else if (resp['interventions'] is List) {
        interventionsList = resp['interventions'] as List<dynamic>;
      } else {
        for (final v in resp.values) {
          if (v is List) {
            interventionsList = v;
            break;
          }
        }
      }
    }

    print('📊 ${interventionsList.length} interventions à charger');

    // Charger les données complètes pour chaque intervention
    List<Map<String, dynamic>> result = [];
    
    for (var intervention in interventionsList) {
      final peId = intervention['pe_id']?.toString();
      if (peId != null) {
        try {
          print('📥 Chargement: $peId');
          final completeData = await fetchInterventions(peId);
          
          result.add({
            'pe_id': peId,
            'intervention_data': intervention,
            'complete_data': {
              'intervention': completeData.intervention,
              'elements_ouvrage': completeData.elementsouvrages,
              'constituants': completeData.constituants,
              'series': completeData.series,
            }
          });
        } catch (e) {
          print('⚠️ Erreur $peId: $e');
          result.add({
            'pe_id': peId,
            'intervention_data': intervention,
            'error': e.toString()
          });
        }
      }
    }

    print('✅ CHARGEMENT COMPLET TERMINÉ: ${result.length} interventions');
    return result;

  } catch (e) {
    print('❌ Erreur chargement complet: $e');
    // Fallback: données locales
    return await _getAllLocalInterventionsComplete();
  }
}

// Fonction helper pour les données locales
Future<List<Map<String, dynamic>>> _getAllLocalInterventionsComplete() async {
  try {
    final db = await LocalDatabase.database;
    final interventions = await db.query('interventions');
    
    List<Map<String, dynamic>> result = [];
    
    for (var intervention in interventions) {
      final peId = intervention['pe_id']?.toString();
      if (peId != null) {
        final elements = await LocalDatabase.getElementsOuvrage(peId);
        final constituants = await LocalDatabase.getConstituants(peId);
        
        result.add({
          'pe_id': peId,
          'intervention_data': intervention,
          'complete_data': {
            'intervention': intervention,
            'elements_ouvrage': elements,
            'constituants': constituants,
          },
          'is_local': true,
        });
      }
    }
    
    return result;
  } catch (e) {
    print('❌ Erreur données locales: $e');
    return [];
  }
}


// Convertir l'objet Intervention en Map pour le stockage
Map<String, dynamic> _convertInterventionToMap(Interventions intervention) {
  return {
    'intervention': intervention.intervention,
    'affaire': intervention.affaire,
    'chargeAffaire': intervention.chargeAffaire,
    'commandes': intervention.commandes?.map((c) => c.toJson()).toList(),
    'betons': intervention.betons?.map((b) => b.toJson()).toList(),
    'elementsouvrages': intervention.elementsouvrages?.map((e) => e.toJson()).toList(),
    'constituants': intervention.constituants?.map((c) => c.toJson()).toList(),
    'series': intervention.series,
    'elementPredefini': intervention.elementPredefini?.map((e) => e.toJson()).toList(),
    'modePro': intervention.modePro?.map((m) => m.toJson()).toList(),
    'carrieres': intervention.carrieres?.map((c) => c.toJson()).toList(),
    'typeciment': intervention.typeciment?.map((t) => t.toJson()).toList(),
    'typeAdjuvant': intervention.typeAdjuvant?.map((t) => t.toJson()).toList(),
    'typeEprouvette': intervention.typeEprouvette?.map((t) => t.toJson()).toList(),
  };
}

// Sauvegarder le cache complet
Future<void> _saveCompleteInterventionsCache(List<Map<String, dynamic>> interventions) async {
  try {
    final storage = FlutterSecureStorage();
    final jsonData = jsonEncode(interventions);
    await storage.write(key: 'complete_interventions_cache', value: jsonData);
    await storage.write(key: 'cache_timestamp', value: DateTime.now().toIso8601String());
    print('💾 Cache sauvegardé: ${interventions.length} interventions');
  } catch (e) {
    print('❌ Erreur sauvegarde cache: $e');
  }
}

// Charger depuis le cache
Future<List<Map<String, dynamic>>> getCachedCompleteInterventions() async {
  try {
    final storage = FlutterSecureStorage();
    final cachedData = await storage.read(key: 'complete_interventions_cache');
    
    if (cachedData != null) {
      final interventions = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      print('📖 Cache chargé: ${interventions.length} interventions');
      return interventions;
    }
  } catch (e) {
    print('❌ Erreur chargement cache: $e');
  }
  return [];
}



  // ===================================================================
  // SAUVEGARDE COMPLÈTE
  // ===================================================================
  Future<void> _saveCompleteInterventionToLocalDB(String interventionId, Map<String, dynamic> data) async {
    try {
      final interventions = _parseInterventionData(data);
      final interventionData = _prepareInterventionData(interventionId, data);

      await _saveReferencesToLocalDB(data);
      print("RÉFÉRENCES: sauvegardées");
  final elementsOuvrage = interventions.elementsouvrages;
    print("📥 ÉLÉMENTS OUVRAGE À SAUVEGARDER: ${elementsOuvrage.length}");

      await LocalDatabase.saveCompleteIntervention(
        peId: interventionId,
        interventionData: interventionData,
        elementsOuvrage: interventions.elementsouvrages,
        constituants: _prepareConstituantsForLocal(interventions.constituants),
        seriesEprouvettes: interventions.series,
        
        motifsNonPrelevement: _getMotifsFromIntervention(data['intervention']),
      );

      print("SAUVEGARDE COMPLÈTE: $interventionId → OK");
    } catch (e) {
      print("ERREUR sauvegarde: $e");
      rethrow;
    }
  }

  // ===================================================================
  // RÉFÉNCES
  // ===================================================================
  Future<void> _saveReferencesToLocalDB(Map<String, dynamic> data) async {
    try {
      print("📥 Données brutes reçues:");
      print("  - beton: ${(data['beton'] as List?)?.length ?? 0} items");
      print("  - modesProduction: ${(data['modesProduction'] as List?)?.length ?? 0} items");
      print("  - carrieres: ${(data['carrieres'] as List?)?.length ?? 0} items");

      // ✅ FIX: Passer les listes directement, pas les objets convertis
      final referencesMap = {
        'commandes': data['commandes'] ?? [],
        'beton': data['beton'] ?? [],
        'elementPredefini': data['famille_elements'] ?? [],
        'modePro': data['modesProduction'] ?? [],
        'carrieres': data['carrieres'] ?? [],
        'typeciment': data['types_ciments'] ?? [],
        'typeAdjuvant': data['types_adjuvants'] ?? [],
        'typeEprouvette': data['types_eprouvettes'] ?? [],
      };

      print("📊 Appel LocalDatabase.saveReferences avec:");
      referencesMap.forEach((key, value) {
        print("  - $key: ${(value as List).length} items");
      });

      await LocalDatabase.saveReferences(referencesMap);

      print("✅ RÉFÉRENCES SAUVÉES AVEC SUCCÈS");
    } catch (e) {
      print("❌ ERREUR références: $e");
      rethrow;
    }
  }

  // ===================================================================
  // CONSTITUANTS → FORMAT LOCAL
  // ===================================================================
  List<Map<String, dynamic>> _prepareConstituantsForLocal(List<Constituant> constituants) {
    return constituants.map((c) {
   final Map<String, dynamic> map = {
  'fb_constituant': c.fbConstituant, 
  'type': c.fbType,
  'dosage': c.fbDosage,
   'fb_type': c.fbType, 
   'fb_provenance': c.fbProvenance,
};

      switch (c.fbConstituant) {
        case "1":
          map['prov'] = c.fbProvenance;
          map['dmin'] = c.fbDmin?.toInt() ?? 0;
          map['dmax'] = c.fbDmax?.toInt() ?? 0;
          break;
        case "2":
          map['prov'] = c.fbProvenance;
          map['dmax'] = c.fbDmax?.toInt() ?? 0;
          break;
        case "3":
          map['prov'] = c.fbProvenance;
          map['type'] = c.fbType ?? '';
          break;
        case "4":
          map['prov'] = c.fbProvenance;
          map['type'] = c.fbType ?? '';
          break;
        case "5":
          map['type'] = c.fbType ?? '';
          map['nomProduit'] = c.fbProvenance;
          break;
        case "6":
          map['source'] = c.fbProvenance;
          break;
      }
      return map;
    }).toList();
  }

  String _getConstituantCategory(String code) {
    switch (code) {
      case "1": return "granulas";
      case "2": return "sables";
      case "3": return "ciment";
      case "4": return "adjuvant";
      case "6": return "additif";
      case "5": return "eau";
      default: return "autre";
    }
  }

  // ===================================================================
  // SÉRIES LOCALES
  // ===================================================================
  Future<List<Map<String, dynamic>>> _getSeriesFromLocal(String interventionId) async {
    try {
      final db = await LocalDatabase.database;
      final intervention = await LocalDatabase.getIntervention(interventionId);
      if (intervention == null) return [];

      final series = await db.query(
        'series_eprouvettes',
        where: 'intervention_id = ?',
        whereArgs: [intervention['id']],
        orderBy: 'serie_order ASC',
      );

      final result = <Map<String, dynamic>>[];
      for (var s in series) {
        final eprouvettes = await db.query(
          'eprouvettes',
          where: 'serie_id = ?',
          whereArgs: [s['id']],
        );
        result.add({
          'Age': s['age'],
          'Forme': s['forme'],
          'NbrEchantillion': s['nbr_echantillon'],
          'eprouvettes': eprouvettes.map((e) => {'epr_id': e['epr_id']}).toList(),
        });
      }
      print("SÉRIES LOCALES: ${result.length} récupérées");
      return result;
    } catch (e) {
      print("ERREUR séries: $e");
      return [];
    }
  }

  // ===================================================================
  // COMMANDES LOCALES
  // ===================================================================
  Future<List<Commande>> _getCommandesLocal() async {
    try {
      final db = await LocalDatabase.database;
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('commandes', 'interventions_recu')");
      if (tables.isNotEmpty) {
        final table = tables.any((r) => r['name'] == 'commandes') ? 'commandes' : 'interventions_recu';
        final rows = await db.query(table);
        return rows.map((r) {
          try {
            return Commande.fromJson(r);
          } catch (_) {
            return Commande.fromJson({
              'NumCommande': r['NumCommande'] ?? r['num_commande'] ?? 'Inconnue'
            });
          }
        }).toList();
      }
    } catch (e) {
      print("ERREUR commandes DB: $e");
    }

    try {
      final vp = await LocalDatabase.instance.getAllCommandes();
      print("FALLBACK commandes: ${vp.length} depuis ancienne DB");
      return vp;
    } catch (_) {
      return [];
    }
  }

  // ===================================================================
  // CONSTRUCTION LOCALE
  // ===================================================================
Interventions _buildInterventionFromLocal(
  Map<String, dynamic> intervention,
  List<Map<String, dynamic>> elementsOuvrage,
  List<Map<String, dynamic>> constituants,
  List<Map<String, dynamic>> eprouvettes,
  List<Map<String, dynamic>> series,
  List<Commande> commandesLocal,
  String interventionId,
) {
  Map<String, dynamic> chargeAffaireData = {};
  Map<String, dynamic> userData = {};

  try {
    // Charger le chargé d'affaire
    final chargeAffaireJson = intervention['charge_affaire_id']?.toString();
    if (chargeAffaireJson != null && chargeAffaireJson.isNotEmpty) {
      chargeAffaireData = Map<String, dynamic>.from(jsonDecode(chargeAffaireJson));
    }
  } catch (e) {
    print("❌ ERREUR parsing charge_affaire: $e");
  }

  try {
    // Charger l'utilisateur (même méthode)
    final userJson = intervention['user_data']?.toString();
    if (userJson != null && userJson.isNotEmpty) {
      userData = Map<String, dynamic>.from(jsonDecode(userJson));
    }
  } catch (e) {
    print("❌ ERREUR parsing user_data: $e");
  }

  final normalized = {
    ...intervention,
    'classeBeton': intervention['classe_beton_id'] ?? intervention['classeBeton'],
    'catChantier': intervention['categorie_chantier'] ?? intervention['catChantier'],
    'entreprise_real': intervention['entreprise_real'] ?? intervention['EntrepriseRealisation'],
    'intitule_affaire': intervention['intitule_affaire'] ?? intervention['IntituleAffaire'],
    'commande_id': intervention['commande_id'] ?? intervention['NumCommande'],
    'pe_id': intervention['pe_id'] ?? intervention['peid'] ?? interventionId,
    'chargedaffaire': {
      'matricule': chargeAffaireData['Matricule'],
      'nom': chargeAffaireData['Nom'],
      'prenom': chargeAffaireData['Prénom'],
    },
    'user': {
      'matricule': userData['Matricule'],
      'nom': userData['Nom'],
      'prenom': userData['Prénom'],
      'structure': userData['Structure'],
    },
  };

  final safeConstituants = constituants.map((c) => {
    ...c,
    'fb_dmin': _safeToInt(c['dmin']),
    'fb_dmax': _safeToInt(c['dmax']),
    'fb_dosage': _safeToDouble(c['dosage']),
  }).toList();

  return Interventions(
    commandes: commandesLocal,
    betons: [],
    elementPredefini: [],
    modePro: [],
    carrieres: [],
    typeciment: [],
    typeAdjuvant: [],
    typeEprouvette: [],
    intervention: normalized,
    affaire: {'IntituleAffaire': normalized['intitule_affaire']},
    elementsouvrages: elementsOuvrage.map((e) => Elemouvrage.fromJson(e)).toList(),
    chargeAffaire: {},
    constituants: safeConstituants.map((c) => Constituant.fromJson(c)).toList(),
    eprouvettes: eprouvettes.map((e) => Eprouvette.fromJson(e)).toList(),
    series: series,
    //interventionuser: userData.isNotEmpty ? userData : {},
  );
}
  int _safeToInt(dynamic v) => v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0);
  double _safeToDouble(dynamic v) => v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? 0.0);

  // ===================================================================
  // HELPERS
  // ===================================================================
  Future<List<T>> _safeGetList<T>(Future<List<T>> future, String name) async {
    try {
      final list = await future;
      print("LOCAL: $name → ${list.length}");
      return list;
    } catch (e) {
      print("ERREUR $name: $e");
      return [];
    }
  }

  Map<String, dynamic> _prepareInterventionData(String interventionId, Map<String, dynamic> data) {
    final i = data['intervention'] as Map<String, dynamic>;
    final chargeAffaire = data['charge_affaire'] as Map<String, dynamic>? ?? {};
      final userData = data['user'] as Map<String, dynamic>? ?? {};
    final chargeAffaireSimplified = {
      'Matricule': chargeAffaire['Matricule']?.toString() ?? '',
      'Nom': chargeAffaire['Nom']?.toString() ?? '',
      'Prénom': chargeAffaire['Prénom']?.toString() ?? '',
    };
      final userSimplified = {
    'Matricule': userData['Matricule']?.toString() ?? '',
    'Nom': userData['Nom']?.toString() ?? '',
    'Prénom': userData['Prénom']?.toString() ?? '',
    'Structure': userData['Structure']?.toString() ?? '',
  };
    return {
      'pe_id': interventionId,
      'pe_date': i['pe_date'],
      'pe_heure': i['pe_heure'],
      'pe_temp': double.tryParse(i['pe_temp'].toString()),
      'pe_affais_cone': double.tryParse(i['pe_affais_cone'].toString()),
      'pe_cim_ec': double.tryParse(i['pe_cim_ec'].toString()),
      'pe_obs': i['pe_obs'],
      'date_validation_laboratoire_item': i['date_validation_laboratoire_it'],
      'pe_mode_prod': i['pe_mode_prod'],
      'charge_affaire_id': jsonEncode(chargeAffaireSimplified),
      'commande_id': _extractNumCommande(data),
      'classe_beton_id': i['classeBeton'],
      'intitule_affaire': data['affaire']?['IntituleAffaire'],
      'Code_Affaire': i['Code_Affaire'],
       'Code_Site': i['Code_Site'],
      'categorie_chantier': i['catChantier'],
  'user_data': jsonEncode(userSimplified),
      'entreprise_real': i['entreprise_real'],
      'date_validation_pm': i['date_validation_pm'] ?? data['date_validation_pm'],
      'is_synced': 1,
    };
  }

  String? _extractNumCommande(Map<String, dynamic> data) {
    try {
      return (data['series'] as List?)?.firstOrNull?['NumCommande']?.toString();
    } catch (_) {}
    try {
      return (data['commandes'] as List?)?.firstOrNull?['NumCommande']?.toString();
    } catch (_) {}
    return null;
  }

  List<String?> _getMotifsFromIntervention(Map<String, dynamic> i) {
    return List.generate(5, (idx) => i['motif_non_prelevement${idx + 1}']);
  }

  // ===================================================================
  // PARSING API
  // ===================================================================
  Interventions _parseInterventionData(Map<String, dynamic> data) {
    print("DEBUG: _parseInterventionData keys: ${data.keys.toList()}");
    final rawElements = data['elements_ouvrages'] ?? 
                       data['elementOuvrages'] ?? 
                       data['ElementOuvrages'] ?? 
                       data['elementOuvrage'];
    print("DEBUG: rawElements type: ${rawElements.runtimeType}, value: $rawElements");

    final commandes = (data['commandes'] as List?)?.map((j) => Commande.fromJson(j)).toList() ?? [];
    final betons = (data['beton'] as List?)?.map((j) => ClasseBeton.fromJson(j)).toList() ?? [];
    final elementPredefini = (data['famille_elements'] as List?)?.map((j) => ElementPredefini.fromJson(j)).toList() ?? [];
    final modePro = (data['modesProduction'] as List?)?.map((j) => ModesProduction.fromJson(j)).toList() ?? [];
    final carrieres = (data['carrieres'] as List?)?.map((j) => ClasseCarrieres.fromJson(j)).toList() ?? [];
    final typeciment = (data['types_ciments'] as List?)?.map((j) => TypeCiments.fromJson(j)).toList() ?? [];
    final typeAdjuvant = (data['types_adjuvants'] as List?)?.map((j) => TypeAdjuvants.fromJson(j)).toList() ?? [];
    final typeEprouvette = (data['types_eprouvettes'] as List?)?.map((j) => TypeEprouvettes.fromJson(j)).toList() ?? [];
    final constituants = (data['constituants'] as List?)?.map((j) => Constituant.fromJson(j)).toList() ?? [];
    final eprouvettes = (data['eprouvettes'] as List?)?.map((j) => Eprouvette.fromJson(j)).toList() ?? [];
    final series = (data['series'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    final elementsouvrages = (rawElements as List?)?.map((j) => Elemouvrage.fromJson(j)).toList() ?? [];
    
    final chargeAffaire = data['charge_affaire'] ?? {};
    final interventionuser = data['user'] ?? {};
    print("API: ${commandes.length} commandes, ${constituants.length} constituants, ${series.length} séries");

    return Interventions(
      series: series,
      commandes: commandes,
      betons: betons,
      elementPredefini: elementPredefini,
      modePro: modePro,
      carrieres: carrieres,
      typeciment: typeciment,
      typeAdjuvant: typeAdjuvant,
      typeEprouvette: typeEprouvette,
      intervention: data['intervention'],
      affaire: data['affaire'],
      elementsouvrages: elementsouvrages,
//interventionuser: interventionuser,
      chargeAffaire: chargeAffaire,
      constituants: constituants,
      eprouvettes: eprouvettes,

    );
  }
   // ===================================================================
  // SAUVEGARDE COMME BROUILLON
  // ===================================================================
  Future<void> saveInterventionAsDraft({
    required String peId,
    required Map<String, dynamic> interventionData,
    required List<Elemouvrage> elementsOuvrage,
    required List<Map<String, dynamic>> constituants,
    required List<Map<String, dynamic>> seriesEprouvettes,
    required List<String?> motifsNonPrelevement,
        
  }) async {
    try {
      print("💾 SAUVEGARDE BROUILLON: Début pour $peId");

      // Préparer les données complètes de l'intervention
      final completeInterventionData = {
        'pe_id': peId,
        'Validation_labo': 0,// 0 = brouillon
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0, // Non synchronisé avec l'API
        ...interventionData,
      };

      // Sauvegarder l'intervention complète
      await LocalDatabase.saveCompleteIntervention(
        peId: peId,
        interventionData: completeInterventionData,
        elementsOuvrage: elementsOuvrage,
        constituants: constituants,
        seriesEprouvettes: seriesEprouvettes,
      
        motifsNonPrelevement: motifsNonPrelevement,
      );

      print("✅ BROUILLON SAUVEGARDÉ: $peId");
    } catch (e) {
      print("❌ ERREUR sauvegarde brouillon: $e");
      rethrow;
    }
  }

  // ===================================================================
  // VALIDATION DE L'INTERVENTION
  // ===================================================================
  Future<void> validateIntervention({
    required String peId,
    required Map<String, dynamic> interventionData,
    required List<Elemouvrage> elementsOuvrage,
    required List<Map<String, dynamic>> constituants,
    required List<Map<String, dynamic>> seriesEprouvettes,
    required List<String?> motifsNonPrelevement,
       r
  }) async {
    try {
      print("✅ VALIDATION: Début pour $peId");

      // Préparer les données avec statut validé
      final completeInterventionData = {
        'pe_id': peId,
        'Validation_labo': 1, // 1 = validée
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0, // À synchroniser plus tard
        ...interventionData,
      };

      // Sauvegarder comme intervention validée
      await LocalDatabase.saveCompleteIntervention(
        peId: peId,
        interventionData: completeInterventionData,
        elementsOuvrage: elementsOuvrage,
        constituants: constituants,
        seriesEprouvettes: seriesEprouvettes,
        motifsNonPrelevement: motifsNonPrelevement,
      

      );

      print("🎉 INTERVENTION VALIDÉE: $peId");
    } catch (e) {
      print("❌ ERREUR validation: $e");
      rethrow;
    }
  }

  // ===================================================================
  // RÉCUPÉRATION INTERVENTION LOCALE
  // ===================================================================
  Future<Map<String, dynamic>?> getLocalIntervention(String peId) async {
    try {
      return await LocalDatabase.getIntervention(peId);
    } catch (e) {
      print("❌ ERREUR récupération locale: $e");
      return null;
    }
  }

  // ===================================================================
  // VÉRIFICATION STATUT INTERVENTION
  // ===================================================================
  Future<bool> isInterventionDraft(String peId) async {
    try {
      final intervention = await LocalDatabase.getIntervention(peId);
      if (intervention == null) return true; // Si pas trouvé, considérer comme brouillon
      
      final validation = intervention['Validation_labo'];
      final int? validationValue = int.tryParse(validation?.toString() ?? '');
      
      return validationValue == 0 || validationValue == null;
    } catch (e) {
      print("❌ ERREUR vérification statut: $e");
      return true;
    }
  }

  // ===================================================================
  // SYNCHRONISATION AVEC L'API (OPTIONNEL)
  // ===================================================================
  Future<void> syncInterventionToAPI(String peId) async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception("Token manquant pour la synchronisation");
      }

      // Récupérer les données locales
      final intervention = await LocalDatabase.getIntervention(peId);
      final elementsOuvrage = await LocalDatabase.getElementsOuvrage(peId);
      final constituants = await LocalDatabase.getConstituants(peId);
      final seriesEprouvettes = await _getSeriesFromLocal(peId);

      if (intervention == null) {
        throw Exception("Intervention non trouvée localement");
      }

      // Préparer les données pour l'API
      final syncData = {
        'intervention': intervention,
        'elements_ouvrages': elementsOuvrage,
        'constituants': constituants,
        'series': seriesEprouvettes,
      };

      // Envoyer à l'API
      final response = await dio().post(
        '/essais/syncIntervention',
        data: syncData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Marquer comme synchronisé
        await LocalDatabase.updateInterventionSyncStatus(peId, 1);
        print("🔄 SYNCHRONISATION RÉUSSIE: $peId");
      } else {
        throw Exception("Erreur API: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ERREUR synchronisation: $e");
      rethrow;
    }
  }
}

Future<List<Constituant>> loadLocalConstituants(String peId) async {
  try {
    print("📥 CHARGEMENT CONSTITUANTS LOCAUX: $peId");
    
    final localCons = await LocalDatabase.getConstituants(peId);
    
    if (localCons.isEmpty) {
      print("⚠️ Aucun constituant local trouvé pour $peId");
      return [];
    }
    
    final result = localCons.map((c) => Constituant.fromJson(c)).toList();
    print("✅ CONSTITUANTS CHARGÉS: ${result.length} constituants");
    return result;
  } catch (e) {
    print("❌ ERREUR chargement constituants locaux: $e");
    return [];
  }
}

// ===================================================================
// REMPLISSAGE DES LISTES DE CONSTITUANTS (HELPER)
// ===================================================================
void fillConstituantLists({
  required List<Constituant> constituants,
  required List<ClasseCarrieres> carrieres,
  required List<TypeCiments> typeciment,
  required List<TypeAdjuvants> typeAdjuvant,
  required Map<String, List<dynamic>> result,
}) {
  // Initialiser les listes
  result['granulas'] = [];
  result['sables'] = [];
  result['ciment'] = [];
  result['adjuvant'] = [];
  result['additifs'] = [];
  result['eau'] = [];

  for (var c in constituants) {
    switch (c.fbConstituant) {
      case "1": // Granulas
        result['granulas']!.add({
          "prov": carrieres.isNotEmpty
              ? carrieres.firstWhere(
                  (car) => car.value.toString() == c.fbProvenance,
                  orElse: () => carrieres.first,
                )
              : null,
          "dosage": c.fbDosage ?? 0,
          "dmin": c.fbDmin ?? 0,
          "dmax": c.fbDmax ?? 0,
        });
        break;

      case "2": // Sables
        result['sables']!.add({
          "prov": carrieres.isNotEmpty
              ? carrieres.firstWhere(
                  (car) => car.value.toString() == c.fbProvenance,
                  orElse: () => carrieres.first,
                )
              : null,
          "dosage": c.fbDosage ?? 0,
          "dmax": c.fbDmax ?? 0,
        });
        break;

      case "3": // Ciment
        result['ciment']!.add({
          "prov": c.fbProvenance,
          "type": typeciment.isNotEmpty
              ? typeciment.firstWhere(
                  (tc) => tc.value.toString() == (c.fbType ?? ""),
                  orElse: () => typeciment.first,
                )
              : null,
          "dosage": c.fbDosage ?? 0,
        });
        break;

      case "4": // Adjuvant
        result['adjuvant']!.add({
          "prov": c.fbProvenance,
          "type": typeAdjuvant.isNotEmpty
              ? typeAdjuvant.firstWhere(
                  (ta) => ta.value.toString() == (c.fbType ?? ""),
                  orElse: () => typeAdjuvant.first,
                )
              : null,
          "dosage": c.fbDosage ?? 0,
        });
        break;

      case "5": // Additifs
        result['additifs']!.add({
          "type": c.fbType,
          "nomProduit": c.fbProvenance,
          "dosage": c.fbDosage ?? 0,
        });
        break;

      case "6": // Eau
        result['eau']!.add({
          "source": c.fbProvenance,
          "dosage": c.fbDosage ?? 0,
        });
        break;
    }
  }

  print("✅ CONSTITUANTS REMPLIS: "
      "granulas=${result['granulas']!.length}, "
      "sables=${result['sables']!.length}, "
      "ciment=${result['ciment']!.length}, "
      "adjuvant=${result['adjuvant']!.length}, "
      "additifs=${result['additifs']!.length}, "
      "eau=${result['eau']!.length}");
} 

Future<Interventions> fetchInterventions(String? pe_id) => InterventionsService().fetchInterventions(pe_id);
