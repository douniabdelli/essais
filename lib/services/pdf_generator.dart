import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Generates the PDF document for a PV and returns its bytes.
/// This function no longer calls `Printing.layoutPdf` so the caller
/// can decide how to display or share the PDF (in-app preview, save,
/// or print).
Future<Uint8List> generateLocalPV(Map<String, dynamic> pvData) async {
  final pdf = pw.Document();

  // 🎨 Couleur thème bleu chantier
  final themeColor = PdfColor.fromInt(0xFF1E3A8A);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // 🔹 HEADER
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black),
            columnWidths: {
              0: const pw.FixedColumnWidth(70),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(100),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Center(
                    child: pw.Container(
                      height: 70,
                      child: pw.Image(pw.MemoryImage(pvData['logo'])),
                    ),
                  ),
                  pw.Container(
                    color: themeColor,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "FORMULAIRE D’ENREGISTREMENT",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Center(child: pw.Text("Procédure : P1")),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(),
                  pw.Center(
                    child: pw.Text(
                      "MODE OPERATOIRE\nEssais et Mesures pour le Contrôle Technique\n(Missions: M1)",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Center(child: pw.Text("Référence : Fxx-I2-P1-CTR-1")),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(),
                  pw.Container(),
                  pw.Center(child: pw.Text("Date d’application: ../../....")),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // 🔹 TITRE
          pw.Center(
            child: pw.Text(
              "Enregistrement des éprouvettes",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 10),

          // 🔹 Informations principales
          pw.Text("PV n° : ${pvData['pe_id']} du ${pvData['date']}, établi par : ${pvData['user']}"),
          pw.Text("Intitulé de l'affaire : ${pvData['intitule']}"),
          pw.Text("Code Affaire : ${pvData['codeAffaire']} - Code Site : ${pvData['codeSite']}"),
          pw.Text("Entreprise de réalisation : ${pvData['entreprise']}"),
          pw.Text("Date de coulage : ${pvData['dateCoulage']}"),
          pw.Text("Classe du béton : ${pvData['classe']}"),

          pw.SizedBox(height: 15),

          // 🔹 Tableau Éléments ouvrages
          pw.Text("Éléments ouvrages :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.black),
            headerDecoration: pw.BoxDecoration(color: themeColor),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headers: ["#", "Bloc", "Famille", "Élément", "Localisation"],
            data: List<List<String>>.generate(
              pvData['elements'].length,
              (index) {
                final e = pvData['elements'][index];
                return [
                  '${index + 1}',
                  e['bloc'],
                  e['famille'],
                  e['nom'],
                  'Axe: ${e['axe']} / File: ${e['file']} / Niveau: ${e['niveau']}',
                ];
              },
            ),
          ),

          pw.SizedBox(height: 15),

          // 🔹 Tableau Constituants
          pw.Text("Constituants :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.black),
            headerDecoration: pw.BoxDecoration(color: themeColor),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headers: ["Constituant", "Provenance", "Dosage"],
            data: List<List<String>>.generate(
              pvData['constituants'].length,
              (index) {
                final c = pvData['constituants'][index];
                return [c['type'], c['provenance'], c['dosage']];
              },
            ),
          ),

          pw.SizedBox(height: 20),

          // 🔹 Signature
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Nom : ${pvData['userNom']}"),
                pw.Text("Prénom : ${pvData['userPrenom']}"),
                pw.Text("Date : ${pvData['date']}"),
                pw.Text("Signature : ____________________"),
              ],
            ),
          ),
        ];
      },
    ),
  );

  // Return PDF bytes to the caller so they can preview/print as needed.
  return pdf.save();
}

/// Convenience helper to directly open the system print/preview UI.
/// Kept for backward compatibility; callers can still use this if they
/// want the OS printing flow.
Future<void> showLocalPV(Map<String, dynamic> pvData) async {
  final bytes = await generateLocalPV(pvData);
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
}
