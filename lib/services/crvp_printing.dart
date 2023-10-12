import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' as mt;
import 'package:pdf/widgets.dart' as pw;

void printPDF(context) async {
  final pdfBytes = await generatePDF(context);

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdfBytes,
    name: 'CRVP_${Provider.of<GlobalProvider>(context, listen: false).selectedAffaire}_${Provider.of<GlobalProvider>(context, listen: false).selectedSite}',
  );
}

generatePDF(context) async {
  final pdf = pw.Document();
  final Size size = MediaQuery.of(context).size;
  var image = await rootBundle.load('assets/images/logo-ctc.png');
  Uint8List imageData = (image).buffer.asUint8List();

  // Prepare Data
  var selectedAffaire = Provider.of<GlobalProvider>(context, listen: false).selectedAffaire;
  var terrainAccessible = Provider.of<GlobalProvider>(context, listen: false).terrainAccessibleController.text;
  var terrainAccessibleInput = Provider.of<GlobalProvider>(context, listen: false).terrainAccessibleInputController.text;
  var terrainCloture = Provider.of<GlobalProvider>(context, listen: false).terrainClotureController.text;
  var terrainClotureInput = Provider.of<GlobalProvider>(context, listen: false).terrainClotureInputController.text;
  var terrainNu = Provider.of<GlobalProvider>(context, listen: false).terrainNuController.text;
  var terrainNuInput = Provider.of<GlobalProvider>(context, listen: false).terrainNuInputController.text;
  var presenceVegetation = Provider.of<GlobalProvider>(context, listen: false).presenceVegetationController.text;
  var presenceVegetationInput = Provider.of<GlobalProvider>(context, listen: false).presenceVegetationInputController.text;
  var presencePylones = Provider.of<GlobalProvider>(context, listen: false).presencePylonesController.text;
  var presencePylonesInput = Provider.of<GlobalProvider>(context, listen: false).presencePylonesInputController.text;
  var existenceMitoyenneteHabitation = Provider.of<GlobalProvider>(context, listen: false).existenceMitoyenneteHabitationController.text;
  var existenceMitoyenneteHabitationInput = Provider.of<GlobalProvider>(context, listen: false).existenceMitoyenneteHabitationInputController.text;
  var existenceVoirieMitoyennete = Provider.of<GlobalProvider>(context, listen: false).existenceVoirieMitoyenneteController.text;
  var existenceVoirieMitoyenneteInput = Provider.of<GlobalProvider>(context, listen: false).existenceVoirieMitoyenneteInputController.text;
  var presenceRemblais = Provider.of<GlobalProvider>(context, listen: false).presenceRemblaisController.text;
  var presenceRemblaisInput = Provider.of<GlobalProvider>(context, listen: false).presenceRemblaisInputController.text;
  var presenceSourcesEauCavite = Provider.of<GlobalProvider>(context, listen: false).presenceSourcesEauCaviteController.text;
  var presenceSourcesEauCaviteInput = Provider.of<GlobalProvider>(context, listen: false).presenceSourcesEauCaviteInputController.text;
  var presenceTalwegs = Provider.of<GlobalProvider>(context, listen: false).presenceTalwegsController.text;
  var presenceTalwegsInput = Provider.of<GlobalProvider>(context, listen: false).presenceTalwegsInputController.text;
  var terrainInondable = Provider.of<GlobalProvider>(context, listen: false).terrainInondableController.text;
  var terrainInondableInput = Provider.of<GlobalProvider>(context, listen: false).terrainInondableInputController.text;
  var terrainPente = Provider.of<GlobalProvider>(context, listen: false).terrainPenteController.text;
  var terrainPenteInput = Provider.of<GlobalProvider>(context, listen: false).terrainPenteInputController.text;
  var risqueInstabilite = Provider.of<GlobalProvider>(context, listen: false).risqueInstabiliteController.text;
  var risqueInstabiliteInput = Provider.of<GlobalProvider>(context, listen: false).risqueInstabiliteInputController.text;
  var terrassementsEntames = Provider.of<GlobalProvider>(context, listen: false).terrassementsEntamesController.text;
  var terrassementsEntamesInput = Provider.of<GlobalProvider>(context, listen: false).terrassementsEntamesInputController.text;
  var conclusion_1Controller = Provider.of<GlobalProvider>(context, listen: false).conclusion_1Controller.text;
  var conclusion_2Controller = Provider.of<GlobalProvider>(context, listen: false).conclusion_2Controller.text;
  var conclusion_3Controller = Provider.of<GlobalProvider>(context, listen: false).conclusion_3Controller;
  var observationsComplementairesInput = Provider.of<GlobalProvider>(context, listen: false).observationsComplementairesInputController.text;
  var controlleur = Provider.of<GlobalProvider>(context, listen: false).controlleur;
  var projet = Provider.of<GlobalProvider>(context, listen: false).projet;
  var adresse = Provider.of<GlobalProvider>(context, listen: false).adresse;
  var nom_direction = Provider.of<GlobalProvider>(context, listen: false).nom_direction;
  var code_agence = Provider.of<GlobalProvider>(context, listen: false).code_agence;
  var nom_agence = Provider.of<GlobalProvider>(context, listen: false).nom_agence;
  var tel = Provider.of<GlobalProvider>(context, listen: false).tel;
  var fax = Provider.of<GlobalProvider>(context, listen: false).fax;
  var email = Provider.of<GlobalProvider>(context, listen: false).email;
  var dateVisite = Provider.of<GlobalProvider>(context, listen: false).dateVisite;
  var listePresents = Provider.of<GlobalProvider>(context, listen: false)
      .personnesTierces.map((e) {
        return '('+ e.thirdPerson + ': '+ e.fullName +')';
      })
      .join(', ');
  var directions = {
    'DRC': 'Direction Régionale Centre',
    'DRSE': 'Direction Régionale Sud Est',
    'DRO': 'Direction Régionale Ouest',
    'DRE': 'Direction Régionale Est',
    'DRSO': 'Direction Régionale Sud Ouest',
    'DG': 'Direction Générale',
    'DDE': 'Direction Diagnostique et Expertise',
  };

  pdf.addPage(
    pw.Page(
        margin: pw.EdgeInsets.all(20.0),
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.openSansRegular(),
          bold: await PdfGoogleFonts.openSansBold(),
          icons: await PdfGoogleFonts.materialIcons(), // this line
        ),
        build: (context) => pw.Container(
          width: size.width,
          height: size.height,
          child: pw.Column(
            children: [
              pw.Container(
                width: size.width,
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: size.width,
                      child: pw.Column(
                        children: [
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(3),
                              1: pw.FlexColumnWidth(7),
                            },
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(1.0),
                                    child: pw.Column(
                                      children: [
                                        pw.Image(
                                          pw.MemoryImage(imageData),
                                          width: 50.0,
                                          height: 50.0,
                                        ),
                                        pw.Text(
                                            directions[nom_direction]!,
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                                fontSize: 10.0
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(1.0),
                                    child: pw.Text(
                                      'COMPTE RENDU DE VISITE PRELIMINAIRE',
                                      style: pw.TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(3),
                              1: pw.FlexColumnWidth(1),
                            },
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                              bottom: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.all(4.0),
                                    child: pw.Row(
                                      children: [
                                        pw.Text(
                                          'Projet : ',
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Container(
                                          child: pw.RichText(
                                            overflow: pw.TextOverflow.span,
                                            textAlign: pw.TextAlign.center,
                                            maxLines: 3,
                                            text: pw.TextSpan(
                                                text: projet,
                                                style: pw.TextStyle(
                                                  color: PdfColors.black,
                                                  fontSize: 10.0,
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(4.0),
                                    child: pw.Text('Convention N° ${selectedAffaire}',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(1),
                              1: pw.FlexColumnWidth(9),
                            },
                            border: pw.TableBorder(
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                              bottom: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.all(4.0),
                                    child: pw.Text(
                                      'Adresse : ',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.all(4.0),
                                    child: pw.Text(
                                      adresse,
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 4.0),
                  width: size.width,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          bottom: 2.0,
                        ),
                        child: pw.Text(
                          'Liste des présents :',
                          style: pw.TextStyle(
                              fontSize: 13.0,
                              fontWeight: pw.FontWeight.bold
                          ),
                        ),
                      ),
                      pw.ConstrainedBox(
                        constraints: pw.BoxConstraints(
                            minHeight: 35.0
                        ),
                        child: pw.Container(
                          width: size.width,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 2.0
                              )
                          ),
                          child: pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                            child: pw.Text(
                              listePresents,
                              style: pw.TextStyle(
                                fontSize: 10.0,
                              ),
                            ),
                          )
                        ),
                      )
                    ],
                  )
              ),
              pw.Container(
                width: size.width,
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: size.width,
                      child: pw.Column(
                        children: [
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(5),
                              1: pw.FlexColumnWidth(1),
                              2: pw.FlexColumnWidth(1),
                              3: pw.FlexColumnWidth(13),
                            },
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              // Header
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Oui',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Non',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'REMARQUES',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Body
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrain accessible',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainAccessible == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainAccessible == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      '${terrainAccessibleInput}',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrain clôturé',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainCloture == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainCloture == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      '${terrainClotureInput}',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrain nu',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainNu == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainNu == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      '${terrainNuInput}',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),

                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Présence de végétation',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceVegetation == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceVegetation == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceVegetationInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Présence de pylônes (Transport d\'énergie)',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presencePylones == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presencePylones == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presencePylonesInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Existence mitoyenneté (Habitation)',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceMitoyenneteHabitation == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceMitoyenneteHabitation == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceMitoyenneteHabitationInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Existence d\'une voirie Mitoyenne',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceVoirieMitoyennete == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceVoirieMitoyennete == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      existenceVoirieMitoyenneteInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Présence de remblais ',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceRemblais == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceRemblais == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceRemblaisInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Présence de source(s), cours d\'eau ou cavité (enquéte chez les habitants)',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceSourcesEauCavite == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceSourcesEauCavite == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceSourcesEauCaviteInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Présence de talweg(s) ',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceTalwegs == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceTalwegs == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      presenceTalwegsInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrain inondable',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainInondable == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainInondable == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainInondableInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrain en pente',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainPente == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainPente == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrainPenteInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Risque d\'instabilité (glissement de terrain)',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      risqueInstabilite == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      risqueInstabilite == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      risqueInstabiliteInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Terrassements entamés ',
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrassementsEntames == 'Oui'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrassementsEntames == 'Non'? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      terrassementsEntamesInput,
                                      style: pw.TextStyle(fontSize: 10.0,),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(
                              width: 2.0,
                            ),
                            children: [
                              pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(2.0),
                                      child: pw.ConstrainedBox(
                                        constraints: pw.BoxConstraints(
                                          minHeight: 75.0,
                                        ),
                                        child: pw.Column(
                                            children: [
                                              pw.Container(
                                                width: size.width,
                                                alignment: pw.Alignment.topLeft,
                                                child: pw.Text(
                                                  'Observations complémentaires :',
                                                  style: pw.TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight: pw.FontWeight.bold
                                                  ),
                                                ),
                                              ),
                                              pw.Container(
                                                width: size.width,
                                                alignment: pw.Alignment.topLeft,
                                                padding: pw.EdgeInsets.only(left: 5.0),
                                                child: pw.Text(
                                                  observationsComplementairesInput,
                                                  style: pw.TextStyle(
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                  ]
                              )
                            ],
                          ),
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(18),
                              1: pw.FlexColumnWidth(1),
                              2: pw.FlexColumnWidth(1),
                            },
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Conclusion :',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Oui',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(2.0),
                                    child: pw.Text(
                                      'Non',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(18),
                              1: pw.FlexColumnWidth(1),
                              2: pw.FlexColumnWidth(1),
                            },
                            border: pw.TableBorder(
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                              bottom: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.only(
                                      top: 2.0,
                                      left: 2.0,
                                      right: 2.0,
                                    ),
                                    child: pw.Text(
                                      'Ce terrain présente t-il des risques d\'instabilité lors des terrassements ?',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.only(
                                      top: 2.0,
                                      left: 2.0,
                                      right: 2.0,
                                    ),
                                    child: pw.Text(
                                      conclusion_1Controller == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.only(
                                      top: 2.0,
                                      left: 2.0,
                                      right: 2.0,
                                    ),
                                    child: pw.Text(
                                      conclusion_1Controller == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.centerLeft,
                                    padding: pw.EdgeInsets.only(
                                      left: 2.0,
                                      right: 2.0,
                                      bottom: 2.0,
                                    ),
                                    child: pw.Text(
                                      'Y\'a-t-il nécessité d\'adresser un courrier au Maitre d\'Ouvrage portant sur un risque encouru ?',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.only(
                                      left: 2.0,
                                      right: 2.0,
                                      bottom: 2.0,
                                    ),
                                    child: pw.Text(
                                      conclusion_2Controller == 'Oui' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.only(
                                      left: 2.0,
                                      right: 2.0,
                                      bottom: 2.0,
                                    ),
                                    child: pw.Text(
                                      conclusion_2Controller == 'Non' ? 'X' : '',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Table(
                            columnWidths: {
                              0: pw.FlexColumnWidth(6),
                              1: pw.FlexColumnWidth(2),
                              2: pw.FlexColumnWidth(3),
                            },
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              verticalInside: pw.BorderSide(
                                  width: 2.0
                              ),
                              left: pw.BorderSide(
                                  width: 2.0
                              ),
                              right: pw.BorderSide(
                                  width: 2.0
                              ),
                              top: pw.BorderSide(
                                  width: 2.0
                              ),
                              bottom: pw.BorderSide(
                                  width: 2.0
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                    child: pw.Row(
                                        children: [
                                          pw.Text(
                                            'Contrôleur ayant effectué la visite : ',
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                          pw.Text(
                                            controlleur,
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                    child: pw.Row(
                                        children: [
                                          pw.Text(
                                            'Date : ',
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                          pw.Text(
                                            dateVisite.day.toString().padLeft(2, '0') +'/'+ dateVisite.month.toString().padLeft(2, '0') +'/'+ dateVisite.year.toString().padLeft(4, '0'),
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                    child: pw.Row(
                                        children: [
                                          pw.Text(
                                            'Document(s) annexé(s) : ',
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                          pw.Icon(
                                            conclusion_3Controller
                                                ? pw.IconData(0xE834)
                                                : pw.IconData(0xE835),
                                            color: PdfColors.grey700,
                                            size: 18,
                                          )
                                        ]
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  width: size.width,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Divider(
                        color: PdfColors.black,
                        thickness: 1.5,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 5.0),
                        child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                              dateVisite.day.toString().padLeft(2, '0') +'/'+ dateVisite.month.toString().padLeft(2, '0') +'/'+ dateVisite.year.toString().padLeft(4, '0')
                                                  +' '+ dateVisite.hour.toString().padLeft(2, '0') +':'+ dateVisite.minute.toString().padLeft(2, '0'),
                                              style: pw.TextStyle(
                                                fontSize: 9.0,
                                                fontStyle: pw.FontStyle.italic,
                                              )
                                          ),
                                          pw.SizedBox(width: 20.0),
                                          pw.Text(
                                              '${selectedAffaire}',
                                              style: pw.TextStyle(
                                                fontSize: 9.0,
                                                fontStyle: pw.FontStyle.italic,
                                              )
                                          ),
                                        ]
                                      ),
                                      pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                                nom_direction,
                                                style: pw.TextStyle(
                                                  fontSize: 9.0,
                                                  fontStyle: pw.FontStyle.italic,
                                                )
                                            ),
                                            pw.SizedBox(width: 10.0),
                                            pw.Text(
                                                'Agence: ${nom_agence}',
                                                style: pw.TextStyle(
                                                  fontSize: 9.0,
                                                  fontStyle: pw.FontStyle.italic,
                                                )
                                            ),
                                          ]
                                      ),
                                      pw.Text(
                                          'Tel: ${tel}',
                                          style: pw.TextStyle(
                                            fontSize: 9.0,
                                            fontStyle: pw.FontStyle.italic,
                                          )
                                      ),
                                      pw.Text(
                                          'Fax: ${fax}',
                                          style: pw.TextStyle(
                                            fontSize: 9.0,
                                            fontStyle: pw.FontStyle.italic,
                                          )
                                      ),
                                      pw.Text(
                                          'Email: ${email}',
                                          style: pw.TextStyle(
                                            fontSize: 9.0,
                                            fontStyle: pw.FontStyle.italic,
                                          )
                                      ),
                                    ]
                                ),
                              ),
                              pw.Expanded(
                                child: pw.RichText(
                                  overflow: pw.TextOverflow.span,
                                  textAlign: pw.TextAlign.center,
                                  text: pw.TextSpan(
                                      text: adresse,
                                      style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontSize: 9.0,
                                      )
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                                    children: [
                                      pw.Text(
                                          'Version Octobre 2018',
                                          style: pw.TextStyle(
                                            fontSize: 9.0,
                                            fontStyle: pw.FontStyle.italic,
                                          )
                                      ),
                                      pw.SizedBox(
                                        height: 10.0,
                                      ),
                                      pw.Text(
                                          'F19-3A-02',
                                          style: pw.TextStyle(
                                              fontSize: 9.0,
                                              fontStyle: pw.FontStyle.italic,
                                              fontWeight: pw.FontWeight.bold
                                          )
                                      ),
                                    ]
                                ),
                              ),
                            ]
                        ),
                      )
                    ]
                  )
                ),
              ),
            ],
          ),
        )
    ),
  );

  return pdf.save();
}