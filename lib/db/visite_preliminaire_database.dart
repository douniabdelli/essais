import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
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
    String affaireQuery = '''
      CREATE TABLE IF NOT EXISTS affaires(        
        Code_Affaire TEXT PRIMARY KEY, 
        IntituleAffaire TEXT, 
        NbrSite INTEGER       
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
        VisitSiteDate TEXT,
        VisitSite_Btn_terrain_accessible INTEGER,
        VisitSiteterrain_accessible TEXT,
        VisitSite_Btn_terrain_cloture INTEGER,
        VisitSiteterrain_cloture TEXT,
        VisitSite_Btn_terrain_nu INTEGER,
        VisitSiteterrain_nu TEXT,
        VisitSite_Btn_presence_vegetation INTEGER,
        VisitSitePresVeget TEXT,
        VisitSite_Btn_presence_pylones INTEGER,
        VisitSite_presence_pylones TEXT,
        VisitSite_Btn_existance_mitoyntehab INTEGER,
        VisitSiteExistantsvoisin TEXT,
        VisitSite_Btn_existance_voirie_mitoyenne INTEGER,
        VisitSite_existance_voirie_mitoyenne TEXT,
        VisitSite_Btn_presence_remblais INTEGER,
        VisitSitePresDepotremblai TEXT,
        VisitSite_Btn_presence_sources_cours_eau_cavite INTEGER,
        VisitSiteEnqHabitant TEXT,
        VisitSite_Btn_presence_talwegs INTEGER,
        visitesitePresDepotremblai TEXT,
        VisitSite_Btn_terrain_inondable INTEGER,
        VisitSite_terrain_inondable TEXT,
        VisitSite_Btn_terrain_enpente INTEGER,
        VisitSite_terrain_enpente TEXT,
        VisitSite_Btn_risque_InstabiliteGlisTerrain INTEGER,
        VisitSite_risque_InstabiliteGlisTerrain TEXT,
        VisitSite_Btn_terrassement_entame INTEGER,
        VisitSite_terrassement_entame TEXT,
        VisitSiteAutre TEXT,
        VisitSite_Btn_Presence_risque_instab_terasmt INTEGER,
        VisitSite_Btn_necessite_courrier_MO_risque_encouru INTEGER,
        VisitSite_Btn_doc_annexe INTEGER,
        VisitSite_liste_present TEXT,
        ValidCRVPIng INTEGER,
        PRIMARY KEY (Code_Affaire, Code_site) 
      )
    ''';
    await db.execute(affaireQuery);
    await db.execute(siteQuery);
    await db.execute(visiteQuery);
  }

  Future<void> createAffaires(List<dynamic> affaires) async {
    String affaireQuery = '''
      INSERT INTO affaires
      (Code_Affaire, IntituleAffaire, NbrSite)
      VALUES (?, ?, ?)
    ''';
    final db = await instance.database;
    affaires.forEach((element) async {
      var item = Affaire.toMap(element);
      var result = await db.rawInsert(
          affaireQuery,
          [
            item['Code_Affaire'].toString(),
            item['IntituleAffaire'].toString(),
            item['NbrSite']
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

  Future<void> createVisites(List<dynamic> sites) async {
    String visiteQuery = '''
      INSERT INTO visites
      (Code_Affaire, Code_site, VisitSiteDate, VisitSite_Btn_terrain_accessible,  VisitSiteterrain_accessible, VisitSite_Btn_terrain_cloture,  VisitSiteterrain_cloture, VisitSite_Btn_terrain_nu, VisitSiteterrain_nu, VisitSite_Btn_presence_vegetation,  VisitSitePresVeget, VisitSite_Btn_presence_pylones,  VisitSite_presence_pylones, VisitSite_Btn_existance_mitoyntehab,  VisitSiteExistantsvoisin, VisitSite_Btn_existance_voirie_mitoyenne,  VisitSite_existance_voirie_mitoyenne, VisitSite_Btn_presence_remblais,  VisitSitePresDepotremblai, VisitSite_Btn_presence_sources_cours_eau_cavite,  VisitSiteEnqHabitant, VisitSite_Btn_presence_talwegs,  visitesitePresDepotremblai, VisitSite_Btn_terrain_inondable,  VisitSite_terrain_inondable, VisitSite_Btn_terrain_enpente,  VisitSite_terrain_enpente, VisitSite_Btn_risque_InstabiliteGlisTerrain,  VisitSite_risque_InstabiliteGlisTerrain, VisitSite_Btn_terrassement_entame,  VisitSite_terrassement_entame, VisitSiteAutre, VisitSite_Btn_Presence_risque_instab_terasmt,  VisitSite_Btn_necessite_courrier_MO_risque_encouru,  VisitSite_Btn_doc_annexe,  VisitSite_liste_present, ValidCRVPIng)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';
    final db = await instance.database;
    sites.forEach((element) async {
      var item = Visite.toMap(element);
      var result = await db.rawInsert(
          visiteQuery,
          [
            item['Code_Affaire'],
            item['Code_site'],
            item['VisitSiteDate'],
            item['VisitSite_Btn_terrain_accessible'] == 'Oui' ? 1 : 0,
            item['VisitSiteterrain_accessible'],
            item['VisitSite_Btn_terrain_cloture'] == 'Oui' ? 1 : 0,
            item['VisitSiteterrain_cloture'],
            item['VisitSite_Btn_terrain_nu'] == 'Oui' ? 1 : 0,
            item['VisitSiteterrain_nu'],
            item['VisitSite_Btn_presence_vegetation'] == 'Oui' ? 1 : 0,
            item['VisitSitePresVeget'],
            item['VisitSite_Btn_presence_pylones'] == 'Oui' ? 1 : 0,
            item['VisitSite_presence_pylones'],
            item['VisitSite_Btn_existance_mitoyntehab'] == 'Oui' ? 1 : 0,
            item['VisitSiteExistantsvoisin'],
            item['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Oui' ? 1 : 0,
            item['VisitSite_existance_voirie_mitoyenne'],
            item['VisitSite_Btn_presence_remblais'] == 'Oui' ? 1 : 0,
            item['VisitSitePresDepotremblai'],
            item['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Oui' ? 1 : 0,
            item['VisitSiteEnqHabitant'],
            item['VisitSite_Btn_presence_talwegs'] == 'Oui' ? 1 : 0,
            item['visitesitePresDepotremblai'],
            item['VisitSite_Btn_terrain_inondable'] == 'Oui' ? 1 : 0,
            item['VisitSite_terrain_inondable'],
            item['VisitSite_Btn_terrain_enpente'] == 'Oui' ? 1 : 0,
            item['VisitSite_terrain_enpente'],
            item['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Oui' ? 1 : 0,
            item['VisitSite_risque_InstabiliteGlisTerrain'],
            item['VisitSite_Btn_terrassement_entame'] == 'Oui' ? 1 : 0,
            item['VisitSite_terrassement_entame'],
            item['VisitSiteAutre'],
            item['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Oui' ? 1 : 0,
            item['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Oui' ? 1 : 0,
            item['VisitSite_Btn_doc_annexe'] == 'Oui' ? 1 : 0,
            item['VisitSite_liste_present'],
            item['ValidCRVPIng'],
          ]
      );
    });
  }

  Future<List<Affaire>> getAffaires() async {
    final db = await instance.database;
    final affaires = await db.query('affaires');
    print('db-------------- ${affaires} -------------db');

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }

  Future<List<Site>> getSites() async {
    final db = await instance.database;
    final sites = await db.query('sites');
    print('db-------------- ${sites} -------------db');

    return sites.map((json) => Site.fromJson(json)).toList();
  }

  Future<List<Visite>> getVisites() async {
    final db = await instance.database;
    final visites = await db.query('visites');
    print('db-------------- ${visites} -------------db');

    return visites.map((json) => Visite.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}
