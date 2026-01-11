import 'dart:convert';
import 'dart:typed_data';
import 'package:mgtrisque_visitepreliminaire/models/user.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/interventions.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'localdatabase.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final cols = [
            "fb_id TEXT",
            "fb_prelevement TEXT",
            "fb_affaire TEXT",
            "fb_site TEXT",
            "fb_pv TEXT",
            "created_at TEXT",
            "updated_at TEXT",
            "fb_constituant TEXT",
            "fb_provenance TEXT",
            "fb_type TEXT",
            "fb_dosage REAL",
            "fb_dmin REAL",
            "fb_dmax REAL"
          ];
          for (final col in cols) {
            try {
              await db.execute("ALTER TABLE constituants ADD COLUMN $col");
              await db.execute("ALTER TABLE interventions_recu ADD COLUMN Structure TEXT");
              await db.execute("ALTER TABLE interventions_recu ADD COLUMN Nom_DR TEXT");
              await db.execute("ALTER TABLE interventions_recu ADD COLUMN bet TEXT");
              await db.execute("ALTER TABLE interventions_recu ADD COLUMN heure TEXT");
              await db.execute("ALTER TABLE interventions_recu ADD COLUMN elementOuvrages TEXT");


            } catch (e) {
              // ignore si la colonne existe déjà
            }
          }
        }
        if (oldVersion < 3) {
          await db.execute('''
      ALTER TABLE interventions_recu ADD COLUMN user_matricule TEXT;
      ALTER TABLE interventions_recu ADD COLUMN user_nom TEXT;
      ALTER TABLE interventions_recu ADD COLUMN user_prenom TEXT;
      ALTER TABLE interventions_recu ADD COLUMN user_role TEXT;
    ''');
        }
        if (oldVersion < 4) {
          // Migration for elements_ouvrage: remove pe_id and peid columns
          await db.transaction((txn) async {
            // 1. Create new table without pe_id and peid
            await txn.execute('''
              CREATE TABLE elements_ouvrage_new(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                intervention_id INTEGER,
                nom TEXT,
                axe TEXT,
                file TEXT,
                bloc TEXT,
                niveau REAL,
                famille TEXT,
                partie_ouvrage_id INTEGER,
                partie_ouvrage_designation TEXT,
                FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE
              )
            ''');

            // 2. Copy data from old table to new table
            // We select columns that exist in both tables
            await txn.execute('''
              INSERT INTO elements_ouvrage_new (id, intervention_id, nom, axe, file, bloc, niveau, famille, partie_ouvrage_id, partie_ouvrage_designation)
              SELECT id, intervention_id, nom, axe, file, bloc, niveau, famille, partie_ouvrage_id, partie_ouvrage_designation
              FROM elements_ouvrage
            ''');

            // 3. Drop old table
            await txn.execute('DROP TABLE elements_ouvrage');

            // 4. Rename new table to old table name
            await txn.execute('ALTER TABLE elements_ouvrage_new RENAME TO elements_ouvrage');
          });
        }
      },
    );
  }
static Future<List<Map<String, dynamic>>> getCarrieresRef() async {
  final db = await database;
  return await db.query('carrieres_ref');
}

