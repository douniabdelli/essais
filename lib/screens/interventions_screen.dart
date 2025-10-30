import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/screens/CreationPv.dart';
import 'package:mgtrisque_visitepreliminaire/screens/interventionsBeton.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mgtrisque_visitepreliminaire/services/pdf_generator.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';

class AffairesScreen extends StatefulWidget {
  final String isNotFirstTime;
  const AffairesScreen({
    super.key,
    this.isNotFirstTime = '',
  });

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
  }

  Future<void> fetchInterventions() async {
    final db = VisitePreliminaireDatabase.instance;
    String? token = await storage.read(key: 'token');

    setState(() => isLoading = true);
    if (isOffline) {
      final local = await db.getAllCommandes();
      print('📴 Mode offline: ${local.length} commandes locales.');
      setState(() {
        interventions = local.map((e) => e.toMap()).toList();
        isLoading = false;
      });
      return;
    }
    try {
      print('🌐 Tentative de récupération des interventions depuis l’API...');

      final response = await dio().get(
        '/essais/interventions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? [];

        await db.createInterventions(data);
        print('💾 Interventions téléchargées et sauvegardées localement (${data.length}).');

        setState(() {
          interventions = data;
          _applyFilters();
          isLoading = false;
        });
      } else {
        print('⚠️ Erreur API: Code ${response.statusCode}');
        final local = await db.getAllCommandes();
        print('📴 Mode offline: chargement ${local.length} interventions locales.');
        setState(() {
          interventions = local.map((e) => e.toMap()).toList();
          _applyFilters();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception API (probablement hors ligne): $e');
      final local = await db.getAllCommandes();
      print('📴 Mode offline: chargement ${local.length} interventions locales.');
      setState(() {
        interventions = local.map((e) => e.toMap()).toList();
        _applyFilters();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredInterventions = interventions.where((item) {
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
                      buildStatCard("Total", "${interventions.length}", chantierBlue, Icons.list_alt),
                      const SizedBox(width: 8),
                      buildStatCard("Validées", "${_countValidated()}", Colors.green, Icons.check_circle),
                      const SizedBox(width: 8),
                      buildStatCard("Brouillons", "${_countDrafts()}", Colors.orange, Icons.pending_actions),
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

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
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
                                  backgroundColor: chantierBlue.withOpacity(0.1),
                                  child: Icon(
                                    isValidated ? Icons.verified : Icons.engineering,
                                    color: chantierBlue,
                                    size: 26,
                                  ),
                                ),
                                title: Text(
                                  item['NumCommande'] ?? 'Commande inconnue',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text("PV: ${item['pe_id'] ?? '—'}",
                                        style: const TextStyle(color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Affaire: ${item['Code_Affaire'] ?? ''}  ",
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
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (typeInterv.isNotEmpty)
                                      Chip(
                                        label: Text(
                                          typeInterv,
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                        backgroundColor: chantierBlue.withOpacity(0.08),
                                      ),
                                    if (isValidated) ...[
                                      const SizedBox(width: 6),
                                      Tooltip(
                                        message: "Imprimer / Prévisualiser le PV",
                                        child: IconButton(
                                          icon: const Icon(Icons.print, color: chantierBlue),
                                          onPressed: () async {
                                            try {
                                              final logo = await rootBundle.load('assets/logo-ctc.png');

                                              final data = {
                                                'logo': logo.buffer.asUint8List(),
                                                'pe_id': item['pe_id'] ?? '—',
                                                'date': item['created_at'] ?? item['createdAt'] ?? '—',
                                                'user': item['user_code'] ?? '—',
                                                'userNom': item['Nom_DR_Laboratoire'] ?? '',
                                                'userPrenom': item['Structure_Laboratoire'] ?? '',
                                                'intitule': item['Intitule_Affaire'] ?? '',
                                                'codeAffaire': item['Code_Affaire'] ?? '',
                                                'codeSite': item['Code_Site'] ?? '',
                                                'entreprise': item['Entreprise'] ?? '',
                                                'dateCoulage': item['DateCoulage'] ?? '',
                                                'classe': item['Classe_Beton'] ?? '',
                                                'elements': (item['elements'] ?? []) as List,
                                                'constituants': (item['constituants'] ?? []) as List,
                                              };

                                              // Show system print/preview UI directly
                                              await showLocalPV(data);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Erreur génération PDF: $e')),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InterventionsPage(
                                        canEdit: !isValidated,
                                        commandeData: item,
                                      ),
                                    ),
                                  );
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
          await showDialog(
            context: context,
            builder: (context) => const ChoixPVDialog(),
          );
        },
        backgroundColor: chantierBlue,
        elevation: 5,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
}
