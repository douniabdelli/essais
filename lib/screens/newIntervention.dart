import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mgtrisque_visitepreliminaire/widgets/searchable_dropdown.dart';

import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
class NewInterventionsPage extends StatefulWidget {
  final bool canInsertion;
  final String? existingInterventionId; // ← AJOUTEZ CE PARAMÈTRE

  const NewInterventionsPage({
    Key? key, 
    required this.canInsertion,
    this.existingInterventionId, // ← AJOUTEZ CE PARAMÈTRE
  }) : super(key: key);

  @override
  _InterventionsPageState createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<NewInterventionsPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int _currentStep = 0;
  bool isLoading = false;             
  bool isOffline = false; 
List<Map<String, dynamic>> additifs = [];
  bool _isLoadingExistingData = false;
  Map<String, dynamic>? _existingInterventionData;
 final GlobalKey<FormBuilderState> _formKey1 = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKey2 = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKey3 = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKey4 = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKey5 = GlobalKey<FormBuilderState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController tempController = TextEditingController(text: "20");
  final TextEditingController ecController = TextEditingController(text: "0.5");
  final TextEditingController observationController = TextEditingController();
  final TextEditingController affaissementController = TextEditingController();
  final TextEditingController niveauController = TextEditingController(text: "0.0");
void _addGranulas() {
  setState(() {
    granulas.add({
      "dosage": 0,
      "dmin": 0,
      "dmax": 0,
       "prov": null,
    });
  });
}
TextEditingController _searchControllerModeProd = TextEditingController();
TextEditingController _searchControllerElemOuvrage = TextEditingController();
void _addCiment() {
  setState(() {
    ciment.add({
      "prov": "",
      "type": null,
      "dosage": 0,
    });
  });
}
void _addAdjuvant() {
  setState(() {
    adjuvant.add({
      "prov": "",
      "type": null,
      "dosage": 0,
    });
  });
}
void _deleteGranulas(int index) {
  setState(() {
    granulas.removeAt(index);
  });
}
  String _incrementPeId(String peId) {
    final match = RegExp(r'^(.*?)(\d+)$').firstMatch(peId);
    if (match == null) {
      throw Exception('Invalid PE ID format: $peId');
    }

    final prefix = match.group(1)!;   // 2025PRLC
    final numStr = match.group(2)!;   // 0000029
    final width = numStr.length;      // 7

    final nextNum = BigInt.parse(numStr) + BigInt.one;
    final padded = nextNum.toString().padLeft(width, '0');

    return '$prefix$padded';
  }

  void _updateLastServerPeId(String candidate) {
    try {
      final re = RegExp(r'(\d{7})$');  // exactement 7 chiffres à la fin
      final m = re.firstMatch(candidate);

      if (m == null) {
        // Pas 7 chiffres à la fin → on ignore ou on garde l'ancien si déjà défini
        if (lastServerPeId == null) {
          lastServerPeId = candidate;
          debugPrint('lastServerPeId set (no 7-digit suffix): $lastServerPeId');
        }
        return;
      }

      final numStr = m.group(1)!;                // "0000029"
      final candNum = int.parse(numStr);         // 29 → int

      if (lastServerPeNumeric == null || candNum > lastServerPeNumeric!) {
        lastServerPeNumeric = candNum;
        lastServerPeId = candidate;
        debugPrint('lastServerPeId updated -> $lastServerPeId (num=$lastServerPeNumeric)');
      }
    } catch (e) {
      debugPrint('Error updating lastServerPeId: $e');
    }
  }
TextEditingController _searchControllerBeton = TextEditingController();
TextEditingController _searchControllerCarriere = TextEditingController();
  String generateNextPeId() {
    if (lastServerPeNumeric == null || lastServerPeId == null) {
      // Premier ID de l'année, on commence à 1
      final prefix = DateTime.now().year.toString() + 'PRLC';
      return prefix + '0000001';
    }

    final int nextNum = lastServerPeNumeric! + 1;
    final String newNumStr = nextNum.toString().padLeft(7, '0');

    // On extrait le préfixe de l'ancien ID (tout sauf les 7 derniers chiffres)
    final prefix = lastServerPeId!.substring(0, lastServerPeId!.length - 7);

    return prefix + newNumStr;  // ex: 2025PRLC0000030
  }
@override
void dispose() {
  _searchControllerBeton.dispose();
  super.dispose();
}

String searchValue = '';
  String? selectedAffaissement;
  Commande? selectedCommande;
  Entreprise? selectedEntreprise;
  ClasseBeton? selectedClasseBeton;
  ElementPredefini? selectedpredfini;
  ModesProduction? selectedModeProd;
  ClasseCarrieres? selectedCarrieres;
  TypeCiments? selectedTypeCiments;
  TypeAdjuvants?selectedTypeAdjuvants;
  TypeEprouvettes?selectedTypeEprouvettes;
  Bloc? selectedBloc;
  Elemouvrage? selectedElem;
 Map<String, String> commandePeIds = {};
  String? lastServerPeId;          // dernière pe_id connue côté serveur
  int? lastServerPeNumeric;
  List<Commande> commandes = [];
  List<ClasseBeton> betons = [];
  List<ElementPredefini> elementPredefini = [];
  List<ModesProduction> ModePro = [];
  List<ClasseCarrieres> carrieres = [];
  List<TypeCiments> typeciment = [];
  List<TypeAdjuvants> typeAdjuvant = [];
  List<TypeEprouvettes> typeEprouvette = [];
  List<Map<String, dynamic>> granulas = [];
  List<Map<String, dynamic>> eau = [];
  List<Map<String, dynamic>> sables = [];
  List<Map<String, dynamic>> ciment = [];
  List<Map<String, dynamic>> adjuvant = [];
  List<Map<String, dynamic>> additif = [];
  
  
  final Map<int, String> fbConstituantMapping = const {1: 'granulas', 2: 'sables', 3: 'ciment', 4: 'adjuvant', 5: 'additifs', 6: 'eau'};
  List<Elemouvrage?> selectedElems = [null];
List<BlocElemSelection> selections = [];


final List<bool> _prelevements = [false, false, false, false, false];

final List<String> _optionsNbrEchantillon = ["1", "2", "3", "4", "5"];



final List<String> prelevements = [
  "Carotte",
  "Béton frais",
  "Granulat",
];



int nbEchantillons = 0;



