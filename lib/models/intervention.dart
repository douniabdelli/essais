import 'dart:convert';

class EntrepriseRealisation {
  final String code;
  final String nom;
  final String? adr;
  final String? tel;
  final String? fax;
  final String? email;
  final String? siteWeb;
  final String? wilaya;
  final String? commune;
  final String? categorieTier;
  final String? dateModif;
  final String? dateArrivSrv;
  final String? nomDr;

  EntrepriseRealisation({
    required this.code,
    required this.nom,
    this.adr,
    this.tel,
    this.fax,
    this.email,
    this.siteWeb,
    this.wilaya,
    this.commune,
    this.categorieTier,
    this.dateModif,
    this.dateArrivSrv,
    this.nomDr,
  });

  factory EntrepriseRealisation.fromJson(Map<String, dynamic> json) {
    return EntrepriseRealisation(
      code: json['code'] ?? '',
      nom: json['nom'] ?? '',
      adr: json['adr'],
      tel: json['tel'],
      fax: json['fax'],
      email: json['email'],
      siteWeb: json['SiteWeb'],
      wilaya: json['Wilaya'],
      commune: json['Commune'],
      categorieTier: json['CategorieTier'],
      dateModif: json['DateModif'],
      dateArrivSrv: json['DateArrivSrv'],
      nomDr: json['Nom_DR'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nom': nom,
      'adr': adr,
      'tel': tel,
      'fax': fax,
      'email': email,
      'SiteWeb': siteWeb,
      'Wilaya': wilaya,
      'Commune': commune,
      'CategorieTier': categorieTier,
      'DateModif': dateModif,
      'DateArrivSrv': dateArrivSrv,
      'Nom_DR': nomDr,
    };
  }
}

class MaitreOuvrage {
  final String code;
  final String nom;
  final String? adr;
  final String? tel;
  final String? fax;
  final String? email;
  final String? siteWeb;
  final String? wilaya;
  final String? commune;
  final String? categorieTier;
  final String? abrevation;
  final String? familleMouvrage;
  final String? tutelleTiers;
  final String? groupeTiers;
  final String? secteur;

  // Ajout des propriétés manquantes
  final String? motDePasse;
  final String? validUser;
  final String? compteComptable;
  final String? nomDr;
  final String? adrArb;
  final String? abrevationArb;
  final String? nomArb;
  final String? nation;
  final String? isEtrangere;

  MaitreOuvrage({
    required this.code,
    required this.nom,
    this.adr,
    this.tel,
    this.fax,
    this.email,
    this.siteWeb,
    this.wilaya,
    this.commune,
    this.categorieTier,
    this.abrevation,
    this.familleMouvrage,
    this.tutelleTiers,
    this.groupeTiers,
    this.secteur,
    this.motDePasse,
    this.validUser,
    this.compteComptable,
    this.nomDr,
    this.adrArb,
    this.abrevationArb,
    this.nomArb,
    this.nation,
    this.isEtrangere,
  });

  factory MaitreOuvrage.fromJson(Map<String, dynamic> json) {
    return MaitreOuvrage(
      code: json['code'] ?? '',
      nom: json['nom'] ?? '',
      adr: json['adr'],
      tel: json['tel'],
      fax: json['fax'],
      email: json['email'],
      siteWeb: json['SiteWeb'],
      wilaya: json['Wilaya'],
      commune: json['Commune'],
      categorieTier: json['CategorieTier'],
      abrevation: json['Abrevation'],
      familleMouvrage: json['FamilleMouvrage'],
      tutelleTiers: json['TutelleTiers'],
      groupeTiers: json['GroupeTiers'],
      secteur: json['Secteur'],
      motDePasse: json['MotDePasse'],
      validUser: json['ValidUser'],
      compteComptable: json['CompteComptable'],
      nomDr: json['Nom_DR'],
      adrArb: json['adrArb'],
      abrevationArb: json['AbrevationArb'],
      nomArb: json['nomArb'],
      nation: json['Nation'],
      isEtrangere: json['isEtrangere'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nom': nom,
      'adr': adr,
      'tel': tel,
      'fax': fax,
      'email': email,
      'SiteWeb': siteWeb,
      'Wilaya': wilaya,
      'Commune': commune,
      'CategorieTier': categorieTier,
      'Abrevation': abrevation,
      'FamilleMouvrage': familleMouvrage,
      'TutelleTiers': tutelleTiers,
      'GroupeTiers': groupeTiers,
      'Secteur': secteur,
      'MotDePasse': motDePasse,
      'ValidUser': validUser,
      'CompteComptable': compteComptable,
      'Nom_DR': nomDr,
      'adrArb': adrArb,
      'AbrevationArb': abrevationArb,
      'nomArb': nomArb,
      'Nation': nation,
      'isEtrangere': isEtrangere,
    };
  }
}

class Intervention {
  final String structure;
  final String nomDr;
  final String codeAffaire;
  final String numCommande;
  final String peId;
  final String peDatePv;
  final String datevalidationpm;
  final EntrepriseRealisation entrepriseRealisation;
  final MaitreOuvrage maitreOuvrage;
  final String? bet;
  final Map<String, dynamic> chargedaffaire;
  final String? validationLabo;
  final String userCode;
  final String nomDrLaboratoire;
  final String structureLaboratoire;
  final String typeIntervention;
  final String? intituleAffaire;
  final String? codeSite;
  final String? motifNonPrelevement;
  final String? ouvrage;
  final String? bloc;
  final String? elemBloc;
  final String? localisation;
  final String? partieOuvrage;
  final List<dynamic>? entreprises;
  final List<dynamic>? blocs;
  final List<dynamic>? elemouvrages;
  final String? age1;
  final String? age2;
  final String? age3;
  final String? age4;
  final String? age5;

