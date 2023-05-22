import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
import 'package:mgtrisque_visitepreliminaire/models/user.dart';
import 'package:mgtrisque_visitepreliminaire/models/visite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VisitePreliminaireDatabase {
  static final VisitePreliminaireDatabase instance =
      VisitePreliminaireDatabase._init();

  static Database? _database;

  VisitePreliminaireDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('visite_preliminaire.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    String userQuery = '''
      CREATE TABLE IF NOT EXISTS users(        
        matricule TEXT PRIMARY KEY, 
        nom TEXT,
        prenom TEXT,
        password TEXT
      )
    ''';
    String affaireQuery = '''
      CREATE TABLE IF NOT EXISTS affaires(        
        Code_Affaire TEXT, 
        Code_Site TEXT, 
        IntituleAffaire TEXT, 
        NbrSite TEXT,
        matricule TEXT,
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
    String visiteQuery = '''
      CREATE TABLE IF NOT EXISTS visites(
        Code_Affaire TEXT,
        Code_site TEXT,
        matricule TEXT,
        VisitSiteDate TEXT,
        VisitSite_Btn_terrain_accessible TEXT,
        VisitSiteterrain_accessible TEXT,
        VisitSite_Btn_terrain_cloture TEXT,
        VisitSiteterrain_cloture TEXT,
        VisitSite_Btn_terrain_nu TEXT,
        VisitSiteterrain_nu TEXT,
        VisitSite_Btn_presence_vegetation TEXT,
        VisitSitePresVeget TEXT,
        VisitSite_Btn_presence_pylones TEXT,
        VisitSite_presence_pylones TEXT,
        VisitSite_Btn_existance_mitoyntehab TEXT,
        VisitSiteExistantsvoisin TEXT,
        VisitSite_Btn_existance_voirie_mitoyenne TEXT,
        VisitSite_existance_voirie_mitoyenne TEXT,
        VisitSite_Btn_presence_remblais TEXT,
        VisitSitePresDepotremblai TEXT,
        VisitSite_Btn_presence_sources_cours_eau_cavite TEXT,
        VisitSiteEngHabitant TEXT,
        VisitSite_Btn_presence_talwegs TEXT,
        visitesitePresDepotremblai TEXT,
        VisitSite_Btn_terrain_inondable TEXT,
        VisitSite_terrain_inondable TEXT,
        VisitSite_Btn_terrain_enpente TEXT,
        VisitSite_terrain_enpente TEXT,
        VisitSite_Btn_risque_InstabiliteGlisTerrain TEXT,
        VisitSite_risque_InstabiliteGlisTerrain TEXT,
        VisitSite_Btn_terrassement_entame TEXT,
        VisitSite_terrassement_entame TEXT,
        VisitSiteAutre TEXT,
        VisitSite_Btn_Presence_risque_instab_terasmt TEXT,
        VisitSite_Btn_necessite_courrier_MO_risque_encouru TEXT,
        VisitSite_Btn_doc_annexe TEXT,
        VisitSite_liste_present TEXT,
        ValidCRVPIng TEXT,
        PRIMARY KEY (Code_Affaire, Code_site) 
      )
    ''';
    String syncQuery = '''
      CREATE TABLE IF NOT EXISTS sync(        
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        matricule TEXT, 
        syncedAt TEXT,
        syncedData TEXT        
      )
    ''';

    await db.execute(userQuery);
    await db.execute(affaireQuery);
    await db.execute(siteQuery);
    await db.execute(visiteQuery);
    await db.execute(syncQuery);
  }

  Future<void> createUsers(List<dynamic> users) async {
    String userQuery = '''
      INSERT INTO users
      (matricule, nom, prenom, password)
      VALUES (?, ?, ?, ?)
    ''';
    final db = await instance.database;
    users.forEach((element) async {
      var item = User.toMap(element);
      var result = await db.rawInsert(
          userQuery,
          [
            item['matricule'].toString(),
            item['nom'].toString(),
            item['prenom'].toString(),
            item['password'].toString()
          ]
      );
    });
  }

  Future<void> createAffaires(List<dynamic> affaires) async {
    String affaireQuery = '''
      INSERT INTO affaires
      (Code_Affaire, Code_Site, matricule, IntituleAffaire, NbrSite)
      VALUES (?, ?, ?, ?, ?)
    ''';
    final db = await instance.database;
    affaires.forEach((element) async {
      var item = Affaire.toMap(element);
      var result = await db.rawInsert(
          affaireQuery,
          [
            item['Code_Affaire'].toString(),
            item['Code_Site'].toString(),
            item['matricule'].toString(),
            item['IntituleAffaire'].toString(),
            item['NbrSite'],
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
            item['Code_Affaire'].toString(),
            item['Code_site'].toString(),
            item['adress_proj'].toString(),
          ]
      );
    });
  }

  Future<void> createVisites(List<dynamic> visites) async {
    String visiteQuery = '''
      INSERT INTO visites
      (Code_Affaire, Code_site, matricule, VisitSiteDate, VisitSite_Btn_terrain_accessible,  VisitSiteterrain_accessible, VisitSite_Btn_terrain_cloture,  VisitSiteterrain_cloture, VisitSite_Btn_terrain_nu, VisitSiteterrain_nu, VisitSite_Btn_presence_vegetation,  VisitSitePresVeget, VisitSite_Btn_presence_pylones,  VisitSite_presence_pylones, VisitSite_Btn_existance_mitoyntehab,  VisitSiteExistantsvoisin, VisitSite_Btn_existance_voirie_mitoyenne,  VisitSite_existance_voirie_mitoyenne, VisitSite_Btn_presence_remblais,  VisitSitePresDepotremblai, VisitSite_Btn_presence_sources_cours_eau_cavite,  VisitSiteEngHabitant, VisitSite_Btn_presence_talwegs,  VisitSitePresDepotremblai, VisitSite_Btn_terrain_inondable,  VisitSite_terrain_inondable, VisitSite_Btn_terrain_enpente,  VisitSite_terrain_enpente, VisitSite_Btn_risque_InstabiliteGlisTerrain,  VisitSite_risque_InstabiliteGlisTerrain, VisitSite_Btn_terrassement_entame,  VisitSite_terrassement_entame, VisitSiteAutre, VisitSite_Btn_Presence_risque_instab_terasmt,  VisitSite_Btn_necessite_courrier_MO_risque_encouru,  VisitSite_Btn_doc_annexe,  VisitSite_liste_present, ValidCRVPIng)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';
    final storage = new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');
    final db = await instance.database;
    visites.forEach((element) async {
      var item = Visite.toMap(element);
      var result = await db.rawInsert(
          visiteQuery,
          [
            item['Code_Affaire'],
            item['Code_site'],
            matricule,
            item['VisitSiteDate'],
            (item['VisitSite_Btn_terrain_accessible'] == 'Oui' || item['VisitSite_Btn_terrain_accessible'] == '1') ? '1' : ((item['VisitSite_Btn_terrain_accessible'] == 'Non' || item['VisitSite_Btn_terrain_accessible'] == '0') ? '0' : ''),
            item['VisitSiteterrain_accessible'],
            (item['VisitSite_Btn_terrain_cloture'] == 'Oui' || item['VisitSite_Btn_terrain_cloture'] == '1') ? '1' : ((item['VisitSite_Btn_terrain_cloture'] == 'Non' || item['VisitSite_Btn_terrain_cloture'] == '0') ? '0' : ''),
            item['VisitSiteterrain_cloture'],
            (item['VisitSite_Btn_terrain_nu'] == 'Oui' || item['VisitSite_Btn_terrain_nu'] == '1') ? '1' : ((item['VisitSite_Btn_terrain_nu'] == 'Non' || item['VisitSite_Btn_terrain_nu'] == '0') ? '0' : ''),
            item['VisitSiteterrain_nu'],
            (item['VisitSite_Btn_presence_vegetation'] == 'Oui' || item['VisitSite_Btn_presence_vegetation'] == '1') ? '1' : ((item['VisitSite_Btn_presence_vegetation'] == 'Non' || item['VisitSite_Btn_presence_vegetation'] == '0') ? '0' : ''),
            item['VisitSitePresVeget'],
            (item['VisitSite_Btn_presence_pylones'] == 'Oui' || item['VisitSite_Btn_presence_pylones'] == '1') ? '1' : ((item['VisitSite_Btn_presence_pylones'] == 'Non' || item['VisitSite_Btn_presence_pylones'] == '0') ? '0' : ''),
            item['VisitSite_presence_pylones'],
            (item['VisitSite_Btn_existance_mitoyntehab'] == 'Oui' || item['VisitSite_Btn_existance_mitoyntehab'] == '1') ? '1' : ((item['VisitSite_Btn_existance_mitoyntehab'] == 'Non' || item['VisitSite_Btn_existance_mitoyntehab'] == '0') ? '0' : ''),
            item['VisitSiteExistantsvoisin'],
            (item['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Oui' || item['VisitSite_Btn_existance_voirie_mitoyenne'] == '1') ? '1' : ((item['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Non' || item['VisitSite_Btn_existance_voirie_mitoyenne'] == '0') ? '0' : ''),
            item['VisitSite_existance_voirie_mitoyenne'],
            (item['VisitSite_Btn_presence_remblais'] == 'Oui' || item['VisitSite_Btn_presence_remblais'] == '1') ? '1' : ((item['VisitSite_Btn_presence_remblais'] == 'Non' || item['VisitSite_Btn_presence_remblais'] == '0') ? '0' : ''),
            item['VisitSitePresDepotremblai'],
            (item['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Oui' || item['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '1') ? '1' : ((item['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Non' || item['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '0') ? '0' : ''),
            item['VisitSiteEngHabitant'],
            (item['VisitSite_Btn_presence_talwegs'] == 'Oui' || item['VisitSite_Btn_presence_talwegs'] == '1') ? '1' : ((item['VisitSite_Btn_presence_talwegs'] == 'Non' || item['VisitSite_Btn_presence_talwegs'] == '0') ? '0' : ''),
            item['visitesitePresDepotremblai'],
            (item['VisitSite_Btn_terrain_inondable'] == 'Oui' || item['VisitSite_Btn_terrain_inondable'] == '1') ? '1' : ((item['VisitSite_Btn_terrain_inondable'] == 'Non' || item['VisitSite_Btn_terrain_inondable'] == '0') ? '0' : ''),
            item['VisitSite_terrain_inondable'],
            (item['VisitSite_Btn_terrain_enpente'] == 'Oui' || item['VisitSite_Btn_terrain_enpente'] == '1') ? '1' : ((item['VisitSite_Btn_terrain_enpente'] == 'Non' || item['VisitSite_Btn_terrain_enpente'] == '0') ? '0' : ''),
            item['VisitSite_terrain_enpente'],
            (item['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Oui' || item['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '1') ? '1' : ((item['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Non' || item['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '0') ? '0' : ''),
            item['VisitSite_risque_InstabiliteGlisTerrain'],
            (item['VisitSite_Btn_terrassement_entame'] == 'Oui' || item['VisitSite_Btn_terrassement_entame'] == '1') ? '1' : ((item['VisitSite_Btn_terrassement_entame'] == 'Non' || item['VisitSite_Btn_terrassement_entame'] == '0') ? '0' : ''),
            item['VisitSite_terrassement_entame'],
            item['VisitSiteAutre'],
            (item['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Oui' || item['VisitSite_Btn_Presence_risque_instab_terasmt'] == '1') ? '1' : ((item['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Non' || item['VisitSite_Btn_Presence_risque_instab_terasmt'] == '0') ? '0' : ''),
            (item['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Oui' || item['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '1') ? '1' : ((item['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Non' || item['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '0') ? '0' : ''),
            (item['VisitSite_Btn_doc_annexe'] == 'Oui' || item['VisitSite_Btn_doc_annexe'] == '1') ? '1' : ((item['VisitSite_Btn_doc_annexe'] == 'Non' || item['VisitSite_Btn_doc_annexe'] == '0') ? '0' : ''),
            item['VisitSite_liste_present'],
            (item['ValidCRVPIng'] == 'Oui' || item['ValidCRVPIng'] == '1') ? '1' : ((item['ValidCRVPIng'] == 'Non' || item['ValidCRVPIng'] == '0') ? '0' : ''),
          ]
      );
    });
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
    print('matricule : ${matricule}');
    final db = await instance.database;
    final sync = await db.query(
      'sync',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );

    return sync.map((json) => SyncHistory.fromJson(json)).toList();
  }

  Future<void> updateVisite(List<dynamic> visites) async {
    final db = await instance.database;
    visites.forEach((element) async {
      var visite = Visite.toMap(element);
      await db.update(
        'visites',
        {
          'VisitSiteDate': visite['VisitSiteDate'],
          'VisitSite_Btn_terrain_accessible': (visite['VisitSite_Btn_terrain_accessible'] == 'Oui' || visite['VisitSite_Btn_terrain_accessible'] == '1') ? '1' : ((visite['VisitSite_Btn_terrain_accessible'] == 'Non' || visite['VisitSite_Btn_terrain_accessible'] == '0') ? '0' : ''),
          'VisitSiteterrain_accessible': visite['VisitSiteterrain_accessible'],
          'VisitSite_Btn_terrain_cloture': (visite['VisitSite_Btn_terrain_cloture'] == 'Oui' || visite['VisitSite_Btn_terrain_cloture'] == '1') ? '1' : ((visite['VisitSite_Btn_terrain_cloture'] == 'Non' || visite['VisitSite_Btn_terrain_cloture'] == '0') ? '0' : ''),
          'VisitSiteterrain_cloture': visite['VisitSiteterrain_cloture'],
          'VisitSite_Btn_terrain_nu': (visite['VisitSite_Btn_terrain_nu'] == 'Oui' || visite['VisitSite_Btn_terrain_nu'] == '1') ? '1' : ((visite['VisitSite_Btn_terrain_nu'] == 'Non' || visite['VisitSite_Btn_terrain_nu'] == '0') ? '0' : ''),
          'VisitSiteterrain_nu': visite['VisitSiteterrain_nu'],
          'VisitSite_Btn_presence_vegetation': (visite['VisitSite_Btn_presence_vegetation'] == 'Oui' || visite['VisitSite_Btn_presence_vegetation'] == '1') ? '1' : ((visite['VisitSite_Btn_presence_vegetation'] == 'Non' || visite['VisitSite_Btn_presence_vegetation'] == '0') ? '0' : ''),
          'VisitSitePresVeget': visite['VisitSitePresVeget'],
          'VisitSite_Btn_presence_pylones': (visite['VisitSite_Btn_presence_pylones'] == 'Oui' || visite['VisitSite_Btn_presence_pylones'] == '1') ? '1' : ((visite['VisitSite_Btn_presence_pylones'] == 'Non' || visite['VisitSite_Btn_presence_pylones'] == '0') ? '0' : ''),
          'VisitSite_presence_pylones': visite['VisitSite_presence_pylones'],
          'VisitSite_Btn_existance_mitoyntehab': (visite['VisitSite_Btn_existance_mitoyntehab'] == 'Oui' || visite['VisitSite_Btn_existance_mitoyntehab'] == '1') ? '1' : ((visite['VisitSite_Btn_existance_mitoyntehab'] == 'Non' || visite['VisitSite_Btn_existance_mitoyntehab'] == '0') ? '0' : ''),
          'VisitSiteExistantsvoisin': visite['VisitSiteExistantsvoisin'],
          'VisitSite_Btn_existance_voirie_mitoyenne': (visite['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Oui' || visite['VisitSite_Btn_existance_voirie_mitoyenne'] == '1') ? '1' : ((visite['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Non' || visite['VisitSite_Btn_existance_voirie_mitoyenne'] == '0') ? '0' : ''),
          'VisitSite_existance_voirie_mitoyenne': visite['VisitSite_existance_voirie_mitoyenne'],
          'VisitSite_Btn_presence_remblais': (visite['VisitSite_Btn_presence_remblais'] == 'Oui' || visite['VisitSite_Btn_presence_remblais'] == '1') ? '1' : ((visite['VisitSite_Btn_presence_remblais'] == 'Non' || visite['VisitSite_Btn_presence_remblais'] == '0') ? '0' : ''),
          'VisitSitePresDepotremblai': visite['VisitSitePresDepotremblai'],
          'VisitSite_Btn_presence_sources_cours_eau_cavite': (visite['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Oui' || visite['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '1') ? '1' : ((visite['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Non' || visite['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '0') ? '0' : ''),
          'VisitSiteEngHabitant': visite['VisitSiteEngHabitant'],
          'VisitSite_Btn_presence_talwegs': (visite['VisitSite_Btn_presence_talwegs'] == 'Oui' || visite['VisitSite_Btn_presence_talwegs'] == '1') ? '1' : ((visite['VisitSite_Btn_presence_talwegs'] == 'Non' || visite['VisitSite_Btn_presence_talwegs'] == '0') ? '0' : ''),
          'visitesitePresDepotremblai': visite['visitesitePresDepotremblai'],
          'VisitSite_Btn_terrain_inondable': (visite['VisitSite_Btn_terrain_inondable'] == 'Oui' || visite['VisitSite_Btn_terrain_inondable'] == '1') ? '1' : ((visite['VisitSite_Btn_terrain_inondable'] == 'Non' || visite['VisitSite_Btn_terrain_inondable'] == '0') ? '0' : ''),
          'VisitSite_terrain_inondable': visite['VisitSite_terrain_inondable'],
          'VisitSite_Btn_terrain_enpente': (visite['VisitSite_Btn_terrain_enpente'] == 'Oui' || visite['VisitSite_Btn_terrain_enpente'] == '1') ? '1' : ((visite['VisitSite_Btn_terrain_enpente'] == 'Non' || visite['VisitSite_Btn_terrain_enpente'] == '0') ? '0' : ''),
          'VisitSite_terrain_enpente': visite['VisitSite_terrain_enpente'],
          'VisitSite_Btn_risque_InstabiliteGlisTerrain': (visite['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Oui' || visite['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '1') ? '1' : ((visite['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Non' || visite['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '0') ? '0' : ''),
          'VisitSite_risque_InstabiliteGlisTerrain': visite['VisitSite_risque_InstabiliteGlisTerrain'],
          'VisitSite_Btn_terrassement_entame': (visite['VisitSite_Btn_terrassement_entame'] == 'Oui' || visite['VisitSite_Btn_terrassement_entame'] == '1') ? '1' : ((visite['VisitSite_Btn_terrassement_entame'] == 'Non' || visite['VisitSite_Btn_terrassement_entame'] == '0') ? '0' : ''),
          'VisitSite_terrassement_entame': visite['VisitSite_terrassement_entame'],
          'VisitSiteAutre': visite['VisitSiteAutre'],
          'VisitSite_Btn_Presence_risque_instab_terasmt': (visite['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Oui' ||visite['VisitSite_Btn_Presence_risque_instab_terasmt'] == '1')? '1': ((visite['VisitSite_Btn_Presence_risque_instab_terasmt'] =='Non' ||visite['VisitSite_Btn_Presence_risque_instab_terasmt'] == '0')? '0': ''),
          'VisitSite_Btn_necessite_courrier_MO_risque_encouru': (visite['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Oui' || visite['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '1') ? '1' : ((visite['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Non' || visite['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '0') ? '0' : ''),
          'VisitSite_Btn_doc_annexe': (visite['VisitSite_Btn_doc_annexe'] == 'Oui' || visite['VisitSite_Btn_doc_annexe'] == '1') ? '1' : ((visite['VisitSite_Btn_doc_annexe'] == 'Non' || visite['VisitSite_Btn_doc_annexe'] == '0') ? '0' : ''),
          'VisitSite_liste_present': visite['VisitSite_liste_present'],
          'ValidCRVPIng': (visite['ValidCRVPIng'] == 'Oui' || visite['ValidCRVPIng'] == '1') ? '1' : ((visite['ValidCRVPIng'] == 'Non' || visite['ValidCRVPIng'] == '0') ? '0' : ''),
          'Code_Affaire': visite['Code_Affaire'],
          'Code_site': visite['Code_site'],
        },
        where: 'Code_Affaire = ? AND Code_site = ?',
        whereArgs: [ visite['Code_Affaire'], visite['Code_site'] ],
      );
    });
  }

  Future<void> validateVisite(Code_Affaire, Code_site) async {
    String visiteQuery = '''
      UPDATE visites
      SET      
      ValidCRVPIng = 1     
      where Code_Affaire = ? AND Code_site = ?
    ''';
    final db = await instance.database;
    var result = await db.rawInsert(
        visiteQuery,
        [ Code_Affaire, Code_site ]
    );
  }

  Future<List<User>> getUser() async {
    final storage = new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');

    final db = await instance.database;
    final users = await db.query(
      'users',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );

    return users.map((json) => User.fromJson(json)).toList();
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

  Future<List<Visite>> getInvalidVisitesWhereMatricule(matricule) async {
    final db = await instance.database;
    final visites = await db.query(
        'visites',
        where: 'matricule = ? AND ValidCRVPIng = 0',
        whereArgs: [ matricule ]
    );

    return visites.map((json) => Visite.fromJson(json)).toList();
  }

  Future<List<Visite>> getAffairesSitesFromVisitesWhereMatricule(matricule) async {
    final db = await instance.database;
    final visites = await db.query(
      'visites',
      where: 'matricule = ? AND ValidCRVPIng = 1',
      whereArgs: [ matricule ]
    );

    return visites.map((json) => Visite.fromJson(json)).toList();
  }

  getVisitesWhereAffairesSites(args) async {
    late String whereArgs = args.map((e) => '"'+(e['Code_Affaire'].toString() + e['Code_site']).toString()+'"').toList().join(',');
    final db = await instance.database;
    final visites = await db.rawQuery('SELECT * FROM visites WHERE Code_Affaire || Code_site IN (${whereArgs})');

    return visites;
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
    print('matricule : ${matricule}');
    final db = await instance.database;
    final affaires = await db.query(
      'affaires',
      where: 'matricule = ?',
      whereArgs: [ matricule ],
    );

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }

  Future<List<Site>> getSites() async {
    final db = await instance.database;
    final sites = await db.query('sites');

    return sites.map((json) => Site.fromJson(json)).toList();
  }

  Future<List<Visite>> getVisites() async {
    final db = await instance.database;
    final visites = await db.query('visites');

    return visites.map((json) => Visite.fromJson(json)).toList();
  }

  getVisite(Code_Affaire, Code_site) async {
    final db = await instance.database;
    final visite = await db.query(
      'visites',
      where: 'Code_Affaire=? and Code_site=?',
      whereArgs: [Code_Affaire, Code_site]
    );

    return Visite.fromJson(visite[0]);
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

}
