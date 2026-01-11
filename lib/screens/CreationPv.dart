import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart' as app_dio;
import 'package:mgtrisque_visitepreliminaire/screens/newIntervention.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';

class TypeIntervention {
  final String label;
  final String value;
  final bool inactive;

  TypeIntervention({
    required this.label,
    required this.value,
    required this.inactive,
  });

  factory TypeIntervention.fromJson(Map<String, dynamic> json) {
    return TypeIntervention(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      inactive: json['inactive'] == true,
    );
  }

  @override
  String toString() => label;
}

class _InterventionCache {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      '$dbPath/ctc_essaies.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE interventions(id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT, value TEXT, inactive INTEGER)');
        await db.execute('CREATE TABLE kv(key TEXT PRIMARY KEY, value TEXT)');
      },
    );
  }

  static Future<List<TypeIntervention>> readCache() async {
    await init();
    final rows = await _db!.query('interventions');
    return rows
        .map((r) => TypeIntervention(label: r['label'] as String? ?? '', value: r['value'] as String? ?? '', inactive: ((r['inactive'] as int?) ?? 0) == 1))
        .where((i) => !i.inactive)
        .toList();
  }

  static Future<void> writeCache(List<TypeIntervention> items) async {
    await init();
    final batch = _db!.batch();
    batch.delete('interventions');
    for (final i in items) {
      batch.insert('interventions', {
        'label': i.label,
        'value': i.value,
        'inactive': i.inactive ? 1 : 0,
      });
    }
    await batch.commit(noResult: true);
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    await _db!.insert('kv', {'key': 'interventions_last_updated', 'value': ts}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<DateTime?> lastUpdated() async {
    await init();
    final rows = await _db!.query('kv', where: 'key = ?', whereArgs: ['interventions_last_updated']);
    if (rows.isEmpty) return null;
    final v = rows.first['value'] as String?;
    if (v == null) return null;
    final ms = int.tryParse(v);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

class ChoixPVDialog extends StatefulWidget {
  const ChoixPVDialog({Key? key}) : super(key: key);

  @override
  State<ChoixPVDialog> createState() => _ChoixPVDialogState();
}

class _ChoixPVDialogState extends State<ChoixPVDialog> {
  List<TypeIntervention> typeInterventions = [];
  TypeIntervention? selectedIntervention;
  bool isLoading = true;
  String? errorMessage;
  final storage = const FlutterSecureStorage();
  bool isOffline = false;
  DateTime? lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    loadFromCacheThenRefresh();
  }

  String _mapTypeLabel(String code) {
    switch (code) {
      case 'i001':
        return 'Béton';
      case 'i004':
        return 'Acier';
      default:
        return code; // fallback: afficher le code
    }
  }

  Future<List<TypeIntervention>> _readTypesFromLocalDb() async {
    try {
      final db = await LocalDatabase.database;
      // Récupérer les types distincts à partir des tables locales susceptibles d'avoir été remplies
      final rows2 = await db.rawQuery('SELECT DISTINCT TypeIntervention as t FROM interventions_recu WHERE TypeIntervention IS NOT NULL AND TypeIntervention != ""');

      final codes = <String>{};
      for (final r in rows2) {
        final v = (r['t'] ?? '').toString();
        if (v.isNotEmpty) codes.add(v);
      }

      final list = codes.map((c) => TypeIntervention(label: _mapTypeLabel(c), value: c, inactive: false)).toList();
      return list;
    } catch (e) {
      debugPrint('⚠️ Lecture locale TypeIntervention échouée: $e');
      return [];
    }
  }

  Future<void> loadFromCacheThenRefresh() async {
    try {
      await _InterventionCache.init();
      final cached = await _InterventionCache.readCache();
      final lu = await _InterventionCache.lastUpdated();

      // 1) Essayer le cache
      if (cached.isNotEmpty) {
        setState(() {
          typeInterventions = cached;
          isOffline = true;
          isLoading = false;
          errorMessage = null;
          lastUpdatedAt = lu;
        });
        // Ne tente pas de refresh auto si on est hors-ligne: l’utilisateur peut utiliser "Rafraîchir"
        return;
      }

      // 2) Fallback sur la base locale si aucun cache n’est disponible
      final localTypes = await _readTypesFromLocalDb();
      if (localTypes.isNotEmpty) {
        setState(() {
          typeInterventions = localTypes;
          isOffline = true;
          isLoading = false;
          errorMessage = null;
          lastUpdatedAt = null;
        });
        return;
      }

      // 3) En dernier recours, tenter un appel réseau (si connecté)
      await fetchTypeInterventions();
    } catch (_) {
      await fetchTypeInterventions();
    }
  }

  Future<void> fetchTypeInterventions() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = typeInterventions.isNotEmpty ? null : "Token non trouvé. Veuillez vous reconnecter.";
        });
        debugPrint("⚠️ Token absent dans le secure storage.");
        return;
      }

      final dio = app_dio.dio();
      final baseUrl = dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final endpoint = '$baseUrl/essais/interventions';

      debugPrint('➡️ GET $endpoint avec token: $token');

      final response = await dio.get(
        '/essais/interventions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final resp = response.data;
        List<dynamic> interventionsData = [];

        if (resp is List) {
          interventionsData = resp;
        } else if (resp is Map<String, dynamic>) {
          if (resp['typeInterventions'] is List) {
            interventionsData = resp['typeInterventions'];
          } else if (resp['beton'] is List) {
            interventionsData = resp['beton'];
          } else if (resp['modes'] is List) {
            interventionsData = resp['modes'];
          } else if (resp['data'] is List) {
            interventionsData = resp['data'];
          } else if (resp['commandes'] is List) {
            interventionsData = resp['commandes'];
          } else {
            for (final v in resp.values) {
              if (v is List) {
                interventionsData = v;
                break;
              }
            }
          }
        }

        debugPrint('fetchTypeInterventions: trouvé ${interventionsData.length} éléments pour le dropdown.');

        setState(() {
          typeInterventions = interventionsData
              .map((json) {
                if (json is Map<String, dynamic>) return TypeIntervention.fromJson(json);
                final s = json?.toString() ?? '';
                return TypeIntervention(label: s, value: s, inactive: false);
              })
              .where((intervention) => !intervention.inactive)
              .toList();
          isLoading = false;
          errorMessage = null;
          isOffline = false;
          lastUpdatedAt = DateTime.now();
        });
        await _InterventionCache.writeCache(typeInterventions);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = typeInterventions.isNotEmpty ? null : "Erreur lors du chargement (${response.statusCode}): ${response.statusMessage}";
          isOffline = typeInterventions.isNotEmpty;
        });
        debugPrint("❌ Réponse du serveur: ${response.data}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = typeInterventions.isNotEmpty ? null : "Erreur de connexion: $e";
        isOffline = typeInterventions.isNotEmpty;
      });
      debugPrint("❌ Erreur fetchTypeInterventions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choix du PV d'intervention à créer"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOffline)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            lastUpdatedAt != null
                                ? 'Données hors ligne'
                                : 'Hors ligne',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<TypeIntervention>(
                    decoration: const InputDecoration(
                      labelText: "Type d'intervention",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    value: selectedIntervention,
                    isExpanded: true,
                    items: typeInterventions
                        .map((intervention) => DropdownMenuItem<TypeIntervention>(
                              value: intervention,
                              child: Text(
                                intervention.label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedIntervention = value;
                      });
                    },
                  ),
                ],
              ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.close, color: Colors.blue),
          label: const Text("Fermer"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton.icon(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          label: const Text("Rafraîchir"),
          onPressed: () async {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
            await fetchTypeInterventions();
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Valider"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: selectedIntervention != null
              ? () {
                Navigator.of(context).pop(); // Ferme le dialogue
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewInterventionsPage(
                      canInsertion: true,
                    ),
                  ),
                );
              }
              : null,
        ),
      ],
    );
  }
}
