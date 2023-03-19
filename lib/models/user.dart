class User {
  String Matricule;
  String Nom;
  String Nomjeunefille;
  String Prenom;
  String Structure;
  String DirectionAntenne;
  String Service;
  String Fonction;
  String GroupSec;
  String? GroupSousSec;


  User({
    required this.Matricule,
    required this.Nom,
    required this.Nomjeunefille,
    required this.Prenom,
    required this.Structure,
    required this.DirectionAntenne,
    required this.Service,
    required this.Fonction,
    required this.GroupSec,
    required this.GroupSousSec,
  });

  User.fromJson(Map<String, dynamic> json)
      : Matricule = json['Matricule'] == null ? '' : json['Matricule'],
        Nom = json['Nom'] == null ? '' : json['Nom'],
        Nomjeunefille = json['Nomjeunefille'] == null ? '' : json['Nomjeunefille'],
        Prenom = json['Prenom'] == null ? '' : json['Prenom'],
        Structure = json['Structure'] == null ? '' : json['Structure'],
        DirectionAntenne = json['DirectionAntenne'] == null ? '' : json['DirectionAntenne'],
        Service = json['Service'] == null ? '' : json['Service'],
        Fonction = json['Fonction'] == null ? '' : json['Fonction'],
        GroupSec = json['GroupSec'] == null ? '' : json['GroupSec'],
        GroupSousSec = json['GroupSousSec'] == null ? '' : json['GroupSousSec']
  ;
}