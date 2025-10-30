import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
// removed unused imports: dart:convert, http client, global_provider, provider


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
  bool get isReadOnly => !widget.canEdit;
  int _currentStep = 0;
  bool isLoading = false;
List<Map<String, dynamic>> additifs = [];
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




  String? selectedAffaissement;
  Commande? selectedCommande;
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
  List<Map<String, dynamic>> additif = [];
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
                            it['dosage'] = int.tryParse(v) ?? 0;
                          },
                        ),
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
  pe_id = widget.commandeData['pe_id']?.toString();
  print("Code commande utilisé : $pe_id");
  fetchInterventions().then((result) {
    setState(() {
      commandes = result.commandes;
      if (commandes.isNotEmpty) {
        selectedCommande = commandes.firstWhere(
          (c) => c.numCommande == result.intervention['NumCommande'],
          orElse: () => commandes.first,
        );
      } else {
        selectedCommande = null;
      }
      betons = result.betons;
      elementPredefini = result.elementPredefini;
      ModePro = result.modePro;
      carrieres = result.carrieres;
      typeciment = result.typeciment;
      typeAdjuvant = result.typeAdjuvant;
      typeEprouvette = result.typeEprouvette;
      intervention = result.intervention;
      affaire = result.affaire;
      chargeAffaire = result.chargeAffaire;
      elementsouvrages = result.elementsouvrages;
 constituants= result.constituants;
 series = result.series; 
      // Remplissage des contrôleurs
      if (intervention != null) {
        final dateStr = intervention!['pe_date'];
        if (dateStr != null && dateStr.isNotEmpty) {
          final dateParts = dateStr.split('-');
          if (dateParts.length == 3) {
            dateController.text = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";
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
      case "1": // Granulas
        granulas.add({
          "prov": carrieres.firstWhere(
            (car) => car.value.toString() == c.fbProvenance,
            orElse: () => carrieres.first,
          ),
          "dosage": c.fbDosage,
          "dmin": c.fbDmin ?? 0,
          "dmax": c.fbDmax ?? 0,
        });
        break;
      case "2": // Sables
        sables.add({
          "prov": carrieres.firstWhere(
            (car) => car.value.toString() == c.fbProvenance,
            orElse: () => carrieres.first,
          ),
          "dosage": c.fbDosage,
          "dmax": c.fbDmax ?? 0,
        });
        break;
      case "3": // Ciment
        ciment.add({
          "prov": c.fbProvenance,
          "type": typeciment.firstWhere(
            (tc) => tc.value.toString() == (c.fbType ?? ""),
            orElse: () => typeciment.first,
          ),
          "dosage": c.fbDosage,
        });
        break;
      case "4": // Adjuvant
        adjuvant.add({
          "prov": c.fbProvenance,
          "type": typeAdjuvant.firstWhere(
            (ta) => ta.value.toString() == (c.fbType ?? ""),
            orElse: () => typeAdjuvant.first,
          ),
          "dosage": c.fbDosage,
        });
        break;
      case "5": // Additif
        additifs.add({
          "type": c.fbType,
          "nomProduit": c.fbProvenance,
          "dosage": c.fbDosage,
        });
        break;
      case "6": // Eau
        eau.add({
          "source": c.fbProvenance,
          "dosage": c.fbDosage,
        });
        break;
    }
  }
}
    }); 
  }); 
} 