  List<Widget> _buildAgeCards(Commande selectedCommande) {
    final List<Map<String, dynamic>> ages = [
      {'label': "Écrasement âge 1", 'age': selectedCommande.age1},
      {'label': "Écrasement âge 2", 'age': selectedCommande.age2},
      {'label': "Écrasement âge 3", 'age': selectedCommande.age3},
    ];

    final validAges = ages.where((a) {
      final ageValue = a['age'];
      return ageValue != null && ageValue.toString().isNotEmpty && ageValue.toString() != '0';
    }).toList();

    return List.generate(validAges.length, (index) {
      final ageData = validAges[index];
      final ageText = ageData['age'].toString(); 
      final label = "${ageData['label']} : $ageText jours";

      void onToggle(bool val) {
        setState(() {
          
        });
      }

      return Column(
        children: [
          _buildAgeCard(
            label: label,
            age: ageText, 
            enabled: true,
            onToggle: onToggle,
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

void _addEau() {
  setState(() {
    eau.add({"source": "", "dosage": ""});
  });
}


Future<List<Map<String, dynamic>>> _fetchFormulations(String codeCommande) async {
  try {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final resp = await dio().get(
      '/essais/get_formulation_beton/$codeCommande',
      options: Options(headers: {'Authorization': token != null ? 'Bearer $token' : ''}),
    );
    if (resp.statusCode == 200) {
      final data = resp.data;
      
      if (data == null) return [];
      if (data is Map && data['pvs_fb'] is List) {
        return List<Map<String, dynamic>>.from(data['pvs_fb']);
      }
      
      if (data is Map && data['firstPv'] is Map) {
        return [Map<String, dynamic>.from(data['firstPv'])];
      }
      return [];
    }
    return [];
  } catch (e) {
    debugPrint('fetchFormulations error: $e');
    return [];
  }
}


Future<void> _showFormulationsDialog() async {
  if (selectedCommande == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner d\'abord une commande')));
    return;
  }

  
  if (commandes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune commande disponible. Veuillez synchroniser les données.')));
    return;
  }

  final code = (selectedCommande != null)
      ? selectedCommande!.codeCommande.toString()
      : commandes.first.codeCommande.toString();
      print("cooooooooooooooode,$code");
  showDialog<void>(
    context: context,
    builder: (context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFormulations(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return AlertDialog(content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
          final items = snapshot.data ?? [];
          return AlertDialog(
            title: const Text('Formulations trouvées'),
            content: SizedBox(
              width: double.maxFinite,
              child: items.isEmpty
                  ? const Text('Aucune formulation trouvée pour cette commande')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final pv = items[idx];
                        final pvfId = pv['pvf_id'] ?? pv['pvfId'] ?? 'unknown';
                        final label = pv['pvf_etb_real'] ?? pv['pvf_etb_pv'] ?? pvfId;
                        return ListTile(
                          title: Text('$pvfId'),
                          subtitle: Text(label.toString()),
                          onTap: () {
                            Navigator.of(context).pop();
                            _showConstituantsDialog(pv);
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
            ],
          );
        },
      );
    },
  );
}

  String incrementPeId(String currentId) {
    final re = RegExp(r'^(.+)(\d{7})$');
    final match = re.firstMatch(currentId);

    if (match == null) {
      throw Exception('Format PE ID invalide: $currentId');
    }

    final prefix = match.group(1)!;  // "2025PRLC"
    final numStr = match.group(2)!;  // "0000029"

    final number = int.parse(numStr);  // 29 (pas besoin de BigInt pour l'instant)
    final newNumber = number + 1;

    final newNumStr = newNumber.toString().padLeft(7, '0');  // "0000030"

    return prefix + newNumStr;  // "2025PRLC0000030"
  }
Future<void> _showConstituantsDialog(Map<String, dynamic> pv) async {
  final List<dynamic> constituants = pv['constituants'] ?? pv['constituents'] ?? [];

  
  showDialog<void>(
    context: context,
    builder: (context) {
      
      final local = constituants.map((e) => Map<String, dynamic>.from(e)).toList();
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Constituants - ${pv['pvf_id'] ?? pv['pvfId'] ?? pv['pvf'] ?? ''}'),
            content: SizedBox(
              width: double.maxFinite,
              child: local.isEmpty
                  ? const Text('Aucun constituant')
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: () {
                          
                          final Map<int, List<Map<String, dynamic>>> groups = {};
                          for (var c in local) {
                            final int code = int.tryParse(c['fb_constituant']?.toString() ?? '') ?? 0;
                            groups.putIfAbsent(code, () => []).add(c);
                          }

                          
                          final List<int> order = [1, 2, 3, 4, 5, 6];
                          final Map<int, String> labels = {1: 'Granulas', 2: 'Sables', 3: 'Ciment', 4: 'Adjuvants', 5: 'Additifs', 6: 'Eau'};
                          final Map<int, Color> colors = {
                            1: const Color.fromARGB(255, 0, 0, 0), 
                            2: const Color(0xFFFFEB3B), 
                            3: const Color.fromARGB(255, 179, 178, 178), 
                            4: const Color(0xFF4CAF50), 
                            5: const Color(0xFFF44336), 
                            6: const Color(0xFF2196F3), 
                          };

                          final List<Widget> sections = [];
                          for (var k in order) {
                            final items = groups[k] ?? [];
                            if (items.isEmpty) continue;

                            sections.add(
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: colors[k]!.withOpacity(0.95),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      ),
                                      child: Center(
                                        child: Text(labels[k] ?? 'Constituants', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        children: items.map((c) {
                                          final dosage = c['fb_dosage']?.toString() ?? '';
                                          final dmin = c['fb_dmin']?.toString() ?? '';
                                          final dmax = c['fb_dmax']?.toString() ?? '';
                                          final provRaw = c['__prov_sel'] ?? c['fb_provenance'];
                                          
                                          String provLabel = '';
                                          if (provRaw != null) {
                                            try {
                                              if (provRaw is Map) {
                                                provLabel = provRaw['label']?.toString() ?? provRaw['value']?.toString() ?? provRaw.toString();
                                              } else {
                                                final rawStr = provRaw.toString();
                                                ClasseCarrieres? matched;
                                                try {
                                                  matched = carrieres.firstWhere((cr) => cr.value.toString() == rawStr || cr.label.toString() == rawStr);
                                                } catch (_) {
                                                  matched = null;
                                                }
                                                provLabel = matched != null ? matched.label : rawStr;
                                              }
                                            } catch (e) {
                                              provLabel = provRaw.toString();
                                            }
                                          }
                                          final type = c['fb_type']?.toString() ?? '';

                                          
                                          final bool showDminDmax = (k == 1 || k == 2 || k == 6);

                                          return Card(
                                            margin: const EdgeInsets.symmetric(vertical: 6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(provLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  const SizedBox(height: 8),
                                                  if (showDminDmax) ...[
                                                    Row(
                                                      children: [
                                                        Expanded(child: Text('Dosage: $dosage', style: const TextStyle(fontWeight: FontWeight.w600))),
                                                        Expanded(child: Text('Dmin: $dmin', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                                                        Expanded(child: Text('Dmax: $dmax', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
                                                      ],
                                                    ),
                                                  ] else ...[
                                                    Row(
                                                      children: [
                                                        Expanded(child: Text('Dosage: $dosage', style: const TextStyle(fontWeight: FontWeight.w600))),
                                                      ],
                                                    ),
                                                  ],
                                                  if (type.isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    Text('Type: $type', style: const TextStyle(fontStyle: FontStyle.italic)),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          
                          final otherKeys = groups.keys.where((kk) => !order.contains(kk)).toList()..sort();
                          if (otherKeys.isNotEmpty) {
                            for (var k in otherKeys) {
                              final items = groups[k] ?? [];
                              if (items.isEmpty) continue;
                              sections.add(
                                Card(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.95),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                        child: Center(
                                          child: Text('Autres (code $k)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: items.map((c) {
                                            final dosage = c['fb_dosage']?.toString() ?? '';
                                            final provRaw = c['__prov_sel'] ?? c['fb_provenance'];
                                            String provLabel = provRaw?.toString() ?? '';
                                            try {
                                              if (provRaw != null) {
                                                if (provRaw is Map) provLabel = provRaw['label']?.toString() ?? provRaw['value']?.toString() ?? provRaw.toString();
                                                else {
                                                  final rawStr = provRaw.toString();
                                                  ClasseCarrieres? matched;
                                                  try {
                                                    matched = carrieres.firstWhere((cr) => cr.value.toString() == rawStr || cr.label.toString() == rawStr);
                                                  } catch (_) {
                                                    matched = null;
                                                  }
                                                  provLabel = matched != null ? matched.label : rawStr;
                                                }
                                              }
                                            } catch (_) {}

                                            return Card(
                                              margin: const EdgeInsets.symmetric(vertical: 6),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(provLabel.isNotEmpty ? provLabel : 'Inconnu', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                    const SizedBox(height: 8),
                                                    Row(children: [Expanded(child: Text('Dosage: $dosage', style: const TextStyle(fontWeight: FontWeight.w600)))],),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }

                          return sections;
                        }(),
                      ),
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
            ],
          );
        },
      );
    },
  );
}






void _deleteCiment(int index) {
  setState(() {
    if (index >= 0 && index < ciment.length) ciment.removeAt(index);
  });
}

void _deleteAdjuvant(int index) {
  setState(() {
    if (index >= 0 && index < adjuvant.length) adjuvant.removeAt(index);
  });
}



void _deleteEau(int index) {
  setState(() {
    if (index >= 0 && index < eau.length) eau.removeAt(index);
  });
}


void _addSable() {
  setState(() {
    sables.add({
      'prov': null,
      'dosage': 0,
      'dmax': 0,
    });
  });
}


void _deleteSable(int index) {
  setState(() {
    sables.removeAt(index);
  });
}


void _addAdditif() {
  setState(() {
    additifs.add({
      'type': null,
      'nomProduit': '',
      'dosage': 0,
    });
  });
}


void _deleteAdditif(int index) {
  setState(() {
    additifs.removeAt(index);
  });
}
Widget _buildAdditifs() {
  if (additifs.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      const Text("Additifs", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),

      ...additifs.asMap().entries.map((e) {
        final i = e.key;
        final it = e.value;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Fumée de Silice"),
                        value: "fumee_silice",
                        groupValue: it['type'],
                        onChanged: (val) {
                          setState(() {
                            it['type'] = val;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Cendres Volantes"),
                        value: "cendres_volantes",
                        groupValue: it['type'],
                        onChanged: (val) {
                          setState(() {
                            it['type'] = val;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Autre"),
                        value: "autre",
                        groupValue: it['type'],
                        onChanged: (val) {
                          setState(() {
                            it['type'] = val;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAdditif(i),
                    ),
                  ],
                ),

                const SizedBox(height: 8),


                if (it['type'] != null && it['type'] != "autre") ...[
                  TextFormField(
                    initialValue: it['dosage'].toString(),
                    decoration: const InputDecoration(
                      labelText: "Dosage (L/m3) *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      it['dosage'] = int.tryParse(v) ?? 0;
                    },
                  ),
                ],


                if (it['type'] == "autre") ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: it['nomProduit'],
                          decoration: const InputDecoration(
                            labelText: "Nom du produit *",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => it['nomProduit'] = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: it['dosage'].toString(),
                          decoration: const InputDecoration(
                            labelText: "Dosage (L/m3) *",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
      }),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    ],
  );
}

   @override
  void initState() {
    super.initState();
    debugPrint('initState: starting fetchInterventions');
      FlutterSecureStorage().read(key: 'last_server_pe_id').then((value) {
        if (value != null && value.isNotEmpty) {
          setState(() {
            lastServerPeId = value;

            try {
              // On force exactement 7 chiffres à la fin
              final re = RegExp(r'(\d{7})$');
              final m = re.firstMatch(value);

              if (m != null) {
                final numStr = m.group(1)!;           // ex: "0000029"
                lastServerPeNumeric = int.parse(numStr);  // → 29 (int)
              } else {
                // Si l'ID chargé n'a pas 7 chiffres → on ignore la partie numérique
                // ou tu peux essayer de corriger automatiquement, mais pour l'instant on laisse null
                lastServerPeNumeric = null;
                debugPrint('Warning: loaded lastServerPeId has invalid numeric suffix: $value');
              }
            } catch (e) {
              debugPrint('Error parsing numeric part of lastServerPeId: $e');
              lastServerPeNumeric = null;
            }
          });

          debugPrint('initState: loaded lastServerPeId from storage -> $value (numeric: $lastServerPeNumeric)');
        }
    }).catchError((e) {
      debugPrint('initState: failed to read last_server_pe_id -> $e');
    });
    if (widget.existingInterventionId != null) {
      _loadExistingIntervention();
    } else {
      // Sinon, charger normalement les références
      debugPrint('initState: starting fetchInterventions');
      fetchInterventions().then((result) {
        debugPrint('initState: fetchInterventions completed, commandes=${result.commandes.length}, betons=${result.betons.length}');
        setState(() {
          commandes = result.commandes;
          betons = result.betons;
          elementPredefini = result.elementPredefini;
          ModePro = result.modePro;
          carrieres = result.carrieres;
          typeciment = result.typeciment;
          typeAdjuvant = result.typeAdjuvants;
          typeEprouvette = result.typeEprouvette;
        });
      }).catchError((e, st) {
        debugPrint('initState: fetchInterventions failed -> $e\n$st');
        setState(() { isLoading = false; });
      });
    }
  }
   Future<void> _loadExistingIntervention() async {
    setState(() {
      _isLoadingExistingData = true;
    });

    try {
      final peId = widget.existingInterventionId!;
      print('🔄 Chargement des données existantes pour: $peId');

      // 1. Charger l'intervention principale
      _existingInterventionData = await LocalDatabase.getIntervention(peId);
      print('✅ Intervention principale: $_existingInterventionData');

      if (_existingInterventionData != null) {
        // 2. Charger les éléments d'ouvrage
        final elements = await LocalDatabase.getElementsOuvrage(peId);
        print('✅ Éléments ouvrage: ${elements.length}');

        // 3. Charger les constituants
        final constituants = await LocalDatabase.getConstituants(peId);
        print('✅ Constituants: ${constituants.length}');

        // 4. Charger les éprouvettes
        final eprouvettes = await LocalDatabase.getSeriesEprouvettes(peId);
        print('✅ Éprouvettes: ${eprouvettes.length}');

        // 5. Pré-remplir le formulaire avec les données existantes
        await _prefillFormWithExistingData(
          _existingInterventionData!,
          elements,
          constituants,
          eprouvettes,
        );
      }

    } catch (e) {
      print('❌ Erreur chargement données existantes: $e');
    } finally {
      setState(() {
        _isLoadingExistingData = false;
      });
    }
  }

  Future<void> _prefillFormWithExistingData(
    Map<String, dynamic> intervention,
    List<Map<String, dynamic>> elements,
    List<Map<String, dynamic>> constituants,
    List<Map<String, dynamic>> eprouvettes,
  ) async {
    print('🔄 Pré-remplissage du formulaire...');

    // 1. Charger d'abord les références nécessaires
    await fetchInterventions();

    // 2. Pré-remplir les champs de base
    setState(() {
      // Date et heure
      dateController.text = intervention['pe_date']?.toString() ?? '';
      timeController.text = intervention['pe_heure']?.toString() ?? '';
      tempController.text = intervention['pe_temp']?.toString() ?? '20';
      affaissementController.text = intervention['pe_affais_cone']?.toString() ?? '';
      ecController.text = intervention['pe_cim_ec']?.toString() ?? '0.5';
      observationController.text = intervention['pe_obs']?.toString() ?? '';

      // Trouver et sélectionner la commande correspondante
      if (intervention['commande_id'] != null) {
        selectedCommande = commandes.firstWhere(
          (c) => c.codeCommande == intervention['commande_id'],
          orElse: () => commandes.first,
        );
      }

      // Charger les éléments d'ouvrage
      _loadExistingElementsOuvrage(elements);

      // Charger les constituants
      _loadExistingConstituants(constituants);

      // Charger les éprouvettes
      _loadExistingEprouvettes(eprouvettes);
    });

    print('✅ Formulaire pré-rempli avec succès');
  }

  void _loadExistingElementsOuvrage(List<Map<String, dynamic>> elements) {
    selections.clear();
    for (var element in elements) {
      selections.add(BlocElemSelection(
        // Vous devrez adapter selon votre structure de données
        elemouvrage: Elemouvrage(
          nom: element['nom']?.toString() ?? '',
          axe: element['axe']?.toString() ?? '',
          file: element['file']?.toString() ?? '',
         // peid: element['pe_id']?.toString() ?? '',
          niveau: element['niveau']?.toString() ?? '0.0',
          bloc: element['bloc']?.toString() ?? '',
          famille: element['famille']?.toString() ?? '',
        ),
        // Vous devrez aussi gérer le bloc sélectionné
      ));
    }
  }

  void _loadExistingConstituants(List<Map<String, dynamic>> constituants) {
    // Réinitialiser les listes
    granulas.clear();
    sables.clear();
    ciment.clear();
    adjuvant.clear();
    additifs.clear();
    eau.clear();

    for (var constituant in constituants) {
      final type = constituant['type']?.toString();
      final category = constituant['category']?.toString();

      switch (type ?? category) {
        case 'granulas':
          granulas.add({
            "dosage": constituant['dosage'],
            "dmin": constituant['dmin'],
            "dmax": constituant['dmax'],
            "prov": _findCarriereById(constituant['prov']),
          });
          break;
        case 'sables':
          sables.add({
            "dosage": constituant['dosage'],
            "dmax": constituant['dmax'],
            "prov": _findCarriereById(constituant['prov']),
          });
          break;
        case 'ciment':
          ciment.add({
            "prov": constituant['prov']?.toString(),
            "type": _findTypeCimentById(constituant['fb_type']),
            "dosage": constituant['dosage'],
          });
          break;
        case 'adjuvant':
          adjuvant.add({
            "prov": constituant['prov']?.toString(),
            "type": _findTypeAdjuvantById(constituant['fb_type']),
            "dosage": constituant['dosage'],
          });
          break;
        case 'additif':
          additifs.add({
            "type": constituant['fb_type']?.toString(),
            "nomProduit": constituant['nom_produit']?.toString(),
            "dosage": constituant['dosage'],
          });
          break;
        case 'eau':
          eau.add({
            "source": constituant['prov']?.toString(),
            "dosage": constituant['dosage'],
          });
          break;
      }
    }
  }

  void _loadExistingEprouvettes(List<Map<String, dynamic>> eprouvettes) {
    // Implémentez le chargement des éprouvettes selon votre structure
    print('📋 Éprouvettes à charger: ${eprouvettes.length}');
    // À adapter selon votre logique d'éprouvettes
  }

  // Méthodes utilitaires pour trouver les références
  ClasseCarrieres? _findCarriereById(dynamic id) {
    if (id == null) return null;
    return carrieres.firstWhere(
      (c) => c.value.toString() == id.toString(),
      orElse: () => carrieres.first,
    );
  }

  TypeCiments? _findTypeCimentById(dynamic id) {
    if (id == null) return null;
    return typeciment.firstWhere(
      (c) => c.value.toString() == id.toString(),
      orElse: () => typeciment.first,
    );
  }

  TypeAdjuvants? _findTypeAdjuvantById(dynamic id) {
    if (id == null) return null;
    return typeAdjuvant.firstWhere(
      (c) => c.value.toString() == id.toString(),
      orElse: () => typeAdjuvant.first,
    );
  }
TextEditingController _searchController = TextEditingController();



Future<Interventions> fetchInterventions() async {
  setState(() => isLoading = true);

  if (isOffline) {
    try {
      final db = LocalDatabase(); // Remplacez VisitePreliminaireDatabase par LocalDatabase
      final localData = await Future.wait([
        db.getAllCommandes(), // Remplacez les appels de méthode
        db.getAllBetons(),
        db.getAllElementsPred(),
        db.getAllModesProd(),
        db.getAllCarrieres(),
        db.getAllTypesCiments(),
        db.getAllTypesAdjuvants(),
        db.getAllTypesEprouvettes(),
      ]);

      setState(() => isLoading = false);
      return Interventions(
        commandes: localData[0] as List<Commande>,
        betons: localData[1] as List<ClasseBeton>,
        elementPredefini: localData[2] as List<ElementPredefini>,
        modePro: localData[3] as List<ModesProduction>,
        carrieres: localData[4] as List<ClasseCarrieres>,
        typeciment: localData[5] as List<TypeCiments>,
        typeAdjuvants: localData[6] as List<TypeAdjuvants>,
        typeEprouvette: localData[7] as List<TypeEprouvettes>,
      );
    } catch (e) {
      debugPrint('Erreur lecture données locales: $e');
      setState(() => isLoading = false);
      throw Exception('Erreur lecture données locales: $e');
    }
  }

  try {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    debugPrint('fetchInterventions: token read -> ${token == null ? "null" : (token.length > 12 ? token.substring(0,12) + "..." : token)}');

    if (token == null || token.isEmpty) {
      debugPrint('fetchInterventions: token missing or empty, fallback to local');
      final db = LocalDatabase();
      final localData = await Future.wait([
        db.getAllCommandes(),
        db.getAllBetons(),
        db.getAllElementsPred(),
        db.getAllModesProd(),
        db.getAllCarrieres(),
        db.getAllTypesCiments(),
        db.getAllTypesAdjuvants(),
        db.getAllTypesEprouvettes(),
      ]);
      setState(() {
        isLoading = false;
        isOffline = true;
      });
      return Interventions(
        commandes: localData[0] as List<Commande>,
        betons: localData[1] as List<ClasseBeton>,
        elementPredefini: localData[2] as List<ElementPredefini>,
        modePro: localData[3] as List<ModesProduction>,
        carrieres: localData[4] as List<ClasseCarrieres>,
        typeciment: localData[5] as List<TypeCiments>,
        typeAdjuvants: localData[6] as List<TypeAdjuvants>,
        typeEprouvette: localData[7] as List<TypeEprouvettes>,
      );
    }

    Map<String, dynamic> _toMap(dynamic item) {
      if (item == null) return {};
      if (item is Map) return Map<String, dynamic>.from(item);
      if (item is String) {
        try {
          final decoded = json.decode(item);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {
          return {'label': item};
        }
      }
      return {};
    }

    List<dynamic> _norm(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw;
      if (raw is Map) return raw.values.toList();
      if (raw is String) {
        try {
          final d = json.decode(raw);
          if (d is List) return d;
          if (d is Map) return d.values.toList();
        } catch (_) {}
      }
      return [];
    }

    final base = dio().options.baseUrl;
    debugPrint('fetchInterventions: calling dio GET /essais/interventions_setpdataBeton (baseUrl="$base")');
    final response = await dio().get(
      '/essais/interventions_setpdataBeton/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('fetchInterventions: statusCode=${response.statusCode}');
    try {
      debugPrint('fetchInterventions: raw response.data=${jsonEncode(response.data)}');
    } catch (e) {
      debugPrint('fetchInterventions: unable to jsonEncode response.data -> $e (type=${response.data.runtimeType})');
    }

    if (response.statusCode == 200) {
      final data = response.data ?? {};
      debugPrint('fetchInterventions: data type ${data.runtimeType}');

      final rawCommandes = _norm(data['commandes']);
      final rawBeton = _norm(data['beton']);
      final rawElementPredefini = _norm(data['elementPredefini']);
      final rawModes = _norm(data['modesProduction']);
      final rawCarrieres = _norm(data['carrieres']);
      final rawTypesCiment = _norm(data['types_ciments']);
      final rawTypesAdjuvants = _norm(data['types_adjuvants']);
      final rawTypesEprouvettes = _norm(data['types_eprouvettes']);

      debugPrint('fetchInterventions: raw lengths -> commandes:${rawCommandes.length}, beton:${rawBeton.length}, elementPredefini:${rawElementPredefini.length}, modes:${rawModes.length}, carrieres:${rawCarrieres.length}');
 final commandes = <Commande>[];
    for (var item in rawCommandes) {
      try {
        final m = _toMap(item);
        if (m.isNotEmpty) {
          final cmd = Commande.fromJson(m);

          // Affecter pe_id/peId si présent dans la réponse API
          try {
            dynamic rawPe = m['pe_id'] ?? m['peId'] ?? m['peid'] ?? m['pe'];

            // --- NOUVEAU: chercher pe_id dans elementOuvrages si non trouvé directement
            if ((rawPe == null || rawPe.toString().isEmpty) && (m['elementOuvrages'] != null || m['elemouvrages'] != null || m['elementOuvrage'] != null)) {
              final elemsRaw = m['elementOuvrages'] ?? m['elemouvrages'] ?? m['elementOuvrage'];
              try {
                final elems = elemsRaw is String ? jsonDecode(elemsRaw) : elemsRaw;
                if (elems is List && elems.isNotEmpty) {
                  final first = elems.first;
                  if (first is Map && (first['pe_id'] != null || first['peId'] != null)) {
                    rawPe = first['pe_id'] ?? first['peId'];
                   debugPrint('fetchInterventions: found pe_id in elementOuvrages -> $rawPe');
                  }
                }
              } catch (_) {
                // ignore parse errors
              }
            }

           // Mettre à jour le dernier pe_id serveur connu (pour incrémentation future)
          if (rawPe != null && rawPe.toString().isNotEmpty) {
             _updateLastServerPeId(rawPe.toString());
           }

            try {
              final key = cmd.codeCommande?.toString() ?? cmd.numCommande?.toString() ?? '';
              if (key.isNotEmpty && rawPe != null && rawPe.toString().isNotEmpty) commandePeIds[key] = rawPe.toString();
            } catch (_) {
              // ignore si pas de clé disponible
            }
          } catch (_) {
            // ignore si la classe Commande ne contient pas peId
          }

          commandes.add(cmd);
        } else {
          debugPrint('fetchInterventions: skip commande empty map for item=$item (type=${item.runtimeType})');
        }
      } catch (e, st) {
        debugPrint('fetchInterventions: failed parse Commande -> $e\n$st\nitem=$item');
      }
    }
      final betons = <ClasseBeton>[];
      for (var item in rawBeton) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) betons.add(ClasseBeton.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse ClasseBeton -> $e\n$st\nitem=$item');
        }
      }

      final elementPredef = <ElementPredefini>[];
      for (var item in rawElementPredefini) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) elementPredef.add(ElementPredefini.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse ElementPredefini -> $e\n$st\nitem=$item');
        }
      }

      final ModePro = <ModesProduction>[];
      for (var item in rawModes) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) ModePro.add(ModesProduction.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse ModesProduction -> $e\n$st\nitem=$item');
        }
      }

      final carrieres = <ClasseCarrieres>[];
      for (var item in rawCarrieres) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) carrieres.add(ClasseCarrieres.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse ClasseCarrieres -> $e\n$st\nitem=$item');
        }
      }

      final typeciment = <TypeCiments>[];
      for (var item in rawTypesCiment) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) typeciment.add(TypeCiments.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse TypeCiments -> $e\n$st\nitem=$item');
        }
      }

      final typeAdjuvants = <TypeAdjuvants>[];
      for (var item in rawTypesAdjuvants) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) typeAdjuvant.add(TypeAdjuvants.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse TypeAdjuvants -> $e\n$st\nitem=$item');
        }
      }

      final typeEprouvette = <TypeEprouvettes>[];
      for (var item in rawTypesEprouvettes) {
        try {
          final m = _toMap(item);
          if (m.isNotEmpty) typeEprouvette.add(TypeEprouvettes.fromJson(m));
        } catch (e, st) {
          debugPrint('fetchInterventions: failed parse TypeEprouvettes -> $e\n$st\nitem=$item');
        }
      }

      debugPrint('fetchInterventions: parsed counts -> commandes:${commandes.length}, betons:${betons.length}, elementPredef:${elementPredef.length}');
      setState(() => isLoading = false);

      
      final db = LocalDatabase();
      await Future.wait([
        db.saveCommandes(commandes),
        db.saveBetons(betons),
        db.saveElementsPred(elementPredef),
        db.saveModesProd(ModePro),
        db.saveCarrieres(carrieres),
        db.saveTypesCiments(typeciment),
        db.saveTypesAdjuvants(typeAdjuvant),
        db.saveTypesEprouvettes(typeEprouvette)
      ]);

      return Interventions(
        commandes: commandes,
        betons: betons,
        elementPredefini: elementPredef,
        modePro: ModePro,
        carrieres: carrieres,
        typeciment: typeciment,
        typeAdjuvants: typeAdjuvants,
        typeEprouvette: typeEprouvette,
      );
    } else {
      debugPrint('fetchInterventions: non-200 status -> ${response.statusCode}');
      setState(() => isLoading = false);
      throw Exception("Erreur ${response.statusCode}: ${response.data}");
    }
  } catch (e, st) {
    debugPrint('fetchInterventions: exception -> $e\n$st, fallback to local');
    try {
      final db = LocalDatabase();
      final localData = await Future.wait([
        db.getAllCommandes(),
        db.getAllBetons(),
        db.getAllElementsPred(),
        db.getAllModesProd(),
        db.getAllCarrieres(),
        db.getAllTypesCiments(),
        db.getAllTypesAdjuvants(),
        db.getAllTypesEprouvettes(),
      ]);
      setState(() {
        isLoading = false;
        isOffline = true;
      });
      return Interventions(
        commandes: localData[0] as List<Commande>,
        betons: localData[1] as List<ClasseBeton>,
        elementPredefini: localData[2] as List<ElementPredefini>,
        modePro: localData[3] as List<ModesProduction>,
        carrieres: localData[4] as List<ClasseCarrieres>,
        typeciment: localData[5] as List<TypeCiments>,
        typeAdjuvants: localData[6] as List<TypeAdjuvants>,
        typeEprouvette: localData[7] as List<TypeEprouvettes>,
      );
    } catch (le) {
      setState(() => isLoading = false);
      throw Exception('Erreur lecture données locales: $le');
    }
  }
}
  @override
  
  Widget build(BuildContext context) {
     if (_isLoadingExistingData) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargement de l\'intervention...'),
        backgroundColor: Color(0xFF1E3A8A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Chargement des données existantes...'),
          ],
        ),
      ),
    );
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interventions'), 
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: Icon(isOffline ? Icons.cloud_off : Icons.cloud),
            tooltip: 'Mode hors-ligne',
            onPressed: () {
              setState(() {
                isOffline = !isOffline;
                
                fetchInterventions().then((result) {
                  setState(() {
                    commandes = result.commandes;
                    betons = result.betons;
                    elementPredefini = result.elementPredefini;
                    ModePro = result.modePro;
                    carrieres = result.carrieres;
                    typeciment = result.typeciment;
                    typeAdjuvant = result.typeAdjuvants;
                    typeEprouvette = result.typeEprouvette;
                  });
                });
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: const Color(0xFF1E3A8A)),
              ),
              child: Stepper(
                currentStep: _currentStep,
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: details.onStepContinue,
                        child: const Text('Suivant'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Annuler'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  );
                },
                onStepContinue: () {
                bool isValid = true;
                switch (_currentStep) {
                  case 0:
                    isValid =
                        _formKey1.currentState?.saveAndValidate() ?? false;
                    break;
                  case 1:
                    isValid =
                        _formKey2.currentState?.saveAndValidate() ?? false;
                    break;
                  case 2:
                    isValid =
                        _formKey3.currentState?.saveAndValidate() ?? false;
                    break;
                  case 3:
                    isValid =
                        _formKey4.currentState?.saveAndValidate() ?? false;
                    break;
                  case 4:
                    isValid =
                        _formKey5.currentState?.saveAndValidate() ?? false;
                    break;
                }

                if (isValid) {
                  if (_currentStep < 4) {
                    setState(() => _currentStep++);
                  } else {
                    _storeData();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              onStepTapped: (step) =>
                  setState(() => _currentStep = step),
              steps: [
                Step(
                  title: const Text('Informations Affaire'),
                  content: _buildStep1(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Élément d\'ouvrage'),
                  content: _buildStep2(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Prélèvement'),
                  content: _buildStep3(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Constituant'),
                  content: _buildStep4(),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Éprouvettes'),
                  content: _buildStep5(),
                  isActive: _currentStep >= 4,
                  state: _currentStep > 4
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
            ),
    ));
  }

  Widget _buildStep1() {
    return FormBuilder(
      key: _formKey1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Informations Affaire",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,

                ),
              ),
            ),

            
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<Commande>(
                  value: selectedCommande,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.receipt_long, color: Color(0xFF1E3A8A)),
                    labelText: "Commande",
                    labelStyle: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  isExpanded: true,
                  
                  selectedItemBuilder: (BuildContext context) {
                    return commandes.map((c) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          c.numCommande.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },

                  items: commandes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Text(
                            c.numCommande.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          Text(
                            '${c.codeAffaire} - ${c.intituleAffaire ?? c.numCommande}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCommande = value;
                      selectedEntreprise = null;
                      selectedClasseBeton = null;
                      selectedBloc = null;
                      selectedElem = null;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Veuillez sélectionner une commande" : null,
                ),
              ),
            ),

            const SizedBox(height: 10),

            
            if (selectedCommande != null) ...[
              Card(
                color: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.business, color: Colors.grey[600]),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                 Text(
  'Code Affaire : ${selectedCommande!.codeAffaire}\nIntitulé Affaire : ${(selectedCommande!.intituleAffaire != null && selectedCommande!.intituleAffaire!.isNotEmpty) ? selectedCommande!.intituleAffaire! : ''}',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey[700],
    fontWeight: FontWeight.w600,
    height: 1.4, 
  ),
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
),

                    ],
                  ),
                ),
              ),

              Card(
                color: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.grey[600]),
                  title: Text("Site", style: TextStyle(color: Colors.grey[700])),
                  subtitle: Text(
                    selectedCommande!.codeSite,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                ),
              ),
              Card(
                color: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.grey[600]),
                  title: Text("Chargé d'affaire", style: TextStyle(color: Colors.grey[700])),
                  subtitle: Text(
                    selectedCommande!.chargeAffaire,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                ),
              ),
              Card(
                color: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.category, color: Colors.grey[600]),
                  title: Text("Catégorie Chantier", style: TextStyle(color: Colors.grey[700])),
                  subtitle: Text(
                    selectedCommande!.catChantier,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],

            const Divider(thickness: 1, height: 30, color: Colors.grey),

if (selectedCommande != null) ...[
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      "Entreprise",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    ),
  ),
  Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField2<Entreprise>(
        isExpanded: true,
        value: selectedEntreprise,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.apartment, color: Color(0xFF1E3A8A)),
          labelText: "Entreprise",
          labelStyle: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        
        dropdownSearchData: DropdownSearchData(
          
          searchController: _searchController,
          searchInnerWidgetHeight: 50,
          
          searchInnerWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                
                setState(() {});
              },
            ),
          ),

       
          searchMatchFn: (DropdownMenuItem<Entreprise> item, String? searchValue) {
            final q = (searchValue ?? '').toLowerCase().trim();
            if (q.isEmpty) return true; 
            final nom = (item.value?.nom ?? '').toLowerCase();
            return nom.contains(q);
          },
        ),

        
        items: selectedCommande!.entreprises.map((e) {
          return DropdownMenuItem<Entreprise>(
            value: e,
            child: Text(e.nom),
          );
        }).toList(),

        onChanged: (value) {
          setState(() {
            selectedEntreprise = value;
          });
        },
        validator: (value) =>
            value == null ? "Veuillez sélectionner une entreprise" : null,

        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            
            _searchController.clear();
            setState(() {}); 
          }
        },
      ),
    ),
  ),
], const Divider(thickness: 1, height: 30, color: Colors.grey),

            
            if (betons.isNotEmpty) ...[
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      "Famille de béton",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    ),
  ),
  Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField2<ClasseBeton>(
        isExpanded: true,
        value: selectedClasseBeton,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.construction, color: Color(0xFF1E3A8A)),
          labelText: "Classe de béton",
          labelStyle: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),

        
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        
        dropdownSearchData: DropdownSearchData(
          searchController: _searchControllerBeton,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: TextField(
              controller: _searchControllerBeton,
              decoration: InputDecoration(
                hintText: 'Rechercher une classe...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                setState(() {}); 
              },
            ),
          ),

          
          searchMatchFn: (DropdownMenuItem<ClasseBeton> item, String? searchValue) {
            final q = (searchValue ?? '').toLowerCase().trim();
            if (q.isEmpty) return true;
            final label = (item.value?.label ?? '').toLowerCase();
            return label.contains(q);
          },
        ),

        
        items: betons.map((cb) {
          return DropdownMenuItem<ClasseBeton>(
            value: cb,
            child: Text(
              cb.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),

        
        onChanged: (value) {
          setState(() {
            selectedClasseBeton = value;
          });
        },
        validator: (value) =>
            value == null ? "Veuillez sélectionner une classe de béton" : null,

        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            
            _searchControllerBeton.clear();
            setState(() {});
          }
        },
      ),
    ),
  ),
],
          ],
        ),
      ),
    );
  }


