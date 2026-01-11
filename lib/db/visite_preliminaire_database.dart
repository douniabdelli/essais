// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
// import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
// import 'package:mgtrisque_visitepreliminaire/models/intervention.dart';
// import 'package:mgtrisque_visitepreliminaire/models/user.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import '../db/intervention_model.dart'; 

// class VisitePreliminaireDatabase {
  
//   static const String _dbFileName = 'visite_preliminaire.db';

//   static final VisitePreliminaireDatabase instance =
//   VisitePreliminaireDatabase._init();
//   static Database? _database;
//   VisitePreliminaireDatabase._init();
//   Future<Database> get database async {
//     if (_database != null) return _database!;

    
//     _database = await _initDB(_dbFileName);
//     return _database!;
//   }



//   Future<void> deleteLocalDatabase() async {
//     final dbPath = await getDatabasesPath();
    
//     final path = join(dbPath, _dbFileName);
//     await deleteDatabase(path);
//     print('🗑️ Base de données supprimée : $path');
//   }
// // Future<void> saveIntervention(String codeCommande, Map<String, dynamic> json) async {
// //   final db = await database;

// //   await db.insert(
// //     "local_interventions",
// //     {
// //       "CodeCommande": codeCommande,
// //       "raw_data": jsonEncode(json),
// //       "created_at": DateTime.now().toIso8601String(),
// //     },
// //     conflictAlgorithm: ConflictAlgorithm.replace,
// //   );
// // }


// Future<void> createInterventions(List<dynamic> interventions) async {
//   final db = await instance.database;
//   print('📦 [DB] Début de l\'insertion des interventions (${interventions.length})...');
//   await db.transaction((txn) async {
//     for (var element in interventions) {
//       try {
//         Map<String, dynamic> interventionData;
//         if (element is Map<String, dynamic>) {
//           interventionData = element;
//         } else {    
//           interventionData = element.toJson();
//         }
        
//         final intervention = Intervention.fromJson(interventionData);
//         print('🟢 Insertion intervention CodeCommande: ${intervention.numCommande}');
        
//         final cleanMap = Map<String, dynamic>.fromEntries(
//           interventionData.entries.map((entry) {
//             final key = entry.key;
//             var value = entry.value;
//             if (value is Map || (value is List && value.isNotEmpty)) {
//               try {
//                 value = jsonEncode(value);
//               } catch (_) {
//                 value = value.toString();
//               }
//             }
//             return MapEntry(key, value);
//           }).where((entry) {
//             final v = entry.value;
//             return v == null || v is num || v is String || v is Uint8List;
//           })
//         );

//         await txn.insert(
//           'interventions', 
//           cleanMap,
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//       } catch (e) {
//         print('❌ Erreur lors de l\'insertion d\'une intervention: $e');
//         print('❌ Données problématiques: $element');
//       }
//     }
//   });
//   print('✅ [DB] Insertion des interventions terminée.');
// }

//  Future<Database> _initDB(String filePath) async {
//   final dbPath = await getDatabasesPath();
//   final path = join(dbPath, filePath);

//   return await openDatabase(
//     path,
//     version: 24,
//     onCreate: _createDB,
//     onUpgrade: (db, oldVersion, newVersion) async {
//       if (oldVersion < 5) {
//    await db.execute("ALTER TABLE commandes ADD COLUMN Age1 TEXT");
//       await db.execute("ALTER TABLE commandes ADD COLUMN Age2 TEXT");
//       await db.execute("ALTER TABLE commandes ADD COLUMN Age3 TEXT");
//       await db.execute("ALTER TABLE commandes ADD COLUMN Age4 TEXT");
//       await db.execute("ALTER TABLE commandes ADD COLUMN Age5 TEXT");
    
//         await db.execute('DROP TABLE IF EXISTS commandes');
//         await _createDB(db, newVersion);
//       }
//     },
//   );
// }

// Future<void> debugTableSchema() async {
//   final db = await instance.database;
//   try {
//     final result = await db.rawQuery('PRAGMA table_info(commandes)');
//     print('📋 Schema de la table commandes:');
//     for (var column in result) {
//       print(' - ${column['name']} (${column['type']})');
//     }
//   } catch (e) {
//     print('❌ Erreur lors de la lecture du schéma: $e');
//   }
// }

//   Future _createDB(Database db, int version) async {
//     String userQuery = '''
//       CREATE TABLE IF NOT EXISTS users(        
//         matricule TEXT, 
//         structure TEXT,
//         nom TEXT,
//         prenom TEXT,
//         password TEXT,
//         privilege TEXT,
//         role TEXT,
//         consultation TEXT,
//         insertion TEXT,
//         modification TEXT,
//         suppression TEXT
//       )
//     ''';

