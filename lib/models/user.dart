import 'dart:convert';

class User {
  String matricule;
  String structure;
  String nom;
  String prenom;
  String password;


  User({
    required this.matricule,
    required this.structure,
    required this.nom,
    required this.prenom,
    required this.password,
  });

  User.fromJson(Map<String, dynamic> json)
      : matricule = json['matricule'] == null ? '' : json['matricule'],
        structure = json['structure'] == null ? '' : json['structure'],
        nom = json['nom'] == null ? '' : json['nom'],
        prenom = json['prenom'] == null ? '' : json['prenom'],
        password = json['password'] == null ? '' : json['password']
  ;

  static Map<String, dynamic> toMap(User model) => 
      <String, dynamic> {
        'matricule': model.matricule,
        'structure': model.structure,
        'nom': model.nom,
        'prenom': model.prenom,
        'password': model.password,
      };
  
  static String serialize(User model) => json.encode(User.toMap(model));
  
  static User deserialize(String json) => User.fromJson(jsonDecode(json));

}