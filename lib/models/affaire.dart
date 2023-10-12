import 'dart:convert';
import 'dart:convert' show utf8;

class Affaire {
  final String Code_Affaire;
  final String Code_Site;
  final String IntituleAffaire;
  final int NbrSite;
  final String matricule;
  final int Multisite;
  final String annee;
  final String Nom_DR;
  final String code_agence;
  final String nom_agence;
  final String adresse;
  final String tel;
  final String fax;
  final String email;


  const Affaire({
    required this.Code_Affaire,
    required this.Code_Site,
    required this.IntituleAffaire,
    required this.NbrSite,
    required this.matricule,
    required this.Multisite,
    required this.annee,
    required this.Nom_DR,
    required this.code_agence,
    required this.nom_agence,
    required this.adresse,
    required this.tel,
    required this.fax,
    required this.email,
  });

  factory Affaire.fromJson(Map<String, dynamic> json) {
    return Affaire(
        Code_Affaire: json['Code_Affaire'] == null ? '' : json['Code_Affaire'],
        Code_Site: json['Code_Site'] == null ? '' : json['Code_Site'],
        IntituleAffaire: json['IntituleAffaire'] == null ? '' : json['IntituleAffaire'],
        NbrSite: json['NbrSite'] == null ? 0 : int.parse(json['NbrSite']),
        matricule: json['matricule'] == null ? '' : json['matricule'],
        Multisite: json['Multisite'] == null ? 0 : int.parse(json['Multisite']),
        annee: json['annee'] == null ? '' : json['annee'],
        Nom_DR: json['Nom_DR'] == null ? '' : json['Nom_DR'],
        code_agence: json['code_agence'] == null ? '' : json['code_agence'],
        nom_agence: json['nom_agence'] == null ? '' : json['nom_agence'],
        adresse: json['adresse'] == null ? '' : json['adresse'],
        tel: json['tel'] == null ? '' : json['tel'],
        fax: json['fax'] == null ? '' : json['fax'],
        email: json['email'] == null ? '' : json['email'],
    );
  }

  static Map<String, dynamic> toMap(Affaire model) =>
      <String, dynamic> {
        'Code_Affaire': model.Code_Affaire,
        'Code_Site': model.Code_Site,
        'IntituleAffaire': model.IntituleAffaire,
        'NbrSite': model.NbrSite,
        'matricule': model.matricule,
        'Multisite': model.Multisite,
        'annee': model.annee,
        'Nom_DR': model.Nom_DR,
        'code_agence': model.code_agence,
        'nom_agence': model.nom_agence,
        'adresse': model.adresse,
        'tel': model.tel,
        'fax': model.fax,
        'email': model.email,
      };

  static String serialize(Affaire model) => json.encode(Affaire.toMap(model));

  static Affaire deserialize(String json) => Affaire.fromJson(jsonDecode(json));

}