//  String commandesQuery = '''
//     CREATE TABLE IF NOT EXISTS commandes(
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//      CodeCommande TEXT,
//       NumCommande TEXT,
//       Code_Site Text,
//       IntituleAffaire TEXT,
//       peid TEXT,
//       pe_id TEXT,
//       Code_Affaire TEXT,
//       pe_date_pv TEXT,
//       ChargedAffaire TEXT,
//       CatChantier TEXT,
//       Validation_labo TEXT,
//       user_code TEXT,
//       Nom_DR_Laboratoire TEXT,
//       Structure_Laboratoire TEXT,
//       TypeIntervention TEXT,
//       Motif_non_prelevement TEXT,
//       Ouvrage TEXT,
//       Bloc TEXT,
//       ElemBloc TEXT,
//       Localisation TEXT,
//       Age1 TEXT,
//       Age2 TEXT,
//       Age3 TEXT,
//       Age4 TEXT,
//       Age5 TEXT,
// Structure Text,
//       Partie_Ouvrage TEXT,
//       Entreprises TEXT,
//       Blocs TEXT,
//       Elemouvrages TEXT,
//         EntrepriseRealisation TEXT,   -- <-- colonne pour stocker JSON ou nom
//       maitre_ouvrage TEXT 
//     )
//   ''';

  
//  String interventionsQuery = '''
//     CREATE TABLE IF NOT EXISTS interventions(
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       Structure TEXT,
//       Nom_DR TEXT,
//       bet Text,
//       CodeCommande TEXT,
//       NumCommande TEXT,
//       Code_Site Text,
//       IntituleAffaire TEXT,
//       peid TEXT,
//       pe_id TEXT,
//       Code_Affaire TEXT,
//       pe_date_pv TEXT,
//       ChargedAffaire TEXT,
//       CatChantier TEXT,
//       Validation_labo TEXT,
//       user_code TEXT,
//       Nom_DR_Laboratoire TEXT,
//       Structure_Laboratoire TEXT,
//       TypeIntervention TEXT,
//       Motif_non_prelevement TEXT,
//       Ouvrage TEXT,
//       Bloc TEXT,
//       ElemBloc TEXT,
//       Localisation TEXT,
//       Age1 TEXT,
//       Age2 TEXT,
//       Age3 TEXT,
//       Age4 TEXT,
//       Age5 TEXT,
//       Partie_Ouvrage TEXT,
//       Entreprises TEXT,
//       Blocs TEXT,
//       Elemouvrages TEXT,
//       EntrepriseRealisation TEXT,   -- <-- colonne pour stocker JSON ou nom
//       maitre_ouvrage TEXT 
//     )
//   ''';
//    String localinterventionsQuery ='''
//   CREATE TABLE local_interventions (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     Structure TEXT,
//     Nom_DR TEXT,
//     bet TEXT,
//     heure TEXT,
//     elementOuvrages TEXT,
//     date TEXT,
//     ClasseBeton TEXT,
//     ChargeAffaire TEXT,
//     CodeAffaire TEXT,
//     CodeCommande TEXT UNIQUE,
//     NumCommande TEXT,
//     CodeSite TEXT,
//     observations TEXT,
//     granulas TEXT,
//     sables TEXT,
//     ciment TEXT,
//     additifs TEXT,
//     eau TEXT,
//     temperature TEXT,
//     modeProduction TEXT,
//     IntituleAffaire TEXT,
//     peid TEXT,
//     ages TEXT,
//     affaissement TEXT,
//     rapportEC TEXT,
//     adjuvant TEXT,
//     pe_id TEXT,
//     Code_Affaire TEXT,
//     pe_date_pv TEXT,
//     ChargedAffaire TEXT,
//     CatChantier TEXT,
//     Validation_labo TEXT,
//     user_code TEXT,
//     Nom_DR_Laboratoire TEXT,
//     Structure_Laboratoire TEXT,
//     TypeIntervention TEXT,
//     Motif_non_prelevement TEXT,
//     Ouvrage TEXT,
//     Bloc TEXT,
//     ElemBloc TEXT,
//     Localisation TEXT,
//     Age1 TEXT,
//     Age2 TEXT,
//     Age3 TEXT,
//     Age4 TEXT,
//     Age5 TEXT,
//     Partie_Ouvrage TEXT,
//     Entreprises TEXT,
//     Blocs TEXT,
//     Elemouvrages TEXT,
//     EntrepriseRealisation TEXT,
//     maitre_ouvrage TEXT,
//     raw_data TEXT,
//     created_at TEXT
//    )
//         ''';

//     String typeinterventionsQuery ='''
//           CREATE TABLE type_interventions (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             label TEXT,
//             value TEXT,
//             inactive INTEGER
//           )
//         ''';
// String PVQuery ='''
// CREATE TABLE local_pvs (
//   intervention_id TEXT PRIMARY KEY,

   
//     Structure TEXT,
//     Nom_DR TEXT,
//     bet TEXT,
//     heure TEXT,
//     elementOuvrages TEXT,
//     date TEXT,
//     ClasseBeton TEXT,
//     ChargeAffaire TEXT,
//     CodeAffaire TEXT,
//     CodeCommande TEXT UNIQUE,
//     NumCommande TEXT,
//     CodeSite TEXT,
//     observations TEXT,
//     granulas TEXT,
//     sables TEXT,
//     ciment TEXT,
//     additifs TEXT,
//     eau TEXT,
//     temperature TEXT,
//     modeProduction TEXT,
//     IntituleAffaire TEXT,
//     peid TEXT,
//     ages TEXT,
//     affaissement TEXT,
//     rapportEC TEXT,
//     adjuvant TEXT,
//     pe_id TEXT,
//     Code_Affaire TEXT,
//     pe_date_pv TEXT,
//     ChargedAffaire TEXT,
//     CatChantier TEXT,
//     Validation_labo TEXT,
//     user_code TEXT,
//     Nom_DR_Laboratoire TEXT,
//     Structure_Laboratoire TEXT,
//     TypeIntervention TEXT,
//     Motif_non_prelevement TEXT,
//     Ouvrage TEXT,
//     Bloc TEXT,
//     ElemBloc TEXT,
//     Localisation TEXT,
//     Age1 TEXT,
//     Age2 TEXT,
//     Age3 TEXT,
//     Age4 TEXT,
//     Age5 TEXT,
//     Partie_Ouvrage TEXT,
//     Entreprises TEXT,
//     Blocs TEXT,
//     Elemouvrages TEXT,
//     EntrepriseRealisation TEXT,
//     maitre_ouvrage TEXT,
//     raw_data TEXT,
//     created_at TEXT
// )

