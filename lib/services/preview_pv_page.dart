import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mgtrisque_visitepreliminaire/services/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PreviewPVPage extends StatelessWidget {
  final Map<String, dynamic> pvData;
  const PreviewPVPage({super.key, required this.pvData});

  Future<void> _generatePDF(BuildContext context) async {
    final logo = await rootBundle.load('assets/logo-ctc.png');

    final data = {
      'logo': logo.buffer.asUint8List(),
      'pe_id': pvData['pe_id'] ?? '—',
      'date': pvData['created_at'] ?? '—',
      'date_validation_laboratoire_item': pvData['date_validation_laboratoire_it'] ?? '—',
      'user': pvData['user_code'] ?? '—',
      'userNom': pvData['user']?['Nom'] ?? '', // Fetch user name
      'userPrenom': pvData['user']?['Prenom'] ?? '', // Fetch user first name
      'intitule': pvData['Intitule_Affaire'] ?? '',
      'codeAffaire': pvData['Code_Affaire'] ?? '',
      'codeSite': pvData['Code_Site'] ?? '',
      'direction': pvData['Nom_DR'] ?? '',
      'entreprise': pvData['Entreprise']?['Nom'] ?? '', // Display only the name of the company
      'dateCoulage': pvData['DateCoulage'] ?? '',
      'classe': pvData['Classe_Beton'] ?? '',
      'elements': (pvData['elements'] ?? []) as List,
      'constituants': (pvData['constituants'] ?? []) as List,
    };

    // Generate PDF bytes
    final bytes = await generateLocalPV(data);

    // Push a new page with PdfPreview to show the PDF in-app
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Aperçu PDF'),
            backgroundColor: const Color(0xFF1E3A8A),
          ),
          body: PdfPreview(
            build: (PdfPageFormat format) async => bytes,
            allowPrinting: true,
            allowSharing: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aperçu du PV"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => _generatePDF(context),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text("Afficher l’aperçu PDF", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
