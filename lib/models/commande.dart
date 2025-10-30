import 'dart:convert';

class Commande {
  final int codeCommande;
  final String numCommande;
  final String? intituleAffaire;
  final String peId;
  final String codeAffaire;
  final String codeSite;
  final String chargeAffaire;
  final String catChantier;
  final String elembloc;
  final String ouvrage;
  final String partieouvrage;
  final String bloc;
  final String localisation;
  final String? peDatePv;
final String? entrepriseRealisationNom;
final String? maitreOuvrageNom;
  final String age1;
  final String age2;
  final String age3;
  final String age4;
  final String age5;
  final String? validationLabo;
  final String userCode;
  final String nomDRLaboratoire;
  final String structureLaboratoire;
  final String typeIntervention;
  final String? motifNonPrelevement;
  final List<Entreprise> entreprises;
  final List<Bloc> blocs;
  final List<Elemouvrage> elemouvrages;
    final FamillePred? partieOuvrage;
  Commande({
    required this.codeCommande,
    required this.numCommande,
    required this.intituleAffaire,
    required this.peId,
    required this.codeAffaire,
    required this.codeSite,
    required this.chargeAffaire,
    required this.catChantier,
    required this.entreprises,
    required this.ouvrage,
    required this.partieouvrage,
    required this.localisation,
    required this.elembloc,
    required this.blocs,
    required this.elemouvrages,
    required this.peDatePv,
required this.entrepriseRealisationNom,
required this.maitreOuvrageNom,

    required this.age1,
    required this.age2,
    required this.age3,
    required this.age4,
    required this.age5,
    required this.bloc,
     required this.motifNonPrelevement,
     this.validationLabo,
    required this.userCode,
    required this.nomDRLaboratoire,
    required this.structureLaboratoire,
    required this.typeIntervention,
    required this.partieOuvrage,
  });
 static Commande empty() {
    return Commande(
      codeCommande: 0,
      numCommande: '',
      intituleAffaire: '',
      peId: '',
      codeAffaire: '',
      codeSite: '',
      chargeAffaire: '',
      catChantier: '',
      entreprises: [],
      ouvrage: '',
      partieouvrage: '',
      bloc:'',
      localisation: '',
      elembloc: '',
      blocs: [],
      elemouvrages: [],
      peDatePv: '',
entrepriseRealisationNom: '',
maitreOuvrageNom: '',

      age1: '',
      age2: '',
      age3: '',
      age4: '',
      age5: '',
      motifNonPrelevement:'',
       validationLabo:'',
      userCode:'',
      nomDRLaboratoire:'',
      structureLaboratoire:'',
      typeIntervention:'',
      partieOuvrage: FamillePred(
      id: '',
      code: '',
      mission: '',
      designation: 'Inconnue',
      type: '',
    ),

    );
  }
  
//   factory Commande.fromJson(Map<String, dynamic> json) {
//     return Commande(
//       codeCommande: json['CodeCommande'] ?? 0,
//       numCommande: json['NumCommande']?.toString() ?? '',
//       codeAffaire: json['Code_Affaire']?.toString() ?? '',
//       peId: json['pe_id']?.toString() ?? '',
//       intituleAffaire: json['IntituleAffaire']?.toString() ?? '',
//       codeSite: json['Code_Site']?.toString() ?? '',
//       chargeAffaire: json['chargedaffaire']?.toString() ?? '',
//       catChantier: json['catChantier']?.toString() ?? '',
//       entreprises: (json['TEntreRealSite'] as List? ?? [])
//           .map((e) => Entreprise.fromJson(e))
//           .toList(),
//      ouvrage: json['partie_ouvrage']?.toString() ?? '',
//      bloc: json['Bloc']?.toString() ?? '',
//      localisation: json['Localisation']?.toString() ?? '',
//      elembloc: json['bloc']?.toString() ?? '',
//      age1: json['age1']?.toString() ?? '',
//      age2: json['age2']?.toString() ?? '',
//      age3: json['age3']?.toString() ?? '',
//      age4: json['age4']?.toString() ?? '',
//      age5: json['age5']?.toString() ?? '',
//     blocs: (json['blocs'] as List? ?? [])
//           .map((e) => Bloc.fromJson(e))
//           .toList(),
//    elemouvrages: (json['elementOuvrages'] as List?)
//         ?.map((e) => Elemouvrage.fromJson(e))
//         .toList() 
//         ?? [],
// motifNonPrelevement: json['motif_non_ecrasement']?.toString() ?? '',
//  validationLabo: json['Validation_labo'],
//       userCode: json['user_code'],
//       nomDRLaboratoire: json['Nom_DR_Laboratoire'],
//       structureLaboratoire: json['Structure_Laboratoire'],
//       typeIntervention: json['TypeIntervention'],
//     );
//   }

factory Commande.fromJson(Map<String, dynamic> json) {
  // helper: convert dynamic item to Map<String, dynamic> if possible
  Map<String, dynamic> _toMap(dynamic item) {
    if (item == null) return {};
    if (item is Map) return Map<String, dynamic>.from(item);
    if (item is String) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // not JSON, fallthrough to return a map with a label
        return {'label': item};
      }
    }
    return {};
  }

  // helper: normalize a dynamic list which may contain Maps or Strings
  List<T> _mapList<T>(dynamic rawList, T Function(dynamic) mapper) {
    final out = <T>[];
    if (rawList == null) return out;
    if (rawList is List) {
      for (var e in rawList) {
        try {
          out.add(mapper(e));
        } catch (_) {
          // skip malformed entry
        }
      }
      return out;
    }
    if (rawList is Map) {
      try {
        out.add(mapper(rawList));
      } catch (_) {}
      return out;
    }
    if (rawList is String) {
      try {
        final decoded = jsonDecode(rawList);
        if (decoded is List) return _mapList(decoded, mapper);
        if (decoded is Map) return _mapList([decoded], mapper);
      } catch (_) {}
    }
    return out;
  }

  final dynamic entreprisesRaw = json['EntrepriseRealisation'] ?? json['TEntreRealSite'] ?? json['entreprises'];
  final entreprisesList = _mapList<Entreprise>(entreprisesRaw, (e) {
    final m = _toMap(e);
    return Entreprise.fromJson(m);
  });

  final blocsList = _mapList<Bloc>(json['blocs'] ?? json['Blocs'] ?? json['BlocList'], (e) {
    if (e is Map) return Bloc.fromJson(Map<String, dynamic>.from(e));
    if (e is String) return Bloc(value: e, label: e);
    return Bloc(value: e?.toString() ?? '', label: e?.toString() ?? '');
  });

  final elemOuvs = _mapList<Elemouvrage>(json['elementOuvrages'] ?? json['ElementOuvrages'] ?? json['elementOuvrage'], (e) {
    if (e is Map) return Elemouvrage.fromJson(Map<String, dynamic>.from(e));
    if (e is String) return Elemouvrage(nom: e, axe: '', file: '', niveau: '', famille: '');
    return Elemouvrage(nom: e?.toString() ?? '', axe: '', file: '', niveau: '', famille: '');
  });

  final partie= json['partie_ouvrage'];
  final partieObj = (partie is Map) ? FamillePred.fromJson(Map<String, dynamic>.from(partie)) : null;

  return Commande(
    codeCommande: json['CodeCommande'] ?? 0,
    numCommande: json['NumCommande']?.toString() ?? '',
    intituleAffaire: json['IntituleAffaire']?.toString() ?? '',
    peId: json['pe_id']?.toString() ?? '',
    peDatePv: json['pe_date_pv']?.toString() ?? '',
    codeAffaire: json['Code_Affaire']?.toString() ?? '',
    codeSite: json['Code_Site']?.toString() ?? '',
    chargeAffaire: json['chargedaffaire']?.toString() ?? '',
    catChantier: json['catChantier']?.toString() ?? '',
    entreprises: entreprisesList,
    ouvrage: json['Partie_Ouvrage']?.toString() ?? json['ouvrage']?.toString() ?? '',
    partieouvrage: json['partie_ouvrage']?.toString() ?? json['partie_ouvrage']?.toString() ??  '',
    bloc: json['Bloc']?.toString() ?? '',
    localisation: json['Localisation']?.toString() ?? '',
    elembloc: json['ElemBloc']?.toString() ?? json['bloc']?.toString() ?? '',
    age1: json['Age1']?.toString() ?? json['age1']?.toString() ?? '',
    age2: json['Age2']?.toString() ?? json['age2']?.toString() ?? '',
    age3: json['Age3']?.toString() ?? json['age3']?.toString() ?? '',
    age4: json['Age4']?.toString() ?? json['age4']?.toString() ?? '',
    age5: json['Age5']?.toString() ?? json['age5']?.toString() ?? '',
    blocs: blocsList,
    elemouvrages: elemOuvs,
    partieOuvrage: partieObj,
    motifNonPrelevement: json['motif_non_prelevement']?.toString() ?? json['motif_non_ecrasement']?.toString() ?? '',
    validationLabo: json['Validation_labo']?.toString() ?? '',
    userCode: json['user_code']?.toString() ?? '',
    nomDRLaboratoire: json['Nom_DR_Laboratoire']?.toString() ?? json['Nom_DR']?.toString() ?? '',
    structureLaboratoire: json['Structure_Laboratoire']?.toString() ?? json['Structure']?.toString() ?? '',
    typeIntervention: json['TypeIntervention']?.toString() ?? '',
    entrepriseRealisationNom: (json['EntrepriseRealisation'] is Map)
        ? (json['EntrepriseRealisation']['nom']?.toString() ?? '')
        : '',
    maitreOuvrageNom: (json['maitre_ouvrage'] is Map) ? (json['maitre_ouvrage']['nom']?.toString() ?? '') : '',
  );
}
Map<String, dynamic> toMap() {
  return {
    'NumCommande': numCommande,
    'pe_id': peId,
    'pe_date_pv': peDatePv,
    'Code_Affaire': codeAffaire,
    'Code_Site': codeSite,
    'ChargedAffaire': chargeAffaire,
    'Validation_labo': validationLabo,
    'user_code': userCode,
    'Nom_DR_Laboratoire': nomDRLaboratoire,
    'Structure_Laboratoire': structureLaboratoire,
    'TypeIntervention': typeIntervention,
    // 'Motif_non_prelevement': motifNonPrelevement,
    // 'Ouvrage': ouvrage,
    // 'Bloc': bloc,
    // 'ElemBloc': elembloc,
    // 'Localisation': localisation,
   
    // 'Partie_Ouvrage': partieOuvrage != null ? jsonEncode({
    //   'id': partieOuvrage!.id,
    //   'code': partieOuvrage!.code,
    //   'designation': partieOuvrage!.designation,
    //   'mission': partieOuvrage!.mission,
    //   'type': partieOuvrage!.type,
    // }) : '',
    // 'Entreprises': entreprisesJson,
    // 'Blocs': jsonEncode(blocs.map((b) => {'value': b.value, 'label': b.label}).toList()),
    // 'Elemouvrages': jsonEncode(elemouvrages.map((el) => {
    //   'elem_nom': el.nom,
    //   'elem_axe': el.axe,
    //   'elem_file': el.file,
    //   'elem_niveau': el.niveau,
    //   'elem_famille': el.famille,
    // }).toList()),
    'EntrepriseRealisation': entrepriseRealisationNom,
    'maitre_ouvrage': maitreOuvrageNom,
    'partie_ouvrage': partieouvrage,
  };
}
}
class Entreprise {
  final String code;
  final String nom;