//         ''';
//     await db.execute(userQuery);
// ;
//     await db.execute(typeinterventionsQuery);
//     await db.execute(commandesQuery);
//     await db.execute(interventionsQuery);
//     await db.execute(localinterventionsQuery);
//       await db.execute(PVQuery);
//     await _updateDatabaseSchema(db, version);
//   }
// Future<void> saveIntervention(String interventionId, Map<String, dynamic> data) async {
//   final db = await VisitePreliminaireDatabase.instance.database;

//   await db.insert(
//     'interventions',
//     {
//       "id": interventionId, // ✅ stocker l'ID
//       "Structure": data["Structure"]?.toString(),
//       "Nom_DR": data["Nom_DR"]?.toString(),
//       "bet": data["bet"]?.toString(),
//       "heure": data["heure"]?.toString(),
//       "elementOuvrages": data["elementOuvrages"]?.toString(),
//       "date": data["date"]?.toString(),
//       "ClasseBeton": data["ClasseBeton"]?.toString(),
//       "ChargeAffaire": data["ChargeAffaire"]?.toString(),
//       "CodeAffaire": data["CodeAffaire"]?.toString(),
//       "CodeCommande": data["CodeCommande"]?.toString(),
//       "NumCommande": data["NumCommande"]?.toString(),
//       "CodeSite": data["CodeSite"]?.toString(),
//       "observations": data["observations"]?.toString(),
//       "granulas": data["granulas"]?.toString(),
//       "sables": data["sables"]?.toString(),
//       "ciment": data["ciment"]?.toString(),
//       "additifs": data["additifs"]?.toString(),
//       "eau": data["eau"]?.toString(),
//       "temperature": data["temperature"]?.toString(),
//       "modeProduction": data["modeProduction"]?.toString(),
//       "IntituleAffaire": data["IntituleAffaire"]?.toString(),
//       "peid": data["peid"]?.toString(),
//       "ages": data["ages"]?.toString(),
//       "affaissement": data["affaissement"]?.toString(),
//       "rapportEC": data["rapportEC"]?.toString(),
//       "adjuvant": data["adjuvant"]?.toString(),
//       "pe_id": data["pe_id"]?.toString(),
//       "Code_Affaire": data["Code_Affaire"]?.toString(),
//       "pe_date_pv": data["pe_date_pv"]?.toString(),
//       "ChargedAffaire": data["ChargedsaveAffaire"]?.toString(),
//       "CatChantier": data["CatChantier"]?.toString(),
//       "Validation_labo": data["Validation_labo"]?.toString(),
//       "user_code": data["user_code"]?.toString(),
//       "Nom_DR_Laboratoire": data["Nom_DR_Laboratoire"]?.toString(),
//       "Structure_Laboratoire": data["Structure_Laboratoire"]?.toString(),
//       "TypeIntervention": data["TypeIntervention"]?.toString(),
//       "Motif_non_prelevement": data["Motif_non_prelevement"]?.toString(),
//       "Ouvrage": data["Ouvrage"]?.toString(),
//       "Bloc": data["Bloc"]?.toString(),
//       "ElemBloc": data["ElemBloc"]?.toString(),
//       "Localisation": data["Localisation"]?.toString(),
//       "Age1": data["Age1"]?.toString(),
//       "Age2": data["Age2"]?.toString(),
//       "Age3": data["Age3"]?.toString(),
//       "Age4": data["Age4"]?.toString(),
//       "Age5": data["Age5"]?.toString(),
//       "Partie_Ouvrage": data["Partie_Ouvrage"]?.toString(),
//       "Entreprises": data["Entreprises"]?.toString(),
//       "Blocs": data["Blocs"]?.toString(),
//       "Elemouvrages": data["Elemouvrages"]?.toString(),
//       "EntrepriseRealisation": data["EntrepriseRealisation"]?.toString(),
//       "maitre_ouvrage": data["maitre_ouvrage"]?.toString(),

//       "raw_data": jsonEncode(data),

//       "created_at": DateTime.now().toIso8601String(),
//     },
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }
//   // ✅ CORRIGÉ - Renommer la méthode de mapping
//   Future<void> savePVFromAPI(String interventionId, Map<String, dynamic> apiResponse) async {
//     // Extraire et mapper les données
//     Map<String, dynamic> flatData = {
//       "Structure": apiResponse["intervention"]?["Structure"]?.toString(),
//       "Nom_DR": apiResponse["intervention"]?["Nom_DR"]?.toString(),
//       "Code_Affaire": apiResponse["intervention"]?["Code_Affaire"]?.toString(),
//       "pe_id": apiResponse["intervention"]?["pe_id"]?.toString(),
//       "date": apiResponse["intervention"]?["pe_date"]?.toString(),
//       "heure": apiResponse["intervention"]?["pe_heure"]?.toString(),
//       "temperature": apiResponse["intervention"]?["pe_temp"]?.toString(),
//       "modeProduction": apiResponse["intervention"]?["pe_mode_prod"]?.toString(),
//       "ClasseBeton": apiResponse["intervention"]?["classeBeton"]?.toString(),
//       "CatChantier": apiResponse["intervention"]?["catChantier"]?.toString(),
//       "observations": apiResponse["intervention"]?["pe_obs"]?.toString(),
//  "IntituleAffaire": apiResponse["affaire"]?["IntituleAffaire"]?.toString(),
//   "CodeAffaire": apiResponse["affaire"]?["Code_Affaire"]?.toString(),
//       // Éléments d'ouvrage (premier élément)
//       "Ouvrage": apiResponse["elements_ouvrages"]?[0]?["elem_nom"]?.toString(),
//       "Bloc": apiResponse["elements_ouvrages"]?[0]?["elem_bloc"]?.toString(),