Widget _buildStep2() {
  return FormBuilder(
    key: _formKey2,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedCommande != null)
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.account_tree, color: Color(0xFF1E3A8A)),
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Bloc, Partie ouvrage et la localisation de l'essai demandés par le chargé d'affaire :\n",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            "${selectedCommande!.elembloc}, ${selectedCommande!.partieouvrage}, ${selectedCommande!.localisation}",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          ...selections.asMap().entries.map((entry) {
            final index = entry.key;
            final selection = entry.value;

            return Card(
              elevation: 3,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Ajouter l’élément d’ouvrage n°${index + 1}",
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bâtiment / Ouvrage field with validator so the FormBuilder can validate it
                    DropdownButtonFormField<Bloc>(
                      value: selection.bloc,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
                      items: selectedCommande!.blocs.map((b) {
                        return DropdownMenuItem(
                          value: b,
                          child: Text(b.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selection.bloc = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.apartment, color: Color(0xFF1E3A8A)),
                        labelText: "Bâtiment / Ouvrage",
                        labelStyle: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value == null ? "Veuillez sélectionner un bâtiment / ouvrage" : null,
                    ),

                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DropdownButtonFormField2<Elemouvrage>(
                          isExpanded: true,
                          value: selection.elemouvrage,
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.home_repair_service, color: Color(0xFF1E3A8A)),
                            labelText: "Élément Ouvrage",
                            labelStyle: const TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),

                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          dropdownSearchData: DropdownSearchData(
                            searchController: _searchControllerElemOuvrage,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              child: TextField(
                                controller: _searchControllerElemOuvrage,
                                decoration: InputDecoration(
                                  hintText: 'Rechercher un élément...',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            ),

                            searchMatchFn: (DropdownMenuItem<Elemouvrage> item, String? searchValue) {
                              final q = (searchValue ?? '').toLowerCase().trim();
                              if (q.isEmpty) return true;
                              final label = (item.value?.label ?? '').toLowerCase();
                              return label.contains(q);
                            },
                          ),

                          items: [
                            ...selectedCommande!.elemouvrages.map((eo) {
                              return DropdownMenuItem<Elemouvrage>(
                                value: eo,
                                child: Text(
                                  eo.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                            const DropdownMenuItem<Elemouvrage>(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Color(0xFF1E3A8A)),
                                  SizedBox(width: 8),
                                  Text("Ajouter un nouvel élément"),
                                ],
                              ),
                            ),
                          ],

                          onChanged: (value) async {
                            if (value == null) {
                              final newElem = await _showAddElemDialog();
                              if (newElem != null) {
                                setState(() {
                                  selectedCommande!.elemouvrages.add(newElem);
                                  selection.elemouvrage = newElem;
                                });
                              }
                            } else {
                              setState(() {
                                selection.elemouvrage = value;
                              });
                            }
                          },

                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _searchControllerElemOuvrage.clear();
                              setState(() {});
                            }
                          },

                          validator: (value) => value == null
                              ? "Veuillez sélectionner un élément d’ouvrage"
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            selections.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 12),

          if (selectedCommande != null)
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selections.add(BlocElemSelection());
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Ajouter un bloc + élément",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }
Future<Elemouvrage?> _showAddElemDialog() async {
  ElementPredefini? selectedpredfini;
  final axeController = TextEditingController();
  final fileController = TextEditingController();
  final nomElementController = TextEditingController();
  final peidcontroller = TextEditingController();
  final niveauController = TextEditingController();
  final familleController = TextEditingController();
  final TextEditingController _searchControllerElem = TextEditingController(); 
  double niveauValue = 0.0;

  return showDialog<Elemouvrage>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Ajouter un nouvel élément",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  DropdownButtonFormField2<ElementPredefini>(
                    isExpanded: true,
                    value: selectedpredfini,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.layers, color: Color(0xFF1E3A8A)),
                      labelText: "Famille de l'élément",
                      labelStyle: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    
                    dropdownSearchData: DropdownSearchData(
                      searchController: _searchControllerElem,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: TextField(
                          controller: _searchControllerElem,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un élément...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (val) {
                            setStateDialog(() {}); 
                          },
                        ),
                      ),
                      searchMatchFn: (DropdownMenuItem<ElementPredefini> item, String? searchValue) {
                        final q = (searchValue ?? '').toLowerCase().trim();
                        if (q.isEmpty) return true;
                        final label = (item.value?.label ?? '').toLowerCase();
                        return label.contains(q);
                      },
                    ),

                    items: elementPredefini.map((cb) {
                      return DropdownMenuItem<ElementPredefini>(
                        value: cb,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            cb.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setStateDialog(() {
                        selectedpredfini = value;
                      });
                    },

                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _searchControllerElem.clear(); 
                        setStateDialog(() {});
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  
                  TextField(
                    controller: nomElementController,
                    decoration: InputDecoration(
                      labelText: "Nom de l'élément",
                      prefixIcon: const Icon(Icons.label, color: Color(0xFF1E3A8A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: axeController,
                    decoration: InputDecoration(
                      labelText: "Axe",
                      prefixIcon: const Icon(Icons.alt_route, color: Color(0xFF1E3A8A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: fileController,
                    decoration: InputDecoration(
                      labelText: "File",
                      prefixIcon: const Icon(Icons.grid_view, color: Color(0xFF1E3A8A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Color(0xFF1E3A8A)),
                        onPressed: () {
                          setStateDialog(() {
                            niveauValue = double.tryParse(niveauController.text) ?? 0.0;
                            niveauValue -= 0.1;
                            niveauController.text = niveauValue.toStringAsFixed(1);
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: niveauController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Niveau",
                            prefixIcon: const Icon(Icons.stairs, color: Color(0xFF1E3A8A)),
                            helperText:
                                "Pour les éléments verticaux, indiquez la côte de niveau du plancher haut de l'étage concerné",
                            helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF1E3A8A)),
                        onPressed: () {
                          setStateDialog(() {
                            niveauValue = double.tryParse(niveauController.text) ?? 0.0;
                            niveauValue += 0.1;
                            niveauController.text = niveauValue.toStringAsFixed(1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final providedName = nomElementController.text.trim();
                  final elem = Elemouvrage(
                    nom: providedName.isNotEmpty
                        ? providedName
                        : (selectedpredfini?.label ?? "Inconnu"),
                        bloc:axeController.text,
                    //peid: peidcontroller.text,
                    axe: axeController.text,
                    file: fileController.text,
                    niveau: niveauController.text,
                    famille: familleController.text,
                  );
                  Navigator.pop(context, elem);
                },
                child: const Text("Ajouter"),
              ),
            ],
          );
        },
      );
    },
  );
}
Widget _buildStep3() {
  return FormBuilder(
    key: _formKey3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: "date",
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1E3A8A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Date obligatoire" : null,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormBuilderTextField(
                name: "heure",
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Heure",
                  prefixIcon: const Icon(Icons.access_time, color: Color(0xFF1E3A8A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Heure obligatoire" : null,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    timeController.text = pickedTime.format(context);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        
        _buildNumericField(
          label: "Température (°C)",
          controller: tempController,
          step: 2,
          min: -20,
          max: 60,
        ),
        const SizedBox(height: 16),
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Text(
    "Mode de production",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade800,
    ),
  ),
),
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 8),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: DropdownButtonFormField2<ModesProduction>(
      isExpanded: true,
      value: selectedModeProd,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.factory, color: Color(0xFF1E3A8A)),
        labelText: "Mode de production",
        labelStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),

      
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      
      dropdownSearchData: DropdownSearchData(
        searchController: _searchControllerModeProd,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: TextField(
            controller: _searchControllerModeProd,
            decoration: InputDecoration(
              hintText: 'Rechercher un mode...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              setState(() {}); 
            },
          ),
        ),

        
        searchMatchFn: (DropdownMenuItem<ModesProduction> item, String? searchValue) {
          final q = (searchValue ?? '').toLowerCase().trim();
          if (q.isEmpty) return true;
          final label = (item.value?.label ?? '').toLowerCase();
          return label.contains(q);
        },
      ),

      
      items: ModePro.map((cb) {
        return DropdownMenuItem<ModesProduction>(
          value: cb,
          child: Text(
            cb.label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),

      
      onChanged: (value) {
        setState(() {
          selectedModeProd = value;
        });
      },
      validator: (value) => value == null ? "Champ obligatoire" : null,

      
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          _searchControllerModeProd.clear();
          setState(() {});
        }
      },
    ),
  ),
),
const SizedBox(height: 16),
        
        _buildNumericField(
          label: "Affaissement du cône (cm)",
          controller: affaissementController,
          step: 0.1,
          min: 0,
          max: 30,
        ),
        const SizedBox(height: 16),

        
        _buildNumericField(
          label: "Rapport E/C",
          controller: ecController,
          step: 0.1,
          min: 0,
          max: 10,
        ),
        const SizedBox(height: 16),

        
        FormBuilderTextField(
          name: "observations",
          controller: observationController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: "Observations",
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ),
  );
}


Widget _buildNumericField({
  required String label,
  required TextEditingController controller,
  required double step,
  required double min,
  required double max,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
      const SizedBox(height: 6),
      Row(
        children: [
          _buildStepperButton(Icons.remove, () {
            double value = double.tryParse(controller.text) ?? 0.0;
            value = (value - step).clamp(min, max);
            controller.text = value.toStringAsFixed(step < 1 ? 1 : 0);
          }),
          const SizedBox(width: 8),
          Expanded(
            child: FormBuilderTextField(
              name: label,
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
             
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width:  8),
          _buildStepperButton(Icons.add, () {
            double value = double.tryParse(controller.text) ?? 0.0;
            value = (value + step).clamp(min, max);
            controller.text = value.toStringAsFixed(step < 1 ? 1 : 0);
                   }),
        ],
      ),
    ],
  );
}


Widget _buildStepperButton(IconData icon, VoidCallback onPressed) {
  return CircleAvatar(
    backgroundColor: Colors.yellow.shade800,

    child: IconButton(icon: Icon(icon, color: Color(0xFFF9FAFB)), onPressed: onPressed),
  );
}

Widget _buildStep4() {
  return FormBuilder(
    key: _formKey4,
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF9FAFB)),
            onPressed: () {
              _showFormulationsDialog();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text("Consulter les constituants des formulations béton"),
            ),
          ),
          const SizedBox(height: 16),


          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(onPressed: _addGranulas, child: const Text("Granulas")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEB3B)),
                onPressed: _addSable,
                child: const Text("Sables"),
              ),
              ElevatedButton(onPressed: _addCiment, child: const Text("Ciment")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                onPressed: _addAdjuvant,
                child: const Text("Adjuvant"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
                onPressed: _addAdditif,
                child: const Text("Additifs"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                onPressed: _addEau,
                child: const Text("Eau"),
              ),
            ],
          ),

          const SizedBox(height: 18),

        
        if (eau.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text("Eau", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...eau.asMap().entries.map((e) {
            final i = e.key;
            final it = e.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: it['source']?.toString(),
                            decoration: InputDecoration(
                              labelText: "Source d'eau",
                              labelStyle: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (v) => it['source'] = v,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEau(i),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        const Text(
                          "Dosage",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                     Expanded(
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () {
          setState(() {
            int current = int.tryParse(it['dosage']?.toString() ?? "0") ?? 0;
            if (current > 0) current--;
            it['dosage'] = current;
          });
        },
      ),
      Expanded(
        child: TextFormField(
          initialValue: it['dosage']?.toString() ?? "0",
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          onChanged: (value) {
            setState(() {
              it['dosage'] = int.tryParse(value) ?? 0;
            });
          },
        ),
      ),
      IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.green),
        onPressed: () {
          setState(() {
            int current = int.tryParse(it['dosage']?.toString() ?? "0") ?? 0;
            current++;
            it['dosage'] = current;
          });
        },
      ),
    ],
  ),
),
 ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        ],

        
        if (carrieres.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("Granulas", style: TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...granulas.asMap().entries.map((e) {
    final i = e.key;
    final item = e.value;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if (carrieres.isNotEmpty)
           Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 8),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: DropdownButtonFormField2<ClasseCarrieres>(
      isExpanded: true,
      value: item['prov'],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.landscape, color: Color(0xFF1E3A8A)),
        labelText: "Provenance des granulas",
        labelStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),

      
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      
      dropdownSearchData: DropdownSearchData(
        searchController: _searchControllerCarriere,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: TextField(
            controller: _searchControllerCarriere,
            decoration: InputDecoration(
              hintText: 'Rechercher une carrière...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              setState(() {}); 
            },
          ),
        ),

        
        searchMatchFn: (DropdownMenuItem<ClasseCarrieres> item, String? searchValue) {
          final q = (searchValue ?? '').toLowerCase().trim();
          if (q.isEmpty) return true;
          final label = (item.value?.label ?? '').toLowerCase();
          return label.contains(q);
        },
      ),

      
      items: carrieres.map((cb) {
        return DropdownMenuItem<ClasseCarrieres>(
          value: cb,
          child: Text(
            cb.label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),

      
      onChanged: (value) {
        setState(() {
          item['prov'] = value;
        });
      },

      
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          _searchControllerCarriere.clear();
          setState(() {});
        }
      },

      
      validator: (value) =>
          value == null ? "Veuillez sélectionner une carrière" : null,
    ),
  ),
),
const SizedBox(height: 8),


            Row(
              children: [
               Expanded(
  child: Row(
    children: [

      const Text(
        "Dosage",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),

      Expanded(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  int current = item['dosage'] ?? 0;
                  if (current > 0) current--;
                  item['dosage'] = current;
                });
              },
            ),
            Expanded(
              child: Text(
                "${item['dosage'] ?? 0}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setState(() {
                  int current = item['dosage'] ?? 0;
                  current++;
                  item['dosage'] = current;
                });
              },
            ),
          ],
        ),
      ),
    ],
  ),
),

                const SizedBox(width: 8),


