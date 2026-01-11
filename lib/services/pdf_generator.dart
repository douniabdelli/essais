import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mgtrisque_visitepreliminaire/db/local_database.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Generates the PDF document for a PV and returns its bytes.
/// This function no longer calls `Printing.layoutPdf` so the caller
/// can decide how to display or share the PDF (in-app preview, save,
/// or print).
Future<Uint8List> generateLocalPV(Map<String, dynamic> pvData) async {
  return generatePVOfficial(pvData, isDraft: pvData['isDraft'] == true);
}
String formatDate(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) {
    return '';
  }
  // Si la chaîne contient un espace, on prend la partie avant l'espace.
  if (dateTimeStr.contains(' ')) {
    return dateTimeStr.split(' ')[0];
  }
  // Sinon, on retourne la chaîne entière (supposant que c'est déjà une date)
  return dateTimeStr;
}
Future<Uint8List> generatePVOfficial(Map<String, dynamic> pvData, {bool isDraft = false}) async {
  final font = await PdfGoogleFonts.openSansRegular();
  final fontBold = await PdfGoogleFonts.openSansBold();

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    ),
  );
final typesEprouvettes = await LocalDatabase.getTypesEprouvettes();
final Map<int, String> typeEprouvetteMap = {
  for (final t in typesEprouvettes)
    int.parse(t['id'].toString()):
        t['value']?.toString() ?? t['label']?.toString() ?? ''
};
final elementsPredifinis = await LocalDatabase.getElementsPredifinisRef();

final Map<int, String> familleMap = {
  for (final f in elementsPredifinis)
    int.parse(f['id'].toString()):
        f['designation']?.toString() ?? ''
};
final carrieres = await LocalDatabase.getCarrieresRef();