//       // Commandes (première commande)
//       "NumCommande": apiResponse["commandes"]?[0]?["NumCommande"]?.toString(),

//       // Autres données
//       "EntrepriseRealisation": apiResponse["intervention"]?["entreprise_real"]?.toString(),
//       "user_code": apiResponse["intervention"]?["user_code"]?.toString(),
//     };

//     // ✅ Appeler la méthode ORIGINALE savePV (pas la même méthode !)
//     await _savePVToDatabase(interventionId, flatData);
//   }

// // ✅ Renommer la méthode originale
//   Future<void> _savePVToDatabase(String interventionId, Map<String, dynamic> data) async {
//     final db = await VisitePreliminaireDatabase.instance.database;

//     await db.insert(
//       'local_pvs',
//       {
//         "intervention_id": interventionId,
//         "Structure": data["Structure"]?.toString(),
//         "Nom_DR": data["Nom_DR"]?.toString(),
//         "bet": data["bet"]?.toString(),
//         "heure": data["heure"]?.toString(),
//         "elementOuvrages": data["elementOuvrages"]?.toString(),
//         "date": data["date"]?.toString(),
//         "ClasseBeton": data["ClasseBeton"]?.toString(),
//         "ChargeAffaire": data["ChargeAffaire"]?.toString(),
//         "CodeAffaire": data["CodeAffaire"]?.toString(),
//         "CodeCommande": data["CodeCommande"]?.toString(),
//         "NumCommande": data["NumCommande"]?.toString(),
//         "CodeSite": data["CodeSite"]?.toString(),
//         "observations": data["observations"]?.toString(),
//         "granulas": data["granulas"]?.toString(),
//         "sables": data["sables"]?.toString(),
//         "ciment": data["ciment"]?.toString(),
//         "additifs": data["additifs"]?.toString(),
//         "eau": data["eau"]?.toString(),
//         "temperature": data["temperature"]?.toString(),
//         "modeProduction": data["modeProduction"]?.toString(),
//         "IntituleAffaire": data["IntituleAffaire"]?.toString(),
//         "peid": data["peid"]?.toString(),
//         "ages": data["ages"]?.toString(),
//         "affaissement": data["affaissement"]?.toString(),
//         "rapportEC": data["rapportEC"]?.toString(),
//         "adjuvant": data["adjuvant"]?.toString(),
//         "pe_id": data["pe_id"]?.toString(),
//         "Code_Affaire": data["Code_Affaire"]?.toString(),
//         "pe_date_pv": data["pe_date_pv"]?.toString(),
//         "ChargedAffaire": data["ChargedAffaire"]?.toString(),
//         "CatChantier": data["CatChantier"]?.toString(),
//         "Validation_labo": data["Validation_labo"]?.toString(),
//         "user_code": data["user_code"]?.toString(),
//         "Nom_DR_Laboratoire": data["Nom_DR_Laboratoire"]?.toString(),
//         "Structure_Laboratoire": data["Structure_Laboratoire"]?.toString(),
//         "TypeIntervention": data["TypeIntervention"]?.toString(),
//         "Motif_non_prelevement": data["Motif_non_prelevement"]?.toString(),
//         "Ouvrage": data["Ouvrage"]?.toString(),
//         "Bloc": data["Bloc"]?.toString(),
//         "ElemBloc": data["ElemBloc"]?.toString(),
//         "Localisation": data["Localisation"]?.toString(),
//         "Age1": data["Age1"]?.toString(),
//         "Age2": data["Age2"]?.toString(),
//         "Age3": data["Age3"]?.toString(),
//         "Age4": data["Age4"]?.toString(),
//         "Age5": data["Age5"]?.toString(),
//         "Partie_Ouvrage": data["Partie_Ouvrage"]?.toString(),
//         "Entreprises": data["Entreprises"]?.toString(),
//         "Blocs": data["Blocs"]?.toString(),
//         "Elemouvrages": data["Elemouvrages"]?.toString(),
//         "EntrepriseRealisation": data["EntrepriseRealisation"]?.toString(),
//         "maitre_ouvrage": data["maitre_ouvrage"]?.toString(),

//         "raw_data": jsonEncode(data),
//         "created_at": DateTime.now().toIso8601String(),
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
// Future<void> _updateDatabaseSchema(Database db, int version) async {
//   try {
    
//     await db.rawQuery('SELECT pe_date_pv FROM commandes LIMIT 1');
//     print('✅ La colonne pe_date_pv existe déjà');
//   } catch (e) {
//     print('➡️ Ajout de la colonne pe_date_pv...');
//     try {
//       await db.execute('ALTER TABLE commandes ADD COLUMN pe_date_pv TEXT');
//       print('✅ Colonne pe_date_pv ajoutée avec succès');
//     } catch (alterError) {
//       print('❌ Erreur lors de l’ajout de la colonne pe_date_pv: $alterError');
//     }
//   }


    
//     final columnsToCheck = ['role', 'consultation', 'insertion', 'modification', 'suppression'];

//     for (final column in columnsToCheck) {
//       try {
//         await db.rawQuery('SELECT $column FROM users LIMIT 1');
//         print('✅ La colonne $column existe');
//       } catch (e) {
//         print('➡️ Ajout de la colonne $column...');
//         try {
//           await db.execute('ALTER TABLE users ADD COLUMN $column TEXT');
//           print('✅ Colonne $column ajoutée');
//         } catch (alterError) {
//           print('❌ Erreur avec la colonne $column: $alterError');
//         }
//       }
//     }
//   }
//   Future<int> dropUsers(String? structure) async {
//     final db = await instance.database;

//     if (structure != null && structure.isNotEmpty) {
      