  Entreprise({required this.code, required this.nom});

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
      code: json['codeEntreprise']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
    );
  }
}

class Predefini {
  final List<ElementPredefini> elementPredefini;

  Predefini({
    required this.elementPredefini,
  });

  factory Predefini.fromJson(Map<String, dynamic> json) {
    return Predefini(
      elementPredefini: (json['elementPredefini'] as List? ?? [])
          .map((e) => ElementPredefini.fromJson(e))
          .toList(),
    );
  }
}

class ElementPredefini {
  final int value;
  final String label;

  ElementPredefini({required this.value, required this.label});

  factory ElementPredefini.fromJson(Map<String, dynamic> json) {
    return ElementPredefini(
      value: json['value'] ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}


class Bloc {
  final String value;
  final String label;

  Bloc({required this.value, required this.label});

  factory Bloc.fromJson(Map<String, dynamic> json) {
    return Bloc(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}
class FamillePred {
  final String id;
  final String code;
  final String designation;
final String mission;
final String type;
  FamillePred({required this.id, required this.code, required this.mission, required this.designation, required this.type});

  factory FamillePred.fromJson(Map<String, dynamic> json) {
    return FamillePred(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      mission: json['mission']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
class Elemouvrage {
  final String nom;
  final String axe;
  final String file;
  final String niveau;
final String famille;
  Elemouvrage({
    required this.nom,
    required this.axe,
    required this.file,
    required this.niveau,
    required this.famille,
  });

  factory Elemouvrage.fromJson(Map<String, dynamic> json) {
    return Elemouvrage(
      nom: json['elem_nom'] ?? '',
      axe: json['elem_axe'] ?? '',
      file: json['elem_file'] ?? '',
      niveau: json['elem_niveau'] ?? '',
      famille: json['elem_famille'] ?? '',
    );
  }

 
  String get label {
    String details = [axe, file, niveau]
        .where((e) => e.isNotEmpty)
        .join(" - ");
    return details.isEmpty ? nom : "$nom ($details)";
  }
}




class Production {
  final List<ModesProduction> modePro;

  Production({
    required this.modePro,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      modePro: (json['elementPredefini'] as List? ?? [])
          .map((e) => ModesProduction.fromJson(e))
          .toList(),
    );
  }
}

class ModesProduction {
  final int value;
  final String label;

  ModesProduction({required this.value, required this.label});

  factory ModesProduction.fromJson(Map<String, dynamic> json) {
    return ModesProduction(
      value: json['value'] ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}
class Carrieres {
  final List<ClasseCarrieres> carrieres;

  Carrieres({required this.carrieres});

  factory Carrieres.fromJson(Map<String, dynamic> json) {
    return Carrieres(
      carrieres: (json['carrieres'] as List? ?? [])
          .map((e) => ClasseCarrieres.fromJson(e))
          .toList(),
    );
  }
}

class ClasseCarrieres {
  final int value;
  final String label;

  ClasseCarrieres({required this.value, required this.label});

  factory ClasseCarrieres.fromJson(Map<String, dynamic> json) {
    return ClasseCarrieres(
      value: int.tryParse(json['value'].toString()) ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}


class Ciment {
  final List<TypeCiments> typeciment;

  Ciment({required this.typeciment});

  factory Ciment.fromJson(Map<String, dynamic> json) {
    return Ciment(
      typeciment: (json['types_ciments'] as List? ?? [])
          .map((e) => TypeCiments.fromJson(e))
          .toList(),
    );
  }
}

class TypeCiments {
  final int value;
  final String label;

  TypeCiments({required this.value, required this.label});

  factory TypeCiments.fromJson(Map<String, dynamic> json) {
    return TypeCiments(
      value: int.tryParse(json['value'].toString()) ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}


class Typeadjuvant{
  final List<TypeAdjuvants> typeAdjuvant;

  Typeadjuvant({required this.typeAdjuvant});

  factory Typeadjuvant.fromJson(Map<String, dynamic> json) {
    return Typeadjuvant(
      typeAdjuvant: (json['types_adjuvants'] as List? ?? [])
          .map((e) => TypeAdjuvants.fromJson(e))
          .toList(),
    );
  }
}

class TypeAdjuvants {
  final int value;
  final String label;

  TypeAdjuvants({required this.value, required this.label});

  factory TypeAdjuvants.fromJson(Map<String, dynamic> json) {
    return TypeAdjuvants(
      value: int.tryParse(json['value'].toString()) ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}
class TypeEprouvette{
  final List<TypeEprouvettes> typeEprouvette;

  TypeEprouvette({required this.typeEprouvette});

  factory TypeEprouvette.fromJson(Map<String, dynamic> json) {
    return TypeEprouvette(
      typeEprouvette: (json['types_eprouvettes'] as List? ?? [])
          .map((e) => TypeEprouvettes.fromJson(e))
          .toList(),
    );
  }
}
class TypeEprouvettes {
final String value;
  final String eprvid;
  final String eprvlabel;
  final String label;
  TypeEprouvettes({required this.value, required this.eprvid, required this.eprvlabel, required this.label });
  factory TypeEprouvettes.fromJson(Map<String, dynamic> json) {
    return TypeEprouvettes(
      value: json['label'].toString(),
   label: json['label'].toString(),
      eprvid: json['eprv_id'].toString(),
      eprvlabel: json['eprv_type'] ?? '',
    );
  }


}

class BlocElemSelection {
  Bloc? bloc;
  Elemouvrage? elemouvrage;

  BlocElemSelection({this.bloc, this.elemouvrage});
}
class Constituant {
  final String fbId;
  final String fbProvenance;
  final String? fbType;
  final int fbDosage;
  final int? fbDmin;
  final int? fbDmax;
  final String fbConstituant;
  final String fbPrelevement;
  final String fbAffaire;
  final String fbSite;
  final String? fbPv;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Constituant({
    required this.fbId,
    required this.fbProvenance,
    required this.fbType,
    required this.fbDosage,
    required this.fbDmin,
    required this.fbDmax,
    required this.fbConstituant,
    required this.fbPrelevement,
    required this.fbAffaire,
    required this.fbSite,
    required this.fbPv,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Constituant.fromJson(Map<String, dynamic> json) {
 print('Constituant reçu: $json');
  print('fb_type: ${json['fb_type']} (${json['fb_type']?.runtimeType})');
  print('fb_dmin: ${json['fb_dmin']} (${json['fb_dmin']?.runtimeType})');
  print('fb_dmax: ${json['fb_dmax']} (${json['fb_dmax']?.runtimeType})');
  print('fb_pv: ${json['fb_pv']} (${json['fb_pv']?.runtimeType})');;
    return Constituant(
      fbId: json['fb_id']?.toString() ?? '',
      fbProvenance: json['fb_provenance']?.toString() ?? '',
      fbType: json['fb_type'] != null ? json['fb_type'].toString() : null,
      fbDosage: json['fb_dosage'] ?? 0,
      fbDmin: json['fb_dmin'] != null ? int.tryParse(json['fb_dmin'].toString()) : null,
      fbDmax: json['fb_dmax'] != null ? int.tryParse(json['fb_dmax'].toString()) : null,
      fbConstituant: json['fb_constituant']?.toString() ?? '',
      fbPrelevement: json['fb_prelevement']?.toString() ?? '',
      fbAffaire: json['fb_affaire']?.toString() ?? '',
      fbSite: json['fb_site']?.toString() ?? '',
      fbPv: json['fb_pv'] != null ? json['fb_pv'].toString() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
class Eprouvette {
  final String id;
  final String eprId;
  final String peInterventionCtc;
  final String? eprPvCtc;
  final String? eprPvEtb;
  final String? eprSpvEtb;
  final String numCommande;
  final String eprCode;
  final String eprEntrpCtc;
  final String? eprRef;
  final String? eprFci;
  final String? eprDensite;
  final String? eprSection;
  final String? eprMasse;
  final String? eprHauteur;
  final String? eprCote;
  final String? eprCharge;
  final String? eprType;
  final String? eprModecure;
  final String? age;
  final String? numSerie;
  final String? recu;
  final String? ecrasement;
  final String? nomDr;
  final String? structure;
  final String? datePrelevement;
  final String? dateEssaiPrevisionnelle;
  final String? dateCoulage;
  final String? dateEcrasement;
  final String? dateReception;
  final String? codeAffaire;
  final String? codeSite;
  final String? typeEchantillon;
  final String? lieu;
  final String? fck;
  final String? rqb;
  final String? rqbi;
  final String? nonEcrasable;
  final String? modeRupture;
  final String? modeCure;
  final String? receivedBy;
  final String? updatedAt;
  final String? createdAt;
  final String? motifNonEcrasement;

  Eprouvette({
    required this.id,
    required this.eprId,
    required this.peInterventionCtc,
    this.eprPvCtc,
    this.eprPvEtb,
    this.eprSpvEtb,
    required this.numCommande,
    required this.eprCode,
    required this.eprEntrpCtc,
    this.eprRef,
    this.eprFci,
    this.eprDensite,
    this.eprSection,
    this.eprMasse,
    this.eprHauteur,
    this.eprCote,
    this.eprCharge,
    this.eprType,
    this.eprModecure,
    this.age,
    this.numSerie,
    this.recu,
    this.ecrasement,
    this.nomDr,
    this.structure,
    this.datePrelevement,
    this.dateEssaiPrevisionnelle,
    this.dateCoulage,
    this.dateEcrasement,
    this.dateReception,
    this.codeAffaire,
    this.codeSite,
    this.typeEchantillon,
    this.lieu,
    this.fck,
    this.rqb,
    this.rqbi,
    this.nonEcrasable,
    this.modeRupture,
    this.modeCure,
    this.receivedBy,
    this.updatedAt,
    this.createdAt,
    this.motifNonEcrasement,
  });

  factory Eprouvette.fromJson(Map<String, dynamic> json) {
    return Eprouvette(
      id: json['id']?.toString() ?? '',
      eprId: json['epr_id']?.toString() ?? '',
      peInterventionCtc: json['pe_intervention_ctc']?.toString() ?? '',
      eprPvCtc: json['epr_pv_ctc']?.toString(),
      eprPvEtb: json['epr_pv_etb']?.toString(),
      eprSpvEtb: json['epr_spv_etb']?.toString(),
      numCommande: json['NumCommande']?.toString() ?? '',
      eprCode: json['epr_code']?.toString() ?? '',
      eprEntrpCtc: json['epr_entrp_ctc']?.toString() ?? '',
      eprRef: json['epr_ref']?.toString(),
      eprFci: json['epr_fci']?.toString(),
      eprDensite: json['epr_densite']?.toString(),
      eprSection: json['epr_section']?.toString(),
      eprMasse: json['epr_masse']?.toString(),
      eprHauteur: json['epr_hauteur']?.toString(),
      eprCote: json['epr_cote']?.toString(),
      eprCharge: json['epr_charge']?.toString(),
      eprType: json['epr_type']?.toString(),
      eprModecure: json['epr_modecure']?.toString(),
      age: json['Age']?.toString(),
      numSerie: json['NumSerie']?.toString(),
      recu: json['recu']?.toString(),
      ecrasement: json['ecrasement']?.toString(),
      nomDr: json['Nom_DR']?.toString(),
      structure: json['Structure']?.toString(),
      datePrelevement: json['DatePrelevement']?.toString(),
      dateEssaiPrevisionnelle: json['DateEssaiPrevisionnelle']?.toString(),
      dateCoulage: json['DateCoulage']?.toString(),
      dateEcrasement: json['DateEcrasement']?.toString(),
      dateReception: json['DateReception']?.toString(),
      codeAffaire: json['Code_Affaire']?.toString(),
      codeSite: json['Code_Site']?.toString(),
      typeEchantillon: json['typeEchantillon']?.toString(),
      lieu: json['lieu']?.toString(),
      fck: json['fck']?.toString(),
      rqb: json['rqb']?.toString(),
      rqbi: json['rqbi']?.toString(),
      nonEcrasable: json['non_ecrasable']?.toString(),
      modeRupture: json['mode_rupture']?.toString(),
      modeCure: json['mode_cure']?.toString(),
      receivedBy: json['received_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      motifNonEcrasement: json['Motif_non_ecrasement']?.toString(),
    );
  }
}