Future<List<Commande>> getAllCommandes() async {
  final db = await database;
  final result = await db.query('interventions');
  return result.map((json) => Commande.fromJson(Map<String, dynamic>.from(json))).toList();
}

  static Future<void> _createTables(Database db, int version) async {
    
    await db.execute('''
      CREATE TABLE interventions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pe_id TEXT UNIQUE,
        pe_date TEXT,
        pe_heure TEXT,
        pe_temp REAL,
        pe_affais_cone REAL,
        pe_cim_ec REAL,
        pe_obs TEXT,
        pe_mode_prod INTEGER,
        Code_Affaire TEXT,
        date_validation_pm TEXT,
        -- Références
        Code_Site TEXT,
        commande_id TEXT,
        entreprise_id TEXT,
        classe_beton_id INTEGER,
        charge_affaire_id TEXT,
        date_validation_laboratoire_item TEXT,
        -- Informations affaire
        intitule_affaire TEXT,
        categorie_chantier TEXT,
        entreprise_real TEXT,
        user_data TEXT,
        -- Statut
        is_synced BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
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
    ''');
    await db.execute('''
      CREATE TABLE elements_ouvrage(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        intervention_id INTEGER,
        nom TEXT,
        axe TEXT,
        file TEXT,
        bloc TEXT,
        niveau REAL,
        famille TEXT,
        partie_ouvrage_id INTEGER,
        partie_ouvrage_designation TEXT,
        FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE
      )
    ''');

    
  await db.execute('''
  CREATE TABLE constituants(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    intervention_id INTEGER,
    fb_id TEXT,
    -- Champs pour l'API
    fb_constituant TEXT,
    fb_provenance TEXT,
    fb_type TEXT,
    fb_dosage REAL,
    fb_dmin REAL,
    fb_dmax REAL,
     fb_prelevement TEXT,
   fb_affaire TEXT,
   fb_site TEXT,
   fb_pv TEXT,
   created_at TEXT,
   updated_at TEXT,
    -- Champs pour le stockage local
    type TEXT,           -- ← NOUVELLE COLONNE
    dosage REAL,
    prov TEXT,
    dmin REAL,
    dmax REAL,
    nom_produit TEXT,
    constituant_order INTEGER,
    category TEXT,
    
    FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE
  )
''');
    
    await db.execute('''
      CREATE TABLE series_eprouvettes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        intervention_id INTEGER,
        age TEXT,
        forme TEXT,
        nbr_echantillon INTEGER,
        serie_order INTEGER,
        motif_non_prelevement TEXT,
        FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE
      )
    ''');

    
    await db.execute('''
      CREATE TABLE eprouvettes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        intervention_id INTEGER,
        serie_id INTEGER,
        epr_id TEXT,
        age TEXT,
        type_eprouvette_id TEXT,
        type_eprouvette_label TEXT,
        forme TEXT,
        nbr_echantillon INTEGER,
        ordre INTEGER,
        FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE,
        FOREIGN KEY (serie_id) REFERENCES series_eprouvettes(id) ON DELETE CASCADE
      )
    ''');

    
    await db.execute('''
      CREATE TABLE motifs_non_prelevement(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        intervention_id INTEGER,
        age_number INTEGER,
        motif TEXT,
        
        FOREIGN KEY (intervention_id) REFERENCES interventions(id) ON DELETE CASCADE
      )
    ''');

    
    await db.execute('''
      CREATE TABLE interventions_recu(
        id INTEGER PRIMARY KEY,
        codeCommande TEXT UNIQUE,
        num_commande TEXT,
        matricule TEXT,
        nom TEXT,
        prenom TEXT,
     
     IntituleAffaire TEXT,
        NumCommande TEXT,
        elembloc TEXT,
        codeSite TEXT,
        bloc TEXT,
        pe_id TEXT,
        bet TEXT,
        Code_Affaire TEXT,
        Code_Site TEXT,
        ChargedAffaire TEXT,
        AutresInfo TEXT,
        Validation_labo TEXT,
        user_code TEXT,
        Nom_DR_Laboratoire TEXT,
        Structure_Laboratoire TEXT, 
        TypeIntervention TEXT, 
        EntrepriseRealisation TEXT, 
        maitre_ouvrage TEXT, 
        partie_ouvrage TEXT,
        pe_date_pv TEXT,
        localisation TEXT,
        age1 INTEGER,
        age2 INTEGER,
        age3 INTEGER,
        age4 INTEGER,
        age5 INTEGER,
        partie_ouvrage_id INTEGER,
        partie_ouvrage_designation TEXT,
         date_validation_laboratoire_item TEXT,
TEntreRealSite TEXT,
    BesoinCommande TEXT,
    DateCommande TEXT,
    DelaiEssai TEXT,
    Description TEXT,
    ElementAusculter TEXT,
  
    NbrCarotte INTEGER,
    NormeEssai TEXT,
    PartieOuvrage TEXT,
    TypeCommande TEXT,
    NumLaboratoire TEXT,
    Nom_DR TEXT,
    Structure TEXT,
    etat TEXT,
    essai TEXT,
    designations_autres TEXT,
    validation_chargedaffaire TEXT,
    date_validation_chargedaffaire TEXT,
    validation_pm TEXT,
    date_validation_pm TEXT,
    rejet_pm TEXT,
    date_rejet_pm TEXT,
    motif_rejet_pm TEXT,
    annulation_pm TEXT,
    date_annulation_pm TEXT,
    motif_annulation_pm TEXT,
 
    createdBy TEXT,
    numero TEXT,
    updated_at TEXT,
    created_at TEXT,
    motif_non_realisation_commande TEXT,
    date_non_realisation_commande TEXT,
    responsable_non_realisation TEXT,
    annulation_ca TEXT,
    date_annulation_ca TEXT,
    motif_annulation_ca TEXT,
    reprogrammation_ca TEXT,
    date_programmation_ca TEXT,
    motif_programmation_ca TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE classes_beton_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE elements_predefinis_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        code TEXT,
        designation TEXT,
        mission TEXT,
        type TEXT,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE modes_production_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE carrieres_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE types_ciment_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE types_adjuvant_ref(
        id INTEGER PRIMARY KEY,
        value INTEGER,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE types_eprouvette_ref(
        id INTEGER PRIMARY KEY,
        eprvid TEXT,
        eprv_id TEXT,
        eprv_type TEXT,
        Etat TEXT,
        created_at TEXT,
        updated_at TEXT,
        eprvlabel TEXT,
        value TEXT,
        label TEXT
      )
    ''');
  }



  static Future<int> saveIntervention(Map<String, dynamic> intervention) async {
    final db = await database;
    
    
    final existing = await db.query(
      'interventions',
      where: 'pe_id = ?',
      whereArgs: [intervention['pe_id']],
    );

    if (existing.isNotEmpty) {
      
      return await db.update(
        'interventions',
        intervention,
        where: 'pe_id = ?',
        whereArgs: [intervention['pe_id']],
      );
    } else {
      
      return await db.insert('interventions', intervention);
    }
  }
 Future<List<User>> getUser() async {
    final db = await database;
    final users = await db.query('users');
    return users.map((json) => User.fromJson(json)).toList();
  }
  
    Future<int> dropUsers(String? structure) async {
    final db = await database;

    if (structure != null && structure.isNotEmpty) {
      
      return await db.rawDelete(
        'DELETE FROM users WHERE structure = ?',
        [structure],
      );
    } else {
      return await db.rawDelete('DELETE FROM users');
    }
  }

    Future<void> createUsers(List<dynamic> users) async {
    final db = await database;

    
    await db.transaction((txn) async {
      for (var element in users) {
        try {
          print('📥 Traitement utilisateur: $element');

          
          Map<String, dynamic> userMap;
          if (element is Map<String, dynamic>) {
            userMap = element;
          } else if (element is User) {
            
            userMap = element.toJson();
          } else {
            print('❌ Type d\'utilisateur non supporté: ${element.runtimeType}');
            continue;
          }

          
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

          
          if (mappedUser['matricule']?.isEmpty ?? true) {
            print('❌ Matricule manquant, utilisateur ignoré');
            continue;
          }

          
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
          
        }
      }
    });
  }
 

  static Future<Map<String, dynamic>?> getIntervention(String peId) async {
    final db = await database;
    final results = await db.query(
      'interventions',
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedInterventions() async {
    final db = await database;
    return await db.query(
      'interventions',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }
  Future<void> saveElementsPred(List<ElementPredefini> elements) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS elements_predefinis(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT,
          code TEXT,
          designation TEXT,
          mission TEXT,
          type TEXT
        )
      ''');

      await txn.delete('elements_predefinis');
      for (var element in elements) {
        await txn.insert('elements_predefinis', element.toJson());
      }
    });
  }
    Future<void> saveCarrieres(List<ClasseCarrieres> carrieres) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS carrieres(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT
        )
      ''');
      
      await txn.delete('carrieres');
      for (var carriere in carrieres) {
        await txn.insert('carrieres', carriere.toJson());
      }
    });
  }

static Future<void> saveElementsOuvrage(
      String peId, List<Elemouvrage> elements) async {
    final db = await database;
    final intervention = await getIntervention(peId);
    
    if (intervention == null) return;

    // Supprimer les anciens éléments (Nettoyage robuste)
    await db.delete(
      'elements_ouvrage',
      where: 'intervention_id = ?',
      whereArgs: [intervention['id']],
    );

    // Insérer les nouveaux éléments
    for (var elem in elements) {
      await db.insert('elements_ouvrage', {
        'intervention_id': intervention['id'],
        'nom': elem.nom,
        'axe': elem.axe,
        'file': elem.file,
        'niveau': elem.niveau,
        'bloc': elem.bloc,
        'famille': elem.famille,
        'partie_ouvrage_id': elem.partieOuvrage?.id,
        'partie_ouvrage_designation': elem.partieOuvrage?.designation,
      });
    }
  }
