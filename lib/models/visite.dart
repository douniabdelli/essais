import 'dart:convert';
import 'dart:convert' show utf8;

class Visite {
  final String Code_Affaire;
  final String Code_site;
  final String matricule;
  final String siteImage;
  final String VisitSiteDate;
  final String VisitSite_Btn_terrain_accessible;
  final String VisitSiteterrain_accessible;
  final String VisitSite_Btn_terrain_cloture;
  final String VisitSiteterrain_cloture;
  final String VisitSite_Btn_terrain_nu;
  final String VisitSiteterrain_nu;
  final String VisitSite_Btn_presence_vegetation;
  final String VisitSitePresVeget;
  final String VisitSite_Btn_presence_pylones;
  final String VisitSite_presence_pylones;
  final String VisitSite_Btn_existance_mitoyntehab;
  // existence mitoyenneté
  final String VisitSiteExistantsvoisin;
  final String VisitSite_Btn_existance_voirie_mitoyenne;
  final String VisitSite_existance_voirie_mitoyenne;
  final String VisitSite_Btn_presence_remblais;
  final String VisitSitePresDepotremblai;
  final String VisitSite_Btn_presence_sources_cours_eau_cavite;
  // presence_sources_cours_eau_cavite
  final String VisitSiteEngHabitant;
  final String VisitSite_Btn_presence_talwegs;
  // presence_talwegs
  final String visitesitePresDepotremblai;
  final String VisitSite_Btn_terrain_inondable;
  final String VisitSite_terrain_inondable;
  final String VisitSite_Btn_terrain_enpente;
  final String VisitSite_terrain_enpente;
  final String VisitSite_Btn_risque_InstabiliteGlisTerrain;
  final String VisitSite_risque_InstabiliteGlisTerrain;
  final String VisitSite_Btn_terrassement_entame;
  final String VisitSite_terrassement_entame;
  // observation
  final String VisitSiteAutre;
  final String VisitSite_Btn_Presence_risque_instab_terasmt;
  final String VisitSite_Btn_necessite_courrier_MO_risque_encouru;
  final String VisitSite_Btn_doc_annexe;
  final String VisitSite_liste_present;
  final String ValidCRVPIng;