Expanded(
  child: Row(
    children: [
      const Text(
        "Dmin (mm)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  int current = int.tryParse(item['dmin']?.toString() ?? "0") ?? 0;
                  if (current > 0) current--;
                  item['dmin'] = current;
                });
              },
            ),
            Expanded(
              child: Text(
                "${item['dmin'] ?? 0}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setState(() {
                  int current = int.tryParse(item['dmin']?.toString() ?? "0") ?? 0;
                  current++;
                  item['dmin'] = current;
                });
              },
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(width: 8),


Expanded(
  child: Row(
    children: [
      const Text(
        "Dmax (mm)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  int current = int.tryParse(item['dmax']?.toString() ?? "0") ?? 0;
                  if (current > 0) current--;
                  item['dmax'] = current;
                });
              },
            ),
            Expanded(
              child: Text(
                "${item['dmax'] ?? 0}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setState(() {
                  int current = int.tryParse(item['dmax']?.toString() ?? "0") ?? 0;
                  current++;
                  item['dmax'] = current;
                });
              },
            ),
          ],
        ),
      ),
    ],
  ),
),

              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteGranulas(i),
              ),
            )
          ],
        ),
      ));
    }).toList(),
],
if (sables.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text(
    "Sables",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 8),

  ...sables.asMap().entries.map((e) {
    final i = e.key;
    final it = e.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if (carrieres.isNotEmpty)
              SearchableDropdown<ClasseCarrieres>(
                value: it['prov'],
                items: carrieres,
                labelBuilder: (cb) => cb.label,
                labelText: "Provenance des sables",
                icon: Icons.landscape,
                searchHint: "Rechercher une carrière...",
                onChanged: (value) {
                  setState(() {
                    it['prov'] = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez sélectionner une carrière" : null,
              ),

            const SizedBox(height: 8),

            Row(
              children: [
                
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "Dosage",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  int current = it['dosage'] ?? 0;
                                  if (current > 0) current--;
                                  it['dosage'] = current;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "${it['dosage'] ?? 0}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  int current = it['dosage'] ?? 0;
                                  current++;
                                  it['dosage'] = current;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "Dmax (mm)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  int current = it['dmax'] ?? 0;
                                  if (current > 0) current--;
                                  it['dmax'] = current;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "${it['dmax'] ?? 0}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  int current = it['dmax'] ?? 0;
                                  current++;
                                  it['dmax'] = current;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteSable(i),
              ),
            ),
          ],
        ),
      ),);
    }).toList(),
]
,

    if (ciment.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("Ciment", style: TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...ciment.asMap().entries.map((e) {
    final i = e.key;
    final it = e.value;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: it['prov']?.toString(),
                    decoration: const InputDecoration(labelText: "Provenance du ciment *"),
                    onChanged: (v) => it['prov'] = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCiment(i),
                ),
              ],
            ),
            const SizedBox(height: 8),
          Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    
  Expanded(
  flex: 2,
  child: StatefulBuilder(
    builder: (context, setInnerState) {
      List<TypeCiments> filteredList = List.from(typeciment);
      TextEditingController searchController = TextEditingController();

      return DropdownButtonFormField<TypeCiments>(
        isExpanded: true,
        value: it['type'],
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
        decoration: InputDecoration(
          labelText: "Type ciment",
          labelStyle: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) =>
            value == null ? "Veuillez sélectionner un type" : null,
        items: filteredList.map((cb) {
          return DropdownMenuItem<TypeCiments>(
            value: cb,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                cb.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            it['type'] = value;
          });
        },
        selectedItemBuilder: (context) {
          return filteredList.map((cb) {
            return Text(
              cb.label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList();
        },
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  "Rechercher un type de ciment",
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: StatefulBuilder(
                  builder: (context, setDialogState) {
                    return SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Rechercher...",
                              prefixIcon: const Icon(Icons.search,
                                  color: Color(0xFF1E3A8A)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                filteredList = typeciment
                                    .where((cb) => cb.label
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final cb = filteredList[index];
                                return ListTile(
                                  title: Text(
                                    cb.label,
                                    style: const TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      it['type'] = cb;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    },
  ),
),

    const SizedBox(width: 12),

    
    Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dosage",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      int current = it['dosage'] ?? 0;
                      if (current > 0) current--;
                      it['dosage'] = current;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "${it['dosage'] ?? 0}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      int current = it['dosage'] ?? 0;
                      current++;
                      it['dosage'] = current;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
)
],
        ),
      ),
    );
  }).toList(),

],

    if (adjuvant.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("ADJUVANT", style: TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...adjuvant.asMap().entries.map((e) {
    final i = e.key;
    final it = e.value;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: it['prov']?.toString(),
                    decoration: const InputDecoration(labelText: "Nom du produit "),
                    onChanged: (v) => it['prov'] = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAdjuvant(i),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
               Expanded(
  child: SearchableDropdown<TypeAdjuvants>(
    value: it['type'],
    items: typeAdjuvant,
    labelBuilder: (cb) => cb.label,
    onChanged: (value) {
      setState(() {
        it['type'] = value;
      });
    },
    labelText: "Type d’adjuvant",
    icon: Icons.science,
    searchHint: "Rechercher un type d’adjuvant...",
    validator: (value) =>
        value == null ? "Veuillez sélectionner un type" : null,
  ),
),
const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "Dosage",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  int current = it['dosage'] ?? 0;
                                  if (current > 0) current--;
                                  it['dosage'] = current;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "${it['dosage'] ?? 0}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  int current = it['dosage'] ?? 0;
                                  current++;
                                  it['dosage'] = current;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
    }).toList(),

],
         if (additifs.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAdditifs(),
          ] ]
    ),
  ));
}





 bool age1Enabled = false;
  bool age2Enabled = false;
 bool age3Enabled = false;
  bool age4Enabled = false;
  bool age5Enabled = false;


