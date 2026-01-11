import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/screens/CreationPv.dart';
import 'package:mgtrisque_visitepreliminaire/screens/interventionsBeton.dart';
import 'package:mgtrisque_visitepreliminaire/screens/newIntervention.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mgtrisque_visitepreliminaire/services/pdf_generator.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';

class AffairesScreen extends StatefulWidget {
  final String isNotFirstTime;
  final bool isOffline;  

  const AffairesScreen({
    Key? key, 
    required this.isNotFirstTime,
    required this.isOffline,  
  }) : super(key: key);

  @override
  State<AffairesScreen> createState() => _AffairesScreenState();
}

class _AffairesScreenState extends State<AffairesScreen> {
  List<dynamic> interventions = [];
  List<dynamic> filteredInterventions = [];
  bool isLoading = true;
  final storage = const FlutterSecureStorage();
  bool isOffline = false;
  final TextEditingController _searchController = TextEditingController();
  int _filterMode = 0;

  static const Color chantierBlue = Color(0xFF1E3A8A);
  static const Color lightBackground = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    fetchInterventions();
    _searchController.addListener(() {
      _applyFilters();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugLocalInterventions();
    });
  }

  Future<void> debugLocalInterventions() async {
    print('=== DÉBOGAGE INTERVENTIONS LOCALES ===');
    
    try {
      // 1. Vérifier les interventions non synchronisées directement
      final unsynced = await LocalDatabase.getUnsyncedInterventions();
      print('📊 Interventions non synchronisées (getUnsyncedInterventions): ${unsynced.length}');
      for (var i = 0; i < unsynced.length; i++) {
        print('   $i: ${unsynced[i]['pe_id']} - ${unsynced[i]['created_at']}');
      }
      
      // 2. Vérifier toutes les interventions dans la table
      final db = await LocalDatabase.database;
      await LocalDatabase.migrateConstituantsFromType();
      final allInterventions = await db.query('interventions');
      print('📊 Toutes les interventions dans la table: ${allInterventions.length}');
      for (var i = 0; i < allInterventions.length; i++) {
        print('   $i: ${allInterventions[i]['pe_id']} - is_synced: ${allInterventions[i]['is_synced']}');
      }
      
      // 3. Vérifier ce que retourne getLocalUnsyncedInterventions()
      final localList = await getLocalUnsyncedInterventions();
      print('📊 Liste locale générée: ${localList.length}');
      for (var i = 0; i < localList.length; i++) {
        print('   $i: ${localList[i]['pe_id']} - is_local: ${localList[i]['is_local']}');
      }
      
      print('=== FIN DÉBOGAGE ===');
    } catch (e) {
      print('❌ Erreur débogage: $e');
    }
  }

   Future<void> fetchInterventions() async {
    String? token = await storage.read(key: 'token');

    setState(() => isLoading = true);
    
    // Si mode hors ligne ou erreur API, charger uniquement les données locales
    if (widget.isOffline) {
      await getAllLocalInterventions();
      return;
    }

    try {
      print('🌐 Tentative de récupération des interventions depuis l\'API...');
      final response = await dio().get(
        '/essais/interventions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final resp = response.data;
        List<dynamic> dataList = [];

        if (resp is List) {
          dataList = resp;
        } else if (resp is Map<String, dynamic>) {
          if (resp['data'] is List) {
            dataList = resp['data'] as List<dynamic>;
          } else if (resp['interventions'] is List) {  
            dataList = resp['interventions'] as List<dynamic>;
          } else {
            for (final v in resp.values) {
              if (v is List) {
                dataList = v;
                break;
              }
            }
          }
        }

        print('fetchInterventions: récupéré ${dataList.length} éléments.');

        // Sauvegarder les références localement (base locale)
        if (dataList.isNotEmpty) {
          await LocalDatabase.saveReferences({'commandes': dataList});
          print('💾 Interventions téléchargées et sauvegardées localement (${dataList.length}).');

        }

        // Mettre à jour last_server_pe_id si possible (depuis les données serveur)
        try {
          final re = RegExp(r'(\d)$');
          BigInt? maxNum;
          String? highestPeId;
          for (var item in dataList) {
            final pid = (item['pe_id'] ?? item['peId'] ?? '').toString();
            if (pid.isEmpty) continue;
            final m = re.firstMatch(pid);
            if (m != null) {
              final num = BigInt.parse(m.group(1)!);
              if (maxNum == null || num > maxNum) {
                maxNum = num;
                highestPeId = pid;
              }
            }
          }
          if (highestPeId != null) {
            await storage.write(key: 'last_server_pe_id', value: highestPeId);
            print('🔖 last_server_pe_id enregistré: $highestPeId');
          }
        } catch (e) {
          print('⚠️ Erreur extraction dernier pe_id: $e');
        }

        // Charger TOUT depuis la base locale (on n'affiche plus directement le résultat serveur)
        await getAllLocalInterventions();
        
      } else {
        // En cas d'erreur API, charger les données locales
        print('⚠️ Erreur API: Code ${response.statusCode}');
        await getAllLocalInterventions();
      }
      
    } catch (e) {
      // En cas d'exception, charger les données locales
      print('❌ Exception API: $e');
      await getAllLocalInterventions();
    }
  }
  Future<List<Map<String, dynamic>>> getLocalUnsyncedInterventions() async {
    try {
      print('🔄 Début getLocalUnsyncedInterventions()');
      
      // Récupérer les interventions non synchronisées
      final unsyncedInterventions = await LocalDatabase.getUnsyncedInterventions();
      print('📥 Interventions non sync récupérées: ${unsyncedInterventions.length}');
      
      // Convertir en format compatible avec l'affichage existant
      final List<Map<String, dynamic>> localInterventions = [];
      
      for (final intervention in unsyncedInterventions) {
        print('🔄 Traitement intervention: ${intervention['pe_id']}');
        
        // Vérifier que l'intervention a les champs requis
        if (intervention['pe_id'] == null) {
          print('⚠️ Intervention sans pe_id, skip');
          continue;
        }
        
        // Créer un objet compatible avec votre affichage
        final localIntervention = {
          'id': intervention['id'],
          'pe_id': intervention['pe_id'],
          'NumCommande': 'LOCAL-${intervention['pe_id']}',
          'Code_Affaire': intervention['Code_Affaire'] ?? 'N/A',
          'intituleAffaire': intervention['intitule_affaire'] ?? 'Intervention locale',
          'Validation_labo': 0, // Toujours brouillon pour les locales
          'TypeIntervention': 'i001', // Béton par défaut
          'created_at': intervention['created_at'] ?? DateTime.now().toIso8601String(),
          'is_local': true, // Marqueur pour identifier les locales
          'entreprise_real': intervention['entreprise_real'] ?? 'N/A',
          'categorie_chantier': intervention['categorie_chantier'] ?? 'N/A',
          'charge_affaire': intervention['charge_affaire_id'] ?? 'N/A',
          'Code_Site': intervention['Code_Affaire']?.toString().split('-').first ?? 'LOCAL',
        };
        
        localInterventions.add(localIntervention);
        print('✅ Intervention ajoutée: ${intervention['pe_id']}');
      }
      
      print('✅ getLocalUnsyncedInterventions() terminé: ${localInterventions.length} interventions');
      return localInterventions;
    } catch (e) {
      print('❌ Erreur récupération interventions locales: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllLocalInterventions() async {
    try {
      // Récupérer les commandes de référence
      final localCommandes = await LocalDatabase.getAllCommandesRef();
      
      // Récupérer les interventions locales non synchronisées
      final localInterventions = await getLocalUnsyncedInterventions();
      
      // Combiner les deux listes
     final combinedList = [...localCommandes, ...localInterventions];
      // Trier local aussi (même logique)
      combinedList.sort((a, b) {
        DateTime? da;
        DateTime? db;
        try {
          da = DateTime.parse((a['created_at'] ?? a['createdAt'] ?? '').toString());
        } catch (_) {}
        try {
          db = DateTime.parse((b['created_at'] ?? b['createdAt'] ?? '').toString());
        } catch (_) {}
        if (da != null && db != null) return db.compareTo(da);
        if (da != null) return -1;
        if (db != null) return 1;
        final re = RegExp(r'(\d)$');
        final ma = re.firstMatch((a['pe_id'] ?? a['peId'] ?? '').toString());
        final mb = re.firstMatch((b['pe_id'] ?? b['peId'] ?? '').toString());
        if (ma != null && mb != null) {
          final na = BigInt.parse(ma.group(1)!);
          final nb = BigInt.parse(mb.group(1)!);
          return nb.compareTo(na);
        }
        return 0;
      });

      print('📴 Chargement local complet: ${combinedList.length} interventions '
            '(${localCommandes.length} commandes  ${localInterventions.length} locales)');
      
      setState(() {
        interventions = combinedList;
        _applyFilters();
        isLoading = false;
      });
      return combinedList;
    } catch (e) {
      print('❌ Erreur chargement local complet: $e');
      setState(() {
        interventions = [];
        isLoading = false;
      });
      return [];
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    print('🔎 Recherche: "$query", mode=$_filterMode, base=${interventions.length}');
    final List<dynamic> result = interventions.where((item) {
      try {
        final v = int.tryParse(item['Validation_labo']?.toString() ?? '0');
        if (_filterMode == 1 && v != 1) return false;
        if (_filterMode == 2 && v == 1) return false;

        if (query.isEmpty) return true;

        final numCommande = (item['NumCommande'] ?? '').toString().toLowerCase();
        final peId = (item['pe_id'] ?? item['peId'] ?? '').toString().toLowerCase();
        return numCommande.contains(query) || peId.contains(query);
      } catch (_) {
        return false;
      }
    }).toList();

    print('🔎 Résultats filtrés: ${result.length}');
    if (result.isNotEmpty) {
      final Map<String, List<Map<String, dynamic>>> byPeId = {};
      for (final it in result) {
        final k = (it['pe_id'] ?? it['peId'] ?? '').toString();
        byPeId.putIfAbsent(k, () => []).add(it as Map<String, dynamic>);
      }
      final dupes = byPeId.entries.where((e) => e.key.isNotEmpty && e.value.length > 1).toList();
      if (dupes.isNotEmpty) {
        print('⚠️ Doublons par pe_id: ${dupes.length}');
        for (final d in dupes) {
          final origins = d.value.map((e) => e['is_local'] == true ? 'local' : 'serveur').join(', ');
          final commandes = d.value.map((e) => e['NumCommande']).join(', ');
          print('   pe_id=${d.key} count=${d.value.length} origins=[$origins] commandes=[$commandes]');
        }
      }
      if (query.isNotEmpty) {
        final preview = result.take(5).map((e) {
          final id = (e['pe_id'] ?? e['peId'] ?? '').toString();
          final nc = (e['NumCommande'] ?? '').toString();
          final loc = e['is_local'] == true ? 'local' : 'serveur';
          final v = int.tryParse(e['Validation_labo']?.toString() ?? '0') ?? 0;
          return '$id/$nc/$loc/v=$v';
        }).join(' | ');
        print('🔎 Aperçu résultats: $preview');
      }
    }

    setState(() {
      filteredInterventions = result;
    });
  }

  String _getStatutValidation(dynamic v) {
    final int? val = int.tryParse(v?.toString() ?? '');
    if (val == 1) return 'Validée';
    if (val == 0 || val == null) return 'Brouillon';
    return 'Inconnue';
  }

  Color _getCouleurStatut(dynamic v) {
    final int? val = int.tryParse(v?.toString() ?? '');
    if (val == 1) return Colors.green;
    if (val == 0 || val == null) return Colors.orange;
    return Colors.grey;
  }

  IconData _getIconStatut(dynamic v) {
    final int? val = int.tryParse(v?.toString() ?? '');
    if (val == 1) return Icons.check_circle;
    if (val == 0 || val == null) return Icons.edit;
    return Icons.help;
  }

  String _getInterventionType(String typeInterv) {
    switch (typeInterv) {
      case 'i001':
        return 'Béton';
      case 'i004':
        return 'Acier';
      default:
        return typeInterv;
    }
  }

  Color _getInterventionColor(String typeInterv) {
    switch (typeInterv) {
      case 'i001':
        return Colors.blue;
      case 'i004':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.95), color.withOpacity(0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _countValidated() {
    try {
      return interventions.where((i) {
        final v = int.tryParse(i['Validation_labo']?.toString() ?? '');
        return v == 1;
      }).length;
    } catch (_) {
      return 0;
    }
  }

  int _countDrafts() {
    try {
      return interventions.where((i) {
        final v = int.tryParse(i['Validation_labo']?.toString() ?? '');
        return v == 0 || v == null;
      }).length;
    } catch (_) {
      return 0;
    }
  }

  int _countLocal() {
    try {
      return interventions.where((i) => i['is_local'] == true).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: chantierBlue,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: '🔍 Rechercher par n° commande ou PV',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        actions: [
          // BOUTON DÉBOGAGE
          IconButton(
            icon: Icon(Icons.bug_report, color: Colors.white),
            onPressed: () async {
              await debugLocalInterventions();

              await fetchInterventions(); // Recharger les données
              setState(() {});
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              setState(() {
                _filterMode = v;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Tous')),
              const PopupMenuItem(value: 1, child: Text('Validées')),
              const PopupMenuItem(value: 2, child: Text('Brouillons')),
            ],
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      buildStatCard("Total", "${interventions.length}", const Color(0xFF1E3A8A), Icons.list_alt),
                      const SizedBox(width: 8),
                      buildStatCard("Validées", "${_countValidated()}", Colors.green, Icons.check_circle),
                      const SizedBox(width: 8),
                      buildStatCard("Brouillons", "${_countDrafts()}", Colors.orange, Icons.pending_actions),
                      const SizedBox(width: 8),
                      buildStatCard("Locales", "${_countLocal()}", Colors.orange, Icons.cloud_off),
                    ],
                  ),
                ),
                Expanded(
                  child: (interventions.isEmpty)
                      ? const Center(
                          child: Text(
                            'Aucune donnée disponible 😕',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: (filteredInterventions.isNotEmpty || _searchController.text.isNotEmpty)
                              ? filteredInterventions.length
                              : interventions.length,
                          itemBuilder: (context, index) {
                            final item = (filteredInterventions.isNotEmpty || _searchController.text.isNotEmpty)
                                ? filteredInterventions[index]
                                : interventions[index];

                            final val = int.tryParse(item['Validation_labo']?.toString() ?? '0');
                            final isValidated = val == 1;
                            final String typeInterv = (item['TypeIntervention'] ?? item['typeIntervention'] ?? '').toString();
                            final isLocal = item['is_local'] == true;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: isLocal ? Border.all(color: Colors.orange, width: 2) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: isLocal 
                                      ? Colors.orange.withOpacity(0.1) 
                                      : chantierBlue.withOpacity(0.1),
                                  child: Icon(
                                    isLocal ? Icons.cloud_off : (isValidated ? Icons.verified : Icons.engineering),
                                    color: isLocal ? Colors.orange : chantierBlue,
                                    size: 26,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      item['NumCommande'] ?? 'Commande inconnue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: isLocal ? Colors.orange : Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isLocal) 
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'HORS LIGNE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (!isLocal) 
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getInterventionColor(typeInterv),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getInterventionType(typeInterv),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text("PV: ${item['pe_id'] ?? '—'}",
                                        style: TextStyle(
                                          color: isLocal ? Colors.orange : Colors.black54,
                                          fontWeight: isLocal ? FontWeight.bold : FontWeight.normal
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Affaire: ${item['Code_Affaire'] ?? ''}",
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          _getIconStatut(item['Validation_labo']),
                                          size: 16,
                                          color: _getCouleurStatut(item['Validation_labo']),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _getStatutValidation(item['Validation_labo']),
                                          style: TextStyle(
                                            color: _getCouleurStatut(item['Validation_labo']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isLocal) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.cloud_off, size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Non synchronisée',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message: isValidated ? "Imprimer / Prévisualiser le PV" : "Prévisualiser brouillon (watermark)",
                                      child: IconButton(
                                        icon: Icon(Icons.print, color: isValidated ? chantierBlue : Colors.orange),
                                        onPressed: () async {
                                          try {
                                            await showPVFromDb((item['pe_id'] ?? '').toString(), isDraft: !isValidated);
                                            print('PRINT BUTTON PRESSED for pe_id=${item['pe_id']} at ${DateTime.now()}'); } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Erreur génération PDF: $e')),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
                                  ],
                                ),
                                onTap: () {
                                  if (isLocal) {
                                    // Pour les interventions locales, ouvrir l'écran d'édition AVEC LES DONNÉES
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewInterventionsPage(
                                          canInsertion: true,
                                          existingInterventionId: item['pe_id'], // ← AJOUTEZ CE PARAMÈTRE
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Pour les interventions de l'API, comportement normal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InterventionsPage(
                                          canEdit: !isValidated,
                                          commandeData: item,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<int>(
            context: context,
            builder: (context) => const ChoixPVDialog(),
          );
          if (result != null) {
            await fetchInterventions();
            setState(() {});
          }
        },
        backgroundColor: chantierBlue,
        elevation: 5,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
