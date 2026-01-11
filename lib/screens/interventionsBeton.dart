import 'dart:convert';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:mgtrisque_visitepreliminaire/models/intervention.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/interventions.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart' as sync;
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';


class InterventionsPage extends StatefulWidget {

  final Map<String, dynamic> commandeData;
    final bool canEdit;
  const InterventionsPage({
    Key? key,
    required this.canEdit,
    required this.commandeData, 
  }) : super(key: key);

  @override
  _InterventionsPageState createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
bool get isReadOnly {
  
  final validationLabo = widget.commandeData['Validation_labo'];
  final int? validationValue = int.tryParse(validationLabo?.toString() ?? '');
  
  
  final isDraft = validationValue == 0 || validationValue == null;
  
  
  return !widget.canEdit && !isDraft;
}
  int _currentStep = 0;
  bool isLoading = false;

    String? pe_id;
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
  final List<TextEditingController> motifControllers = List.generate(
    5, 
    (index) => TextEditingController()
  );
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

  String classeBetonLabel = 'Non spécifié';
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

 Future<void> _loadOfflineReferenceData() async {
    try {
      print('📱 Chargement des données de référence en mode offline...');
      
      // 1. Modes de production
      final localModes = await LocalDatabase.getTableData(tableName: 'modes_production_ref');
      setState(() {
        ModePro = localModes.map((m) => ModesProduction.fromJson(m)).toList();
        print('✅ Modes de production chargés: ${ModePro.length}');
      });
      
      // 2. Carrières (provenance)
      final localCarrieres = await LocalDatabase.getTableData(tableName: 'carrieres_ref');
      setState(() {
        carrieres = localCarrieres.map((c) => ClasseCarrieres.fromJson(c)).toList();
        print('✅ Carrières chargées: ${carrieres.length}');
      });
      
      // 3. Types d'éprouvettes
      final localEprouvettes = await LocalDatabase.getTableData(tableName: 'types_eprouvette_ref');
      setState(() {
        typeEprouvette = localEprouvettes.map((t) => TypeEprouvettes.fromJson(t)).toList();
        print('✅ Types éprouvettes chargés: ${typeEprouvette.length}');
      });
      
      // 4. Types de ciment
      final localCiments = await LocalDatabase.getTableData(tableName: 'types_ciment_ref');
      setState(() {
        typeciment = localCiments.map((c) => TypeCiments.fromJson(c)).toList();
        print('✅ Types ciment chargés: ${typeciment.length}');
      });
      
      // 5. Types d'adjuvant
      final localAdjuvants = await LocalDatabase.getTableData(tableName: 'types_adjuvant_ref');
      setState(() {
        typeAdjuvant = localAdjuvants.map((a) => TypeAdjuvants.fromJson(a)).toList();
        print('✅ Types adjuvant chargés: ${typeAdjuvant.length}');
      });
      
      // 6. Classes béton
      final localBetons = await LocalDatabase.getTableData(tableName: 'classes_beton_ref');
      setState(() {
        betons = localBetons.map((b) => ClasseBeton.fromJson(b)).toList();
        print('✅ Classes béton chargées: ${betons.length}');
      });
      
      // 7. Éléments prédéfinis
      final localElements = await LocalDatabase.getTableData(tableName: 'elements_predefinis_ref');
      setState(() {
        elementPredefini = localElements.map((e) => ElementPredefini.fromJson(e)).toList();
        print('✅ Éléments prédéfinis chargés: ${elementPredefini.length}');
      });
      
    } catch (e) {
      print('❌ Erreur lors du chargement des données de référence offline: $e');
    }
  }
Future<Elemouvrage?> _showAddElemDialog() async {
  ElementPredefini? selectedpredfini;
  final axeController = TextEditingController();
  final fileController = TextEditingController();
  final peidcontroller= TextEditingController();
  final niveauController = TextEditingController();
  final familleController = TextEditingController();
    final blocController = TextEditingController();
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
            title: Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Color(0xFF1E3A8A)),
                SizedBox(width: 8),
                Text(
                  "Nouvel élément",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  DropdownButtonFormField<ElementPredefini>(
                    value: selectedpredfini,
                    items: elementPredefini.map((cb) {
                      return DropdownMenuItem(
                        value: cb,
                        child: Text(cb.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() => selectedpredfini = value);
                    },
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.layers, color: Color(0xFF1E3A8A)),
                      labelText: "Classe Béton",
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
                  ),

                  const SizedBox(height: 12),

                  
                  TextField(
                    controller: axeController,
                    decoration: InputDecoration(
                      labelText: "Axe",
                      prefixIcon:
                          const Icon(Icons.alt_route, color: Color(0xFF1E3A8A)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  TextField(
                    controller: fileController,
                    decoration: InputDecoration(
                      labelText: "File",
                      prefixIcon:
                          const Icon(Icons.grid_view, color: Color(0xFF1E3A8A)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Color(0xFF1E3A8A)),
                        onPressed: () {
                          setStateDialog(() {
                            niveauValue =
                                double.tryParse(niveauController.text) ?? 0.0;
                            niveauValue -= 0.1;
                            niveauController.text =
                                niveauValue.toStringAsFixed(1);
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: niveauController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Niveau",
                            prefixIcon:
                                const Icon(Icons.stairs, color: Color(0xFF1E3A8A)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF1E3A8A)),
                        onPressed: () {
                          setStateDialog(() {
                            niveauValue =
                                double.tryParse(niveauController.text) ?? 0.0;
                            niveauValue += 0.1;
                            niveauController.text =
                                niveauValue.toStringAsFixed(1);
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
                  backgroundColor: Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final elem = Elemouvrage(
                    nom: selectedpredfini?.label ?? "Inconnu",
                    bloc: blocController.text,
                    axe: axeController.text,
                    file: fileController.text,
                    //peid: peidcontroller.text,
                    niveau: niveauController.text,
                    famille : familleController.text,
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



String _formatChargeAffaire(Map<String, dynamic>? chargeAffaire) {
  if (chargeAffaire == null) return 'Non spécifié';
  
  final matricule = chargeAffaire['Matricule'] ?? 'N/A';
  final nom = chargeAffaire['Nom'] ?? '';
  final prenom = chargeAffaire['Prénom'] ?? '';
  
  final nomComplet = '$nom $prenom'.trim();
  return nomComplet.isNotEmpty ? '$matricule - $nomComplet' : matricule;
}

  String? selectedAffaissement;
  Commande? selectedCommande;
  Intervention? selectedIntervention;
  Entreprise? selectedEntreprise;
  ClasseBeton? selectedClasseBeton;
  ElementPredefini? selectedpredfini;
  ModesProduction? selectedModeProd;
  ClasseCarrieres? selectedCarrieres;
  TypeCiments? selectedTypeCiments;
  TypeAdjuvants?selectedTypeAdjuvants;
  TypeEprouvette?selectedTypeEprouvettes;
  Bloc? selectedBloc;
  Elemouvrage? selectedElem;
  FamillePred?selectedFamil;
Map<String, dynamic>? intervention;
Map<String, dynamic>? affaire;
Map<String, dynamic>? interventionuser;
Map<String, dynamic>? chargeAffaire;
  List<Commande> commandes = [];
  List<ClasseBeton> betons = [];
  List<Elemouvrage> elementsouvrages = [];
  List<ElementPredefini> elementPredefini = [];
  List<ModesProduction> ModePro = [];
  List<ClasseCarrieres> carrieres = [];
  List<TypeCiments> typeciment = [];
  List<TypeAdjuvants> typeAdjuvant = [];
  List<TypeEprouvettes> typeEprouvette = [];
List<Constituant> constituants = [];
  List<Map<String, dynamic>> granulas = [];
  List<Map<String, dynamic>> eau = [];
  List<Map<String, dynamic>> sables = [];
  List<Map<String, dynamic>> ciment = [];
  List<Map<String, dynamic>> adjuvant = [];
  List<Map<String, dynamic>> additifs = [];
  List<Elemouvrage?> selectedElems = [];
List<BlocElemSelection> selections = [];
List<Eprouvette> eprouvettes = [];
List<Map<String, dynamic>> series = [];
 List<FamillePred> famillePred= [];
final List<bool> _prelevements = [false, false, false, false, false];
final List<String> _optionsNbrEchantillon = ["1", "2", "3", "4", "5"];
final List<String> prelevements = [
  "Carotte",
  "Béton frais",
  "Granulat",
];

int nbEchantillons = 0; 
void _addEau() {
  setState(() {
    eau.add({"source": "", "dosage": ""});
  });
}
Future<String> _getCarriereLabel(String provenanceValue) async {
  if (provenanceValue.isEmpty) return 'Non spécifié';

  try {
    print('DEBUG: Appel de _getCarriereLabel avec provenanceValue=$provenanceValue');
    final result = await LocalDatabase.getTableData(
      tableName: 'carrieres_ref',
      where: 'id = ?',
      whereArgs: [provenanceValue],
    );

    if (result.isNotEmpty && result.first['label'] != null) {
      final label = result.first['label']!.toString();
      print('DEBUG: Label trouvé pour provenanceValue=$provenanceValue: $label');
      return label;
    } else {
      print('DEBUG: Aucun label trouvé pour provenanceValue=$provenanceValue');
      return 'Non spécifié';
    }
  } catch (e) {
    print('❌ Erreur dans _getCarriereLabel pour provenanceValue=$provenanceValue: $e');
    return 'Erreur de chargement';
  }
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
                            it['dosage'] = int.tryParse(v) ?? 0;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          )
        );
        }),
    ],
  );
}
  
  
  
  bool _validateAllForms() {
    final formKeys = [_formKey1, _formKey2, _formKey3, _formKey4, _formKey5];
    bool allValid = true;

    for (int i = 0; i < formKeys.length; i++) {
      final formKey = formKeys[i];
      if (formKey.currentState != null) {
        if (!formKey.currentState!.validate()) {
          print("❌ Formulaire ${i + 1} invalide");
          allValid = false;
          
          if (_currentStep != i) {
            setState(() => _currentStep = i);
          }
          break;
        } else {
          formKey.currentState!.save();
          print("✅ Formulaire ${i + 1} valide");
        }
      }
    }

    return allValid;
  }

  
  
  
  Map<String, dynamic> _prepareInterventionData() {
    return {
      'Code_Site':selectedCommande?.codeSite,
      'pe_date': dateController.text,
      
      'pe_heure': timeController.text,
      'pe_temp': double.tryParse(tempController.text) ?? 20.0,
      'pe_affais_cone': double.tryParse(affaissementController.text),
      'pe_cim_ec': double.tryParse(ecController.text) ?? 0.5,
      'pe_obs': observationController.text,
      'pe_mode_prod': selectedModeProd?.value,
      'classeBeton': selectedClasseBeton?.value?.toString(),
      'entreprise_real': selectedEntreprise?.nom,
      'catChantier': intervention?['catChantier'],
      'commande_id': selectedCommande?.numCommande,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  
  
  
  List<Map<String, dynamic>> _prepareConstituants() {
    final allConstituants = <Map<String, dynamic>>[];

       for (final granula in granulas) {
      final provObj = granula['prov'];
      final provValue = provObj is ClasseCarrieres ? provObj.value?.toString() : provObj?.toString();
      final provLabel = provObj is ClasseCarrieres ? provObj.label?.toString() : provObj?.toString();
      allConstituants.add({
        'type': 'granulas',
        'fb_provenance': provValue ?? '',
        'prov_label': provLabel ?? '',
        'prov': provValue ?? '', 
        'dosage': granula['dosage'] ?? 0,
        'dmin': granula['dmin'] ?? 0,
        'dmax': granula['dmax'] ?? 0,
      });
    }

    
    for (final sable in sables) {
      final provObj = sable['prov'];
      final provValue = provObj is ClasseCarrieres ? provObj.value?.toString() : provObj?.toString();
      final provLabel = provObj is ClasseCarrieres ? provObj.label?.toString() : provObj?.toString();
      allConstituants.add({
        'type': 'sables',
        'fb_provenance': provValue ?? '',
        'prov_label': provLabel ?? '',
        'prov': provValue ?? '',
        'dosage': sable['dosage'] ?? 0,
        'dmax': sable['dmax'] ?? 0,
      });
    }

    
    for (final cim in ciment) {
      allConstituants.add({
        'type': 'ciment',
        'prov': cim['prov']?.toString(),
        'dosage': cim['dosage'] ?? 0,
        'type_ciment': cim['type']?.value?.toString(),
      });
    }

    
    for (final adj in adjuvant) {
      allConstituants.add({
        'type': 'adjuvant',
        'prov': adj['prov']?.toString(),
        'dosage': adj['dosage'] ?? 0,
        'type_adjuvant': adj['type']?.value?.toString(),
      });
    }

    
    for (final add in additifs) {
      allConstituants.add({
        'type': 'additif',
        'nomProduit': add['nomProduit']?.toString(),
        'dosage': add['dosage'] ?? 0,
        'type_additif': add['type']?.toString(),
      });
    }

    
    for (final e in eau) {
      allConstituants.add({
        'type': 'eau',
        'source': e['source']?.toString(),
        'dosage': e['dosage'] ?? 0,
      });
    }

    print("📊 Constituants préparés: ${allConstituants.length}");
    return allConstituants;
  }

  
  
  
  List<Map<String, dynamic>> _prepareSeriesData() {
    final seriesData = <Map<String, dynamic>>[];

    for (int i = 0; i < series.length; i++) {
      final serie = series[i];
      seriesData.add({
        'Age': serie['Age']?.toString(),
        'Forme': serie['Forme']?.toString(),
        'NbrEchantillion': serie['NbrEchantillion']?.toString(),
        'eprouvettes': serie['eprouvettes'] ?? [],
        'serie_order': i,
      });
    }

    print("📊 Séries préparées: ${seriesData.length}");
    return seriesData;
  }

  
  
  
  List<String?> _getMotifsNonPrelevement() {
    final motifs = List.generate(5, (index) {
      final motif = motifControllers[index].text.trim();
      return motif.isEmpty ? null : motif;
    });

    print("📊 Motifs non prélèvement: ${motifs.where((m) => m != null).length}");
    return motifs;
  }

  
  
  
  void _saveAsDraft() async {
    if (!_validateAllForms()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de sauvegarder'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await InterventionsService().saveInterventionAsDraft(
        peId: pe_id!,
        interventionData: _prepareInterventionData(),
        elementsOuvrage: elementsouvrages,
        constituants: _prepareConstituants(),
        seriesEprouvettes: _prepareSeriesData(),
        motifsNonPrelevement: _getMotifsNonPrelevement(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brouillon sauvegardé localement avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _validateIntervention() async {
    if (!_validateAllForms()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de valider'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final shouldValidate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider l\'intervention'),
        content: const Text('Êtes-vous sûr de vouloir valider définitivement cette intervention ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (shouldValidate != true) return;

    setState(() => isLoading = true);

    try {
      await InterventionsService().validateIntervention(
        peId: pe_id!,
        interventionData: _prepareInterventionData(),
        elementsOuvrage: elementsouvrages,
        constituants: _prepareConstituants(),
        seriesEprouvettes: _prepareSeriesData(),
        motifsNonPrelevement: _getMotifsNonPrelevement(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intervention validée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      
      await _reloadInterventionData();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la validation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
String partieOuvrageDesignation = 'Non spécifié';

Future<void> loadPartieOuvrageDesignation(String peId) async {
  try {
    // Récupération de la colonne partie_ouvrage depuis la table locale interventions_recu
    final Map<String, dynamic>? result = await LocalDatabase.querySingle(
      table: 'interventions_recu',
      where: 'pe_id = ?',
      whereArgs: [peId],
    );

    if (result != null && result['partie_ouvrage'] != null) {
      // Décodage de la chaîne JSON
      final Map<String, dynamic> json = jsonDecode(result['partie_ouvrage']);
      partieOuvrageDesignation = json['designation']?.toString() ?? 'Non spécifié';
    }
  } catch (e) {
    print('Erreur lors de la récupération de partie_ouvrage.designation: $e');
    partieOuvrageDesignation = 'Non spécifié';
  }
}
  Future<void> _reloadInterventionData() async {
    try {
      final updated = await InterventionsService().getLocalIntervention(pe_id!);
      if (updated != null) {
        setState(() {
          intervention = updated;
        });
        print("🔄 Données rechargées - Statut: ${updated['Validation_labo']}");
      }
    } catch (e) {
      print("❌ Erreur rechargement: $e");
    }
  }
@override

void initState() {
  super.initState();
  pe_id = widget.commandeData['pe_id']?.toString();
    if (pe_id != null) {
    loadPartieOuvrageDesignation(pe_id!).then((_) {
      setState(() {});
    });
  }
  print("Code commande utilisé : $pe_id");
  final validationLabo = widget.commandeData['Validation_labo'];
  final int? validationValue = int.tryParse(validationLabo?.toString() ?? '');
  final isDraft = validationValue == 0 || validationValue == null;
  
  print("🔍 Statut intervention - Validation_labo: $validationLabo");
  print("🔍 Est un brouillon: $isDraft");
  print("🔍 CanEdit: ${widget.canEdit}");
  print("🔍 isReadOnly: $isReadOnly");
    LocalDatabase.getSeriesEprouvettes(pe_id ?? '').then((localSeries) {
    if (localSeries != null && localSeries.isNotEmpty) {
      setState(() {
        series = localSeries.cast<Map<String, dynamic>>();
        
      });
    }
  }).catchError((e) {
    print('Erreur lecture series locales depuis initState: $e');
  });
  
  _loadInterventionData();
}

Future<void> _loadInterventionData() async {
   final localSeries = await LocalDatabase.getSeriesEprouvettes(pe_id ?? '');
  try {
    final result = await sync.fetchInterventions(pe_id);
    setState(() {
      
      commandes = result.commandes ?? [];
      betons = result.betons;
      elementPredefini = result.elementPredefini;
      ModePro = result.modePro;
      carrieres = result.carrieres;
      typeciment = result.typeciment;
      typeAdjuvant = result.typeAdjuvant;
      typeEprouvette = result.typeEprouvette;
      intervention = result.intervention;
      affaire = result.affaire;
     //interventionuser = result.interventionuser;
      String? numCommandeToFind;
      if (result.series.isNotEmpty && result.series[0]['NumCommande'] != null) {
        numCommandeToFind = result.series[0]['NumCommande']?.toString();
      }
      numCommandeToFind ??= result.intervention?['commande_id']?.toString()
                          ?? result.intervention?['NumCommande']?.toString();

      
      if (numCommandeToFind == null && commandes.isNotEmpty) {
        numCommandeToFind = commandes.first.numCommande;
      }

      
      Commande? matchedCommande;
      if (numCommandeToFind != null) {
        try {
          matchedCommande = commandes.firstWhere((c) => c.numCommande == numCommandeToFind);
        } catch (_) {
          
          final fallback = Commande.fromJson({'NumCommande': numCommandeToFind});
          commandes.insert(0, fallback);
          matchedCommande = fallback;
        }
      }

      
      if (matchedCommande != null) {
        selectedCommande = matchedCommande;
      } else if (commandes.isNotEmpty) {
        selectedCommande = commandes.first;
      } else {
        selectedCommande = null;
      }
      print("num commande utilisé : $numCommandeToFind");

      
     
      if (numCommandeToFind != null) {
        try {
          matchedCommande = commandes.firstWhere((c) => c.numCommande == numCommandeToFind);
        } catch (_) {
          
          final fallback = Commande.fromJson({'NumCommande': numCommandeToFind});
          commandes.insert(0, fallback);
          matchedCommande = fallback;
        }
      }

      if (matchedCommande != null) {
        selectedCommande = matchedCommande;
      } else if (commandes.isNotEmpty) {
        selectedCommande = commandes.first;
      } else {
        selectedCommande = null;
      }
      
      final dynamic cidRaw = intervention?['classe_beton_id'] ?? intervention?['classeBeton'] ?? intervention?['classe_beton'];
      final int? classeId = cidRaw != null ? int.tryParse(cidRaw.toString()) : null;
      LocalDatabase.getClasseBetonLabel(classeId).then((label) {
        setState(() => classeBetonLabel = label);
      }).catchError((_) {});
      
      final dynamic rawCharge = intervention?['charge_affaire_id'] ?? result.chargeAffaire ?? intervention?['charge_affaire'];
      Map<String, dynamic>? parsedCharge;

      if (rawCharge == null) {
        parsedCharge = null;
      } else if (rawCharge is Map) {
        parsedCharge = Map<String, dynamic>.from(rawCharge);
      } else if (rawCharge is String) {
        
        try {
          final decoded = jsonDecode(rawCharge);
          if (decoded is Map) {
            parsedCharge = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          
          final s = rawCharge.trim();
          final body = (s.startsWith('{') && s.endsWith('}')) ? s.substring(1, s.length - 1) : s;
          final Map<String, dynamic> m = {};
          for (var part in body.split(',')) {
            final kv = part.split('=');
            if (kv.length >= 2) {
              final key = kv[0].trim();
              final value = kv.sublist(1).join('=').trim();
              
              String normKey = key;
              if (key.toLowerCase().contains('matric')) normKey = 'Matricule';
              else if (key.toLowerCase().contains('nom')) normKey = 'Nom';
              else if (key.toLowerCase().contains('prenom') || key.toLowerCase().contains('prénom')) normKey = 'Prénom';
              m[normKey] = value.replaceAll(RegExp(r'^"|"$'), '').trim();
            }
          }
          if (m.isNotEmpty) parsedCharge = m;
        }
      } else {
        
        try {
          parsedCharge = Map<String, dynamic>.from(rawCharge);
        } catch (_) {
          parsedCharge = null;
        }
      }

      chargeAffaire = parsedCharge ?? result.chargeAffaire;
      print("Parsed chargeAffaire: $chargeAffaire");
      elementsouvrages = result.elementsouvrages;
      constituants = result.constituants;
      series = result.series; 
       try {
      
        if (localSeries != null && localSeries.isNotEmpty) {
          series = localSeries.cast<Map<String, dynamic>>();
          
          eprouvettes.clear();
          for (final s in series) {
            final List localEprs = (s['eprouvettes'] as List?) ?? [];
            for (final m in localEprs) {
              try {
                
                eprouvettes.add(Eprouvette.fromJson(Map<String, dynamic>.from(m)));
              } catch (_) {
                
              }
            }
          }
        } else {
          
          series = result.series ?? [];
          
          eprouvettes.clear();
          for (final s in series) {
            final List apiEprs = (s['eprouvettes'] as List?) ?? [];
            for (final m in apiEprs) {
              try {
                eprouvettes.add(Eprouvette.fromJson(Map<String, dynamic>.from(m)));
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        
        print('Erreur lecture séries locales: $e');
        series = result.series ?? [];
      }
      if (intervention != null) {
        final dateStr = intervention!['pe_date'];
        if (dateStr != null && dateStr.isNotEmpty) {
          final dateParts = dateStr.split('-');
          if (dateParts.length == 3) {
            dateController.text = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";
          }
        }
       
        for (int i = 0; i < 5; i++) {
          final motif = intervention!['motif_non_prelevement${i + 1}'];
          if (motif != null) {
            motifControllers[i].text = motif.toString();
          }
        }
        
        timeController.text = intervention!['pe_heure']?.substring(0, 5) ?? "";
        tempController.text = intervention!['pe_temp']?.toString() ?? "";
        affaissementController.text = intervention!['pe_affais_cone']?.toString() ?? "";
        ecController.text = intervention!['pe_cim_ec']?.toString() ?? "";
        observationController.text = intervention!['pe_obs']?.toString() ?? "";
        selectedModeProd = ModePro.firstWhere(
          (m) => m.value.toString() == intervention!['pe_mode_prod']?.toString(),
          orElse: () => ModePro.isNotEmpty ? ModePro.first : ModesProduction(value: 0, label: ''),
        );
      }
    
      if (result.constituants.isNotEmpty) {
        granulas.clear();
        sables.clear();
        ciment.clear();
        adjuvant.clear();
        additifs.clear();
        eau.clear();

        for (var c in result.constituants) {
          switch (c.fbConstituant) {
          case "1":
              final provObjRes = carrieres.firstWhere(
                (car) => car.value.toString() == c.fbProvenance,
                orElse: () => carrieres.first,
              );
              print('DEBUG: remote granula - fbProvenance=${c.fbProvenance} resolved_label=${provObjRes?.label ?? provObjRes?.value ?? 'n/a'}');
              granulas.add({
                "prov": provObjRes,
                "dosage": c.fbDosage,
                "dmin": c.fbDmin ?? 0,
                "dmax": c.fbDmax ?? 0,
                
              });
              break;
            case "2": 
              sables.add({
                "prov": carrieres.firstWhere(
                  (car) => car.value.toString() == c.fbProvenance,
                  orElse: () => carrieres.first,
                ),
                "dosage": c.fbDosage,
                "dmax": c.fbDmax ?? 0,
              });
              break;
           case "3":
              final typeCimObj = typeciment.isNotEmpty
                  ? typeciment.firstWhere(
                      (tc) => tc.value.toString() == (c.fbType ?? ""),
                      orElse: () => typeciment.first,
                    )
                  : null;
              
              print('DEBUG: remote ciment - fbType=${c.fbType} resolved_type=${typeCimObj?.label ?? typeCimObj?.value ?? 'n/a'}');
              ciment.add({
                "prov": c.fbProvenance,
                "type": typeCimObj,
                "dosage": c.fbDosage,
              });
              break;
          case "4":
              final typeAdjObj = typeAdjuvant.isNotEmpty
                  ? typeAdjuvant.firstWhere(
                      (ta) => ta.value.toString() == (c.fbType ?? ""),
                      orElse: () => typeAdjuvant.first,
                    )
                  : null;
              print('DEBUG: remote adjuvant - fbType=${c.fbType} resolved_type=${typeAdjObj?.label ?? typeAdjObj?.value ?? 'n/a'}');
              adjuvant.add({
                "prov": c.fbProvenance,
                "type": typeAdjObj,
                "dosage": c.fbDosage,
              });
              break;
            case "5": 
              additifs.add({
                "type": c.fbType,
                "nomProduit": c.fbProvenance,
                "dosage": c.fbDosage,
              });
              break;
            case "6": 
              eau.add({
                "source": c.fbProvenance,
                "dosage": c.fbDosage,
              });
              break;
          }
        }
      }
    });
    try {
        final localConsts = await LocalDatabase.getConstituants(pe_id ?? '');
        if (localConsts.isNotEmpty) {
          
          final List<Map<String,dynamic>> localGranulas = [];
          final List<Map<String,dynamic>> localSables = [];
          final List<Map<String,dynamic>> localCiment = [];
          final List<Map<String,dynamic>> localAdjuvant = [];
          final List<Map<String,dynamic>> localAdditifs = [];
          final List<Map<String,dynamic>> localEau = [];
 int _toInt(dynamic v) {
            if (v == null) return 0;
            if (v is int) return v;
            if (v is double) return v.toInt();
            return int.tryParse(v.toString()) ?? 0;
          }

          double _toDouble(dynamic v) {
            if (v == null) return 0.0;
            if (v is double) return v;
            if (v is int) return v.toDouble();
            return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0.0;
          }

           for (final c in localConsts) {
           final String code = (c['fb_constituant']?.toString() ?? c['category']?.toString() ?? c['type']?.toString() ?? '');
  switch (code) {
                    case 'granulas':
    case '1':
      final provVal = c['fb_provenance'] ?? c['fbProvenance'] ?? c['prov'] ?? '';
      final provObj = carrieres.isNotEmpty
          ? carrieres.firstWhere(
              (car) => car.value.toString() == provVal?.toString(),
              orElse: () => carrieres.first,
            )
          : null;
           print('DEBUG: local granula - fb_provenance=$provVal resolved_label=${provObj?.label ?? provVal}');
      localGranulas.add({
        'prov': provObj,
        'fb_provenance': provVal?.toString() ?? '',
        'prov_label': provObj?.label ?? provVal?.toString() ?? '',
        'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
        'dmin': _toInt(c['dmin'] ?? c['fb_dmin']),
        'dmax': _toInt(c['dmax'] ?? c['fb_dmax']),
      });
      break;
    case 'sables':
    case '2':
      final provVal = c['fb_provenance'] ?? c['fbProvenance'] ?? c['prov'] ?? '';
      final provObj = carrieres.isNotEmpty
          ? carrieres.firstWhere(
              (car) => car.value.toString() == provVal?.toString(),
              orElse: () => carrieres.first,
            )
          : null;
      localSables.add({
        'prov': provObj,
        'fb_provenance': provVal?.toString() ?? '',
        'prov_label': provObj?.label ?? provVal?.toString() ?? '',
        'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
        'dmax': _toInt(c['dmax'] ?? c['fb_dmax']),
      });
      break;
              case 'ciment':
              case '3':
             final provTxt = c['prov']?.toString() ?? c['fb_provenance']?.toString();
                final typeObj = typeciment.isNotEmpty
                    ? typeciment.firstWhere(
                        (tc) => tc.value.toString() == (c['type']?.toString() ?? c['fb_type']?.toString() ?? ''),
                        orElse: () => typeciment.first,
                      )
                    : null;
                print('DEBUG: local ciment - fb_type=${c['fb_type'] ?? c['type']} resolved_type=${typeObj?.label ?? typeObj?.value ?? 'n/a'} prov=$provTxt');
                localCiment.add({
                  'prov': provTxt,
                  'type': typeObj,
                  'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
                });
                break;
              case 'adjuvant':
              case '4':
                final provTxtAdj = c['prov']?.toString() ?? c['fb_provenance']?.toString();
                final typeAdjLocal = typeAdjuvant.isNotEmpty
                    ? typeAdjuvant.firstWhere(
                        (ta) => ta.value.toString() == (c['type']?.toString() ?? c['fb_type']?.toString() ?? ''),
                        orElse: () => typeAdjuvant.first,
                      )
                    : null;
                print('DEBUG: local adjuvant - fb_type=${c['fb_type'] ?? c['type']} resolved_type=${typeAdjLocal?.label ?? typeAdjLocal?.value ?? 'n/a'} prov=$provTxtAdj');
                localAdjuvant.add({
                  'prov': provTxtAdj,
                  'type': typeAdjLocal,
                  'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
                });
                 
                break;
              case 'additif':
              case '6':
                localAdditifs.add({
                  'type': c['type'] ?? c['fb_type'],
                  'nomProduit': c['nom_produit'] ?? c['nomProduit'] ?? c['fb_provenance'],
                  'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
                });
                break;
              case 'eau':
              case '5':
                localEau.add({
                  'source': c['prov'] ?? c['source'] ?? c['fb_provenance'],
                  'dosage': _toDouble(c['dosage'] ?? c['fb_dosage']),
                });
                break;
              default:
                break;
            }
          }

          
          setState(() {
            if (granulas.isEmpty && localGranulas.isNotEmpty) granulas = localGranulas;
            if (sables.isEmpty && localSables.isNotEmpty) sables = localSables;
            if (ciment.isEmpty && localCiment.isNotEmpty) ciment = localCiment;
            if (adjuvant.isEmpty && localAdjuvant.isNotEmpty) adjuvant = localAdjuvant;
            if (additifs.isEmpty && localAdditifs.isNotEmpty) additifs = localAdditifs;
            if (eau.isEmpty && localEau.isNotEmpty) eau = localEau;
          });
        }
      } catch (e) {
        print('Erreur lecture constituants locaux: $e');
      }
   try {
      if (elementsouvrages.isEmpty) {
        final localElems = await LocalDatabase.getElementsOuvrage(pe_id ?? '');
        if (localElems.isNotEmpty) {
          setState(() {
            elementsouvrages = localElems.map((m) {
              return Elemouvrage(
                nom: m['nom']?.toString() ?? '',
                axe: m['axe']?.toString() ?? '',
                file: m['file']?.toString() ?? '',
                niveau: m['niveau']?.toString() ?? '0.0',
                bloc: m['bloc']?.toString() ?? '',
                //peid: m['pe_id']?.toString() ?? '',
                famille: m['famille']?.toString() ?? '',
                partieOuvrage: m['partie_ouvrage'] != null 
                  ? PartieOuvrage.fromJson(m['partie_ouvrage'])
                  : null,
              );
            }).toList();
            print('✅ Chargés ${elementsouvrages.length} éléments d\'ouvrage depuis la BD locale');
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement éléments locaux: $e');
    }

    
    try {
      if (constituants.isEmpty) {
        final localCons = await LocalDatabase.getConstituants(pe_id ?? '');
        if (localCons.isNotEmpty) {
          setState(() {
            constituants = localCons.cast<Constituant>();
          });
        }
      }
      if (series.isEmpty) {
      final localSeries = await LocalDatabase.getSeriesEprouvettes(pe_id ?? '');
if (localSeries.isNotEmpty) {
  series = localSeries;
  
  eprouvettes.clear();
  for (final s in series) {
    final List localEprs = s['eprouvettes'] as List? ?? [];
    for (final m in localEprs) {
      eprouvettes.add(Eprouvette.fromJson(Map<String,dynamic>.from(m))); 
    }
  }
} else {
  series = result.series ?? [];
}
      }
    } catch (e) {
      print('❌ Erreur chargement constituants/séries: $e');
    }

  } catch (e) {
    print('❌ Erreur lors du chargement des données d\'intervention: $e');
 await _loadOfflineReferenceData();
    
    try {
      final local = await LocalDatabase.getIntervention(pe_id ?? '');
      if (local != null) {
        setState(() {
          intervention = local;
          affaire = {
            'Code_Affaire': local['Code_Affaire'] ?? local['codeAffaire'] ?? '',
            'Code_Site': local['Code_Site'] ?? local['codeSite'] ?? '',
            'IntituleAffaire': local['intitule_affaire'] ?? local['intituleAffaire'] ?? ''
          };
          print('Code_AffaireCode_AffaireCode_AffaireCode_AffaireCode_Affaire: $affaire.Code_Affaire');
          final dynamic cidRaw = local['classe_beton_id'] ?? local['classeBeton'] ?? local['classe_beton'];
          final int? classeId = cidRaw != null ? int.tryParse(cidRaw.toString()) : null;
          LocalDatabase.getClasseBetonLabel(classeId).then((label) {
            setState(() => classeBetonLabel = label);
          }).catchError((_) {});
          
          
          final dynamic rawCharge = local['charge_affaire_id'] ?? local['charge_affaire'];
          Map<String, dynamic>? parsedCharge;
          if (rawCharge is Map) {
            parsedCharge = Map<String, dynamic>.from(rawCharge);
          } else if (rawCharge is String) {
            try {
              parsedCharge = Map<String, dynamic>.from(jsonDecode(rawCharge));
            } catch (_) {
              parsedCharge = null;
            }
          }
          chargeAffaire = parsedCharge;
        });
           try {
          final localElems = await LocalDatabase.getElementsOuvrage(pe_id ?? '');
          if (localElems.isNotEmpty) {
            setState(() {
              elementsouvrages = localElems.map((m) {
                return Elemouvrage(
                  nom: m['nom']?.toString() ?? '',
                  axe: m['axe']?.toString() ?? '',
                  file: m['file']?.toString() ?? '',
                  niveau: m['niveau']?.toString() ?? '0.0',
                  //peid: m['pe_id']?.toString() ?? '',
                  bloc: m['bloc']?.toString() ?? '',
                  famille: m['famille']?.toString() ?? '',
                );
              }).toList();
            });
          }
        } catch (e) {
          print('❌ Erreur chargement éléments offline: $e');
        }
 try {
          final String? numCmdLocal = local['commande_id']?.toString()
              ?? local['NumCommande']?.toString();
          final String? codeAffaireLocal = local['Code_Affaire']?.toString();
          final String? codeSiteLocal = local['Code_Site']?.toString();

          
          if (commandes.isEmpty) {
            final localCmds = await LocalDatabase.getAllCommandesRef();
            if (localCmds.isNotEmpty) {
              commandes = localCmds.map((c) => Commande.fromJson(c)).toList();
            }
          }

          Commande? matched;
          if (numCmdLocal != null) {
            try {
              matched = commandes.firstWhere((c) => c.numCommande == numCmdLocal);
            } catch (_) {
              matched = null;
            }
          }

          if (matched != null) {
            
            final Map<String, dynamic> m = matched.toJson();
            if ((m['Code_Affaire'] == null || m['Code_Affaire'].toString().isEmpty) && codeAffaireLocal != null) {
              m['Code_Affaire'] = codeAffaireLocal;
            }
            if ((m['Code_Site'] == null || m['Code_Site'].toString().isEmpty) && codeSiteLocal != null) {
              m['Code_Site'] = codeSiteLocal;
            }
            final updated = Commande.fromJson(m);
            final idx = commandes.indexWhere((c) => c.numCommande == matched!.numCommande);
            if (idx >= 0) commandes[idx] = updated;
            setState(() => selectedCommande = updated);
          } else {
            
            final fallbackJson = {
              'NumCommande': numCmdLocal ?? local['pe_id']?.toString() ?? 'LOCAL-${pe_id ?? ''}',
              'Code_Affaire': codeAffaireLocal ?? '',
              'Code_Site': codeSiteLocal ?? '',
            };
            final fallback = Commande.fromJson(fallbackJson);
            setState(() {
              commandes.insert(0, fallback);
              selectedCommande = fallback;
            });
          
          }
        } catch (e) {
          print('❌ Erreur lors du complément selectedCommande (offline): $e');
        }
        
        try {
          final localElems = await LocalDatabase.getElementsOuvrage(pe_id ?? '');
          if (localElems.isNotEmpty) {
            setState(() {
              elementsouvrages = localElems.map((m) {
                return Elemouvrage(
                  nom: m['nom']?.toString() ?? '',
                  axe: m['axe']?.toString() ?? '',
                  file: m['file']?.toString() ?? '',
                  niveau: m['niveau']?.toString() ?? '0.0',
                  bloc: m['bloc']?.toString() ?? '',
                  //peid: m['pe_id']?.toString() ?? '',
                  famille: m['famille']?.toString() ?? '',
                  partieOuvrage: m['partie_ouvrage'] != null 
                    ? PartieOuvrage.fromJson(m['partie_ouvrage'])
                    : null,
                );
              }).toList();
              print('✅ Chargés ${elementsouvrages.length} éléments d\'ouvrage (offline)');
            });
          }
        } catch (_) {}
      } else {
        print("⚠️ Aucune intervention locale trouvée pour pe_id=$pe_id");
      }
    } catch (e2) {
      print("❌ Erreur fallback offline: $e2");
    }
  }
}




String formatChargeAffaire(Map<String, dynamic> chargeAffaire) {
  final matricule = chargeAffaire['Matricule'] ?? '';
  final nom = chargeAffaire['Nom'] ?? '';
  final prenom = chargeAffaire['Prénom'] ?? '';

  return '$matricule - $nom $prenom'.trim();
}
  @override
Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
        title: const Text('Interventions'),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.orange),
              onPressed: _saveAsDraft,
              tooltip: 'Sauvegarder comme brouillon',
            ),
          
          
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: _validateIntervention,
              tooltip: 'Valider l\'intervention',
            ),
          
          
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Theme(
            data: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A8A),
              ),
            ).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ),
            child: Builder(
              builder: (themeContext) {
                return Stepper(
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    
                    final Color navBg = const Color(0xFF1E3A8A); 
                    final Color navFg = Colors.white;
                    final Color prevFg = const Color(0xFF1E3A8A);

                    
                    final bg = isReadOnly ? Colors.grey[300] : const Color(0xFFF9FAFB);
                    final fg = isReadOnly ? Colors.grey : const Color(0xFF1E3A8A);

                    return Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navBg,
                            foregroundColor: navFg,
                          ),
                          onPressed: () {
                            
                            if (isReadOnly) {
                              if (_currentStep < 4) {
                                setState(() => _currentStep++);
                              }
                            } else {
                              details.onStepContinue?.call();
                            }
                          },
                          child: const Text('Suivant'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: prevFg,
                          ),
                          onPressed: () {
                            
                            details.onStepCancel?.call();
                          },
                          child: const Text('precedent'),
                        ),
                      ],
                    );
                  },
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (isReadOnly) {
                      if (_currentStep < 4) {
                        setState(() => _currentStep++);
                      }
                      return;
                    }

                    bool isValid = true;
                    switch (_currentStep) {
                      case 0:
                        isValid = _formKey1.currentState?.saveAndValidate() ?? false;
                        break;
                      case 1:
                        isValid = _formKey2.currentState?.saveAndValidate() ?? false;
                        break;
                      case 2:
                        isValid = _formKey3.currentState?.saveAndValidate() ?? false;
                        break;
                      case 3:
                        isValid = _formKey4.currentState?.saveAndValidate() ?? false;
                        break;
                      case 4:
                        isValid = _formKey5.currentState?.saveAndValidate() ?? false;
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
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  steps: [
                    Step(
                      title: const Text('Informations Affaire'),
                      content: IgnorePointer(
                        ignoring: isReadOnly,
                        child: Opacity(opacity: isReadOnly ? 0.7 : 1.0, child: _buildStep1()),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Élément d\'ouvrage'),
                      content: IgnorePointer(
                        ignoring: isReadOnly,
                        child: Opacity(opacity: isReadOnly ? 0.7 : 1.0, child: _buildStep2()),
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Prélèvement'),
                      content: IgnorePointer(
                        ignoring: isReadOnly,
                        child: Opacity(opacity: isReadOnly ? 0.7 : 1.0, child: _buildStep3()),
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Constituant'),
                      content: IgnorePointer(
                        ignoring: isReadOnly,
                        child: Opacity(opacity: isReadOnly ? 0.7 : 1.0, child: _buildStep4()),
                      ),
                      isActive: _currentStep >= 3,
                      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Éprouvettes'),
                      content: IgnorePointer(
                        ignoring: isReadOnly,
                        child: Opacity(opacity: isReadOnly ? 0.7 : 1.0, child: _buildStep5()),
                      ),
                      isActive: _currentStep >= 4,
                      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
                    ),
                  ],
                );
              },
            ),
          ),
  );
}








  
































































     



















     
          

          





















    





























          









Widget _buildStep1() {
  
  final String codeAffaire = intervention?['Code_Affaire']?.toString() ??
      intervention?['codeAffaire']?.toString() ??
      '';

  final String codeSite = intervention?['Code_Site']?.toString() ??
      intervention?['codeSite']?.toString() ??
      selectedCommande?.codeSite ??
      widget.commandeData['Code_Site']?.toString() ??
      'Non spécifié';

  final String intituleAffaire = affaire?['IntituleAffaire']?.toString() ??
      intervention?['IntituleAffaire']?.toString() ??
      intervention?['intitule_affaire']?.toString() ??
      'Non spécifié';

  return FormBuilder(
    key: _formKey1,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.7,
                  child: DropdownButtonFormField<Commande>(
                    value: selectedCommande,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.receipt_long, color: Colors.grey),
                      labelText: "Commande",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: commandes.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.numCommande,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: null,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Code Affaire : $codeAffaire",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Intitulé Affaire : $intituleAffaire",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                     Icon(
  Icons.location_on,
  color: Colors.grey[700],
),
                      const SizedBox(width: 6),
                      Text(
                        "Site : $codeSite",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          
          if (classeBetonLabel != 'Non spécifié')
            Card(
              child: ListTile(
                title: const Text("Classe Béton"),
                subtitle: Text(classeBetonLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),

          if (intervention?['catChantier'] != null)
            Card(
              child: ListTile(
                title: const Text("Catégorie Chantier"),
                subtitle: Text(intervention!['catChantier'].toString()),
              ),
            ),

          if (intervention?['entreprise_real'] != null)
            Card(
              child: ListTile(
                title: const Text("Entreprise"),
                subtitle: Text(intervention!['entreprise_real'].toString()),
              ),
            ),

          if (chargeAffaire != null)
            Card(
              child: ListTile(
                title: const Text("Chargé d'affaire"),
                subtitle: Text(_formatChargeAffaire(chargeAffaire!)),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
Widget _buildStep2() {
  
final String blocOuvrage = selectedCommande?.bloc?.toString().isNotEmpty == true
    ? selectedCommande!.bloc.toString()
    : (selectedCommande?.bloc?.toString().isNotEmpty == true
        ? selectedCommande!.bloc.toString()
        : 'Non spécifié');

final String localisation = selectedCommande?.localisation?.toString().isNotEmpty == true
    ? selectedCommande!.localisation.toString()
    : (selectedCommande?.localisation?.toString().isNotEmpty == true
        ? selectedCommande!.localisation.toString()
        : 'Non spécifié');
final String partieOuvrageDesignation = () {
  try {
    // Retrieve the raw value of partieOuvrage
    final dynamic rawValue = selectedCommande?.partieOuvrage ?? intervention?['partie_ouvrage'];

    // Log the raw value
    print('Valeur brute de partieOuvrage : $rawValue');

    // Check if the value is already an object (e.g., FamillePred)
    if (rawValue is FamillePred) {
      // Handle the object directly if possible
      return rawValue.designation ?? 'Non spécifié';
    }

    // Check if the value is a valid JSON string
    if (rawValue is String && rawValue.isNotEmpty) {
      final Map<String, dynamic> json = jsonDecode(rawValue);
      print('Valeur décodée de partieOuvrage : $json');
      return json['designation']?.toString() ?? 'Non spécifié';
    }

    // If the value is null or empty
    return 'Non spécifié';
  } catch (e) {
    // Handle errors gracefully
    print('Erreur lors du traitement de partieOuvrage : $e');
    return 'Non spécifié';
  }
}();
  
 final Map<String, String> familleDesignationMap = {
  for (var predef in elementPredefini)
    predef.id.toString(): predef.designation
};

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      if (selectedCommande != null || blocOuvrage != 'Non spécifié')
        Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: const Icon(Icons.account_tree_outlined, color: Color(0xFF1E3A8A), size: 32),
            title: Text(
              "Ouvrage : $blocOuvrage",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Localisation : $localisation", style: const TextStyle(fontSize: 14)),
              

  Text(
    "Élément de bloc : $partieOuvrageDesignation",
    style: const TextStyle(fontSize: 14),
  ),],
            ),
          ),
        ),

      const SizedBox(height: 16),

      
      if (elementsouvrages.isNotEmpty) ...[
        const Text(
          "Éléments prélevés",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 12),
        ...elementsouvrages.map((elem) {
          
         final String familleDes = elem.famille != null
    ? (familleDesignationMap[elem.famille.toString()] ?? 'Famille inconnue (ID: ${elem.famille})')
    : 'Non spécifiée';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.business, color: Colors.blueGrey[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Bâtiment/Ouvrage :${elem.bloc}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  Text(
                    elem.nom ?? 'Élément sans nom',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),

                  const SizedBox(height: 10),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoChip("Axe", elem.axe ?? '-'),
                      _infoChip("File", elem.file ?? '-'),
                      _infoChip("Niveau", elem.niveau ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Famille : $familleDes",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: familleDes.contains('non trouvée') ? Colors.red : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ] else ...[
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Aucun élément d'ouvrage ajouté", style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],

      const SizedBox(height: 20),
    ],
  );
}


Widget _infoChip(String label, String value) {
  return Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
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

        
        DropdownButtonFormField<ModesProduction>(
          value: selectedModeProd,
          items: ModePro.map((cb) {
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
              selectedModeProd = value;
            });
          },
          decoration: InputDecoration(
            labelText: "Mode de production",
            labelStyle: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value == null ? "Champ obligatoire" : null,
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
    backgroundColor: Color(0xFF1E3A8A),
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
          // Bouton pour consulter les constituants
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3A8A)),
            onPressed: () {
              // Votre logique ici
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text("Consulter les constituants des formulations béton"),
            ),
          ),
          const SizedBox(height: 16),

          // Boutons d'ajout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(onPressed: _addGranulas, child: const Text("Granulas")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                onPressed: _addSable,
                child: const Text("Sables"),
              ),
              ElevatedButton(onPressed: _addCiment, child: const Text("Ciment")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _addAdjuvant,
                child: const Text("Adjuvant"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _addAdditif,
                child: const Text("Additifs"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _addEau,
                child: const Text("Eau"),
              ),
            ],
          ),

          const SizedBox(height: 18),

  if (granulas.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("Granulas", style: TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...granulas.asMap().entries.map((e) {
    final i = e.key;
    final item = e.value;
    // Récupérer l'objet carrière complet basé sur la valeur
    final carriereObjet = item['prov']; // C'est déjà l'objet carrière
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Affichage de la provenance directement depuis l'objet carrière
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provenance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    carriereObjet?.label ?? 'Non spécifiée',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: carriereObjet?.label != null ? Colors.black : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                  // Afficher la valeur de référence si disponible
                  if (carriereObjet?.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Référence: ${carriereObjet!.value}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
                      // Contrôles pour dosage, dmin, dmax
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
                ),
              );
            }).toList(),
          ],

          // Section Sables
         if (sables.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("Sables", style: TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...sables.asMap().entries.map((e) {
    final i = e.key;
    final it = e.value;
    // Récupérer l'objet carrière complet basé sur la valeur
    final carriereObjet = it['prov']; // C'est déjà l'objet carrière
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Affichage de la provenance directement depuis l'objet carrière
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.beach_access, size: 16, color: Colors.blueGrey[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Provenance des sables',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    carriereObjet?.label ?? 'Non spécifiée',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: carriereObjet?.label != null ? Colors.black : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                  // Afficher la valeur de référence si disponible
                  if (carriereObjet?.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Référence: ${carriereObjet!.value}',
                        style: TextStyle(
                          color: Colors.blueGrey[600],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

                      // Contrôles pour dosage et dmax
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text("Dosage", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                const Text("Dmax (mm)", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            int current = int.tryParse(it['dmax']?.toString() ?? "0") ?? 0;
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
                                            int current = int.tryParse(it['dmax']?.toString() ?? "0") ?? 0;
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
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ],

          // Section Ciment
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
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TypeCiments>(
                              value: it['type'],
                              items: typeciment.map((cb) {
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
                                  it['type'] = value;
                                });
                              },
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
                ),
              );
            }).toList(),
          ],

          // Section Adjuvant
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
                            child: DropdownButtonFormField<TypeAdjuvants>(
                              value: it['type'],
                              items: typeAdjuvant.map((cb) {
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
                                  it['type'] = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Type t",
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
                ),
              );
            }).toList(),
          ],

          // Section Additifs
          if (additifs.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAdditifs(),
          ],

          // Section Eau
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: it['source']?.toString() ?? "",
                          decoration: const InputDecoration(labelText: "Source d'eau"),
                          onChanged: (v) => it['source'] = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: it['dosage']?.toString() ?? "0",
                          decoration: const InputDecoration(labelText: "Dosage (L/m3)"),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => it['dosage'] = int.tryParse(v) ?? 0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEau(i),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    ),
  );
}




 bool age1Enabled = false; 
  bool age2Enabled = false; 
 bool age3Enabled = false; 
  bool age4Enabled = false; 
  bool age5Enabled = false; 
 

Future<String> fetchEprvType(String typeId) async {
  try {
    // Replace 'query' with the correct method from LocalDatabase
    final result = await LocalDatabase.getTableData(
      tableName: 'types_eprouvette_ref',
      where: 'eprv_id = ?',
      whereArgs: [typeId],
    );

    if (result.isNotEmpty) {
      return result.first['eprv_type']?.toString() ?? 'Type inconnu';
    }
  } catch (e) {
    print('Erreur lors de la récupération de eprv_type : $e');
  }
  return 'Type inconnu';
}


Widget _buildStep5() {
  if (selectedCommande == null) {
    return const Center(
      child: Text(
        "Aucune commande sélectionnée pour l'instant.",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  // 1. Préparer les données une seule fois
  final agesDemande = [
    selectedCommande?.age1,
    selectedCommande?.age2,
    selectedCommande?.age3,
    selectedCommande?.age4,
    selectedCommande?.age5,
  ];

  // 2. Récupérer tous les types d'éprouvettes nécessaires
  final List<String> typeIds = series.map((serie) => serie['Forme']?.toString() ?? '').toList();
  final Set<String> uniqueTypeIds = typeIds.where((id) => id.isNotEmpty).toSet();

  return FutureBuilder<Map<String, String>>(
    future: _fetchAllEprvTypes(uniqueTypeIds),
    builder: (context, snapshot) {
      // 3. Afficher un indicateur de chargement global
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (snapshot.hasError) {
        return Center(
          child: Text('Erreur: ${snapshot.error}'),
        );
      }

      // 4. Récupérer la map des types
      final Map<String, String> typeMap = snapshot.data ?? {};

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne de gauche - Âges demandés
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(agesDemande.length, (i) {
                      final String ageFromSeries = (i < series.length)
                          ? (series[i]['Age']?.toString() ?? '')
                          : '';
                      final String fallbackAge = agesDemande[i]?.toString() ?? "";
                      final String displayAge = ageFromSeries.isNotEmpty ? ageFromSeries : fallbackAge;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          initialValue: displayAge,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Écrasement âge ${i + 1} :",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 24),
       
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(series.length, (i) {
                      final serie = series[i];
                      final ageKey = serie['Age']?.toString() ?? '';
                      final typeId = serie['Forme']?.toString() ?? '';
                      final typeLabel = typeMap[typeId] ?? 'Type inconnu';
                      final nbEprouvettes = serie['NbrEchantillon']?.toString() ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: ageKey,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Écrasement âge ${i + 1}",
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: typeLabel,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Type d'éprouvette",
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: nbEprouvettes.toString(),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Nombre d'éprouvettes",
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: (serie['eprouvettes'] as List? ?? []).map((epr) => Chip(
                                label: Text(epr['epr_id']?.toString() ?? ''),
                                backgroundColor: Color(0xFFF9FAFB),
                              )).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Méthode pour récupérer tous les types d'éprouvettes en une seule requête
Future<Map<String, String>> _fetchAllEprvTypes(Set<String> typeIds) async {
  final Map<String, String> result = {};

  for (final typeId in typeIds) {
    if (typeId.isEmpty) continue;
    
    try {
      final typeName = await fetchEprvType(typeId);
      result[typeId] = typeName;
    } catch (e) {
      result[typeId] = 'Erreur: $e';
      print('❌ Erreur pour TypeId = $typeId : $e');
    }
  }

  return result;
}
  
  
  void _storeData() {
    final formData1 = _formKey1.currentState?.value ?? {};
    final formData2 = _formKey2.currentState?.value ?? {};
    final formData3 = _formKey3.currentState?.value ?? {};
    final formData4 = _formKey4.currentState?.value ?? {};
    final formData5 = _formKey5.currentState?.value ?? {};

    final allFormData = {
      ...formData1,
      ...formData2,
      ...formData3,
      ...formData4,
      ...formData5,
      "selectedCommande": selectedCommande?.numCommande,
      "selectedEntreprise": selectedEntreprise?.nom,
      "selectedClasseBeton": selectedClasseBeton?.label,
    };

    print(allFormData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Données enregistrées avec succès')),
    );
  }
}
