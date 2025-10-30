import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/image_data.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
import 'package:mgtrisque_visitepreliminaire/models/user.dart';

import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';
import 'package:bcrypt/bcrypt.dart';
import 'package:mgtrisque_visitepreliminaire/models/document_annexe.dart';
class VisitePreliminaireDatabase {
  static final VisitePreliminaireDatabase instance =
  VisitePreliminaireDatabase._init();

  static Database? _database;

  VisitePreliminaireDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('interventions_essai.db');
    return _database!;
  }



  Future<void> deleteLocalDatabase() async {
  // Récupère le chemin complet de la base
  final dbPath = await getDatabasesPath();
  final path = '$dbPath/visite_preliminaire.db'; // 🔹 adapte le nom ici

  // Supprime la base si elle existe
  await deleteDatabase(path);
  print('🗑️ Base de données supprimée : $path');
}
Future<void> createInterventions(List<dynamic> interventions) async {
  final db = await instance.database;

  print('📦 [DB] Début de l\'insertion des interventions (${interventions.length})...');

  await db.transaction((txn) async {
    for (var element in interventions) {
      try {
        // Vérifier si c'est déjà une Map
        Map<String, dynamic> interventionData;
        if (element is Map<String, dynamic>) {
          interventionData = element;
        } else {
          // Si c'est un autre type, essayer de convertir en JSON d'abord
          interventionData = element.toJson();
        }

        // Convertir les données API en Commande
        final commande = Commande.fromJson(interventionData);

        print('🟢 Insertion intervention CodeCommande: ${commande.codeCommande}');

        // Préparer la map pour l'insertion
        final commandeMap = commande.toMap();
        
          final cleanMap = Map<String, dynamic>.fromEntries(
          commandeMap.entries.map((entry) {
            final key = entry.key;
            var value = entry.value;
            // Sérialiser les Map et les List non vides en JSON texte
            if (value is Map || (value is List && value.isNotEmpty)) {
              try {
                value = jsonEncode(value);
              } catch (_) {
                value = value.toString();
              }
            }
            // Garder Uint8List, num, String, null, ou chaîne JSON générée
            return MapEntry(key, value);
          }).where((entry) {
            final v = entry.value;
            return v == null || v is num || v is String || v is Uint8List;
          })
        );

        await txn.insert(
          'commandes',
          cleanMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

      } catch (e) {
        print('❌ Erreur lors de l\'insertion d\'une intervention: $e');
        print('❌ Données problématiques: $element');
      }
    }
  });

  print('✅ [DB] Insertion des interventions terminée.');
}

 Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(
    path,
    version: 9, 
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 5) {
        // Recréer la table avec le bon schéma
        await db.execute('DROP TABLE IF EXISTS commandes');
        await _createDB(db, newVersion);
      }
    },
  );
}

