import 'dart:convert';
import 'dart:convert' show utf8;

class Visite {
  //final String Code_Affaire;
  final DateTime dateVisite;

  const Visite({
   required this.dateVisite
  });
  //
  // factory Visite.fromJson(Map<String, dynamic> json) {
  //   return Visite(
  //       //Code_Affaire: json['Code_Affaire'] == null ? '' : json['Code_Affaire'],
  //   );
  // }
  //
  // static Map<String, dynamic> toMap(Visite model) =>
  //     <String, dynamic> {
  //       //'Code_Affaire': model.Code_Affaire,
  //     };
  //
  // static String serialize(Visite model) => json.encode(Visite.toMap(model));
  //
  // static Visite deserialize(String json) => Visite.fromJson(jsonDecode(json));

}