Future<Interventions> fetchInterventions() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final String interventionId = pe_id ?? "";

  print("🔍 [fetchInterventions] token: $token, interventionId: $interventionId");

  if (token == null || token.isEmpty || interventionId.isEmpty) {
    print("❌ [fetchInterventions] Token ou ID manquant.");
    throw Exception("Token ou ID manquant.");
  }

  try {
    final response = await dio().get(
      '/essais/getIntervention/$interventionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print("🔍 [fetchInterventions] Response status: ${response.statusCode}");
    print("🔍 [fetchInterventions] Response data: ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;

      // Log les clés principales du JSON
      print("🔍 [fetchInterventions] Clés reçues: ${data.keys.toList()}");

      // Log chaque parsing
      try {
    print("🔹 Parsing Commande...");
final commandes = (data['commandes'] as List)
    .map((json) {
      try {
        return Commande.fromJson(json);
      } catch (e) {
        print('❌ Erreur Commande.fromJson: $e, data: $json');
        rethrow;
      }
    })
    .toList();
        print("✅ [fetchInterventions] commandes: ${commandes.length}");
        final betons = (data['beton'] as List)
            .map((json) => ClasseBeton.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] betons: ${betons.length}");
        final elementPredefini = (data['famille_elements'] as List)
            .map((json) => ElementPredefini.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] elementPredefini: ${elementPredefini.length}");
        final ModePro = (data['modesProduction'] as List)
            .map((json) => ModesProduction.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] ModePro: ${ModePro.length}");
        final carrieres = (data['carrieres'] as List)
            .map((json) => ClasseCarrieres.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] carrieres: ${carrieres.length}");
        final typeciment = (data['types_ciments'] as List)
            .map((json) => TypeCiments.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] typeciment: ${typeciment.length}");
        final typeAdjuvant = (data['types_adjuvants'] as List)
            .map((json) => TypeAdjuvants.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] typeAdjuvant: ${typeAdjuvant.length}");
        final typeEprouvette = (data['types_eprouvettes'] as List)
            .map((json) => TypeEprouvettes.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] typeEprouvette: ${typeEprouvette.length}");
       final constituants = (data['constituants'] as List).map((json) {
  print('Parsing constituant: $json');
  try {
    return Constituant.fromJson(json);
  } catch (e) {
    print('❌ Erreur Constituant.fromJson: $e, data: $json');
    rethrow;
  }
}).toList();
        final eprouvettes = (data['eprouvettes'] as List)
            .map((json) => Eprouvette.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] eprouvettes: ${eprouvettes.length}");
        final series = (data['series'] as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
        print("✅ [fetchInterventions] series: ${series.length}");

        final intervention = (data['intervention'] ?? {}) as Map<String, dynamic>;
        print("✅ [fetchInterventions] intervention: $intervention");
        final affaire = (data['affaire'] ?? {}) as Map<String, dynamic>;
        print("✅ [fetchInterventions] affaire: $affaire");
        final chargeAffaire = (data['charge_affaire'] ?? {}) as Map<String, dynamic>;
        print("✅ [fetchInterventions] chargeAffaire: $chargeAffaire");
        final elementsouvrages = (data['elements_ouvrages'] as List)
            .map((json) => Elemouvrage.fromJson(json))
            .toList();
        print("✅ [fetchInterventions] elementsouvrages: ${elementsouvrages.length}");
     
        return Interventions(
          series: series,
          commandes: commandes,
          betons: betons,
          elementPredefini: elementPredefini,
          modePro: ModePro,
          carrieres: carrieres,
          typeciment: typeciment,
          typeAdjuvant: typeAdjuvant,
          typeEprouvette: typeEprouvette,
          intervention: intervention,
          affaire: affaire,
          elementsouvrages: elementsouvrages,
          chargeAffaire: chargeAffaire,
          constituants: constituants,
          eprouvettes: eprouvettes,
        );
      } catch (e) {
        print("❌ [fetchInterventions] Erreur parsing: $e");
        throw Exception("Erreur parsing: $e");
      }
    } else {
      print("❌ [fetchInterventions] Erreur HTTP: ${response.statusCode}: ${response.data}");
      throw Exception("Erreur ${response.statusCode}: ${response.data}");
    }
  } catch (e) {
    print("❌ [fetchInterventions] Exception: $e");
    throw Exception("Erreur lors du chargement des interventions: $e");
  }
}
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Interventions'),
      backgroundColor: const Color(0xFF1E3A8A),
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
                    // Navigation buttons should remain active (not grayed) even in read-only mode.
                    final Color navBg = const Color(0xFF1E3A8A); // primary
                    final Color navFg = Colors.white;
                    final Color prevFg = const Color(0xFF1E3A8A);

                    // Keep these for other potential uses (unused for nav buttons below)
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
                            // In read-only (recovery) mode, always go to next step without validation
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
                            // allow cancel navigation even in read-only
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
    return FormBuilder(
      key: _formKey1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
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
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.receipt_long, color: Colors.grey),
            labelText: "Commande",
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {},
          validator: (value) =>
          value == null ? "Veuillez sélectionner une commande" : null,
        ),
      ),
    ),
  ),
),

            const SizedBox(height: 10),

     