//       return await db.rawDelete(
//         'DELETE FROM users WHERE structure = ?',
//         [structure],
//       );
//     } else {
//       return await db.rawDelete('DELETE FROM users');
//     }
//   }
//   Future<void> insertIntervention(Map<String, dynamic> pv) async {
//   final db = await database;

//   await db.insert(
//     'local_interventions',
//     {
//       "Structure": pv["Structure"],
//       "Nom_DR": pv["Nom_DR"],
//       "bet": pv["bet"],
//       "heure": pv["heure"],
//       "elementOuvrages": pv["elementOuvrages"],
//       "date": pv["date"],
//       "ClasseBeton": pv["ClasseBeton"],
//       "ChargeAffaire": pv["ChargeAffaire"],
//       "CodeAffaire": pv["CodeAffaire"],
//       "CodeCommande": pv["CodeCommande"],
//       "NumCommande": pv["NumCommande"],
//       "CodeSite": pv["CodeSite"],
//       "observations": pv["observations"],
//       "granulas": pv["granulas"],
//       "sables": pv["sables"],
//       "ciment": pv["ciment"],
//       "additifs": pv["additifs"],
//       "eau": pv["eau"],
//       "temperature": pv["temperature"],
//       "modeProduction": pv["modeProduction"],
//       "IntituleAffaire": pv["IntituleAffaire"],
//       "peid": pv["peid"],
//       "ages": pv["ages"],
//       "affaissement": pv["affaissement"],
//       "rapportEC": pv["rapportEC"],
//       "adjuvant": pv["adjuvant"],
//       "pe_id": pv["pe_id"],
//       "Code_Affaire": pv["Code_Affaire"],
//       "pe_date_pv": pv["pe_date_pv"],
//       "ChargedAffaire": pv["ChargedAffaire"],
//       "CatChantier": pv["CatChantier"],
//       "Validation_labo": pv["Validation_labo"],
//       "user_code": pv["user_code"],
//       "Nom_DR_Laboratoire": pv["Nom_DR_Laboratoire"],
//       "Structure_Laboratoire": pv["Structure_Laboratoire"],
//       "TypeIntervention": pv["TypeIntervention"],
//       "Motif_non_prelevement": pv["Motif_non_prelevement"],
//       "Ouvrage": pv["Ouvrage"],
//       "Bloc": pv["Bloc"],
//       "ElemBloc": pv["ElemBloc"],
//       "Localisation": pv["Localisation"],
//       "Age1": pv["Age1"],
//       "Age2": pv["Age2"],
//       "Age3": pv["Age3"],
//       "Age4": pv["Age4"],
//       "Age5": pv["Age5"],
//       "Partie_Ouvrage": pv["Partie_Ouvrage"],
//       "Entreprises": pv["Entreprises"],
//       "Blocs": pv["Blocs"],
//       "Elemouvrages": pv["Elemouvrages"],
//       "EntrepriseRealisation": pv["EntrepriseRealisation"],
//       "maitre_ouvrage": pv["maitre_ouvrage"],

//       // 🔥 très important !
//       "raw_data": jsonEncode(pv),     
//       "created_at": DateTime.now().toIso8601String()
//     },
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }
// Future<Map<String, dynamic>?> getIntervention(String id) async {
//   final db = await database;

//   final res = await db.query(
//     "local_pvs",
//     where: "CodeCommande = ?",
//     whereArgs: [id],
//   );

//   if (res.isEmpty) return null;

//   return jsonDecode(res.first["raw_json"] as String);
// }


// Future<int> insertCommande(Commande commande) async {
//   final db = await database;

  
//   print('🟡 [DB] Insertion d\'une commande dans la table "commandes"...');

  
//   final commandeMap = commande.toMap();
//   print('📦 [DB] Données de la commande à insérer :');
//   commandeMap.forEach((key, value) {
//     print('   ➜ $key: $value');
//   });

//   try {
    
//     final id = await db.insert(
//       'commandes',
//       commandeMap,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

    
//     print('✅ [DB] Commande insérée avec succès. ID = $id');
//     return id;
//   } catch (e) {
    
//     print('❌ [DB] Erreur lors de l\'insertion de la commande : $e');
//     rethrow;
//   }
// }



//   Future<void> createUsers(List<dynamic> users) async {
//     final db = await instance.database;

    
//     await db.transaction((txn) async {
//       for (var element in users) {
//         try {
//           print('📥 Traitement utilisateur: $element');

          
//           Map<String, dynamic> userMap;
//           if (element is Map<String, dynamic>) {
//             userMap = element;
//           } else if (element is User) {
            
//             userMap = element.toJson();
//           } else {
//             print('❌ Type d\'utilisateur non supporté: ${element.runtimeType}');
//             continue;
//           }

          
//           final mappedUser = {
//             'matricule': userMap['matricule']?.toString() ?? '',
//             'structure': userMap['Structure']?.toString() ?? userMap['structure']?.toString() ?? '',
//             'nom': (userMap['nom']?.toString() ?? '').trim(),
//             'prenom': (userMap['prenom']?.toString() ?? '').trim(),
//             'password': userMap['password']?.toString() ?? '',
//             'privilege': userMap['privilege']?.toString() ?? '',
//             'role': userMap['role']?.toString() ?? '',
//             'consultation': userMap['consultation']?.toString() ?? '0',
//             'insertion': userMap['insertion']?.toString() ?? '0',
//             'modification': userMap['modification']?.toString() ?? '0',
//             'suppression': userMap['suppression']?.toString() ?? '0',
//           };

          
//           if (mappedUser['matricule']?.isEmpty ?? true) {
//             print('❌ Matricule manquant, utilisateur ignoré');
//             continue;
//           }

          
//           await txn.rawInsert('''
//           INSERT OR REPLACE INTO users 
//           (matricule, structure, nom, prenom, password, privilege, role, consultation, insertion, modification, suppression)
//           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
//         ''', [
//             mappedUser['matricule'],
//             mappedUser['structure'],
//             mappedUser['nom'],
//             mappedUser['prenom'],
//             mappedUser['password'],
//             mappedUser['privilege'],
//             mappedUser['role'],
//             mappedUser['consultation'],
//             mappedUser['insertion'],
//             mappedUser['modification'],
//             mappedUser['suppression'],
//           ]);