  const Visite({
    required this.Code_Affaire,
    required this.Code_site,
    required this.matricule,
    required this.siteImage,
    required this.VisitSiteDate,
    required this.VisitSite_Btn_terrain_accessible,
    required this.VisitSiteterrain_accessible,
    required this.VisitSite_Btn_terrain_cloture,
    required this.VisitSiteterrain_cloture,
    required this.VisitSite_Btn_terrain_nu,
    required this.VisitSiteterrain_nu,
    required this.VisitSite_Btn_presence_vegetation,
    required this.VisitSitePresVeget,
    required this.VisitSite_Btn_presence_pylones,
    required this.VisitSite_presence_pylones,
    required this.VisitSite_Btn_existance_mitoyntehab,
    // existence mitoyenneté
    required this.VisitSiteExistantsvoisin,
    required this.VisitSite_Btn_existance_voirie_mitoyenne,
    required this.VisitSite_existance_voirie_mitoyenne,
    required this.VisitSite_Btn_presence_remblais,
    required this.VisitSitePresDepotremblai,
    required this.VisitSite_Btn_presence_sources_cours_eau_cavite,
    // presence_sources_cours_eau_cavite
    required this.VisitSiteEngHabitant,
    required this.VisitSite_Btn_presence_talwegs,
    // presence_talwegs
    required this.visitesitePresDepotremblai,
    required this.VisitSite_Btn_terrain_inondable,
    required this.VisitSite_terrain_inondable,
    required this.VisitSite_Btn_terrain_enpente,
    required this.VisitSite_terrain_enpente,
    required this.VisitSite_Btn_risque_InstabiliteGlisTerrain,
    required this.VisitSite_risque_InstabiliteGlisTerrain,
    required this.VisitSite_Btn_terrassement_entame,
    required this.VisitSite_terrassement_entame,
    // observation
    required this.VisitSiteAutre,
    required this.VisitSite_Btn_Presence_risque_instab_terasmt,
    required this.VisitSite_Btn_necessite_courrier_MO_risque_encouru,
    required this.VisitSite_Btn_doc_annexe,
    required this.VisitSite_liste_present,
    required this.ValidCRVPIng,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      Code_Affaire: json['Code_Affaire'].toString(),
      Code_site: json['Code_site'].toString(),
      matricule: json['matricule'].toString(),
      siteImage: json['siteImage'].toString(),
      VisitSiteDate: json['VisitSiteDate'].toString(),
      VisitSite_Btn_terrain_accessible: (json['VisitSite_Btn_terrain_accessible'] == 'Oui' || json['VisitSite_Btn_terrain_accessible'] == '1') ? '1' : ((json['VisitSite_Btn_terrain_accessible'] == 'Non' || json['VisitSite_Btn_terrain_accessible'] == '0') ? '0' : ''),
      VisitSiteterrain_accessible: json['VisitSiteterrain_accessible'].toString(),
      VisitSite_Btn_terrain_cloture: (json['VisitSite_Btn_terrain_cloture'] == 'Oui' || json['VisitSite_Btn_terrain_cloture'] == '1') ? '1' : ((json['VisitSite_Btn_terrain_cloture'] == 'Non' || json['VisitSite_Btn_terrain_cloture'] == '0') ? '0' : ''),
      VisitSiteterrain_cloture: json['VisitSiteterrain_cloture'].toString(),
      VisitSite_Btn_terrain_nu: (json['VisitSite_Btn_terrain_nu'] == 'Oui' || json['VisitSite_Btn_terrain_nu'] == '1') ? '1' : ((json['VisitSite_Btn_terrain_nu'] == 'Non' || json['VisitSite_Btn_terrain_nu'] == '0') ? '0' : ''),
      VisitSiteterrain_nu: json['VisitSiteterrain_nu'].toString(),
      VisitSite_Btn_presence_vegetation: (json['VisitSite_Btn_presence_vegetation'] == 'Oui' || json['VisitSite_Btn_presence_vegetation'] == '1') ? '1' : ((json['VisitSite_Btn_presence_vegetation'] == 'Non' || json['VisitSite_Btn_presence_vegetation'] == '0') ? '0' : ''),
      VisitSitePresVeget: json['VisitSitePresVeget'].toString(),
      VisitSite_Btn_presence_pylones: (json['VisitSite_Btn_presence_pylones'] == 'Oui' || json['VisitSite_Btn_presence_pylones'] == '1') ? '1' : ((json['VisitSite_Btn_presence_pylones'] == 'Non' || json['VisitSite_Btn_presence_pylones'] == '0') ? '0' : ''),
      VisitSite_presence_pylones: json['VisitSite_presence_pylones'].toString(),
      VisitSite_Btn_existance_mitoyntehab: (json['VisitSite_Btn_existance_mitoyntehab'] == 'Oui' || json['VisitSite_Btn_existance_mitoyntehab'] == '1') ? '1' : ((json['VisitSite_Btn_existance_mitoyntehab'] == 'Non' || json['VisitSite_Btn_existance_mitoyntehab'] == '0') ? '0' : ''),
      VisitSiteExistantsvoisin: json['VisitSiteExistantsvoisin'].toString(),
      VisitSite_Btn_existance_voirie_mitoyenne: (json['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Oui' || json['VisitSite_Btn_existance_voirie_mitoyenne'] == '1') ? '1' : ((json['VisitSite_Btn_existance_voirie_mitoyenne'] == 'Non' || json['VisitSite_Btn_existance_voirie_mitoyenne'] == '0') ? '0' : ''),
      VisitSite_existance_voirie_mitoyenne: json['VisitSite_existance_voirie_mitoyenne'].toString(),
      VisitSite_Btn_presence_remblais: (json['VisitSite_Btn_presence_remblais'] == 'Oui' || json['VisitSite_Btn_presence_remblais'] == '1') ? '1' : ((json['VisitSite_Btn_presence_remblais'] == 'Non' || json['VisitSite_Btn_presence_remblais'] == '0') ? '0' : ''),
      VisitSitePresDepotremblai: json['VisitSitePresDepotremblai'].toString(),
      VisitSite_Btn_presence_sources_cours_eau_cavite: (json['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Oui' || json['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '1') ? '1' : ((json['VisitSite_Btn_presence_sources_cours_eau_cavite'] == 'Non' || json['VisitSite_Btn_presence_sources_cours_eau_cavite'] == '0') ? '0' : ''),
      VisitSiteEngHabitant: json['VisitSiteEngHabitant'].toString(),
      VisitSite_Btn_presence_talwegs: (json['VisitSite_Btn_presence_talwegs'] == 'Oui' || json['VisitSite_Btn_presence_talwegs'] == '1') ? '1' : ((json['VisitSite_Btn_presence_talwegs'] == 'Non' || json['VisitSite_Btn_presence_talwegs'] == '0') ? '0' : ''),
      visitesitePresDepotremblai: json['visitesitePresDepotremblai'].toString(),
      VisitSite_Btn_terrain_inondable: (json['VisitSite_Btn_terrain_inondable'] == 'Oui' || json['VisitSite_Btn_terrain_inondable'] == '1') ? '1' : ((json['VisitSite_Btn_terrain_inondable'] == 'Non' || json['VisitSite_Btn_terrain_inondable'] == '0') ? '0' : ''),
      VisitSite_terrain_inondable: json['VisitSite_terrain_inondable'].toString(),
      VisitSite_Btn_terrain_enpente: (json['VisitSite_Btn_terrain_enpente'] == 'Oui' || json['VisitSite_Btn_terrain_enpente'] == '1') ? '1' : ((json['VisitSite_Btn_terrain_enpente'] == 'Non' || json['VisitSite_Btn_terrain_enpente'] == '0') ? '0' : ''),
      VisitSite_terrain_enpente: json['VisitSite_terrain_enpente'].toString(),
      VisitSite_Btn_risque_InstabiliteGlisTerrain: (json['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Oui' || json['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '1') ? '1' : ((json['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == 'Non' || json['VisitSite_Btn_risque_InstabiliteGlisTerrain'] == '0') ? '0' : ''),
      VisitSite_risque_InstabiliteGlisTerrain: json['VisitSite_risque_InstabiliteGlisTerrain'].toString(),
      VisitSite_Btn_terrassement_entame: (json['VisitSite_Btn_terrassement_entame'] == 'Oui' || json['VisitSite_Btn_terrassement_entame'] == '1') ? '1' : ((json['VisitSite_Btn_terrassement_entame'] == 'Non' || json['VisitSite_Btn_terrassement_entame'] == '0') ? '0' : ''),
      VisitSite_terrassement_entame: json['VisitSite_terrassement_entame'].toString(),
      VisitSiteAutre: json['VisitSiteAutre'].toString(),
      VisitSite_Btn_Presence_risque_instab_terasmt: (json['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Oui' || json['VisitSite_Btn_Presence_risque_instab_terasmt'] == '1') ? '1' : ((json['VisitSite_Btn_Presence_risque_instab_terasmt'] == 'Non' || json['VisitSite_Btn_Presence_risque_instab_terasmt'] == '0') ? '0' : ''),
      VisitSite_Btn_necessite_courrier_MO_risque_encouru: (json['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Oui' || json['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '1') ? '1' : ((json['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == 'Non' || json['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] == '0') ? '0' : ''),
      VisitSite_Btn_doc_annexe: (json['VisitSite_Btn_doc_annexe'] == 'Oui' || json['VisitSite_Btn_doc_annexe'] == '1') ? '1' : ((json['VisitSite_Btn_doc_annexe'] == 'Non' || json['VisitSite_Btn_doc_annexe'] == '0') ? '0' : ''),
      VisitSite_liste_present: json['VisitSite_liste_present'].toString(),
      ValidCRVPIng: (json['ValidCRVPIng'] == 'Oui' || json['ValidCRVPIng'] == '1') ? '1' : ((json['ValidCRVPIng'] == 'Non' || json['ValidCRVPIng'] == '0') ? '0' : ''),
    );
  }

  static Map<String, dynamic> toMap(Visite model) =>
      <String, dynamic> {
        'Code_Affaire': model.Code_Affaire,
        'Code_site': model.Code_site,
        'matricule': model.matricule,
        'siteImage': model.siteImage,
        'VisitSiteDate': model.VisitSiteDate,
        'VisitSite_Btn_terrain_accessible': (model.VisitSite_Btn_terrain_accessible == 'Oui' || model.VisitSite_Btn_terrain_accessible == '1') ? '1' : ((model.VisitSite_Btn_terrain_accessible == 'Non' || model.VisitSite_Btn_terrain_accessible == '0') ? '0' : ''),
        'VisitSiteterrain_accessible': model.VisitSiteterrain_accessible,
        'VisitSite_Btn_terrain_cloture': (model.VisitSite_Btn_terrain_cloture == 'Oui' || model.VisitSite_Btn_terrain_cloture == '1') ? '1' : ((model.VisitSite_Btn_terrain_cloture == 'Non' || model.VisitSite_Btn_terrain_cloture == '0') ? '0' : ''),
        'VisitSiteterrain_cloture': model.VisitSiteterrain_cloture,
        'VisitSite_Btn_terrain_nu': (model.VisitSite_Btn_terrain_nu == 'Oui' || model.VisitSite_Btn_terrain_nu == '1') ? '1' : ((model.VisitSite_Btn_terrain_nu == 'Non' || model.VisitSite_Btn_terrain_nu == '0') ? '0' : ''),
        'VisitSiteterrain_nu': model.VisitSiteterrain_nu,
        'VisitSite_Btn_presence_vegetation': (model.VisitSite_Btn_presence_vegetation == 'Oui' || model.VisitSite_Btn_presence_vegetation == '1') ? '1' : ((model.VisitSite_Btn_presence_vegetation == 'Non' || model.VisitSite_Btn_presence_vegetation == '0') ? '0' : ''),
        'VisitSitePresVeget': model.VisitSitePresVeget,
        'VisitSite_Btn_presence_pylones': (model.VisitSite_Btn_presence_pylones == 'Oui' || model.VisitSite_Btn_presence_pylones == '1') ? '1' : ((model.VisitSite_Btn_presence_pylones == 'Non' || model.VisitSite_Btn_presence_pylones == '0') ? '0' : ''),
        'VisitSite_presence_pylones': model.VisitSite_presence_pylones,
        'VisitSite_Btn_existance_mitoyntehab': (model.VisitSite_Btn_existance_mitoyntehab == 'Oui' || model.VisitSite_Btn_existance_mitoyntehab == '1') ? '1' : ((model.VisitSite_Btn_existance_mitoyntehab == 'Non' || model.VisitSite_Btn_existance_mitoyntehab == '0') ? '0' : ''),
        'VisitSiteExistantsvoisin': model.VisitSiteExistantsvoisin,
        'VisitSite_Btn_existance_voirie_mitoyenne': (model.VisitSite_Btn_existance_voirie_mitoyenne == 'Oui' || model.VisitSite_Btn_existance_voirie_mitoyenne == '1') ? '1' : ((model.VisitSite_Btn_existance_voirie_mitoyenne == 'Non' || model.VisitSite_Btn_existance_voirie_mitoyenne == '0') ? '0' : ''),
        'VisitSite_existance_voirie_mitoyenne': model.VisitSite_existance_voirie_mitoyenne,
        'VisitSite_Btn_presence_remblais': (model.VisitSite_Btn_presence_remblais == 'Oui' || model.VisitSite_Btn_presence_remblais == '1') ? '1' : ((model.VisitSite_Btn_presence_remblais == 'Non' || model.VisitSite_Btn_presence_remblais == '0') ? '0' : ''),
        'VisitSitePresDepotremblai': model.VisitSitePresDepotremblai,
        'VisitSite_Btn_presence_sources_cours_eau_cavite': (model.VisitSite_Btn_presence_sources_cours_eau_cavite == 'Oui' || model.VisitSite_Btn_presence_sources_cours_eau_cavite == '1') ? '1' : ((model.VisitSite_Btn_presence_sources_cours_eau_cavite == 'Non' || model.VisitSite_Btn_presence_sources_cours_eau_cavite == '0') ? '0' : ''),
        'VisitSiteEngHabitant': model.VisitSiteEngHabitant,
        'VisitSite_Btn_presence_talwegs': (model.VisitSite_Btn_presence_talwegs == 'Oui' || model.VisitSite_Btn_presence_talwegs == '1') ? '1' : ((model.VisitSite_Btn_presence_talwegs == 'Non' || model.VisitSite_Btn_presence_talwegs == '0') ? '0' : ''),
        'visitesitePresDepotremblai': model.visitesitePresDepotremblai,
        'VisitSite_Btn_terrain_inondable': (model.VisitSite_Btn_terrain_inondable == 'Oui' || model.VisitSite_Btn_terrain_inondable == '1') ? '1' : ((model.VisitSite_Btn_terrain_inondable == 'Non' || model.VisitSite_Btn_terrain_inondable == '0') ? '0' : ''),
        'VisitSite_terrain_inondable': model.VisitSite_terrain_inondable,
        'VisitSite_Btn_terrain_enpente': (model.VisitSite_Btn_terrain_enpente == 'Oui' || model.VisitSite_Btn_terrain_enpente == '1') ? '1' : ((model.VisitSite_Btn_terrain_enpente == 'Non' || model.VisitSite_Btn_terrain_enpente == '0') ? '0' : ''),
        'VisitSite_terrain_enpente': model.VisitSite_terrain_enpente,
        'VisitSite_Btn_risque_InstabiliteGlisTerrain': (model.VisitSite_Btn_risque_InstabiliteGlisTerrain == 'Oui' || model.VisitSite_Btn_risque_InstabiliteGlisTerrain == '1') ? '1' : ((model.VisitSite_Btn_risque_InstabiliteGlisTerrain == 'Non' || model.VisitSite_Btn_risque_InstabiliteGlisTerrain == '0') ? '0' : ''),
        'VisitSite_risque_InstabiliteGlisTerrain': model.VisitSite_risque_InstabiliteGlisTerrain,
        'VisitSite_Btn_terrassement_entame': (model.VisitSite_Btn_terrassement_entame == 'Oui' || model.VisitSite_Btn_terrassement_entame == '1') ? '1' : ((model.VisitSite_Btn_terrassement_entame == 'Non' || model.VisitSite_Btn_terrassement_entame == '0') ? '0' : ''),
        'VisitSite_terrassement_entame': model.VisitSite_terrassement_entame,
        'VisitSiteAutre': model.VisitSiteAutre,
        'VisitSite_Btn_Presence_risque_instab_terasmt': (model.VisitSite_Btn_Presence_risque_instab_terasmt == 'Oui' || model.VisitSite_Btn_Presence_risque_instab_terasmt == '1') ? '1' : ((model.VisitSite_Btn_Presence_risque_instab_terasmt == 'Non' || model.VisitSite_Btn_Presence_risque_instab_terasmt == '0') ? '0' : ''),
        'VisitSite_Btn_necessite_courrier_MO_risque_encouru': (model.VisitSite_Btn_necessite_courrier_MO_risque_encouru == 'Oui' || model.VisitSite_Btn_necessite_courrier_MO_risque_encouru == '1') ? '1' : ((model.VisitSite_Btn_necessite_courrier_MO_risque_encouru == 'Non' || model.VisitSite_Btn_necessite_courrier_MO_risque_encouru == '0') ? '0' : ''),
        'VisitSite_Btn_doc_annexe': (model.VisitSite_Btn_doc_annexe == 'Oui' || model.VisitSite_Btn_doc_annexe == '1') ? '1' : ((model.VisitSite_Btn_doc_annexe == 'Non' || model.VisitSite_Btn_doc_annexe == '0') ? '0' : ''),
        'VisitSite_liste_present': model.VisitSite_liste_present,
        'ValidCRVPIng': (model.ValidCRVPIng == 'Oui' || model.ValidCRVPIng == '1') ? '1' : ((model.ValidCRVPIng == 'Non' || model.ValidCRVPIng == '0') ? '0' : ''),
      };

  static String serialize(Visite model) => json.encode(Visite.toMap(model));

  static Visite deserialize(String json) => Visite.fromJson(jsonDecode(json));

}