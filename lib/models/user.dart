import 'dart:convert';

class User {
  String matricule;
  String structure;
  String nom;
  String prenom;
  String password;
  String? role;
  String? consultation;
  String? insertion;
  String? modification;
  String? suppression;


  User({
    required this.matricule,
    required this.structure,
    required this.nom,
    required this.prenom,
    required this.password,
    required this.role,
    required this.consultation,
    required this.insertion,
    required this.modification,
    required this.suppression,
  });

  User.fromJson(Map<String, dynamic> json)
      : matricule = json['matricule'] == null ? '' : json['matricule'],
        structure = json['structure'] == null ? '' : json['structure'],
        nom = json['nom'] == null ? '' : json['nom'],
        prenom = json['prenom'] == null ? '' : json['prenom'],
        password = json['password'] == null ? '' : json['password'],
        role = json['role'] == null ? '' : json['role'],
        consultation = json['consultation'] == null ? '' : json['consultation'],
        insertion = json['insertion'] == null ? '' : json['insertion'],
        modification = json['modification'] == null ? '' : json['modification'],
        suppression = json['suppression'] == null ? '' : json['suppression']
  ;

  static Map<String, dynamic> toMap(User model) => 
      <String, dynamic> {
        'matricule': model.matricule,
        'structure': model.structure,
        'nom': model.nom,
        'prenom': model.prenom,
        'password': model.password,
        'role': model.role,
        'consultation': model.consultation,
        'insertion': model.insertion,
        'modification': model.modification,
        'suppression': model.suppression,
      };
  
  static String serialize(User model) => json.encode(User.toMap(model));
  
  static User deserialize(String json) => User.fromJson(jsonDecode(json));

}