//           print("💾 Utilisateur inséré: ${mappedUser['matricule']}");

//         } catch (e) {
//           print('❌ Erreur insertion utilisateur $element: $e');
          
//         }
//       }
//     });
//   }
 


 

// Future<List<Commande>> getAllCommandes() async {
//   final db = await instance.database;
//   final result = await db.query('commandes');
//   return result.map((json) => Commande.fromJson(Map<String, dynamic>.from(json))).toList();
// }

//   Future<List<ClasseBeton>> getAllBetons() async {
//     final db = await instance.database;
//     final result = await db.query('betons');
//     return result.map((json) => ClasseBeton.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<ElementPredefini>> getAllElementsPred() async {
//     final db = await instance.database;
//     final result = await db.query('elements_predefinis');
//     return result.map((json) => ElementPredefini.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<ModesProduction>> getAllModesProd() async {
//     final db = await instance.database;
//     final result = await db.query('modes_production');
//     return result.map((json) => ModesProduction.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<ClasseCarrieres>> getAllCarrieres() async {
//     final db = await instance.database;
//     final result = await db.query('carrieres');
//     return result.map((json) => ClasseCarrieres.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<TypeCiments>> getAllTypesCiments() async {
//     final db = await instance.database;
//     final result = await db.query('types_ciments');
//     return result.map((json) => TypeCiments.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<TypeAdjuvants>> getAllTypesAdjuvants() async {
//     final db = await instance.database;
//     final result = await db.query('types_adjuvants');
//     return result.map((json) => TypeAdjuvants.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<List<TypeEprouvettes>> getAllTypesEprouvettes() async {
//     final db = await instance.database;
//     final result = await db.query('types_eprouvettes');
//     return result.map((json) => TypeEprouvettes.fromJson(Map<String, dynamic>.from(json))).toList();
//   }

//   Future<void> saveCommandes(List<Commande> commandes) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS commandes(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           CodeCommande TEXT,
//           NumCommande TEXT,
//           Code_Site TEXT,
//           IntituleAffaire TEXT,
//           peid TEXT,
//           pe_id TEXT,
//           Code_Affaire TEXT,
//           pe_date_pv TEXT,
//           ChargedAffaire TEXT,
//           CatChantier TEXT,
//           Validation_labo TEXT,
//           user_code TEXT,
//           Nom_DR_Laboratoire TEXT,
//           Structure_Laboratoire TEXT,
//           TypeIntervention TEXT,
//           Motif_non_prelevement TEXT,
//           Ouvrage TEXT,
//           Age1 TEXT,
//           Age2 TEXT,
//           Age3 TEXT,
//           Age4 TEXT,
//           Age5 TEXT,
//           Bloc TEXT,
//           ElemBloc TEXT,
//           Localisation TEXT,
//           Partie_Ouvrage TEXT,
//           Entreprises TEXT,
//           Blocs TEXT,
//           Elemouvrages TEXT,
//           EntrepriseRealisation TEXT,
//           maitre_ouvrage TEXT
//         )
//       ''');
      
//       await txn.delete('commandes');
//       for (var commande in commandes) {
//         final map = commande.toJson();
        
//         map.forEach((key, value) {
//           if (value is Map || value is List) {
//             map[key] = jsonEncode(value);
//           }
//         });
//         await txn.insert('commandes', map);
//       }
//     });
//   }

//   Future<void> saveBetons(List<ClasseBeton> betons) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS betons(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT
//         )
//       ''');
      
//       await txn.delete('betons');
//       for (var beton in betons) {
//         await txn.insert('betons', beton.toJson());
//       }
//     });
//   }
  
  
  

//   Future<List<User>> getUser() async {
//     final db = await instance.database;
//     final users = await db.query('users');
//     return users.map((json) => User.fromJson(json)).toList();
//   }
//   Future<User> getUserByMatricule(matricule) async {
//     final db = await instance.database;
//     final users = await db.query(
//       'users',
//       where: 'matricule = ?',
//       whereArgs: [ matricule ],
//     );

//     return users.map((json) => User.fromJson(json)).toList()[0];
//   }
//   Future<void> saveElementsPred(List<ElementPredefini> elements) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS elements_predefinis(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT,
//           code TEXT,
//           designation TEXT,
//           mission TEXT,
//           type TEXT
//         )
//       ''');
      
//       await txn.delete('elements_predefinis');
//       for (var element in elements) {
//         await txn.insert('elements_predefinis', element.toJson());
//       }
//     });
//   }

//   Future<void> saveModesProd(List<ModesProduction> modes) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS modes_production(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT
//         )
//       ''');
      
//       await txn.delete('modes_production');
//       for (var mode in modes) {
//         await txn.insert('modes_production', mode.toJson());
//       }
//     });
//   }

//   Future<void> saveCarrieres(List<ClasseCarrieres> carrieres) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS carrieres(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT
//         )
//       ''');
      
//       await txn.delete('carrieres');
//       for (var carriere in carrieres) {
//         await txn.insert('carrieres', carriere.toJson());
//       }
//     });
//   }

//   Future<void> saveTypesCiments(List<TypeCiments> types) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS types_ciments(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT
//         )
//       ''');
      