if (affaire != null) ...[
  Card(
    child: ListTile(
      title: const Text("Intitulé Affaire"),
      subtitle: Text(affaire!['IntituleAffaire'] ?? ""),
    ),
  ),
],
if (intervention != null) ...[
 Card(
  child: ListTile(
    title: const Text("Classe Béton"),
    subtitle: Text(
      betons.firstWhere(
        (b) => b.value.toString() == intervention!['classeBeton']?.toString(),
       orElse: () => ClasseBeton(value: 0, label: ''),
      ).label,
    ),
  ),
),
  Card(
    child: ListTile(
      title: const Text("Catégorie Chantier"),
      subtitle: Text(intervention!['catChantier'] ?? ""),
    ),
  ),
  Card(
    child: ListTile(
      title: const Text("Entreprise"),
      subtitle: Text(intervention!['entreprise_real'] ?? ""),
    ),
  ),
],
if (chargeAffaire != null) ...[
  Card(
    child: ListTile(
      title: const Text("Chargé d'affaire"),
      subtitle: Text("${chargeAffaire!['Matricule']} - ${chargeAffaire!['Nom']} ${chargeAffaire!['Prénom']}"),
    ),
  ),
],
           
        

            const Divider(thickness: 1, height: 30, color: Colors.grey),

        
            ],
          
        ),
      ),
    );
  }