static Future<List<Map<String, dynamic>>> getElementsOuvrageByPeId(String peId) async {
  final db = await database;
  final intervention = await getIntervention(peId);
  
  if (intervention == null) return [];

  return await db.query(
    'elements_ouvrage',
    where: 'intervention_id = ?',
    whereArgs: [intervention['id']],
  );
}

static Future<List<Map<String, dynamic>>> getElementsOuvrageByInterventionId(int interventionId) async {
  final db = await database;
  return await db.query(
    'elements_ouvrage',
    where: 'intervention_id = ?',
    whereArgs: [interventionId],
  );
}



  // static Future<void> saveElementsOuvrage(
  //     String peId, List<Elemouvrage> elements) async {
  //   final db = await database;
  //   final intervention = await getIntervention(peId);
    
  //   if (intervention == null) return;

    
  //   await db.delete(
  //     'elements_ouvrage',
  //     where: 'intervention_id = ?',
  //     whereArgs: [intervention['id']],
  //   );

    
  //   for (var elem in elements) {
  //     await db.insert('elements_ouvrage', {
  //       'intervention_id': intervention['id'],
  //       'nom': elem.nom,
  //       'axe': elem.axe,
  //       'file': elem.file,
  //       'niveau': elem.niveau,
  //       'bloc': elem.bloc,
  //       'famille': elem.famille,
  //       'partie_ouvrage_id': elem.partieOuvrage?.id,
  //       'partie_ouvrage_designation': elem.partieOuvrage?.designation,
  //     });
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getElementsOuvrage(String peId) async {
    final db = await database;
    final intervention = await getIntervention(peId);
    
    if (intervention == null) return [];
    
    return await db.query(
      'elements_ouvrage',
      where: 'intervention_id = ?',
      whereArgs: [intervention['id']],
    );
  }
  Future<List<ClasseBeton>> getAllBetons() async {
    final db = await database;
    final result = await db.query('betons');
    return result.map((json) => ClasseBeton.fromJson(Map<String, dynamic>.from(json))).toList();
  }


  Future<List<ElementPredefini>> getAllElementsPred() async {
    final db = await database;
    final result = await db.query('elements_predefinis');
    return result.map((json) => ElementPredefini.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<ModesProduction>> getAllModesProd() async {
    final db = await database;
    final result = await db.query('modes_production');
    return result.map((json) => ModesProduction.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<ClasseCarrieres>> getAllCarrieres() async {
    final db = await database;
    final result = await db.query('carrieres');
    return result.map((json) => ClasseCarrieres.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<TypeCiments>> getAllTypesCiments() async {
    final db = await database;
    final result = await db.query('types_ciments');
    return result.map((json) => TypeCiments.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<TypeAdjuvants>> getAllTypesAdjuvants() async {
    final db = await database;
    final result = await db.query('types_adjuvants');
    return result.map((json) => TypeAdjuvants.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<TypeEprouvettes>> getAllTypesEprouvettes() async {
    final db = await database;
    final result = await db.query('types_eprouvettes');
    return result.map((json) => TypeEprouvettes.fromJson(Map<String, dynamic>.from(json))).toList();
  }
  static Future<List<Constituant>> getConstituantsByIntervention(String peId) async {
  final db = await database;
  final intervention = await getIntervention(peId);
  
  if (intervention == null) return [];

  final List<Map<String, dynamic>> maps = await db.query(
    'constituants',
    where: 'intervention_id = ?',
    whereArgs: [intervention['id']],
    orderBy: 'constituant_order ASC',
  );

  return maps.map((map) => _mapToConstituant(map)).toList();
}

static Future<List<Map<String, dynamic>>> getConstituantsByType(String peId, String type) async {
  final db = await database;
  final intervention = await getIntervention(peId);
  
  if (intervention == null) return [];

  final List<Map<String, dynamic>> maps = await db.query(
    'constituants',
    where: 'intervention_id = ? AND category = ?',
    whereArgs: [intervention['id'], type],
    orderBy: 'constituant_order ASC',
  );

  return maps;
}

static Constituant _mapToConstituant(Map<String, dynamic> map) {
  return Constituant(
    fbId: map['id']?.toString() ?? '',
    fbProvenance: map['fb_provenance']?.toString() ?? '',
    fbType: map['fb_type']?.toString(),
    fbDosage: map['fb_dosage'] ?? 0,
    fbDmin: map['fb_dmin'] != null ? int.tryParse(map['fb_dmin'].toString()) : null,
    fbDmax: map['fb_dmax'] != null ? int.tryParse(map['fb_dmax'].toString()) : null,
    fbConstituant: map['fb_constituant']?.toString() ?? '',
    fbPrelevement: map['intervention_id']?.toString() ?? '',
    fbAffaire: '', // À récupérer depuis l'intervention si nécessaire
    fbSite: '', // À récupérer depuis l'intervention si nécessaire
    fbPv: map['fb_pv']?.toString(),
    createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
  );
}

  // static Future<void> saveConstituants(
  //     String peId, List<Map<String, dynamic>> constituants) async {
  //   final db = await database;
  //   final intervention = await getIntervention(peId);
    
  //   if (intervention == null) return;

    
  //   await db.delete(
  //     'constituants',
  //     where: 'intervention_id = ?',
  //     whereArgs: [intervention['id']],
  //   );

    
  //   for (var i = 0; i < constituants.length; i++) {
  //     final constituant = constituants[i];
  //     await db.insert('constituants', {
  //       'intervention_id': intervention['id'],
  //       'fb_constituant': _getConstituantType(constituant),
  //       'fb_provenance': _getProvenance(constconstituant),
  //       'fb_type': constituant['type']?.toString(),
  //       'fb_dosage': constituant['dosage'],
  //       'fb_dmin': constituant['dmin'],
  //       'fb_dmax': constituant['dmax'],
  //       'nom_produit': constituant['nomProduit'],
  //       'constituant_order': i,
  //       'category': constituant['type'],
  //     });
  //   }
  // }


  static Future<void> migrateConstituantsFromType() async {
    final db = await database;

    // Utiliser un batch pour appliquer plusieurs updates rapidement
    final batch = db.batch();

    // Mapping texte -> code fb_constituant
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '1' WHERE fb_constituant IS NULL AND LOWER(type) = 'granulas'");
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '2' WHERE fb_constituant IS NULL AND LOWER(type) = 'sables'");
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '3' WHERE fb_constituant IS NULL AND LOWER(type) = 'ciment'");
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '4' WHERE fb_constituant IS NULL AND LOWER(type) = 'adjuvant'");
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '6' WHERE fb_constituant IS NULL AND LOWER(type) = 'additif'");
    batch.rawUpdate("UPDATE constituants SET fb_constituant = '5' WHERE fb_constituant IS NULL AND LOWER(type) = 'eau'");

    // Si `type` contient déjà un code numérique (ex: '6', '8'), recopier dans fb_constituant
    batch.rawUpdate("UPDATE constituants SET fb_constituant = type WHERE fb_constituant IS NULL AND type GLOB '[0-9]*'");

    // Récupérer provenance / dosage si manquants
    batch.rawUpdate("UPDATE constituants SET fb_provenance = prov WHERE fb_provenance IS NULL AND prov IS NOT NULL");
    batch.rawUpdate("UPDATE constituants SET fb_dosage = dosage WHERE fb_dosage IS NULL AND dosage IS NOT NULL");

    // Copier dmin/dmax si vides (optionnel)
    batch.rawUpdate("UPDATE constituants SET fb_dmin = dmin WHERE fb_dmin IS NULL AND dmin IS NOT NULL");
    batch.rawUpdate("UPDATE constituants SET fb_dmax = dmax WHERE fb_dmax IS NULL AND dmax IS NOT NULL");

    await batch.commit(noResult: true);
    print('✅ Migration: constituants normalisés (fb_constituant/fb_provenance/fb_dosage...)');
  }
static Future<void> saveConstituants(
    String peId, List<Map<String, dynamic>> constituants) async {
  final db = await database;
  final intervention = await getIntervention(peId);
  
  if (intervention == null) return;

  await db.delete(
    'constituants',
    where: 'intervention_id = ?',
    whereArgs: [intervention['id']],
  );

  for (var i = 0; i < constituants.length; i++) {
    final constituant = constituants[i];

    // Garder les champs bruts reçus par l'API (fb_*) tout en remplissant les colonnes locales
    final dosage = _safeConvertToDouble(constituant['fb_dosage'] ?? constituant['dosage']) ?? 0.0;
    final dmin = _safeConvertToDouble(constituant['fb_dmin'] ?? constituant['dmin']);
    final dmax = _safeConvertToDouble(constituant['fb_dmax'] ?? constituant['dmax']);

    await db.insert('constituants', {
      'intervention_id': intervention['id'],
  
      'fb_id': constituant['fb_id']?.toString() ?? constituant['fbId']?.toString(),
      'fb_constituant': constituant['fb_constituant']?.toString() ?? constituant['fb_Constituant']?.toString(),
      'fb_provenance': constituant['fb_provenance']?.toString() ?? constituant['fb_provenance'],
      'fb_type': constituant['fb_type']?.toString() ?? constituant['fb_type'],
      'fb_dosage': dosage,
      'fb_dmin': dmin,
      'fb_dmax': dmax,
      'fb_prelevement': constituant['fb_prelevement']?.toString(),
      'fb_affaire': constituant['fb_affaire']?.toString(),
      'fb_site': constituant['fb_site']?.toString(),
      'fb_pv': constituant['fb_pv']?.toString(),
      'created_at': constituant['created_at']?.toString(),
      'updated_at': constituant['updated_at']?.toString(),

  
      'type': constituant['type'] ?? _mapFbConstituantToLocalType(constituant),
      'dosage': dosage,
      'prov': constituant['prov'] ?? constituant['fb_provenance'] ?? constituant['source'] ?? constituant['nomProduit'],
      'dmin': dmin,
      'dmax': dmax,
      'nom_produit': constituant['nomProduit']?.toString() ?? '',
      'constituant_order': i,
      'category': constituant['type'] ?? constituant['category'] ?? constituant['fb_constituant']?.toString(),
    });
  }
}

static String _mapFbConstituantToLocalType(Map<String, dynamic> c) {
  final fb = c['fb_constituant']?.toString() ?? c['fbConstituant']?.toString() ?? '';
  switch (fb) {
    case '1': return 'granulas';
    case '2': return 'sables';
    case '3': return 'ciment';
    case '4': return 'adjuvant';
    case '6': return 'additif';
    case '5': return 'eau';
    default: return c['type'] ?? 'autre';
  }
}

static Future<Map<String, dynamic>> getCompleteIntervention(String peId) async {
  final intervention = await getIntervention(peId);
  if (intervention == null) return {};

  final elements = await getElementsOuvrage(peId);
  final constituants = await getConstituants(peId);
  final eprouvettes = await getSeriesEprouvettes(peId);

  return {
    'intervention': intervention,
    'elements_ouvrage': elements,
    'constituants': constituants,
    'eprouvettes': eprouvettes,
  };
}
  static String _getConstituantType(Map<String, dynamic> constituant) {
    switch (constituant['type']) {
      case 'granulas': return '1';
      case 'sables': return '2';
      case 'ciment': return '3';
      case 'adjuvant': return '4';
      case 'additif': return '6';
      case 'eau': return '5';
      default: return '0';
    }
  }

  static String _getProvenance(Map<String, dynamic> constituant) {
    if (constituant['prov'] is ClasseCarrieres) {
      return constituant['prov'].value.toString();
    }
    return constituant['prov']?.toString() ?? '';
  }

  // static Future<List<Map<String, dynamic>>> getConstituants(String peId) async {
  //   final db = await database;
  //   final intervention = await getIntervention(peId);

  //   if (intervention == null) return [];

  //   final constituants = await db.query(
  //     'constituants',
  //     where: 'intervention_id = ?',
  //     whereArgs: [intervention['id']],
  //     orderBy: 'constituant_order ASC',
  //   );

    
  //   return constituants.map((constituant) {
  //     return {
  //       ...constituant,
  //       'fb_dmin': _safeConvertToInt(constituant['fb_dmin']),
  //       'fb_dmax': _safeConvertToInt(constituant['fb_dmax']),
  //       'fb_dosage': _safeConvertToDouble(constituant['fb_dosage']),
  //     };
  //   }).toList();
  // }

 
   Future<bool> checkStructure(structure) async {
    final db = await database;
    final affaires = await db.query(
        'affaires',
        where: 'code_agence=?',
        whereArgs: [structure]
    );
    return affaires.isNotEmpty;
  }
 
  static Future<List<Map<String, dynamic>>> getConstituants(String peId) async {
    final db = await database;
    final intervention = await getIntervention(peId);

    if (intervention == null) return [];

    final constituants = await db.query(
      'constituants',
      where: 'intervention_id = ?',
      whereArgs: [intervention['id']],
      orderBy: 'constituant_order ASC',
    );

    return constituants.map((constituant) {
      return {
        ...constituant,
        // conserver les champs API bruts
        'fb_id': constituant['fb_id']?.toString(),
        'fb_provenance': constituant['fb_provenance']?.toString(),
        'fb_type': constituant['fb_type']?.toString(),
        'fb_dosage': _safeConvertToDouble(constituant['fb_dosage']),
        'fb_dmin': _safeConvertToInt(constituant['fb_dmin']),
        'fb_dmax': _safeConvertToInt(constituant['fb_dmax']),
        'fb_prelevement': constituant['fb_prelevement']?.toString(),
        'fb_affaire': constituant['fb_affaire']?.toString(),
        'fb_site': constituant['fb_site']?.toString(),
        'fb_pv': constituant['fb_pv']?.toString(),
        'created_at': constituant['created_at']?.toString(),
        'updated_at': constituant['updated_at']?.toString(),

        // champs locaux inchangés
        'fb_dmin': _safeConvertToInt(constituant['fb_dmin']),
        'fb_dmax': _safeConvertToInt(constituant['fb_dmax']),
        'fb_dosage': _safeConvertToDouble(constituant['fb_dosage']),
      };
    }).toList();
  }

  static int? _safeConvertToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _safeConvertToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

    Future<void> saveCommandes(List<Commande> commandes) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS commandes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          CodeCommande TEXT,
          NumCommande TEXT,
          Code_Site TEXT,
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
          date_validation_pm TEXT,
          datevalidationpm TEXT,
          Motif_non_prelevement TEXT,
          Ouvrage TEXT,
          Age1 TEXT,
          Age2 TEXT,
          Age3 TEXT,
          Age4 TEXT,
          Age5 TEXT,
          Bloc TEXT,
          ElemBloc TEXT,
          Localisation TEXT,
          Partie_Ouvrage TEXT,
          Entreprises TEXT,
          Blocs TEXT,
          Elemouvrages TEXT,
          EntrepriseRealisation TEXT,
          maitre_ouvrage TEXT
        )
      ''');
      
      await txn.delete('commandes');
      for (var commande in commandes) {
        final map = commande.toJson();
        
        map.forEach((key, value) {
          if (value is Map || value is List) {
            map[key] = jsonEncode(value);
          }
        });
        await txn.insert('commandes', map);
      }
    });
  }

    Future<void> saveModesProd(List<ModesProduction> modes) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS modes_production(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT
        )
      ''');
      
      await txn.delete('modes_production');
      for (var mode in modes) {
        await txn.insert('modes_production', mode.toJson());
      }
    });
  }


    Future<void> saveTypesAdjuvants(List<TypeAdjuvants> types) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS types_adjuvants(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT
        )
      ''');
      
      await txn.delete('types_adjuvants');
      for (var type in types) {
        await txn.insert('types_adjuvants', type.toJson());
      }
    });
  }
  Future<void> saveTypesCiments(List<TypeCiments> types) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS types_ciments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT
        )
      ''');
      
      await txn.delete('types_ciments');
      for (var type in types) {
        await txn.insert('types_ciments', type.toJson());
      }
    });
  }
  Future<void> saveTypesEprouvettes(List<TypeEprouvettes> types) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS types_eprouvettes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT,
          eprv_id TEXT,
          eprv_type TEXT
        )
      ''');
      
      
      for (var type in types) {
        await txn.insert('types_eprouvettes', type.toJson());
      }
    });
  }
  Future<void> saveBetons(List<ClasseBeton> betons) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS betons(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value TEXT,
          label TEXT
        )
      ''');
      
      await txn.delete('betons');
      for (var beton in betons) {
        await txn.insert('betons', beton.toJson());
      }
    });
  }
  
  

 // ...existing code...
  static Future<void> saveEprouvettes(
      String peId, List<Map<String, dynamic>> series) async {
    final db = await database;
    final intervention = await getIntervention(peId);
    if (intervention == null) return;

    await db.transaction((txn) async {
      // Supprime séries + éprouvettes existantes pour cette intervention
      final existingSeries = await txn.query(
        'series_eprouvettes',
        where: 'intervention_id = ?',
        whereArgs: [intervention['id']],
      );
      if (existingSeries.isNotEmpty) {
        final ids = existingSeries.map((s) => s['id']).toList();
        // delete eprouvettes linked to these series
        await txn.delete('eprouvettes',
            where: 'serie_id IN (${List.filled(ids.length, '?').join(',')})',
            whereArgs: ids);
        await txn.delete('series_eprouvettes',
            where: 'id IN (${List.filled(ids.length, '?').join(',')})',
            whereArgs: ids);
      }

      // Insère les nouvelles séries et leurs éprouvettes
      for (var i = 0; i < series.length; i++) {
        final s = series[i];
        final serieRow = {
          'intervention_id': intervention['id'],
          'age': s['Age']?.toString() ?? s['age']?.toString() ?? '',
          'forme': s['Forme']?.toString() ?? s['forme']?.toString() ?? '',
          'nbr_echantillon': s['NbrEchantillon'] ?? s['nbr_echantillon'] ?? 0,
          'serie_order': s['serie_order'] ?? i,
          'motif_non_prelevement': s['motif_non_prelevement'] ?? s['motif'] ?? null,
        };
        final serieId = await txn.insert('series_eprouvettes', serieRow);

        final List eprList = (s['eprouvettes'] as List?) ?? [];
        for (var j = 0; j < eprList.length; j++) {
          final e = Map<String, dynamic>.from(eprList[j] as Map? ?? {});
          // Priorité : valeurs propres à l'éprouvette, sinon reprendre age/forme de la série
          final eprRow = {
            'serie_id': serieId,
            'epr_id': e['epr_id'] ?? e['id'] ?? null,
            'age': e['age']?.toString() ?? serieRow['age']?.toString() ?? '',
            'type_eprouvette_id': e['type_id']?.toString() ?? e['type_eprouvette_id']?.toString() ?? '',
            'type_eprouvette_label': e['type_label'] ?? e['type_eprouvette_label'] ?? '',
            'forme': e['forme']?.toString() ?? serieRow['forme']?.toString() ?? '',
            'nbr_echantillon': e['nbr_echantillon'] ?? serieRow['nbr_echantillon'] ?? 0,
            'ordre': e['ordre'] ?? j,
          };
          await txn.insert('eprouvettes', eprRow);
        }
      }
    });
  }
  static Future<List<Map<String, dynamic>>> getSeriesEprouvettes(String peId) async {
    final db = await database;
    final intervention = await getIntervention(peId);
    if (intervention == null) return [];

    // Récupère les séries
    final seriesRows = await db.query(
      'series_eprouvettes',
      where: 'intervention_id = ?',
      whereArgs: [intervention['id']],
      orderBy: 'serie_order ASC',
    );

    final List<Map<String, dynamic>> result = [];

    for (final s in seriesRows) {
      // Récupère les éprouvettes de la série en conservant âge et type
      final eprRows = await db.query(
        'eprouvettes',
        where: 'serie_id = ?',
        whereArgs: [s['id']],
        orderBy: 'ordre ASC, id ASC',
      );

      result.add({
        'id': s['id'],
        'Age': s['age'],
        'Forme': s['forme'],
        'NbrEchantillon': s['nbr_echantillon'],
        'serie_order': s['serie_order'],
        'motif_non_prelevement': s['motif_non_prelevement'],
        'eprouvettes': eprRows.map((e) => {
              'id': e['id'],
              'epr_id': e['epr_id'],
              'age': e['age'],
              'type_id': e['type_eprouvette_id'],
              'type_label': e['type_eprouvette_label'],
              'forme': e['forme'],
              'nbr_echantillon': e['nbr_echantillon'],
              'ordre': e['ordre'],
            }).toList(),
      });
    }

    return result;
  }
  static Future<Database> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'localdatabase.db');
    return openDatabase(path);
  }

 static Future<List<Map<String, dynamic>>> getTableData({
    required String tableName,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await getDatabase();
    return db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }
  

  static Future<void> saveMotifsNonPrelevement(
      String peId, List<String?> motifs) async {
    final db = await database;
    final intervention = await getIntervention(peId);
    
    if (intervention == null) return;

    
    await db.delete(
      'motifs_non_prelevement',
      where: 'intervention_id = ?',
      whereArgs: [intervention['id']],
    );

    for (var i = 0; i < motifs.length; i++) {
      if (motifs[i] != null && motifs[i]!.isNotEmpty) {
        await db.insert('motifs_non_prelevement', {
          'intervention_id': intervention['id'],
          'age_number': i + 1,
          'motif': motifs[i],
        });
      }
    }
  }
 

  static Future<Map<String, dynamic>?> getClasseBetonById(int? classeBetonId) async {
    if (classeBetonId == null) return null;
    
    final db = await database;
    final results = await db.query(
      'classes_beton_ref',
      where: 'value = ?',
      whereArgs: [classeBetonId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<String> getClasseBetonLabel(int? classeBetonId) async {
    if (classeBetonId == null) return 'Non spécifié';
    
    final classeBeton = await getClasseBetonById(classeBetonId);
    return classeBeton?['label'] ?? 'Classe béton inconnue';
  }
  

    static Future<void> saveReferences(Map<String, dynamic> references) async {
    final db = await database;
    

 if (references['commandes'] != null) {
      if (references['commandes'].isNotEmpty) {
        try {
          await db.delete('interventions_recu');
          print("🧹 Table interventions_recu vidée avant mise à jour");
        } catch (e) {
          print("⚠️ Erreur nettoyage interventions_recu: $e");
        }
      }

      for (var commande in references['commandes']) {
        final data = commande is Map ? Map<String, dynamic>.from(commande) : commande.toMap();

        await upsertCommandeRef(data);
      }
      print("✅ ${references['commandes'].length} commandes sauvegardées");
    }
    
    if (references['beton'] != null) {
      print("📊 Tentative sauvegarde béton: ${references['beton'].length} items");
      for (var item in references['beton']) {
        final data = item is Map ? item : item.toMap();
        print("  → Insérant: $data");
        await db.insert('classes_beton_ref', data, 
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print("✅ Classes béton sauvegardées");
    }

    
    await _saveReferenceList(db, 'elements_predefinis_ref', references['elementPredefini']);
    await _saveReferenceList(db, 'modes_production_ref', references['modePro']);
    await _saveReferenceList(db, 'carrieres_ref', references['carrieres']);
    await _saveReferenceList(db, 'types_ciment_ref', references['typeciment']);
    await _saveReferenceList(db, 'types_adjuvant_ref', references['typeAdjuvant']);
    await _saveReferenceList(db, 'types_eprouvette_ref', references['typeEprouvette']);
  }
    static Future<List<Map<String, dynamic>>> getAllTypeEprouvettesRef() async {
    final db = await database;
    return await db.query('types_eprouvette_ref');
  }

  static Future<int> saveCommandeRefForIntervention(String peId, Commande commande) async {
  final db = await database;
  try {
    final map = commande.toJson();
    final id = await upsertCommandeRef(Map<String, dynamic>.from(map), peId: peId);
    print('✅ Commande ref sauvegardée pour peId=$peId, id=$id');
    return id;
  } catch (e) {
    print('❌ Erreur sauvegarde commande_ref: $e');
    rethrow;
  }
}
  static Future<Map<String, dynamic>?> querySingle({
  required String table,
  required String where,
  required List<dynamic> whereArgs,
}) async {
  try {
    // Get the database instance
    final db = await getDatabase();

    // Perform the query
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1, // Limit to one result
    );

    // Return the first result if available, otherwise null
    return result.isNotEmpty ? result.first : null;
  } catch (e) {
    print('Error querying single row from $table: $e');
    return null;
  }
}
String partieOuvrageDesignation = 'Non spécifié';


  
  
  static Future<List<Map<String, dynamic>>> getAllCommandesRef() async {
    final db = await database;
    final rows = await db.query('interventions_recu');
    final Map<String, Map<String, dynamic>> byPeId = {};
    for (final r in rows) {
      final key = (r['pe_id'] ?? '').toString();
      if (key.isEmpty) {
        continue;
      }
      final prev = byPeId[key];
      if (prev == null) {
        byPeId[key] = r;
      } else {
        DateTime? pa;
        DateTime? pb;
        try {
          pa = DateTime.parse((prev['updated_at'] ?? prev['created_at'] ?? '').toString());
        } catch (_) {}
        try {
          pb = DateTime.parse((r['updated_at'] ?? r['created_at'] ?? '').toString());
        } catch (_) {}
        if (pb != null && (pa == null || pb.isAfter(pa))) {
          byPeId[key] = r;
        }
      }
    }
    return byPeId.values.toList();
  }


   static Future<int> saveCommandeRef(Map<String, dynamic> commande) async {
    final db = await database;
    try {
      // Assurer la présence d'une clé unique minimale
      if (!commande.containsKey('codeCommande') && !commande.containsKey('num_commande')) {
        print('❌ saveCommandeRef: missing codeCommande/num_commande in $commande');
      }
      final id = await upsertCommandeRef(Map<String, dynamic>.from(commande));
      print('✅ saveCommandeRef inserted id=$id for ${commande['pe_id'] ?? 'no-pe_id'}');
      return id;
    } catch (e) {
      print('❌ saveCommandeRef error: $e — data: $commande');
      rethrow;
    }
  }
  static Future<List<Map<String, dynamic>>> getTypesEprouvettes() async {
    final db = await database;
    return await db.query('types_eprouvettes');
  }

  static Future<List<Map<String, dynamic>>> getCommandesRefByPeId(String peId) async {
    final db = await database;
    final rows = await db.query(
      'interventions_recu',
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
    print('🔎 getCommandesRefByPeId($peId) -> ${rows.length} rows');
    return rows;
  }
  static Future<List<Map<String, dynamic>>> getCommandesRefByInterventionId(String id) async {
    final db = await database;
    final rows = await db.query(
      'interventions_recu',
      where: 'pe_id = ?',
      whereArgs: [id],
    );
    print('🔎 getCommandesRefByInterventionId($id) -> ${rows.length} rows');
    return rows;
  }
  static Future<void> _saveReferenceList(
      Database db, String table, List<dynamic>? items) async {
    if (items == null || items.isEmpty) {
      print("⚠️ Aucun item pour $table");
      return;
    }
    
    print("📊 Sauvegarde $table: ${items.length} items");
    for (var item in items) {
      try {
        final data = item is Map ? item : item.toMap();
        await db.insert(table, data, 
            conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        print("❌ Erreur insertion dans $table: $e, item: $item");
      }
    }
    print("✅ $table complétée");
  }

  static Future<int> upsertCommandeRef(Map<String, dynamic> raw, {String? peId}) async {
    final db = await database;
    final codeRaw = raw['codeCommande'] ?? raw['CodeCommande'];
    final numRaw = raw['num_commande'] ?? raw['NumCommande'];
    String? code = codeRaw?.toString();
    final num = numRaw?.toString();
    if (code == null || code.isEmpty || code == '0') {
      code = num;
    }
    if (code == null || code.isEmpty) {
      return 0;
    }

    // Nettoyage des données pour éviter les types non pris en charge
    final data = Map<String, dynamic>.from(raw).map((key, value) {
      if (value == null) {
        return MapEntry(key, ''); // Remplace les null par des chaînes vides
      } else if (value is! int && value is! double && value is! String && value is! Uint8List) {
        return MapEntry(key, value.toString()); // Convertit les autres types en String
      }
      return MapEntry(key, value);
    });

    data['NumCommande'] = code;
    if (num != null && num.isNotEmpty) {
      data['NumCommande'] = num;
      data['num_commande'] = num;
    }
    if (peId != null && peId.isNotEmpty) {
      data['pe_id'] = peId;
    }
    data['updated_at'] = DateTime.now().toIso8601String();
    data['created_at'] = data['created_at'] ?? DateTime.now().toIso8601String();

    // Normaliser la clé de la date de validation PM
    // Certains flux/fichiers utilisent "datevalidationpm" au lieu de "date_validation_pm"
    final dvpRaw = data['date_validation_pm'];
    if ((dvpRaw == null || (dvpRaw is String && dvpRaw.isEmpty)) && data.containsKey('datevalidationpm')) {
      final alt = data['datevalidationpm']?.toString();
      if (alt != null && alt.isNotEmpty) {
        data['date_validation_pm'] = alt;
      }
    }
    // Enlever la clé non supportée par le schéma interventions_recu
    if (data.containsKey('datevalidationpm')) {
      data.remove('datevalidationpm');
    }

    final existing = await db.query(
      'interventions_recu',
      where: 'codeCommande = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return await db.update(
        'interventions_recu',
        data,
        where: 'codeCommande = ?',
        whereArgs: [code],
      );
    } else {
      return await db.insert(
        'interventions_recu',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  

  
  
  
  
  
  
  
  
  
    
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  
  

  static Future<int> _getInterventionId(Transaction txn, String peId) async {
    final results = await txn.query(
      'interventions',
      columns: ['id'],
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
    return results.first['id'] as int;
  }

  

  static Future<void> deleteIntervention(String peId) async {
    final db = await database;
    await db.delete(
      'interventions',
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
  }

  

  static Future<void> markAsSynced(String peId) async {
    final db = await database;
    await db.update(
      'interventions',
      {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
    
  }


  
  
  
  static Future<void> updateInterventionSyncStatus(String peId, int isSynced) async {
    final db = await database;
    await db.update(
      'interventions',
      {'is_synced': isSynced, 'updated_at': DateTime.now().toIso8601String()},
      where: 'pe_id = ?',
      whereArgs: [peId],
    );
  }

  
  
  
  static Future<void> saveCompleteIntervention({
    required String peId,
    required Map<String, dynamic> interventionData,
    
    required List<Elemouvrage> elementsOuvrage,
    required List<Map<String, dynamic>> constituants,
    required List<Map<String, dynamic>> seriesEprouvettes,
    required List<String?> motifsNonPrelevement,
  }) async {
    final db = await database;
    int _safeInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _safeDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    await db.transaction((txn) async {
      
      await txn.insert(
        'interventions',
        interventionData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      
      final interventionRow = await txn.query(
        'interventions',
        where: 'pe_id = ?',
        whereArgs: [peId],
      );
      final interventionId = interventionRow.first['id'] as int;

      
      await txn.delete('elements_ouvrage', where: 'intervention_id = ?', whereArgs: [interventionId]);
      for (final elem in elementsOuvrage) {
        await txn.insert('elements_ouvrage', {
          'intervention_id': interventionId,
          'nom': elem.nom,
          'axe': elem.axe,
          'file': elem.file,
          'bloc': elem.bloc,
          'niveau': elem.niveau,
          
          'famille': elem.famille,
        });
      }

      
  for (var i = 0; i < constituants.length; i++) {
        final constituant = constituants[i];
        final dosage = _safeDouble(constituant['fb_dosage'] ?? constituant['dosage']);
        final dmin = _safeDouble(constituant['fb_dmin'] ?? constituant['dmin']);
        final dmax = _safeDouble(constituant['fb_dmax'] ?? constituant['dmax']);

        await txn.insert('constituants', {
          'intervention_id': interventionId,
          // champs API (préfixe fb_)
          'fb_id': constituant['fb_id']?.toString() ?? constituant['fbId']?.toString(),
          'fb_constituant': constituant['fb_constituant']?.toString() ?? constituant['fbConstituant']?.toString(),
          'fb_provenance': constituant['fb_provenance']?.toString() ?? constituant['fb_provenance'],
          'fb_type': constituant['fb_type']?.toString() ?? constituant['fb_type'],
          'fb_dosage': dosage,
          'fb_dmin': dmin,
          'fb_dmax': dmax,
          'fb_prelevement': constituant['fb_prelevement']?.toString(),
          'fb_affaire': constituant['fb_affaire']?.toString(),
          'fb_site': constituant['fb_site']?.toString(),
          'fb_pv': constituant['fb_pv']?.toString(),
          'created_at': constituant['created_at']?.toString(),
          'updated_at': constituant['updated_at']?.toString(),

          // champs locaux (compatibilité UI)
          'type': constituant['type'] ?? _mapFbConstituantToLocalType(constituant),
          'dosage': dosage,
          'prov': constituant['prov'] ?? constituant['fb_provenance'] ?? constituant['source'] ?? constituant['nomProduit'],
          'dmin': dmin,
          'dmax': dmax,
          'nom_produit': constituant['nomProduit']?.toString() ?? '',
          'constituant_order': i,
          'category': constituant['type'] ?? constituant['category'] ?? constituant['fb_constituant']?.toString(),
        });
      }
      
       await txn.delete('series_eprouvettes', where: 'intervention_id = ?', whereArgs: [interventionId]);
      await txn.delete('eprouvettes', where: 'intervention_id = ?', whereArgs: [interventionId]);

      for (int i = 0; i < seriesEprouvettes.length; i++) {
        final serie = seriesEprouvettes[i];

        // Lecture normalisée des champs de la série (gère variantes de clés)
        final serieAge = (serie['Age'] ?? serie['age'])?.toString() ?? '';
        final serieForme = (serie['Forme'] ?? serie['forme'])?.toString() ?? '';
        final serieNbrRaw = serie['NbrEchantillon'] ?? serie['NbrEchantillion'] ?? serie['nbr_echantillon'] ?? serie['NbrEchantillion'];
        final serieNbr = _safeInt(serieNbrRaw);

        final serieId = await txn.insert('series_eprouvettes', {
          'intervention_id': interventionId,
          'serie_order': i,
          'age': serieAge,
          'forme': serieForme,
          'nbr_echantillon': serieNbr,
          'motif_non_prelevement': motifsNonPrelevement.length > i ? motifsNonPrelevement[i] : null,
        });

        
        final eprouvettes = serie['eprouvettes'] as List? ?? [];
        for (var j = 0; j < eprouvettes.length; j++) {
          final epr = eprouvettes[j] is Map ? Map<String,dynamic>.from(eprouvettes[j]) : {};
          final eprAge = (epr['age'] ?? serieAge)?.toString() ?? '';
          final eprTypeId = (epr['type_id'] ?? epr['type_eprouvette_id'] ?? epr['type'])?.toString() ?? '';
          final eprTypeLabel = epr['type_label'] ?? epr['type_eprouvette_label'] ?? '';
          final eprForme = (epr['forme'] ?? serieForme)?.toString() ?? '';
          final eprNbr = _safeInt(epr['nbr_echantillon'] ?? serieNbr);

          await txn.insert('eprouvettes', {
            'intervention_id': interventionId,
            'serie_id': serieId,
            'epr_id': epr['epr_id'] ?? epr['id'] ?? null,
            'age': eprAge,
            'type_eprouvette_id': eprTypeId,
            'type_eprouvette_label': eprTypeLabel,
            'forme': eprForme,
            'nbr_echantillon': eprNbr,
          });
        }
      }
    });
  }

  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;

  LocalDatabase();
static Future<List<Map<String, dynamic>>> getElementsPredifinisRef() async {
  final db = await database;
  return await db.query('elements_predefinis_ref');
}

  static Future<String?> getElementsPredefinisDesignation(String familleId) async {
    final db = await database;
    final result = await db.query(
      'elements_predefinis_ref',
      columns: ['designation'],
      where: 'id = ?',
      whereArgs: [familleId],
    );

    if (result.isNotEmpty) {
      return result.first['designation']?.toString();
    }
    return null;
  }

  static Future<void> saveUser(Map<String, dynamic> userinter) async {
    final db = await database;

    // Vérification des clés dans userData
    if (!userinter.containsKey('Matricule') || !userinter.containsKey('Nom') || !userinter.containsKey('Prénom')) {
      print("❌ Données utilisateur incomplètes : $userinter");
      return;
    }

    // Log des données utilisateur avant insertion
    print("🔄 Tentative de sauvegarde des données utilisateur : $userinter");

    await db.insert(
      'interventions_recu',
      {
        'matricule': userinter['Matricule'],
        'structure': userinter['Structure'],
        'nom': userinter['Nom'],
        'prenom': userinter['Prénom'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Vérification des données insérées
    final result = await db.query(
      'interventions_recu',
      columns: ['matricule', 'nom', 'prenom'],
      where: 'matricule = ?',
      whereArgs: [userinter['Matricule']],
    );
    print("🔎 Données insérées : $result");

    print("✅ Données utilisateur sauvegardées : ${userinter['Nom']} ${userinter['Prénom']}");
  }

  static Future<void> saveInterventionRecu(Map<String, dynamic> interventionData) async {
  final db = await database;

  try {
    await db.insert(
      'interventions_recu',
      {
        'matricule': interventionData['matricule'],
        'structure': interventionData['structure'],
        'nom': interventionData['nom'],
        'prenom': interventionData['prenom'],
        // Ajoutez d'autres champs nécessaires ici
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("✅ Intervention reçue sauvegardée pour ${interventionData['matricule']}");
  } catch (e) {
    print("❌ Erreur lors de la sauvegarde de l'intervention reçue: $e");
  }
}
}
