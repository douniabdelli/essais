import 'dart:convert';
import 'dart:convert' show utf8;

class Visite {
  final String Code_Affaire;
  final String Code_site;
  final String VisitSiteDate;
  final int VisitSite_Btn_terrain_accessible;
  final String VisitSiteterrain_accessible;
  final int VisitSite_Btn_terrain_cloture;
  final String VisitSiteterrain_cloture;
  final int VisitSite_Btn_terrain_nu;
  final String VisitSiteterrain_nu;
  final int VisitSite_Btn_presence_vegetation;
  final String VisitSitePresVeget;
  final int VisitSite_Btn_presence_pylones;
  final String VisitSite_presence_pylones;
  final int VisitSite_Btn_existance_mitoyntehab;
  // existence mitoyenneté
  final String VisitSiteExistantsvoisin;
  final int VisitSite_Btn_existance_voirie_mitoyenne;
  final String VisitSite_existance_voirie_mitoyenne;
  final int VisitSite_Btn_presence_remblais;
  final String VisitSitePresDepotremblai;
  final int VisitSite_Btn_presence_sources_cours_eau_cavite;
  // presence_sources_cours_eau_cavite
  final String VisitSiteEngHabitant;
  final int VisitSite_Btn_presence_talwegs;
  // presence_talwegs
  final String visitesitePresDepotremblai;
  final int VisitSite_Btn_terrain_inondable;
  final String VisitSite_terrain_inondable;
  final int VisitSite_Btn_terrain_enpente;
  final String VisitSite_terrain_enpente;
  final int VisitSite_Btn_risque_InstabiliteGlisTerrain;
  final String VisitSite_risque_InstabiliteGlisTerrain;
  final int VisitSite_Btn_terrassement_entame;
  final String VisitSite_terrassement_entame;
  // observation
  final String VisitSiteAutre;
  final int VisitSite_Btn_Presence_risque_instab_terasmt;
  final int VisitSite_Btn_necessite_courrier_MO_risque_encouru;
  final int VisitSite_Btn_doc_annexe;
  // todo: photo
  // final String ;
  final String VisitSite_liste_present;
  final int ValidCRVPIng;

  const Visite({
    required this.Code_Affaire,
    required this.Code_site,
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
    // todo: photo
    required this.VisitSite_liste_present,
    required this.ValidCRVPIng,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      Code_Affaire: json['Code_Affaire'].toString(),
      Code_site: json['Code_site'].toString(),
      VisitSiteDate: json['VisitSiteDate'].toString(),
      VisitSite_Btn_terrain_accessible: json['VisitSite_Btn_terrain_accessible'] != null ? int.parse(json['VisitSite_Btn_terrain_accessible']) : 0,
      VisitSiteterrain_accessible: json['VisitSiteterrain_accessible'].toString(),
      VisitSite_Btn_terrain_cloture: json['VisitSite_Btn_terrain_cloture'] != null ? int.parse(json['VisitSite_Btn_terrain_cloture']) : 0,
      VisitSiteterrain_cloture: json['VisitSiteterrain_cloture'].toString(),
      VisitSite_Btn_terrain_nu: json['VisitSite_Btn_terrain_nu'] != null ? int.parse(json['VisitSite_Btn_terrain_nu']) : 0,
      VisitSiteterrain_nu: json['VisitSiteterrain_nu'].toString(),
      VisitSite_Btn_presence_vegetation: json['VisitSite_Btn_presence_vegetation'] != null ? int.parse(json['VisitSite_Btn_presence_vegetation']) : 0,
      VisitSitePresVeget: json['VisitSitePresVeget'].toString(),
      VisitSite_Btn_presence_pylones: json['VisitSite_Btn_presence_pylones'] != null ? int.parse(json['VisitSite_Btn_presence_pylones']) : 0,
      VisitSite_presence_pylones: json['VisitSite_presence_pylones'].toString(),
      VisitSite_Btn_existance_mitoyntehab: json['VisitSite_Btn_existance_mitoyntehab'] != null ? int.parse(json['VisitSite_Btn_existance_mitoyntehab']) : 0,
      VisitSiteExistantsvoisin: json['VisitSiteExistantsvoisin'].toString(),
      VisitSite_Btn_existance_voirie_mitoyenne: json['VisitSite_Btn_existance_voirie_mitoyenne'] != null ? int.parse(json['VisitSite_Btn_existance_voirie_mitoyenne']) : 0,
      VisitSite_existance_voirie_mitoyenne: json['VisitSite_existance_voirie_mitoyenne'].toString(),
      VisitSite_Btn_presence_remblais: json['VisitSite_Btn_presence_remblais'] != null ? int.parse(json['VisitSite_Btn_presence_remblais']) : 0,
      VisitSitePresDepotremblai: json['VisitSitePresDepotremblai'].toString(),
      VisitSite_Btn_presence_sources_cours_eau_cavite: json['VisitSite_Btn_presence_sources_cours_eau_cavite'] != null ? int.parse(json['VisitSite_Btn_presence_sources_cours_eau_cavite']) : 0,
      VisitSiteEngHabitant: json['VisitSiteEngHabitant'].toString(),
      VisitSite_Btn_presence_talwegs: json['VisitSite_Btn_presence_talwegs'] != null ? int.parse(json['VisitSite_Btn_presence_talwegs']) : 0,
      visitesitePresDepotremblai: json['visitesitePresDepotremblai'].toString(),
      VisitSite_Btn_terrain_inondable: json['VisitSite_Btn_terrain_inondable'] != null ? int.parse(json['VisitSite_Btn_terrain_inondable']) : 0,
      VisitSite_terrain_inondable: json['VisitSite_terrain_inondable'].toString(),
      VisitSite_Btn_terrain_enpente: json['VisitSite_Btn_terrain_enpente'] != null ? int.parse(json['VisitSite_Btn_terrain_enpente']) : 0,
      VisitSite_terrain_enpente: json['VisitSite_terrain_enpente'].toString(),
      VisitSite_Btn_risque_InstabiliteGlisTerrain: json['VisitSite_Btn_risque_InstabiliteGlisTerrain'] != null ? int.parse(json['VisitSite_Btn_risque_InstabiliteGlisTerrain']) : 0,
      VisitSite_risque_InstabiliteGlisTerrain: json['VisitSite_risque_InstabiliteGlisTerrain'].toString(),
      VisitSite_Btn_terrassement_entame: json['VisitSite_Btn_terrassement_entame'] != null ? int.parse(json['VisitSite_Btn_terrassement_entame']) : 0,
      VisitSite_terrassement_entame: json['VisitSite_terrassement_entame'].toString(),
      VisitSiteAutre: json['VisitSiteAutre'].toString(),
      VisitSite_Btn_Presence_risque_instab_terasmt: json['VisitSite_Btn_Presence_risque_instab_terasmt'] != null ? int.parse(json['VisitSite_Btn_Presence_risque_instab_terasmt']) : 0,
      VisitSite_Btn_necessite_courrier_MO_risque_encouru: json['VisitSite_Btn_necessite_courrier_MO_risque_encouru'] != null ? int.parse(json['VisitSite_Btn_necessite_courrier_MO_risque_encouru']) : 0,
      VisitSite_Btn_doc_annexe: json['VisitSite_Btn_doc_annexe'] != null ? int.parse(json['VisitSite_Btn_doc_annexe']) : 0,
      VisitSite_liste_present: json['VisitSite_liste_present'].toString(),
      ValidCRVPIng: json['ValidCRVPIng'] != null ? int.parse(json['ValidCRVPIng']) : 0,
    );
  }

