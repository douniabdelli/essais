import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
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
    // String visiteQuery = '''
    //   CREATE TABLE IF NOT EXISTS visite(
    //
    //   )
    // ''';
    await db.execute(affaireQuery);
    // await db.execute(visiteQuery);
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
            int.parse(item['NbrSite'])
          ]
      );
      print('***0***   ${item}   +++0+++');
    });
  }

  Future<List<Affaire>> getAffaires() async {
    final db = await instance.database;
    final affaires = await db.query('affaires');
    print('db-------------- ${affaires} -------------db');

    return affaires.map((json) => Affaire.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}