Widget _buildStep2() {
  print("selectedCommande: $selectedCommande");
  print("elementsouvrages: ${elementsouvrages.length}");
  for (var elem in elementsouvrages) {
    print("Elemouvrage: nom=${elem.nom}, axe=${elem.axe}, file=${elem.file}, niveau=${elem.niveau}");
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🔹 Résumé de la commande sélectionnée
      if (selectedCommande != null)
        Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.account_tree, color: Color(0xFF1E3A8A)),
            title: Text(
              "Ouvrage : ${selectedCommande!.elembloc}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            subtitle: Text(
                "Élément Bloc : ${selectedCommande!.bloc}\n"
              "Localisation : ${selectedCommande!.localisation}",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),

      const SizedBox(height: 12),

      // 🔹 Liste des éléments ouvrages
      if (selectedCommande != null && elementsouvrages.isNotEmpty)
        ...elementsouvrages.map((elem) {
          // 🔹 Trouver la famille (partieOuvrage) correspondante
        final partieOuvrage = commandes.firstWhere(
  (c) => c.partieOuvrage != null && c.partieOuvrage!.id.toString() == elem.famille.toString(),
  orElse: () => Commande.empty(),
).partieOuvrage;

print('Recherche famille pour elem.nom=${elem.nom}, elem.famille=${elem.famille}');
commandes.forEach((c) {
  print('  -> partieOuvrage.id=${c.partieOuvrage?.id}, designation=${c.partieOuvrage?.designation}');
});
print('Résultat: ${partieOuvrage?.designation}');
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elem.nom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Axe : ${elem.axe}",
                          style: const TextStyle(color: Colors.black87)),
                      Text("File : ${elem.file}",
                          style: const TextStyle(color: Colors.black87)),
                      Text("Niveau : ${elem.niveau}",
                          style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Famille de l'élément : ${partieOuvrage?.designation ?? 'Inconnue'}",
                    style: TextStyle(
                      color: (partieOuvrage?.designation == null)
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

      const SizedBox(height: 16),

      // 🔹 Bouton d’ajout
      //if (selectedCommande != null ) 
        // Align(
        //   alignment: Alignment.center,
        //   child: ElevatedButton.icon(
        //     onPressed: () async {
        //       final newElem = await _showAddElemDialog();
        //       if (newElem != null) {
        //         setState(() {
        //           elementsouvrages.add(newElem);
        //         });
        //       }
        //     },
        //     icon: const Icon(Icons.add, color: Colors.white),
        //     label: const Text(
        //       "Ajouter un nouvel élément",
        //       style: TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Color(0xFF1E3A8A),
        //       padding:
        //           const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   ),
        // ),
    ],
  );
}

Future<Elemouvrage?> _showAddElemDialog() async {
  ElementPredefini? selectedpredfini;
  final axeController = TextEditingController();
  final fileController = TextEditingController();
  final niveauController = TextEditingController();
  final familleController = TextEditingController();
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
                  // 🔹 Classe Béton
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

                  // 🔹 Axe
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

                  // 🔹 File
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

                  // 🔹 Niveau avec boutons +/-
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
                    axe: axeController.text,
                    file: fileController.text,
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

Widget _buildStep3() {
  return FormBuilder(
    key: _formKey3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Date & Heure
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

        // 🔹 Température
        _buildNumericField(
          label: "Température (°C)",
          controller: tempController,
          step: 2,
          min: -20,
          max: 60,
        ),
        const SizedBox(height: 16),

        // 🔹 Mode de production
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

        // 🔹 Affaissement du cône
        _buildNumericField(
          label: "Affaissement du cône (cm)",
          controller: affaissementController,
          step: 0.1,
          min: 0,
          max: 30,
        ),
        const SizedBox(height: 16),

        // 🔹 E/C
        _buildNumericField(
          label: "Rapport E/C",
          controller: ecController,
          step: 0.1,
          min: 0,
          max: 10,
        ),
        const SizedBox(height: 16),

        // 🔹 Observations
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

/// 🔹 Widget réutilisable pour les champs numériques avec + / -
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

/// 🔹 Bouton +/-
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
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3A8A)),
            onPressed: () {
             
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
            DropdownButtonFormField<ClasseCarrieres>(
  value: item['prov'],
  items: carrieres.map((cb) {
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
      item['prov'] = value;
    });
  },
  decoration: InputDecoration(
    labelText: "Provenance des granulas ",
    labelStyle: const TextStyle(
      color: Color(0xFF1E3A8A),
      fontWeight: FontWeight.bold,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
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
// --- Sables ---
if (sables.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text("Sables", style: TextStyle(fontWeight: FontWeight.bold)),
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
           DropdownButtonFormField<ClasseCarrieres>(
  value: it['prov'],
  items: carrieres.map((cb) {
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
      it['prov'] = value;
    });
  },
  decoration: InputDecoration(
    labelText: "Provenance des sables",
    labelStyle: const TextStyle(
      color: Color(0xFF1E3A8A),
      fontWeight: FontWeight.bold,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  validator: (value) =>
      value == null ? "Veuillez sélectionner une carrière" : null,
),  const SizedBox(height: 8),

          
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
                                  int current = int.tryParse(it['dosage']?.toString() ?? "0") ?? 0;
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
      ));
    }).toList(),
],

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
                                  int current = it['dosage'] ?? 0; // Utilisez 'it' au lieu de 'item'
                                  if (current > 0) current--;
                                  it['dosage'] = current;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "${it['dosage'] ?? 0}", // Utilisez 'it' au lieu de 'item'
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
      ));
    }).toList(),

],
         if (additifs.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAdditifs(),
          ],
          
          
          
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
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
           ]
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

  // Âges demandés par le chargé d’affaire
  final agesDemande = [
    selectedCommande?.age1,
    selectedCommande?.age2,
    selectedCommande?.age3,
    selectedCommande?.age4,
    selectedCommande?.age5,
  ];

  // Regrouper les éprouvettes par âge
  final Map<String, List<Eprouvette>> groupedByAge = {};
  for (var epr in eprouvettes) {
    final age = epr.age ?? '';
    if (!groupedByAge.containsKey(age)) {
      groupedByAge[age] = [];
    }
    groupedByAge[age]!.add(epr);
  }

  // Motifs de non-prélèvement (à adapter selon tes données)
  final motifsNonPrelevement = [
    intervention?['motif_non_prelevement1'],
    intervention?['motif_non_prelevement2'],
    intervention?['motif_non_prelevement3'],
    intervention?['motif_non_prelevement4'],
    intervention?['motif_non_prelevement5'],
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne gauche : Âges demandés
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(agesDemande.length, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    initialValue: agesDemande[i]?.toString() ?? "",
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
                )),
              ),
            ),
            const SizedBox(width: 24),
            // Colonne droite : Âges planifiés
   Expanded(
  flex: 3,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(series.length, (i) {
      final serie = series[i];
      final ageKey = serie['Age']?.toString() ?? '';
      final typeId = serie['Forme']?.toString() ?? '';
      final typesList = typeEprouvette;
      
      // Debug détaillé de la recherche
      print('=== DEBUG Recherche Type ===');
      print('typeId recherché: "$typeId" (type: ${typeId.runtimeType})');
      print('Types disponibles dans typesList:');
      typesList.forEach((t) {
        print('  - eprvid: "${t.eprvid}" (type: ${t.eprvid.runtimeType}), eprvlabel: "${t.eprvlabel}"');
      });

      // Recherche du type d'éprouvette
      String typeLabel;
      try {
        final foundType = typesList.firstWhere(
          (t) => t.eprvid.toString() == typeId.toString(),
          orElse: () => TypeEprouvettes(eprvid: '', eprvlabel: 'Type inconnu',label: '',value: ''),
        );
        typeLabel = foundType.eprvlabel.isNotEmpty ? foundType.eprvlabel : 'Type inconnu';
        
        print('Résultat recherche: $typeLabel');
      } catch (e) {
        typeLabel = 'Erreur: $e';
        print('Erreur lors de la recherche: $e');
      }

      final nbEprouvettes = int.tryParse(serie['NbrEchantillion']?.toString() ?? "0") ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Âge planifié
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
                // Type d'éprouvette (label)
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
                // Nombre d'éprouvettes
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
            if (motifsNonPrelevement[i] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Le prélèvement d'écrasement âge ${i + 1} demandé par le chargé d'affaire n'a pas été fait, motif :",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      motifsNonPrelevement[i] ?? "",
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ), // end Column inside Padding
      ); // end Padding
    }), // end List.generate
    ), // end Column
  ), // end Expanded

          ],
        ),
      ],
    ),
  );
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

class Interventions {
  final List<Commande> commandes;
  final List<ClasseBeton> betons;
final List<ElementPredefini> elementPredefini;
final List<ModesProduction> modePro;
final List<ClasseCarrieres> carrieres;
final List<TypeCiments> typeciment;
final List<TypeAdjuvants> typeAdjuvant;
final List<TypeEprouvettes> typeEprouvette;
final Map<String, dynamic> intervention; 
final Map<String, dynamic> affaire;
final Map<String, dynamic> chargeAffaire;
final List<Elemouvrage> elementsouvrages;
  final List<Constituant> constituants;
  final List<Eprouvette> eprouvettes;
  final List<Map<String, dynamic>> series;
  Interventions({required this.commandes, required this.betons, required this.elementPredefini, required this.modePro, required this.carrieres, required this.typeciment, required this.typeAdjuvant, required this.typeEprouvette, required this.intervention, required this.affaire, required this.chargeAffaire,required this.elementsouvrages,    required this.constituants, required this.eprouvettes, required this.series});
}