  static Map<String, dynamic> toMap(Visite model) =>
      <String, dynamic> {
        'Code_Affaire': model.Code_Affaire,
        'Code_site': model.Code_site,
        'VisitSiteDate': model.VisitSiteDate,
        'VisitSite_Btn_terrain_accessible': model.VisitSite_Btn_terrain_accessible,
        'VisitSiteterrain_accessible': model.VisitSiteterrain_accessible,
        'VisitSite_Btn_terrain_cloture': model.VisitSite_Btn_terrain_cloture,
        'VisitSiteterrain_cloture': model.VisitSiteterrain_cloture,
        'VisitSite_Btn_terrain_nu': model.VisitSite_Btn_terrain_nu,
        'VisitSiteterrain_nu': model.VisitSiteterrain_nu,
        'VisitSite_Btn_presence_vegetation': model.VisitSite_Btn_presence_vegetation,
        'VisitSitePresVeget': model.VisitSitePresVeget,
        'VisitSite_Btn_presence_pylones': model.VisitSite_Btn_presence_pylones,
        'VisitSite_presence_pylones': model.VisitSite_presence_pylones,
        'VisitSite_Btn_existance_mitoyntehab': model.VisitSite_Btn_existance_mitoyntehab,
        'VisitSiteExistantsvoisin': model.VisitSiteExistantsvoisin,
        'VisitSite_Btn_existance_voirie_mitoyenne': model.VisitSite_Btn_existance_voirie_mitoyenne,
        'VisitSite_existance_voirie_mitoyenne': model.VisitSite_existance_voirie_mitoyenne,
        'VisitSite_Btn_presence_remblais': model.VisitSite_Btn_presence_remblais,
        'VisitSitePresDepotremblai': model.VisitSitePresDepotremblai,
        'VisitSite_Btn_presence_sources_cours_eau_cavite': model.VisitSite_Btn_presence_sources_cours_eau_cavite,
        'VisitSiteEngHabitant': model.VisitSiteEngHabitant,
        'VisitSite_Btn_presence_talwegs': model.VisitSite_Btn_presence_talwegs,
        'visitesitePresDepotremblai': model.visitesitePresDepotremblai,
        'VisitSite_Btn_terrain_inondable': model.VisitSite_Btn_terrain_inondable,
        'VisitSite_terrain_inondable': model.VisitSite_terrain_inondable,
        'VisitSite_Btn_terrain_enpente': model.VisitSite_Btn_terrain_enpente,
        'VisitSite_terrain_enpente': model.VisitSite_terrain_enpente,
        'VisitSite_Btn_risque_InstabiliteGlisTerrain': model.VisitSite_Btn_risque_InstabiliteGlisTerrain,
        'VisitSite_risque_InstabiliteGlisTerrain': model.VisitSite_risque_InstabiliteGlisTerrain,
        'VisitSite_Btn_terrassement_entame': model.VisitSite_Btn_terrassement_entame,
        'VisitSite_terrassement_entame': model.VisitSite_terrassement_entame,
        'VisitSiteAutre': model.VisitSiteAutre,
        'VisitSite_Btn_Presence_risque_instab_terasmt': model.VisitSite_Btn_Presence_risque_instab_terasmt,
        'VisitSite_Btn_necessite_courrier_MO_risque_encouru': model.VisitSite_Btn_necessite_courrier_MO_risque_encouru,
        'VisitSite_Btn_doc_annexe': model.VisitSite_Btn_doc_annexe,
        'VisitSite_liste_present': model.VisitSite_liste_present,
        'ValidCRVPIng': model.ValidCRVPIng,
      };

  static String serialize(Visite model) => json.encode(Visite.toMap(model));

  static Visite deserialize(String json) => Visite.fromJson(jsonDecode(json));

}