//       await txn.delete('types_ciments');
//       for (var type in types) {
//         await txn.insert('types_ciments', type.toJson());
//       }
//     });
//   }

//   Future<void> saveTypesAdjuvants(List<TypeAdjuvants> types) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS types_adjuvants(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT
//         )
//       ''');
      
//       await txn.delete('types_adjuvants');
//       for (var type in types) {
//         await txn.insert('types_adjuvants', type.toJson());
//       }
//     });
//   }

//   Future<bool> checkStructure(structure) async {
//     final db = await instance.database;
//     final affaires = await db.query(
//         'affaires',
//         where: 'code_agence=?',
//         whereArgs: [structure]
//     );
//     return affaires.isNotEmpty;
//   }
//   Future<void> saveTypesEprouvettes(List<TypeEprouvettes> types) async {
//     final db = await instance.database;
//     await db.transaction((txn) async {
//       await txn.execute('''
//         CREATE TABLE IF NOT EXISTS types_eprouvettes(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           value TEXT,
//           label TEXT,
//           eprv_id TEXT,
//           eprv_type TEXT
//         )
//       ''');
      
//       await txn.delete('types_eprouvettes');
//       for (var type in types) {
//         await txn.insert('types_eprouvettes', type.toJson());
//       }
//     });
//   }
  
//   Future<List<Intervention>> getAllInterventions() async {
//     final db = await instance.database;
//     final result = await db.query('interventions');
    
//     return result.map((json) {
      
//       final modifiableJson = Map<String, dynamic>.from(json);
      
      
//       if (modifiableJson['EntrepriseRealisation'] != null) {
//         modifiableJson['EntrepriseRealisation'] = 
//             jsonDecode(modifiableJson['EntrepriseRealisation'] as String);
//       }
//       if (modifiableJson['maitre_ouvrage'] != null) {
//         modifiableJson['maitre_ouvrage'] = 
//             jsonDecode(modifiableJson['maitre_ouvrage'] as String);
//       }
//       if (modifiableJson['Entreprises'] != null) {
//         modifiableJson['Entreprises'] = 
//             jsonDecode(modifiableJson['Entreprises'] as String);
//       }
//       if (modifiableJson['Blocs'] != null) {
//         modifiableJson['Blocs'] = 
//             jsonDecode(modifiableJson['Blocs'] as String);
//       }
//       if (modifiableJson['Elemouvrages'] != null) {
//         modifiableJson['Elemouvrages'] = 
//             jsonDecode(modifiableJson['Elemouvrages'] as String);
//       }
      
//       return Intervention.fromJson(modifiableJson);
//     }).toList();
//   }

//   // Future<void> saveInterventionsPayload(Map<String, dynamic> payload) async {
//   //   final db = await instance.database;
//   //   await db.transaction((txn) async {
      
//   //     Future<void> _insertList(String table, List<dynamic> list) async {
        
//   //       await txn.delete(table);
//   //       for (var item in list) {
//   //         Map<String, dynamic> row;
//   //         if (item is Map<String, dynamic>) {
//   //           row = Map<String, dynamic>.from(item);
//   //         } else {
            
//   //           row = Map<String, dynamic>.from(json.decode(json.encode(item)));
//   //         }
          
//   //         final cleaned = <String, dynamic>{};
//   //         row.forEach((k, v) {
//   //           if (v == null) {
//   //             cleaned[k] = null;
//   //           } else if (v is Map || v is List) {
//   //             try {
//   //               cleaned[k] = jsonEncode(v);
//   //             } catch (_) {
//   //               cleaned[k] = v.toString();
//   //             }
//   //           } else if (v is Uint8List) {
//   //             cleaned[k] = v;
//   //           } else {
//   //             cleaned[k] = v;
//   //           }
//   //         });
//   //         await txn.insert(table, cleaned, conflictAlgorithm: ConflictAlgorithm.replace);
//   //       }
//   //     }

      
//   //     if (payload['commandes'] is List) {
//   //       await _insertList('commandes', payload['commandes'] as List<dynamic>);
//   //     }
      
//   //     if (payload['interventions'] is List) {
//   //       await _insertList('interventions', payload['interventions'] as List<dynamic>);
//   //     } else if (payload['data'] is List) {
        
//   //       await _insertList('interventions', payload['data'] as List<dynamic>);
//   //     }

      
//   //     if (payload['beton'] is List) {
//   //       await _insertList('betons', payload['beton'] as List<dynamic>);
//   //     }

      
//   //     if (payload['modesProduction'] is List) {
//   //       await _insertList('modes_production', payload['modesProduction'] as List<dynamic>);
//   //     }

      
//   //     if (payload['carrieres'] is List) {
//   //       await _insertList('carrieres', payload['carrieres'] as List<dynamic>);
//   //     }

      
//   //     if (payload['types_ciments'] is List) {
//   //       await _insertList('types_ciments', payload['types_ciments'] as List<dynamic>);
//   //     }

      
//   //     if (payload['types_adjuvants'] is List) {
//   //       await _insertList('types_adjuvants', payload['types_adjuvants'] as List<dynamic>);
//   //     }

      
//   //     if (payload['types_eprouvettes'] is List) {
//   //       await _insertList('types_eprouvettes', payload['types_eprouvettes'] as List<dynamic>);
//   //     }

      
//   //     if (payload['famille_elements'] is List) {
//   //       await _insertList('elements_predefinis', payload['famille_elements'] as List<dynamic>);
//   //     }
//   //   });
//   // }

//   Future<void> _ensureLocalInterventionsTableExists() async {
//     final db = await database;