Future<void> debugTableSchema() async {
  final db = await instance.database;
  try {
    final result = await db.rawQuery('PRAGMA table_info(commandes)');
    print('📋 Schema de la table commandes:');
    for (var column in result) {
      print(' - ${column['name']} (${column['type']})');
    }
  } catch (e) {
    print('❌ Erreur lors de la lecture du schéma: $e');
  }
}

  Future _createDB(Database db, int version) async {
    String userQuery = '''
      CREATE TABLE IF NOT EXISTS users(        
        matricule TEXT, 
        structure TEXT,
        nom TEXT,
        prenom TEXT,
        password TEXT,
        privilege TEXT,
        role TEXT,
        consultation TEXT,
        insertion TEXT,
        modification TEXT,
        suppression TEXT
      )
    ''';
    String affaireQuery = '''
      CREATE TABLE IF NOT EXISTS affaires(        
        Code_Affaire TEXT, 
        Code_Site TEXT, 
        IntituleAffaire TEXT, 
        NbrSite TEXT,
        matricule TEXT,
        Multisite TEXT,
        annee TEXT,
        Nom_DR TEXT,
        code_agence TEXT,
        nom_agence TEXT,
        adresse TEXT,
        tel TEXT,
        fax TEXT,
        email TEXT,
        hasVisite TEXT,
        PRIMARY KEY (Code_Affaire, matricule)
      )
    ''';
    String siteQuery = '''
      CREATE TABLE IF NOT EXISTS sites(        
        Code_site TEXT, 
        Code_Affaire TEXT,
        adress_proj TEXT,
        PRIMARY KEY (Code_site, Code_Affaire) 
      )
    ''';

 String commandesQuery = '''
    CREATE TABLE IF NOT EXISTS commandes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
     CodeCommande TEXT,
      NumCommande TEXT,
      
      IntituleAffaire TEXT,
      peid TEXT,
      pe_id TEXT,
      Code_Affaire TEXT,
      pe_date_pv TEXT,
      ChargedAffaire TEXT,
      CatChantier TEXT,
      Validation_labo TEXT,
      user_code TEXT,
      Nom_DR_Laboratoire TEXT,
      Structure_Laboratoire TEXT,
      TypeIntervention TEXT,
      Motif_non_prelevement TEXT,
      Ouvrage TEXT,
      Bloc TEXT,
      ElemBloc TEXT,
      Localisation TEXT,
  
      Partie_Ouvrage TEXT,
      Entreprises TEXT,
      Blocs TEXT,
      Elemouvrages TEXT,
        EntrepriseRealisation TEXT,   -- <-- colonne pour stocker JSON ou nom
      maitre_ouvrage TEXT 
    )
  ''';

    await db.execute(userQuery);
    await db.execute(affaireQuery);
    await db.execute(siteQuery);
  
    await db.execute(commandesQuery);
    await _updateDatabaseSchema(db, version);
  }

Future<void> _updateDatabaseSchema(Database db, int version) async {
  try {
    // Vérifier si la colonne existe déjà
    await db.rawQuery('SELECT pe_date_pv FROM commandes LIMIT 1');
    print('✅ La colonne pe_date_pv existe déjà');
  } catch (e) {
    print('➡️ Ajout de la colonne pe_date_pv...');
    try {
      await db.execute('ALTER TABLE commandes ADD COLUMN pe_date_pv TEXT');
      print('✅ Colonne pe_date_pv ajoutée avec succès');
    } catch (alterError) {
      print('❌ Erreur lors de l’ajout de la colonne pe_date_pv: $alterError');
    }
  }


    // Vérifier les autres colonnes si nécessaire
    final columnsToCheck = ['role', 'consultation', 'insertion', 'modification', 'suppression'];

    for (final column in columnsToCheck) {
      try {
        await db.rawQuery('SELECT $column FROM users LIMIT 1');
        print('✅ La colonne $column existe');
      } catch (e) {
        print('➡️ Ajout de la colonne $column...');
        try {
          await db.execute('ALTER TABLE users ADD COLUMN $column TEXT');
          print('✅ Colonne $column ajoutée');
        } catch (alterError) {
          print('❌ Erreur avec la colonne $column: $alterError');
        }
      }
    }
  }
  Future<int> dropUsers(String? structure) async {
    final db = await instance.database;

    if (structure != null && structure.isNotEmpty) {
      // ✅ Utilisation de whereArgs pour éviter l'injection SQL
      return await db.rawDelete(
        'DELETE FROM users WHERE structure = ?',
        [structure],
      );
    } else {
      return await db.rawDelete('DELETE FROM users');
    }
  }
  
