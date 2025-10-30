class DocumentAnnexe {
  final int? id;
  final String? codeSite;
  final String codeAffaire;
  final String nomDocument;

  DocumentAnnexe({
    this.id,
     this.codeSite,
    required this.codeAffaire,
    required this.nomDocument,
  });

  factory DocumentAnnexe.fromJson(Map<String, dynamic> json) {
    return DocumentAnnexe(
      id: json['id'] as int?,
      codeSite: json['Code_site']?.toString(),  
      codeAffaire: json['Code_Affaire'].toString(), 
       nomDocument: json['nom_document'].toString(),
    );
  }
Map<String, dynamic> toMap() {
    return {'id': id,
      'code_site': codeSite,
      'code_affaire': codeAffaire,
      'nom_document': nomDocument,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Code_site': codeSite,
      'Code_Affaire': codeAffaire,
      'nom_document': nomDocument,
    };
  }
}