final Map<int, String> carriereMap = {
  for (final c in carrieres)
    int.parse(c['value'].toString()):
        c['label']?.toString() ?? ''
};

  final themeBlue = PdfColor.fromInt(0xFF1E3A8A);

  final elements = (pvData['elements'] as List?) ?? await LocalDatabase.getElementsOuvrageByPeId((pvData['pe_id'] ?? '').toString());
  final constituants = (pvData['constituants'] as List?) ?? await LocalDatabase.getConstituants(pvData['pe_id']?.toString() ?? '');
  final series = (pvData['series'] as List?) ?? await LocalDatabase.getSeriesEprouvettes(pvData['pe_id']?.toString() ?? '');

  pw.Widget _background(pw.Context ctx) {
    if (!isDraft) return pw.SizedBox();
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.3,
        child: pw.Opacity(
          opacity: 0.12,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Text(
              'BROUILLON',
              style: pw.TextStyle(
                fontSize: 72,
                color: PdfColors.red,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        buildBackground: _background,
      ),
      header: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 20), // Espace sous l'en-tête
        child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(90), // Logo
            1: const pw.FlexColumnWidth(),    // Colonne centrale (titre + sous-titre)
            2: const pw.FixedColumnWidth(140), // Infos droite
          },
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                // Logo à gauche
                pw.Container(
                  height: 80,
                  padding: const pw.EdgeInsets.all(8),
                  alignment: pw.Alignment.center,
                  child: pvData['logo'] != null
                      ? pw.Image(pw.MemoryImage(pvData['logo'] as Uint8List), fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
                // Colonne centrale : titre + sous-titre en bleu, tout centré
                pw.Container(
                  color: themeBlue,
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "FORMULAIRE D'ENREGISTREMENT",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4), // Petit espace entre les deux lignes
                      pw.Text(
                        "MODE OPERATOIRE\nEssais et Mesure pour le Contrôle Technique\n(Missions: M1)",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Colonne droite : Procédure, Référence, Date d'Application
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text("Procédure : "),
                          pw.Text("P1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Text("Référence : "),
                          pw.Text("Fxx-I2-P1-CTR-1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Text("Date d'Application : "),
                          pw.Text(".../.../....", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      build: (context) {
        List<List<String>> elementRows = [];
        for (var i = 0; i < elements.length; i++) {
          final e = elements[i] as Map<String, dynamic>;
     final int? familleId = int.tryParse(e['famille']?.toString() ?? '');
final String familleLabel = familleMap[familleId] ?? '';

elementRows.add([
  '${i + 1}',
  (e['bloc'] ?? e['Bloc'] ?? '').toString(),
  familleLabel, // 👈 designation depuis elements_predifinis_ref
  (e['nom'] ?? e['ElemBloc'] ?? '').toString(),
  'Axe : ${e['axe'] ?? ''}, File : ${e['file'] ?? ''}, Niveau : ${e['niveau'] ?? ''}',
]);
        }

        List<List<String>> constituantRows = [];
        for (var c in constituants) {
          final m = c is Map<String, dynamic> ? c : <String, dynamic>{};
      final int? provenanceId =
    int.tryParse((m['prov'] ?? m['fb_provenance'])?.toString() ?? '');

final String provenanceLabel = carriereMap[provenanceId] ?? (m['prov']?.toString() ?? '');

          // Formater le dosage pour enlever .0 si c'est un nombre entier
          final dosage = m['dosage'] ?? m['fb_dosage'];
          String dosageStr = '';

          if (dosage != null) {
            final str = dosage.toString();
            if (str.isNotEmpty) {
              final numValue = double.tryParse(str);
              if (numValue != null) {
                // Vérifier si c'est un nombre entier
                if (numValue % 1 == 0) {
                  dosageStr = '${numValue.toInt().toString()} kg/m³';
                } else {
                  dosageStr = '$str kg/m³';
                }
              } else {
                dosageStr = '$str kg/m³';
              }
            }
          }

          constituantRows.add([
            (m['type'] ?? m['fb_constituant'] ?? '').toString(),
            provenanceLabel,
            dosageStr,
          ]);
        }
  print('agence: ${pvData['agence']}');
     List<List<String>> eprRows = [];
int eprouvetteCounter = 1; // Initialize counter for numbering
final affaissementValue = pvData['affaissement'];
final affaissementLabel = getAffaissementLabel(affaissementValue);

for (final s in series) {
  final sm = Map<String, dynamic>.from(s as Map);
  final ageSerie = sm['age']?.toString() ?? '';

  final eprs = (sm['eprouvettes'] as List?) ?? [];

  for (final e in eprs) {
    final em = Map<String, dynamic>.from(e as Map);

    // 1️⃣ Récupération de la forme depuis series_eprouvettes
    final int? formeId = int.tryParse(em['forme']?.toString() ?? '');

    // 2️⃣ Récupération du libellé depuis types_eprouvettes
    final String typeEchantillon = typeEprouvetteMap[formeId] ?? '';

    // Extract only the last 6 digits for "N° à transcrire sur l'éprouvette"
    final eprouvetteId = (em['epr_id'] ?? '').toString();
    final last6Digits = eprouvetteId.length > 6 ? eprouvetteId.substring(eprouvetteId.length - 6) : eprouvetteId;

    eprRows.add([
         
      eprouvetteCounter.toString(), // Add numbering as a separate column
    eprouvetteId,
      (em['age'] ?? ageSerie).toString(),
      last6Digits,
      typeEchantillon,
    ]);

    eprouvetteCounter++; // Increment counter
  }
}

       return [
  pw.SizedBox(height: 8),
  pw.Center(
    child: pw.Text(
      'ENREGISTREMENT DES ÉPROUVETTES',
      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    ),
  ),
  pw.SizedBox(height: 10),
  pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'PV n° : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['pe_id'] ?? '—'} '),
      pw.TextSpan(
        text: 'du ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['date_validation_laboratoire_item'] ?? '—'}, '),
      pw.TextSpan(
        text: 'établi par : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['userNom'] ?? ''} ${pvData['userPrenom'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: "Intitulé de l'affaire : ",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['intitule'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Code Affaire : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['codeAffaire'] ?? ''}, '),
      pw.TextSpan(
        text: 'Direction/Agence : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['direction'] ?? ''} Agence: ${pvData['agence'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Entreprise de réalisation : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['entreprise'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Commande n° : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['NumCommande'] ?? pvData['num_commande'] ?? ''}, '),
      pw.TextSpan(
        text: 'du ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['dateCommande'] ?? '—'}, '),
      pw.TextSpan(
        text: 'Date de coulage : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['dateCoulage'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Nombre d\'éprouvettes : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${eprRows.length}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Catégorie du chantier : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['chantier'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: 'Classe du béton : ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${pvData['classe'] ?? ''}'),
    ],
  ),
),
pw.RichText(
  text: pw.TextSpan(
    children: [
      pw.TextSpan(
        text: "Affaissement au cône d'Abrams (NA 5092-2)(cm) : ",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.TextSpan(text: '${affaissementValue ?? ''}  $affaissementLabel'),
    ],
  ),
),
    ],
  ),
  pw.SizedBox(height: 12),
  pw.Text('Éléments ouvrages :'),
  pw.Table.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.black),
    headerDecoration: pw.BoxDecoration(color: themeBlue),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headers: ['#', 'Bloc', 'Famille', 'Élément', 'Localisation'],
    cellAlignment: pw.Alignment.centerLeft,
    data: elementRows.isEmpty
        ? [['', '', '', '', '']]
        : elementRows,
  ),
  pw.SizedBox(height: 12),
  pw.Text('Constituants :'),
  pw.Table.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.black),
    headerDecoration: pw.BoxDecoration(color: themeBlue),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headers: ['Constituants', 'Provenance', 'Dosage'],
    cellAlignment: pw.Alignment.centerLeft,
    data: constituantRows.isEmpty
        ? [['', '', '']]
        : constituantRows,
  ),
  pw.SizedBox(height: 12),
  pw.Text('Détails du prélèvement :'),
  pw.Table.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.black),
    headerDecoration: pw.BoxDecoration(color: themeBlue),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
               headers: ["#","N° d'éprouvettes", 'Âge (Jours)', "N° à transcrire sur l'éprouvette", "Type d'échantillon"],

    cellAlignment: pw.Alignment.centerLeft,
    data: eprRows.isEmpty
        ? [['', '', '', '']]
        : eprRows,
  ),
  pw.SizedBox(height: 20),
  pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
    pw.Text('Nom : ${pvData['userNom'] ?? ''}'), // Affichera "CHAIB"
