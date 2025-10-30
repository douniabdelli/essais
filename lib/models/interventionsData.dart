class InterventionData {
  final List<dynamic> elementsOuvrages;
  final List<dynamic> constituants;
  final List<dynamic> series;
  final List<dynamic> eprouvettes;
  final Map<String, dynamic> intervention;
  final List<dynamic> commandes;
  final Map<String, dynamic> affaire;
  final Map<String, dynamic> user;
  final List<dynamic> familleElements;
  final Map<String, dynamic> modeProduction;
  final List<dynamic> beton;
  final List<dynamic> chantier;
  final List<dynamic> modesProduction;
  final List<dynamic> typesAdditifs;
  final List<dynamic> typesAdjuvants;
  final List<dynamic> typesCiments;
  final List<dynamic> carrieres;
  final List<dynamic> typesEprouvettes;
  final List<dynamic> modesCure;
  final Map<String, dynamic> chargeAffaire;

  InterventionData({
    required this.elementsOuvrages,
    required this.constituants,
    required this.series,
    required this.eprouvettes,
    required this.intervention,
    required this.commandes,
    required this.affaire,
    required this.user,
    required this.familleElements,
    required this.modeProduction,
    required this.beton,
    required this.chantier,
    required this.modesProduction,
    required this.typesAdditifs,
    required this.typesAdjuvants,
    required this.typesCiments,
    required this.carrieres,
    required this.typesEprouvettes,
    required this.modesCure,
    required this.chargeAffaire,
    
  
  });

  factory InterventionData.fromJson(Map<String, dynamic> json) {
    return InterventionData(
      elementsOuvrages: json['elements_ouvrages'] ?? [],
      constituants: json['constituants'] ?? [],
      series: json['series'] ?? [],
      eprouvettes: json['eprouvettes'] ?? [],
      intervention: json['intervention'] ?? {},
      commandes: json['commandes'] ?? [],
      affaire: json['affaire'] ?? {},
      user: json['user'] ?? {},
      familleElements: json['famille_elements'] ?? [],
      modeProduction: json['mode_production'] ?? {},
      beton: json['beton'] ?? [],
      chantier: json['chantier'] ?? [],
      modesProduction: json['modesProduction'] ?? [],
      typesAdditifs: json['types_additifs'] ?? [],
      typesAdjuvants: json['types_adjuvants'] ?? [],
      typesCiments: json['types_ciments'] ?? [],
      carrieres: json['carrieres'] ?? [],
      typesEprouvettes: json['types_eprouvettes'] ?? [],
      modesCure: json['modes_cure'] ?? [],
      chargeAffaire: json['charge_affaire'] ?? {},
    
    );
  }
}
