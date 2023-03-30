import 'dart:convert';
import 'dart:convert' show utf8;

class Affaire {
  String Code_Affaire;
  String IntituleAffaire;
  int NbrSite;


  Affaire({
    required this.Code_Affaire,
    required this.IntituleAffaire,
    required this.NbrSite,
  });

  factory Affaire.fromJson(Map<String, dynamic> json) {
    return Affaire(
        Code_Affaire: json['Code_Affaire'] == null ? '' : json['Code_Affaire'],
        IntituleAffaire: json['IntituleAffaire'] == null ? '' : json['IntituleAffaire'],
        NbrSite: json['NbrSite'] == null ? 0 : int.parse(json['NbrSite'])
    );
  }

  static Map<String, dynamic> toMap(Affaire model) =>
      <String, dynamic> {
        'Code_Affaire': model.Code_Affaire,
        'IntituleAffaire': model.IntituleAffaire,
        'NbrSite': model.NbrSite,
      };

  static String serialize(Affaire model) => json.encode(Affaire.toMap(model));

  static Affaire deserialize(String json) => Affaire.fromJson(jsonDecode(json));

}