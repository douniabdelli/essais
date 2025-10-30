import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart' as app_dio;
// ...existing code...
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/screens/newIntervention.dart';
class TypeIntervention {
  final String label;
  final String value;
  final bool inactive;

  TypeIntervention({
    required this.label,
    required this.value,
    required this.inactive,
  });

  factory TypeIntervention.fromJson(Map<String, dynamic> json) {
    return TypeIntervention(
      label: json['label'],
      value: json['value'],
      inactive: json['inactive'],
    );
  }

  @override
  String toString() => label; // Pour l'affichage dans le Dropdown
}

class ChoixPVDialog extends StatefulWidget {
  const ChoixPVDialog({Key? key}) : super(key: key);

  @override
  State<ChoixPVDialog> createState() => _ChoixPVDialogState();
}

class _ChoixPVDialogState extends State<ChoixPVDialog> {
  List<TypeIntervention> typeInterventions = [];
  TypeIntervention? selectedIntervention;
  bool isLoading = true;
  String? errorMessage;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchTypeInterventions();
  }


  Future<void> fetchTypeInterventions() async {
    // Récupère le token stocké lors du login
    String? token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Token non trouvé. Veuillez vous reconnecter.";
      });
      debugPrint("Token absent dans le secure storage.");
      return;
    }

     // Récupère la baseUrl depuis services/dio.dart (fonction dio())
    String baseUrl = 'http://192.168.108.2:56/api';
    try {
      final dioInstance = app_dio.dio();
      final maybeBase = dioInstance.options.baseUrl;
      if (maybeBase != null && maybeBase.isNotEmpty) {
        baseUrl = maybeBase;
      }
    } catch (e) {
      debugPrint("Impossible de récupérer baseUrl depuis dio(): $e. Utilisation de la valeur par défaut.");
    }

    // Normalise la base (retire slash final si présent) puis ajoute /essais/interventions
    final normalizedBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$normalizedBase/essais/interventions');
    debugPrint('GET $uri avec token: $token');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> interventionsData =
            data['typeInterventions'] ?? data['data'] ?? [];

        setState(() {
          typeInterventions = interventionsData
              .map((json) => TypeIntervention.fromJson(json))
              .where((intervention) => !intervention.inactive)
              .toList();
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Erreur lors du chargement: ${response.statusCode}";
        });
        debugPrint("Réponse du serveur: ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion: $e";
      });
      debugPrint("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choix du PV d'intervention à créer"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TypeIntervention>(
                decoration: const InputDecoration(
                  labelText: "Type d'intervention ",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                value: selectedIntervention,
                isExpanded: true,
                items: typeInterventions
                    .map<DropdownMenuItem<TypeIntervention>>((intervention) {
                  return DropdownMenuItem<TypeIntervention>(
                    value: intervention,
                    child: Text(
                      intervention.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedIntervention = value;
                  });

                  // Navigation immédiate vers la page de création.
                  // Remplacez le constructeur ci‑dessous par celui que vous avez dans NewInterventionsPage,
                  // ou utilisez Navigator.pushNamed(...) si la route est enregistrée.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewInterventionsPage(

                     canInsertion: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.close, color: Colors.blue),
          label: const Text("Fermer"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade800, // couleur du texte et de l’icône
          ),
          onPressed: () => Navigator.pop(context),
        ),

        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Valider"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: selectedIntervention != null
              ? () {
                  Navigator.pop(context, selectedIntervention!.value);
                }
              : null,
        ),
      ],
    );
  }
}