//     final desiredCols = <String>[
//       'Structure',
//       'Nom_DR',
//       'bet',
//       'ClasseBeton',
//       'elementOuvrages',
//       'ChargeAffaire',
//       'CodeAffaire',
//       'CodeCommande',
//       'NumCommande',
//       'CodeSite',
//       'IntituleAffaire',
//       'peid',
//       'pe_id',
//       'Code_Affaire',
//       'pe_date_pv',
//       'ChargedAffaire',
//       'CatChantier',
//       'Validation_labo',
//       'user_code',
//       'Nom_DR_Laboratoire',
//       'Structure_Laboratoire',
//       'TypeIntervention',
//       'Motif_non_prelevement',
//       'Ouvrage',
//       'Bloc',
//       'date',
//       'heure',
//       'temperature',
//       'ElemBloc',
//       'Localisation',
//       'Age1',
//       'Age2',
//       'Age3',
//       'Age4',
//       'Age5',
//       'modeProduction',
//       'granulas',
//       'sables',
//       'affaissement',
//       'Partie_Ouvrage',
//       'rapportEC',
//       'observations',
//       'Entreprises',
//       'Blocs',
//       'ciment',
//       'adjuvant',
//       'additifs',
//       'eau',
//       'ages',
//       'Elemouvrages',
//       'EntrepriseRealisation',
//       'maitre_ouvrage',
//       'raw_data',
//       'created_at',
//     ];

//     try {
//       final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='local_interventions'");
//       if (tables.isEmpty) {
//         await db.execute('''
//           CREATE TABLE local_interventions (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             Structure TEXT,
//             Nom_DR TEXT,
//             bet TEXT,
//             heure TEXT,
//             elementOuvrages TEXT,
//             date TEXT,
//             ClasseBeton TEXT,
//             ChargeAffaire TEXT,
//             CodeAffaire TEXT,
//             CodeCommande TEXT,
//             NumCommande TEXT,
//             CodeSite TEXT,
//             observations TEXT,
//             granulas TEXT,
//             sables TEXT,
//             ciment TEXT,
//             additifs TEXT,
//             eau TEXT,
//             temperature TEXT,
//             modeProduction TEXT,
//             IntituleAffaire TEXT,
//             peid TEXT,
//             ages TEXT,
//             affaissement TEXT,
//             rapportEC TEXT,
//             adjuvant TEXT,
//             pe_id TEXT,
//             Code_Affaire TEXT,
//             pe_date_pv TEXT,
//             ChargedAffaire TEXT,
//             CatChantier TEXT,
//             Validation_labo TEXT,
//             user_code TEXT,
//             Nom_DR_Laboratoire TEXT,
//             Structure_Laboratoire TEXT,
//             TypeIntervention TEXT,
//             Motif_non_prelevement TEXT,
//             Ouvrage TEXT,
//             Bloc TEXT,
//             ElemBloc TEXT,
//             Localisation TEXT,
//             Age1 TEXT,
//             Age2 TEXT,
//             Age3 TEXT,
//             Age4 TEXT,
//             Age5 TEXT,
//             Partie_Ouvrage TEXT,
//             Entreprises TEXT,
//             Blocs TEXT,
//             Elemouvrages TEXT,
//             EntrepriseRealisation TEXT,
//             maitre_ouvrage TEXT,
//             raw_data TEXT,
//             created_at TEXT
//           )
//         ''');
//         await db.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_local_interventions_peid ON local_interventions(pe_id)");
//         print('✅ Table local_interventions créée avec toutes les colonnes.');
//       } else {
//         final pragma = await db.rawQuery('PRAGMA table_info(local_interventions)');
//         final existing = <String>{};
//         for (final row in pragma) {
//           final name = (row['name'] ?? row['NAME']).toString();
//           existing.add(name.toLowerCase());
//         }
//         for (final col in desiredCols) {
//           if (!existing.contains(col.toLowerCase())) {
//             try {
//               await db.execute('ALTER TABLE local_interventions ADD COLUMN "$col" TEXT');
//               print('➡️ Colonne ajoutée local_interventions.$col');
//             } catch (e) {
//               print('❌ Impossible d\'ajouter la colonne $col: $e');
//             }
//           }
//         }
//         try {
//           await db.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_local_interventions_peid ON local_interventions(pe_id)");
//         } catch (e) {
//           print('❌ Impossible de créer l\'index unique pe_id: $e');
//         }
//       }

//       // créer/assurer tables relationnelles détaillées
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_granulas (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           provenance TEXT,
//           dosage REAL,
//           dmin REAL,
//           dmax REAL
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_sables (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           provenance TEXT,
//           dosage REAL,
//           dmax REAL
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_ciments (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           provenance TEXT,
//           type TEXT,
//           dosage REAL
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_adjuvants (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           provenance TEXT,
//           type TEXT,
//           dosage REAL
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_additifs (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           type TEXT,
//           nomProduit TEXT,
//           dosage REAL
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS local_eau (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           pe_id TEXT,
//           source TEXT,
//           dosage REAL
//         )
//       ''');
//       print('✅ Tables relationnelles locales (granulas/sables/...) crées.');
//     } catch (e) {
//       print('❌ Erreur lors de la vérification/création de local_interventions et tables associées: $e');
//     }
//   }
//   Future<int> insertLocalIntervention(InterventionModel model) async {
//     final db = await database;
//     await _ensureLocalInterventionsTableExists();
//     return await db.insert(
//       'local_interventions',
//       model.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

  
//   Future<List<InterventionModel>> getAllLocalInterventions() async {
//     final db = await database;
//     await _ensureLocalInterventionsTableExists();
//     final result = await db.query('local_interventions', orderBy: 'created_at DESC');
//     return result.map((m) => InterventionModel.fromMap(m)).toList();
//   }

  
//   Future<void> closeLocalInterventions() async {
    
    
//     return;
//   }
// }
