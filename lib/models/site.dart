import 'dart:convert';
import 'dart:convert' show utf8;

class Site {
  final String Code_Affaire;
  final String Code_site;
  final String adress_proj;

  const Site({
    required this.Code_Affaire,
    required this.Code_site,
    required this.adress_proj,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
        Code_Affaire: json['Code_Affaire'].toString(),
        Code_site: json['Code_site'].toString(),
        adress_proj: json['adress_proj'].toString(),
    );
  }

  static Map<String, dynamic> toMap(Site model) =>
      <String, dynamic> {
        'Code_Affaire': model.Code_Affaire,
        'Code_site': model.Code_site,
        'adress_proj': model.adress_proj,
      };

  static String serialize(Site model) => json.encode(Site.toMap(model));

  static Site deserialize(String json) => Site.fromJson(jsonDecode(json));

}