Widget _buildStep5() {
  if (selectedCommande == null) {
    return const Center(
      child: Text(
        "Aucune commande sélectionnée pour l'instant.",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  
  
  
  
  
        
  
  
  
  
  
  

  

        
  
  
  
  
  
  

  

        
  
  
  
  
  
  
  
  
  



return FormBuilder(
  key: _formKey5,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: selectedCommande != null
        ? _buildAgeCards(selectedCommande!)
        : [], 
  ));
}


Widget _buildAgeCard({
  required String label,
  required String age,
  required bool enabled,
  required ValueChanged<bool> onToggle,
}) {
  
  bool showMotif = !enabled;
  int nbEchantillons = 3;
  TypeEprouvettes? selectedTypeEprouvettes;

  return Card(
    color: Colors.grey[100],
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label : $age", style: const TextStyle(fontSize: 14)),

          
          SwitchListTile(
            title: const Text("Le prélèvement a-t-il été réalisé ?"),
            value: enabled,
            onChanged: (value) {
              onToggle(value);
              
              setState(() {
                showMotif = !value;
              });
            },
          ),

          
          if (showMotif)
            Column(
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Motif de non réalisation",
                    labelStyle: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    
                  },
                  validator: (value) {
                    if (showMotif && (value == null || value.isEmpty)) {
                      return "Veuillez saisir un motif";
                    }
                    return null;
                  },
                ),
              ],
            ),

          if (enabled)
            Column(
              children: [
                const SizedBox(height: 12),
                DropdownButtonFormField<TypeEprouvettes>(
                  value: selectedTypeEprouvettes,
                  items: typeEprouvette.map((cb) {
                    return DropdownMenuItem(
                      value: cb,
                      child: Text(
                        cb.label,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTypeEprouvettes = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Type Eprouvette ",
                    labelStyle: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? "Veuillez sélectionner un type" : null,
                ),

                const SizedBox(height: 12),


                DropdownButtonFormField<int>(
                  value: nbEchantillons,
                  items: const [
                    DropdownMenuItem(value: 3, child: Text("3 ")),
                    DropdownMenuItem(value: 6, child: Text("6 ")),
                    DropdownMenuItem(value: 9, child: Text("9 ")),
                    DropdownMenuItem(value: 12, child: Text("12 ")),
                    DropdownMenuItem(value: 15, child: Text("15 ")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      nbEchantillons = value ?? 3;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Nombre d'éprouvettes *",
                    labelStyle: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

  
Future<void> _storeData() async {
  if (!_formKey1.currentState!.saveAndValidate() ||
      !_formKey2.currentState!.saveAndValidate() ||
      !_formKey3.currentState!.saveAndValidate() ||
      !_formKey4.currentState!.saveAndValidate() ||
      !_formKey5.currentState!.saveAndValidate()) {
    return;
  }

 

  try {
       // Résolution peId : priorité -> lastServerPeId+1  / map commandePeIds / fallback selectedCommande.peId / sinon local_
      String peId;
      if (lastServerPeId != null) {
        peId = _incrementPeId(lastServerPeId!);
        debugPrint('storeData: incrementing lastServerPeId $lastServerPeId -> $peId');
        // Mettre à jour en mémoire pour éviter doublons locaux successifs
        _updateLastServerPeId(peId);
      } else {
        final key = selectedCommande?.codeCommande?.toString() ?? selectedCommande?.numCommande?.toString();
        if (key != null && key.isNotEmpty && commandePeIds.containsKey(key)) {
          peId = commandePeIds[key]!;
          debugPrint('storeData: using commandePeIds[$key] -> $peId');
          _updateLastServerPeId(peId);
        } else {
          final cand = (selectedCommande != null) ? (selectedCommande!.peId?.toString() ?? '') : '';
          if (cand.isNotEmpty) {
            peId = cand;
            debugPrint('storeData: using selectedCommande.peId -> $peId');
            _updateLastServerPeId(peId);
          } else {
            peId = 'local_${DateTime.now().millisecondsSinceEpoch}';
            debugPrint('storeData: no server pe_id available, generating local peId -> $peId');
          }
        }
      }
       debugPrint('storeData: resolved peId=$peId for selectedCommande=${selectedCommande?.codeCommande ?? selectedCommande?.numCommande}');
       
      final bool isSynced = !(peId.startsWith('local_'));
      if (isSynced) {
        try {
          lastServerPeId = peId;

          // On force exactement 7 chiffres à la fin pour être strict et éviter les anciens bugs
          final re = RegExp(r'(\d{7})$');
          final m = re.firstMatch(peId);

          if (m != null) {
            final numStr = m.group(1)!;               // ex: "0000030"
            lastServerPeNumeric = int.parse(numStr);  // → 30 (type int)
          } else {
            // Si pour une raison quelconque le peId n'a pas 7 chiffres, on met null
            // (ça ne devrait jamais arriver si tu génères correctement les IDs)
            lastServerPeNumeric = null;
            debugPrint('Warning: persisted peId has invalid format (not 7 digits): $peId');
          }

          await _secureStorage.write(key: 'last_server_pe_id', value: peId);
          debugPrint('storeData: persisted last_server_pe_id = $peId (numeric: $lastServerPeNumeric)');
        } catch (e) {
          debugPrint('storeData: failed to persist last_server_pe_id -> $e');
        }
      }


 debugPrint('storeData: resolved peId=$peId for selectedCommande=${selectedCommande?.codeCommande ?? selectedCommande?.numCommande}');
      
    

    final interventionData = {
          'pe_id': peId,
            'pe_date': (() {
        final input = dateController.text.trim();
        DateTime? dt;
        if (input.contains('/')) {
          final parts = input.split('/');
          if (parts.length == 3) {
            try {
              dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            } catch (_) { dt = null; }
          }
        } else {
          try { dt = DateTime.parse(input); } catch (_) { dt = null; }
        }
        return dt != null ? dt.toIso8601String().split('T').first : input;
      })(),
      'pe_heure': timeController.text,
      'pe_temp': double.tryParse(tempController.text) ?? 20.0,
      'pe_affais_cone': double.tryParse(affaissementController.text) ?? 0.0,
      'pe_cim_ec': double.tryParse(ecController.text) ?? 0.5,
      'pe_obs': observationController.text,
      'pe_mode_prod': selectedModeProd?.value,
      'Code_Affaire': selectedCommande?.codeAffaire,
      'Code_Site': selectedCommande?.codeSite,
      'commande_id': selectedCommande?.numCommande,
      'entreprise_id': selectedEntreprise?.code,
      'classe_beton_id': selectedClasseBeton?.value,
      'charge_affaire_id': selectedCommande?.chargeAffaire,
      'intitule_affaire': selectedCommande?.intituleAffaire,
      'categorie_chantier': selectedCommande?.catChantier,
      'entreprise_real': selectedEntreprise?.nom,
       'is_synced': isSynced ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await LocalDatabase.saveIntervention(interventionData);
  try {
final Map<String, dynamic> cmdRef = {
  'pe_id': peId,
  'codeCommande': selectedCommande?.codeCommande?.toString() ?? selectedCommande?.numCommande?.toString(),
  'num_commande': selectedCommande?.numCommande?.toString(),
  'NumCommande': selectedCommande?.numCommande?.toString(),
  'elembloc': selectedCommande?.elembloc?.toString() ?? '',
  'codeSite': selectedCommande?.codeSite?.toString() ?? '',
  'bloc': selectedCommande?.elembloc?.toString() ?? '', // Utilise elembloc pour bloc
  'Code_Affaire': selectedCommande?.codeAffaire?.toString() ?? '',
  'Code_Site': selectedCommande?.codeSite?.toString() ?? '',
  'ChargedAffaire': selectedCommande?.chargeAffaire?.toString() ?? '',
  'partie_ouvrage': selectedCommande?.partieOuvrage?.toString() ?? '',
  'pe_date_pv': selectedCommande?.peDatePv?.toString() ?? '',
  'localisation': selectedCommande?.localisation?.toString() ?? '',
  'age1': selectedCommande?.age1 ?? 0,
  'age2': selectedCommande?.age2 ?? 0,
  'age3': selectedCommande?.age3 ?? 0,
  'age4': selectedCommande?.age4 ?? 0,
  'age5': selectedCommande?.age5 ?? 0,
  'created_at': DateTime.now().toIso8601String(),
  'updated_at': DateTime.now().toIso8601String(),
};
   
if (selectedCommande != null) {
  await LocalDatabase.saveCommandeRefForIntervention(peId, selectedCommande!);
}

  debugPrint('storeData: saved interventions_recu for peId=$peId');

  // Optionnel : lecture pour vérification
  final rows = await LocalDatabase.getCommandesRefByPeId(peId);
  debugPrint('storeData: interventions_recu rows for $peId -> ${rows.length}');
} catch (e) {
  debugPrint('storeData: failed to save interventions_recu -> $e');
}
    // 2. Sauvegarder les éléments d'ouvrage
    final elementsOuvrage = selections
        .where((s) => s.elemouvrage != null)
        .map((s) => Elemouvrage(
              nom: s.elemouvrage!.nom,
              axe: s.elemouvrage!.axe ?? '',
              file: s.elemouvrage!.file ?? '',
              niveau: s.elemouvrage!.niveau ?? '0.0',
              //peid: s.elemouvrage!.peid ?? '',
              bloc: s.bloc?.label ?? '',
              famille: s.elemouvrage!.famille ?? '',
              partieOuvrage: s.elemouvrage!.partieOuvrage,
            ))
        .toList();

    await LocalDatabase.saveElementsOuvrage(peId, elementsOuvrage);

    // 3. Sauvegarder les constituants
    final allConstituants = <Map<String, dynamic>>[];

    // Granulas
    for (var granula in granulas) {
      allConstituants.add({
        'type': 'granulas',
        'dosage': granula['dosage'],
        'prov': granula['prov'] is ClasseCarrieres 
            ? granula['prov'].label 
            : granula['prov']?.toString(),
        'dmin': granula['dmin'],
        'dmax': granula['dmax'],
        'nomProduit': 'Granulat',
      });
    }

    // Sables
    for (var sable in sables) {
      allConstituants.add({
        'type': 'sables',
        'dosage': sable['dosage'],
        'prov': sable['prov'] is ClasseCarrieres 
            ? sable['prov'].label 
            : sable['prov']?.toString(),
        'dmax': sable['dmax'],
        'nomProduit': 'Sable',
      });
    }

    // Ciment
    for (var cim in ciment) {
      allConstituants.add({
        'type': 'ciment',
        'dosage': cim['dosage'],
        'prov': cim['prov']?.toString(),
        'nomProduit': 'Ciment',
      });
    }

    // Adjuvant
    for (var adj in adjuvant) {
      allConstituants.add({
        'type': 'adjuvant',
        'dosage': adj['dosage'],
        'prov': adj['prov']?.toString(),
        'nomProduit': 'Adjuvant',
      });
    }

    // Additifs
    for (var add in additifs) {
      allConstituants.add({
        'type': 'additif',
        'dosage': add['dosage'],
        'prov': add['nomProduit']?.toString() ?? 'Additif',
        'nomProduit': add['nomProduit'] ?? 'Additif',
      });
    }


    for (var water in eau) {
      allConstituants.add({
        'type': 'eau',
        'dosage': water['dosage'],
        'prov': water['source']?.toString() ?? 'Eau',
        'nomProduit': 'Eau',
      });
    }

    await LocalDatabase.saveConstituants(peId, allConstituants);

    final seriesEprouvettes = <Map<String, dynamic>>[];
    
    
    if (age1Enabled && selectedTypeEprouvettes != null) {
      seriesEprouvettes.add({
        'Age': selectedCommande?.age1?.toString(),
        'Forme': selectedTypeEprouvettes?.label,
        'NbrEchantillion': nbEchantillons,
        'eprouvettes': List.generate(nbEchantillons, (index) => {
          'epr_id': 'EPR_${peId}_${index + 1}',
          'type_label': selectedTypeEprouvettes?.label,
        }),
      });
    }

    await LocalDatabase.saveEprouvettes(peId, seriesEprouvettes);

    // 5. Sauvegarder les motifs de non prélèvement
    final motifsNonPrelevement = <String?>[];
    // Adaptez selon votre logique pour les motifs
    if (!age1Enabled) motifsNonPrelevement.add("Motif de non réalisation");
    
    await LocalDatabase.saveMotifsNonPrelevement(peId, motifsNonPrelevement);

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Intervention sauvegardée localement (ID: $peId)'),
       
        backgroundColor: Colors.green,
      ),
    ); print ("peidddddddddddddddddddddddddddd,$peId");
     print ("code commande ,${selectedCommande!.codeCommande}");
await _testRetrieveData(peId);
    // Rediriger ou réinitialiser le formulaire
    Navigator.of(context).pop(peId);

  } catch (e) {
    debugPrint('Erreur sauvegarde intervention: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la sauvegarde: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// Méthode pour tester la récupération des données
Future<void> _testRetrieveData(String peId) async {
  try {
    final intervention = await LocalDatabase.getIntervention(peId);
    final elements = await LocalDatabase.getElementsOuvrage(peId);
    final constituants = await LocalDatabase.getConstituants(peId);
    final eprouvettes = await LocalDatabase.getSeriesEprouvettes(peId);

    debugPrint('Intervention: $intervention');
    debugPrint('Éléments ouvrage: ${elements.length}');
    debugPrint('Constituants: ${constituants.length}');
    debugPrint('Éprouvettes: ${eprouvettes.length}');
  } catch (e) {
    debugPrint('Erreur récupération données: $e');
  }
}
}
class Interventions {
final List<Commande> commandes;
final List<ClasseBeton> betons;
final List<ElementPredefini> elementPredefini;
final List<ModesProduction> modePro;
final List<ClasseCarrieres> carrieres;
final List<TypeCiments> typeciment;
final List<TypeAdjuvants> typeAdjuvants;
final List<TypeEprouvettes> typeEprouvette;
  Interventions({required this.commandes, required this.betons, required this.elementPredefini, required this.modePro, required this.carrieres, required this.typeciment, required this.typeAdjuvants, required this.typeEprouvette});
}