Future<int> insertCommande(Commande commande) async {
  final db = await database;

  // 🔹 Log 1 : début de l'insertion
  print('🟡 [DB] Insertion d\'une commande dans la table "commandes"...');

  // 🔹 Log 2 : afficher la map complète
  final commandeMap = commande.toMap();
  print('📦 [DB] Données de la commande à insérer :');
  commandeMap.forEach((key, value) {
    print('   ➜ $key: $value');
  });

  try {
    // 🔹 Insertion dans la base
    final id = await db.insert(
      'commandes',
      commandeMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 🔹 Log 3 : succès
    print('✅ [DB] Commande insérée avec succès. ID = $id');
    return id;
  } catch (e) {
    // 🔹 Log 4 : erreur
    print('❌ [DB] Erreur lors de l\'insertion de la commande : $e');
    rethrow;
  }
}



  Future<void> createUsers(List<dynamic> users) async {
    final db = await instance.database;

    // Commencer une transaction pour plus de performance
    await db.transaction((txn) async {
      for (var element in users) {
        try {
          print('📥 Traitement utilisateur: $element');

          // ✅ Vérification plus robuste du type
          Map<String, dynamic> userMap;
          if (element is Map<String, dynamic>) {
            userMap = element;
          } else if (element is User) {
            // Si c'est un objet User, convertir en Map
            userMap = element.toJson();
          } else {
            print('❌ Type d\'utilisateur non supporté: ${element.runtimeType}');
            continue;
          }

          // ✅ Normalisation avec valeurs par défaut sécurisées
          final mappedUser = {
            'matricule': userMap['matricule']?.toString() ?? '',
            'structure': userMap['Structure']?.toString() ?? userMap['structure']?.toString() ?? '',
            'nom': (userMap['nom']?.toString() ?? '').trim(),
            'prenom': (userMap['prenom']?.toString() ?? '').trim(),
            'password': userMap['password']?.toString() ?? '',
            'privilege': userMap['privilege']?.toString() ?? '',
            'role': userMap['role']?.toString() ?? '',
            'consultation': userMap['consultation']?.toString() ?? '0',
            'insertion': userMap['insertion']?.toString() ?? '0',
            'modification': userMap['modification']?.toString() ?? '0',
            'suppression': userMap['suppression']?.toString() ?? '0',
          };

          // ✅ Vérification des données requises
          if (mappedUser['matricule']?.isEmpty ?? true) {
            print('❌ Matricule manquant, utilisateur ignoré');
            continue;
          }

          // ✅ Insertion sécurisée avec gestion des conflits
          await txn.rawInsert('''
          INSERT OR REPLACE INTO users 
          (matricule, structure, nom, prenom, password, privilege, role, consultation, insertion, modification, suppression)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            mappedUser['matricule'],
            mappedUser['structure'],
            mappedUser['nom'],
            mappedUser['prenom'],
            mappedUser['password'],
            mappedUser['privilege'],
            mappedUser['role'],
            mappedUser['consultation'],
            mappedUser['insertion'],
            mappedUser['modification'],
            mappedUser['suppression'],
          ]);

          print("💾 Utilisateur inséré: ${mappedUser['matricule']}");

        } catch (e) {
          print('❌ Erreur insertion utilisateur $element: $e');
          // Continuer avec les autres utilisateurs même en cas d'erreur
        }
      }
    });
  }
  Future<void> createAffaires(List<dynamic> affaires) async {
    String affaireQuery = '''
      INSERT INTO affaires
      (Code_Affaire, Code_Site, matricule, IntituleAffaire, NbrSite, Multisite, annee, Nom_DR, code_agence, nom_agence, adresse, tel, fax, email, hasVisite)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';
    final db = await instance.database;
    affaires.forEach((element) async {
      var item = Affaire.toMap(element);
      var result = await db.rawInsert(
          affaireQuery,
          [
            item['Code_Affaire'].toString().trim(),
            item['Code_Site'].toString().trim(),
            item['matricule'].toString(),
            item['IntituleAffaire'].toString(),
            item['NbrSite'],
            item['Multisite'],
            item['annee'],
            item['Nom_DR'],
            item['code_agence'],
            item['nom_agence'],
            item['adresse'],
            item['tel'],
            item['fax'],
            item['email'],
            item['hasVisite'],
          ]
      );
    });
  }

  Future<void> createSites(List<dynamic> sites) async {
    String siteQuery = '''
      INSERT INTO sites
      (Code_Affaire, Code_site, adress_proj)
      VALUES (?, ?, ?)
    ''';
    final db = await instance.database;
    sites.forEach((element) async {
      var item = Site.toMap(element);
      var result = await db.rawInsert(
          siteQuery,
          [
            item['Code_Affaire'].toString().trim(),
            item['Code_site'].toString().trim(),
            item['adress_proj'].toString(),
          ]
      );
    });
  }

  Future<void> setHasVisite(code_affaire, code_site) async {
    final storage =new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');
    final db = await instance.database;
    await db.update(
      'affaires',
      {
        'hasVisite': '1'
      },
      where: 'Code_Affaire = ? AND Code_site = ? AND matricule = ?',
      whereArgs: [ code_affaire, code_site, matricule ],
    );
  }
  Future<bool> existeVisite(String code_affaire, String code_site) async {
    final db = await instance.database;
    var result = await db.rawQuery('''
      SELECT COUNT(*) FROM visites WHERE code_affaire = ? AND code_site = ?
    ''', [code_affaire, code_site]);

    return Sqflite.firstIntValue(result)! > 0;
  }

  Future<bool> checkVisiteExists(String codeAffaire, String codeSite) async {
    final db = await instance.database;

    final result = await db.query(
      'visites',
      where: 'Code_Affaire = ? AND Code_site = ?',
      whereArgs: [codeAffaire, codeSite],
    );

    return result.isNotEmpty;
  }


  Future<void> createSync(sync) async {
    String syncQuery = '''
      INSERT INTO sync
      (matricule, syncedAt, syncedData)
      VALUES (?, ?, ?)
    ''';
    final db = await instance.database;
    var item = SyncHistory.toMap(sync);
    var result = await db.rawInsert(
        syncQuery,
        [
          item['matricule'].toString(),
          '${item['syncedAt'].year.toString().padLeft(4, '0')}-${item['syncedAt'].month.toString().padLeft(2, '0')}-${item['syncedAt'].day.toString().padLeft(2, '0')} ${item['syncedAt'].hour.toString().padLeft(2, '0')}:${item['syncedAt'].minute.toString().padLeft(2, '0')}:${item['syncedAt'].second.toString().padLeft(2, '0')}',
          item['syncedData'].toString(),
        ]
    );
  }

  Future<List<SyncHistory>> getSyncHistory() async {
    final storage = new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');
    final db = await instance.database;
    final sync = await db.query(
      'sync',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );
    return sync.map((json) => SyncHistory.fromJson(json)).toList();
  }

Future<List<Commande>> getAllCommandes() async {
  final db = await instance.database;
  final result = await db.query('commandes');
  return result.map((json) => Commande.fromJson(json)).toList();
}


  Future<List<User>> getUser() async {
    final db = await instance.database;
    final users = await db.query('users');
    return users.map((json) => User.fromJson(json)).toList();
  }


  Future<User> getUserByMatricule(matricule) async {
    final db = await instance.database;
    final users = await db.query(
      'users',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );
    return users.map((json) => User.fromJson(json)).toList()[0];
  }

  Future<List<Affaire>> getAffairesFromAffaires() async {
    final db = await instance.database;
    final affaires = await db.query(
      'affaires',
    );

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }

  Future<List<Affaire>> getAffairesFromAffairesWhereMatricule(matricule) async {
    final db = await instance.database;
    final affaires = await db.query(
        'affaires',
        where: 'matricule = ?',
        whereArgs: [ matricule ]
    );

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }




Future<Map<String, dynamic>> getVisitesWhereAffairesSites(args) async {
  if (args.isEmpty) {
    return {'visites': [], 'images': [], 'documentsAnnexes': []};
  }

  final db = await instance.database;

  // Créer les conditions WHERE correctement
  final whereConditions = args.map((e) {
    final codeAffaire = e['Code_Affaire']?.toString() ?? '';
    final codeSite = e['Code_site']?.toString() ?? '';
    return '(Code_Affaire = "$codeAffaire" AND Code_site = "$codeSite")';
  }).toList().join(' OR ');

  final visites = await db.rawQuery('''
    SELECT * FROM visites 
    WHERE $whereConditions
  ''');

  print("Visites récupérées getVisitesWhereAffairesSites: ${visites.length}");

  final Map<String, dynamic> result = {
    'visites': [],
    'images': [],
    'documentsAnnexes': []
  };

  for (var visite in visites) {
    final codeAffaire = visite['Code_Affaire'].toString();
    final codeSite = visite['Code_site'].toString();

    // Récupérer les images avec DEUX patterns différents
    final imagePattern1 = "${codeAffaire}_${codeSite}_%"; // format: codeaffaire_codesite_path
    final imagePattern2 = "${codeAffaire}${codeSite}%";   // format: codeaffairecodesite (concaténation)
    
    final images = await db.query(
      'images',
      where: 'name LIKE ? OR name LIKE ?',
      whereArgs: [imagePattern1, imagePattern2]
    );

    print("Images trouvées pour $codeAffaire/$codeSite: ${images.length}");
    print("Patterns utilisés: '$imagePattern1' et '$imagePattern2'");

    final imagePaths = await Future.wait(images.map((img) async {
      final bytes = img['imageBytes'] as List<int>?;
      final name = img['name'] as String? ?? '';
      final path = img['path'] as String? ?? ''; // Ajout du champ path si nécessaire
      
      print("Traitement image: $path");
      
      try {
        if (bytes != null && bytes.isNotEmpty) {

          final imageFile = await getImage(bytes, name: path);
          print("Image traitée avec succès: ${imageFile.path}");
          return imageFile.path;
        } else {
          print("Image sans bytes: $path");
          return null;
        }
      } catch (e) {
        print("Erreur lors du traitement de l'image $name: $e");
        return null;
      }
    }));

     // Récupérer les documents annexes
    final documents = await db.query(
      'DocumentsAnnexe',
      where: 'Code_Affaire = ? AND Code_site = ?',
      whereArgs: [codeAffaire, codeSite]
    );

    // Filtrer les documents avec contenu valide
    final validDocuments = documents.where((doc) {
      final content = doc['nom_document']?.toString();
      return content != null && content.isNotEmpty;
    }).toList();

    result['visites'].add(visite);
    result['images'].addAll(imagePaths.where((path) => path != null).cast<String>());
    result['documentsAnnexes'].addAll(validDocuments);
  }

  print("Résultat - Visites: ${result['visites'].length}, Images: ${result['images'].length}, Documents: ${result['documentsAnnexes'].length}");
  return result;
}
  Future<List<Site>> getAffairesFromSites() async {
    final db = await instance.database;
    final sites = await db.query(
      'sites',
    );

    return sites.map((json) => Site.fromJson(json)).toList();
  }

  Future<List<Affaire>> getAffaires() async {
    final storage = new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');
    final db = await instance.database;
    final affaires = await db.query(
      'affaires',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }

  Future<Affaire> getAffaire(codeAffaire) async {
    final db = await instance.database;
    final affaires = await db.query(
      'affaires',
      where: 'Code_Affaire = ?',
      whereArgs: [ codeAffaire ],
    );

    return affaires.map((json) => Affaire.fromJson(json)).toList()[0];
  }

  Future<List<Site>> getSites() async {
    final db = await instance.database;
    final sites = await db.query('sites');

    return sites.map((json) => Site.fromJson(json)).toList();
  }




  Future<bool> checkStructure(structure) async {
    final db = await instance.database;
    final affaires = await db.query(
        'affaires',
        where: 'code_agence=?',
        whereArgs: [structure]
    );
    return affaires.isNotEmpty;
  }

  Future<bool> checkExistanceVisite(Code_Affaire, Code_site) async {
    final db = await instance.database;
    final visite = await db.query(
        'visites',
        where: 'Code_Affaire=? and Code_site=?',
        whereArgs: [Code_Affaire, Code_site]
    );
    return visite.length > 0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }


  static Future<void> saveImage(Database db, ImageData imageData) async {
    try {
      await db.insert(
        'images',
        {
          'name': imageData.name,
          'path': imageData.path,
          'imageBytes': imageData.imageBytes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Image sauvegardée avec succès: ${imageData.name}');
    } catch (e) {
      print('Erreur dans saveImage: $e');
      rethrow;
    }
  }

  static Future<List<int>> getImageBytes(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Fichier introuvable: $imagePath');
      }
      return await imageFile.readAsBytes();
    } catch (e) {
      print('Erreur dans getImageBytes: $e');
      rethrow;
    }
  }

 static Future<void> insertImage(String imagePath, String name) async {
  final db = await instance.database;
  try {
    print('Tentative de lecture du fichier: $imagePath');

    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Le fichier image n\'existe pas: $imagePath');
    }

    final List<int> imageBytes = await file.readAsBytes();
    print('Fichier lu avec succès, taille: ${imageBytes.length} bytes');

    final imageData = ImageData(
      name: name,
      path: p.basename(imagePath),
      imageBytes: Uint8List.fromList(imageBytes),
    );

    await saveImage(db, imageData);
    print('Image insérée avec succès dans la base de données');
  } catch (e, stacktrace) {
    print('Erreur dans insertImage: $e');
    print('Stacktrace: $stacktrace');
    rethrow;
  }
}

  static Future<File> getImageFromBytes(List<int> byte, {required String name}) async {
    try {
      final bytes = Uint8List.fromList(byte);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$name';
      return await File(filePath).writeAsBytes(bytes);
    } catch (e) {
      print('Erreur dans getImage: $e');
      rethrow;
    }
  }

Future<List<ImageData>> getAllImages() async {
  try {
    final List<Map<String, dynamic>> maps = await _database!.query('images');
    return List.generate(maps.length, (i) {
      return ImageData(
        id: maps[i]['id'], // <-- AJOUTE CETTE LIGNE
        name: maps[i]['name'],
        path: maps[i]['path'],
        imageBytes: Uint8List.fromList(maps[i]['imageBytes']),
      );
    });
  } catch (e) {
    print('Erreur dans getAllImages: $e');
    return [];
  }
}

  static Future<String> convertBase64ToFile(String base64String, String fileName) async {
    try {
      final decodedBytes = base64Decode(base64String);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      await File(filePath).writeAsBytes(decodedBytes);
      return filePath;
    } catch (e) {
      print('Erreur dans convertBase64ToFile: $e');
      rethrow;
    }
  }
  Future<List<ImageData>> getImagesByVisite(String codeAffaire, String codeSite) async {
    try {
      
      final allImages = await getAllImages();
      final filteredImages = allImages.where((image) {
        final name = image.name.toLowerCase();
        return name.contains(codeSite.toLowerCase()) &&
            name.contains(codeAffaire.toLowerCase());
      }).toList();

      return filteredImages;
    } catch (e) {
      print('Erreur dans getImagesByVisite: $e');
      rethrow;
    }
  }
  static Future<void> deleteImage(int id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'images',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erreur dans deleteImage: $e');
      rethrow;
    }
  }
  static Future<void> deleteImagesForVisite(String codeAffaire, String codeSite) async {
    try {
      final db = await instance.database;
      await db.delete(
        'images',
        where: 'code_affaire = ? AND code_site = ?',
        whereArgs: [codeAffaire, codeSite],
      );
      print('🗑️ Images supprimées pour la visite: $codeAffaire / $codeSite');
    } catch (e) {
      print('Erreur dans deleteImagesForVisite: $e');
      rethrow;
    }
  }

static Future<File> getImage(List<int>? byte, {required String name}) async {
  if (byte == null) {
    throw Exception("Les données de l'image sont nulles pour le fichier: $name");
  }
  final bytes = Uint8List.fromList(byte);
  String filePath = '${Directory.systemTemp.path}/$name';
  return await convertUint8ListToFile(bytes, filePath);
}


  static Future<File> convertUint8ListToFile(
      Uint8List uint8List, String filePath) async {
    File file = File(filePath);
    return await file.writeAsBytes(uint8List);
  }





}