pw.Text('Prénom : ${pvData['userPrenom'] ?? ''}'), // Affichera "Rima"
pw.Text('Date : ${pvData['date_validation']?.split(' ')[0] ?? ''}'),
        pw.Text('Signature : ____________________'),
        
      ],
    ),
  ),
];

      },
    ),
  );
  return pdf.save();
}
String getAffaissementLabel(dynamic value) {
  if (value == null) return 'Non défini';

  final double? v = double.tryParse(value.toString());
  if (v == null) return 'Non défini';

  if (v <= 4) {
    return 'Ferme';
  } else if (v >= 5 && v <= 9) {
    return 'Plastique';
  } else if (v >= 10 && v <= 15) {
    return 'Très plastique';
  } else if (v >= 16) {
    return 'Fluide';
  } else {
    return 'Non défini';
  }
}

Future<void> showLocalPV(Map<String, dynamic> pvData) async {
  final bytes = await generatePVOfficial(pvData, isDraft: pvData['isDraft'] == true);
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
}

Future<Map<String, dynamic>> buildPvDataFromLocal(String peId) async {
  final cmdRows = await LocalDatabase.getCommandesRefByPeId(peId);
  final intervention = await LocalDatabase.getIntervention(peId);
  final elements = await LocalDatabase.getElementsOuvrageByPeId(peId);
  final constituants = await LocalDatabase.getConstituants(peId);
  final series = await LocalDatabase.getSeriesEprouvettes(peId);

  final cmd = cmdRows.isNotEmpty ? cmdRows.first : <String, dynamic>{};
  final classeIdRaw = intervention?['classe_beton_id'] ?? intervention?['classeBeton'] ?? intervention?['classe_beton'];
  final classeId = classeIdRaw != null ? int.tryParse(classeIdRaw.toString()) : null;
  final classeLabel = await LocalDatabase.getClasseBetonLabel(classeId);

  final date = intervention?['created_at']?.toString() ?? intervention?['created_at']?.toString() ?? cmd['created_at']?.toString();

  String extractNom(String s) {
    final reg = RegExp(r'nom=([^,]+)');
    final match = reg.firstMatch(s);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    return '';
  }

String entrepriseNom = '';
if (cmd['EntrepriseRealisation'] is Map) {
entrepriseNom = cmd['EntrepriseRealisation']['nom']?.toString() ?? '';
} else if (cmd['EntrepriseRealisation'] is String) {
entrepriseNom = extractNom(cmd['EntrepriseRealisation']);
}

// Si entrepriseNom est toujours vide, on essaie avec intervention
if (entrepriseNom.isEmpty) {
if (intervention?['entreprise_real'] is Map) {
entrepriseNom = intervention?['entreprise_real']?['nom']?.toString() ?? '';
} else if (intervention?['entreprise_real'] is String) {
final str = intervention!['entreprise_real'] as String;
if (str.contains('-')) {
entrepriseNom = str.split('-').sublist(1).join('-').trim();
} else {
entrepriseNom = str;
}
}
}
print('cccccccccccccccccccccccccc,$entrepriseNom');
  // Parse user_data JSON string
  Map<String, dynamic> userDataMap = {};
  final userDataString = intervention?['user_data']?.toString();
  if (userDataString != null && userDataString.isNotEmpty) {
    try {
      userDataMap = jsonDecode(userDataString);
    } catch (e) {
      print('Erreur parsing user_data JSON: $e');
    }
  }

  // Parse charge_affaire_id JSON string (si nécessaire)
  Map<String, dynamic> chargeAffaireMap = {};
  final chargeAffaireString = intervention?['charge_affaire_id']?.toString();
  if (chargeAffaireString != null && chargeAffaireString.isNotEmpty && chargeAffaireString.startsWith('{')) {
    try {
      chargeAffaireMap = jsonDecode(chargeAffaireString);
    } catch (e) {
      print('Erreur parsing charge_affaire_id JSON: $e');
    }
  }

  // Récupération des données utilisateur
  // Priorité: user_data JSON > charge_affaire_id JSON > cmd
  final userNom = userDataMap['Nom']?.toString() ?? 
                 chargeAffaireMap['Nom']?.toString() ?? 
                 cmd['Nom_DR_Laboratoire']?.toString() ?? '';
  
  final userPrenom = userDataMap['Prénom']?.toString() ?? 
                    chargeAffaireMap['Prénom']?.toString() ??
                    cmd['Structure_Laboratoire']?.toString() ?? '';
  
  final dateValidation = intervention?['date_validation_laboratoire_item']?.toString() ?? 
                        cmd['date_validation_laboratoire_it']?.toString() ?? '';
   final dateCommande =cmd['DateCommande']?.toString() ?? intervention?['date_validation_pm']?.toString() ?? '';
  print('DEBUG - userNom final: $userNom (depuis user_data: ${userDataMap['Nom']})');
  print('DEBUG - userPrenom final: $userPrenom (depuis user_data: ${userDataMap['Prénom']})');
  print("DEBUG cmd: $cmd");
print("DEBUG intervention: $intervention");
print("DEBUG cmd['DateCommande']: ${cmd['DateCommande']}");
print("DEBUG intervention['date_validation_pm']: ${intervention?['date_validation_pm']}");
 print('DEBUG dateCommandedateCommandedateCommande: $dateCommande)');
  
  return {
    'pe_id': peId,
    'NumCommande': cmd['NumCommande']?.toString() ?? cmd['num_commande']?.toString() ?? intervention?['commande_id']?.toString() ?? '',
    'intitule': cmd['IntituleAffaire']?.toString() ?? intervention?['intitule_affaire']?.toString() ?? '',
    'codeAffaire': cmd['Code_Affaire']?.toString() ?? intervention?['Code_Affaire']?.toString() ?? '',
    'entreprise': entrepriseNom,
    'chantier': intervention?['categorie_chantier']?.toString() ?? '',
    'date_validation_laboratoire_item': dateValidation,
    'classe': classeLabel,
    'affaissement': intervention?['pe_affais_cone']?.toString() ?? '',
    'dateCoulage': cmd['pe_date_pv']?.toString() ?? '',
    'dateCommande': dateCommande,
    'user': cmd['ChargedAffaire']?.toString() ?? '',
    
    // Utiliser les données de la table interventions
    'userNom': userNom,
    'userPrenom': userPrenom,
     'direction': cmd['Nom_DR_Laboratoire']?.toString() ?? '',
    'agence': cmd['Structure_Laboratoire']?.toString() ?? '',
    'date': date ?? '',
    'date_validation': dateValidation, // Pour la signature

    'elements': elements,
    'constituants': constituants,
    'series': series,
    'isDraft': (() {
      final v = cmd['Validation_labo']?.toString();
      final iv = v != null ? int.tryParse(v) : null;
      return !(iv == 1);
    })(),
  };
}
Future<void> showPVFromDb(String peId, {bool? isDraft}) async {
  final data = await buildPvDataFromLocal(peId);
  try {
    final logo = await rootBundle.load('assets/logo-ctc.png');
    data['logo'] = logo.buffer.asUint8List();
  } catch (_) {}
  data['isDraft'] = isDraft ?? data['isDraft'] ?? false;
  await showLocalPV(data);
}

Future<void> sharePVOfficial(Map<String, dynamic> pvData, {String? fileName}) async {
  final bytes = await generatePVOfficial(pvData, isDraft: pvData['isDraft'] == true);
  await Printing.sharePdf(bytes: bytes, filename: fileName ?? 'pv_${pvData['pe_id'] ?? 'document'}.pdf');
}

Future<File> savePVOfficial(Map<String, dynamic> pvData, {String? fileName}) async {
  final bytes = await generatePVOfficial(pvData, isDraft: pvData['isDraft'] == true);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/${fileName ?? 'pv_${pvData['pe_id'] ?? 'document'}.pdf'}');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