  Intervention({
    required this.structure,
    required this.nomDr,
    required this.codeAffaire,
    required this.numCommande,
    required this.peId,
    required this.peDatePv,
    required this.entrepriseRealisation,
    required this.maitreOuvrage,
    required this.datevalidationpm,
    this.bet,
    required this.chargedaffaire,
    this.validationLabo,
    required this.userCode,
    required this.nomDrLaboratoire,
    required this.structureLaboratoire,
    required this.typeIntervention,
    this.intituleAffaire,
    required this.codeSite,
    this.motifNonPrelevement,
    this.ouvrage,
    this.bloc,
    this.elemBloc,
    this.localisation,
    this.partieOuvrage,
    this.entreprises,
    this.blocs,
    this.elemouvrages,
    this.age1,
    this.age2,
    this.age3,
    this.age4,
    this.age5,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      structure: json['Structure'] ?? '',
      nomDr: json['Nom_DR']?.toString().trim() ?? '',
      codeAffaire: json['Code_Affaire'] ?? '',
      numCommande: json['C'] ?? '',
      peId: json['pe_id'] ?? '',
      peDatePv: json['pe_date_pv'] ?? '',
      datevalidationpm: json['date_validation_pm'] ?? '',
      entrepriseRealisation: EntrepriseRealisation.fromJson(json['EntrepriseRealisation'] ?? {}),
      maitreOuvrage: MaitreOuvrage.fromJson(json['maitre_ouvrage'] ?? {}),
      bet: json['bet'],
      chargedaffaire: json['chargedaffaire'] != null
          ? json['chargedaffaire'] as Map<String, dynamic>
          : {},


      validationLabo: json['Validation_labo'],
      userCode: json['user_code'] ?? '',
      nomDrLaboratoire: json['Nom_DR_Laboratoire'] ?? '',
      structureLaboratoire: json['Structure_Laboratoire'] ?? '',
      typeIntervention: json['TypeIntervention'] ?? '',
      intituleAffaire: json['IntituleAffaire'],
      codeSite: json['Code_Site'],
      motifNonPrelevement: json['Motif_non_prelevement'],
      ouvrage: json['Ouvrage'],
      bloc: json['Bloc'],
      elemBloc: json['ElemBloc'],
      localisation: json['Localisation'],
      partieOuvrage: json['Partie_Ouvrage'],
      entreprises: json['Entreprises'] != null 
          ? jsonDecode(json['Entreprises']) 
          : null,
      blocs: json['Blocs'] != null 
          ? jsonDecode(json['Blocs']) 
          : null,
      elemouvrages: json['Elemouvrages'] != null 
          ? jsonDecode(json['Elemouvrages']) 
          : null,
      age1: json['Age1'],
      age2: json['Age2'],
      age3: json['Age3'],
      age4: json['Age4'],
      age5: json['Age5'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Structure': structure,
      'Nom_DR': nomDr,
      'Code_Affaire': codeAffaire,
      'NumCommande': numCommande,
      'pe_id': peId,
      'pe_date_pv': peDatePv,
      'date_validation_pm': datevalidationpm,
      'EntrepriseRealisation': entrepriseRealisation.toJson(),
      'maitre_ouvrage': maitreOuvrage.toJson(),
      'bet': bet,
      'chargedaffaire': chargedaffaire,
      'Validation_labo': validationLabo,
      'user_code': userCode,
      'Nom_DR_Laboratoire': nomDrLaboratoire,
      'Structure_Laboratoire': structureLaboratoire,
      'TypeIntervention': typeIntervention,
      'IntituleAffaire': intituleAffaire,
      'Code_Site': codeSite,
      'Motif_non_prelevement': motifNonPrelevement,
      'Ouvrage': ouvrage,
      'Bloc': bloc,
      'ElemBloc': elemBloc,
      'Localisation': localisation,
      'Partie_Ouvrage': partieOuvrage,
      'Entreprises': entreprises != null ? jsonEncode(entreprises) : null,
      'Blocs': blocs != null ? jsonEncode(blocs) : null,
      'Elemouvrages': elemouvrages != null ? jsonEncode(elemouvrages) : null,
      'Age1': age1,
      'Age2': age2,
      'Age3': age3,
      'Age4': age4,
      'Age5': age5,
    };
  }
}
