import 'dart:convert';
import 'dart:convert' show utf8;

class Affaire {
  final String Code_Affaire;
  final String Code_Site;
  final String IntituleAffaire;
  final int NbrSite;
  final String matricule;
  final int Multisite;


  const Affaire({
    required this.Code_Affaire,
    required this.Code_Site,
    required this.IntituleAffaire,
    required this.NbrSite,
    required this.matricule,
    required this.Multisite,
  });

  factory Affaire.fromJson(Map<String, dynamic> json) {
    return Affaire(
        Code_Affaire: json['Code_Affaire'],
        Code_Site: json['Code_Site'],
        IntituleAffaire: json['IntituleAffaire'],
        NbrSite: json['NbrSite'] == null ? 0 : int.parse(json['NbrSite']),
        matricule: json['matricule'],
        Multisite: json['Multisite'] == null ? 0 : int.parse(json['Multisite']),
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
      };

  static String serialize(Affaire model) => json.encode(Affaire.toMap(model));

  static Affaire deserialize(String json) => Affaire.fromJson(jsonDecode(json));

}