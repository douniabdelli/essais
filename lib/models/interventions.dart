import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';

// Aggregated data returned by the services to the intervention screens

class Interventions {
  final List<Commande> commandes;
  final List<ClasseBeton> betons;
  final List<ElementPredefini> elementPredefini;
  final List<ModesProduction> modePro;
  final List<ClasseCarrieres> carrieres;
  final List<TypeCiments> typeciment;
  final List<TypeAdjuvants> typeAdjuvant;
  final List<TypeEprouvettes> typeEprouvette;

  // Additional runtime data used by some screens
  final Map<String, dynamic> intervention;
  final Map<String, dynamic> affaire;
  final Map<String, dynamic> chargeAffaire;
  final List<Elemouvrage> elementsouvrages;
  final List<Constituant> constituants;
  final List<Eprouvette> eprouvettes;
  final List<Map<String, dynamic>> series;
// final Map<String, dynamic> interventionuser;
  Interventions({
    required this.commandes,
    required this.betons,
    required this.elementPredefini,
    required this.modePro,
    required this.carrieres,
    required this.typeciment,
    required this.typeAdjuvant,
    required this.typeEprouvette,
    required this.intervention,
    required this.affaire,
    required this.chargeAffaire,
    required this.elementsouvrages,
    // required this.interventionuser,
    required this.constituants,
    required this.eprouvettes,
    required this.series,
  });
  String get chargeAffaireInfo {
    final matricule = chargeAffaire['Matricule'] ?? '';
    final nom = chargeAffaire['Nom'] ?? '';
    final prenom = chargeAffaire['Prénom'] ?? '';
    return '$matricule - $nom $prenom'.trim();
  }

  // Getter pour les données simplifiées (pour stockage local)
  Map<String, String> get chargeAffaireSimplified {
    return {
      'Matricule': chargeAffaire['Matricule']?.toString() ?? '',
      'Nom': chargeAffaire['Nom']?.toString() ?? '',
      'Prénom': chargeAffaire['Prénom']?.toString() ?? '',
    };
  }




  factory Interventions.fromJson(Map<String, dynamic> json) {
  return Interventions(
    series: List<Map<String, dynamic>>.from(json['series'] ?? []),
    commandes: (json['commandes'] ?? [])
        .map<Commande>((c) => Commande.fromJson(c))
        .toList(),
    betons: (json['beton'] ?? [])
        .map<ClasseBeton>((b) => ClasseBeton.fromJson(b))
        .toList(),
    elementPredefini: (json['famille_elements'] ?? [])
        .map<ElementPredefini>((e) => ElementPredefini.fromJson(e))
        .toList(),
    modePro: (json['modesProduction'] ?? [])
        .map<ModesProduction>((e) => ModesProduction.fromJson(e))
        .toList(),
    carrieres: (json['carrieres'] ?? [])
        .map<ClasseCarrieres>((c) => ClasseCarrieres.fromJson(c))
        .toList(),
    typeciment: (json['types_ciments'] ?? [])
        .map<TypeCiments>((c) => TypeCiments.fromJson(c))
        .toList(),
    typeAdjuvant: (json['types_adjuvants'] ?? [])
        .map<TypeAdjuvants>((c) => TypeAdjuvants.fromJson(c))
        .toList(),
    typeEprouvette: (json['types_eprouvettes'] ?? [])
        .map<TypeEprouvettes>((c) => TypeEprouvettes.fromJson(c))
        .toList(),
    constituants: (json['constituants'] ?? [])
        .map<Constituant>((c) => Constituant.fromJson(c))
        .toList(),
    eprouvettes: (json['eprouvettes'] ?? [])
        .map<Eprouvette>((c) => Eprouvette.fromJson(c))
        .toList(),
    elementsouvrages: (json['elements_ouvrages'] ?? [])
        .map<Elemouvrage>((e) => Elemouvrage.fromJson(e))
        .toList(),

            // interventionuser: Map<String, dynamic>.from(json['user'] ?? {}),
    intervention: Map<String, dynamic>.from(json['intervention'] ?? {}),
    affaire: Map<String, dynamic>.from(json['affaire'] ?? {}),
    chargeAffaire: Map<String, dynamic>.from(json['charge_affaire'] ?? {}),
  );
}

}