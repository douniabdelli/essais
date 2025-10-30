// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
// import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
// import 'package:mgtrisque_visitepreliminaire/screens/CreationPv.dart';
// import 'package:mgtrisque_visitepreliminaire/screens/interventionsBeton.dart';
// import 'package:mgtrisque_visitepreliminaire/services/preview_pv_page.dart';
// class AffairesScreen extends StatefulWidget {
//   const AffairesScreen({Key? key}) : super(key: key);

//   @override
//   State<AffairesScreen> createState() => _AffairesScreenState();
// }

// class _AffairesScreenState extends State<AffairesScreen> {
//   List<dynamic> interventions = [];
//   bool isLoading = true;
//   final storage = const FlutterSecureStorage();

//   // Couleurs du thème
//   static const Color chantierBlue = Color(0xFF1E3A8A);
//   static const Color chantierAccent = Color(0xFFFBBF24); // accent optionnel pour call-to-action

//   @override
//   void initState() {
//     super.initState();
//     fetchInterventions();
//   }

//   Future<void> fetchInterventions() async {
//     String? token = await storage.read(key: 'token');

//     if (token == null) {
//       setState(() => isLoading = false);
//       return;
//     }

//     try {
//       final response = await dio().get(
//         '/essais/interventions',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           interventions = response.data['data'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       print("⚠️ Erreur API: $e");
//     }
//   }

//   // Fonctions statut + couleur + icône
//   String _getStatutValidation(dynamic v) {
//     final int? val = int.tryParse(v?.toString() ?? '');
//     if (val == 1) return 'Validée';
//     if (val == 0 || val == null) return 'Brouillon';
//     return 'Inconnue';
//   }

//   Color _getCouleurStatut(dynamic v) {
//     final int? val = int.tryParse(v?.toString() ?? '');
//     if (val == 1) return Colors.green;
//     if (val == 0 || val == null) return Colors.orange;
//     return Colors.grey;
//   }

//   IconData _getIconStatut(dynamic v) {
//     final int? val = int.tryParse(v?.toString() ?? '');
//     if (val == 1) return Icons.check_circle;
//     if (val == 0 || val == null) return Icons.edit;
//     return Icons.help;
//   }

//   Widget buildStatCard(String title, String value, Color color, IconData icon) {
//     return Expanded(
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         child: Card(
//           elevation: 5,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               gradient: LinearGradient(
//                 colors: [color.withOpacity(0.95), color.withOpacity(0.55)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Icon(icon, size: 30, color: Colors.white),
//                 const SizedBox(height: 8),
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.white)),
//                 const SizedBox(height: 4),
//                 Text(value,
//                     style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // Section Statistiques
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               children: [
//                 // Toutes les cartes utilisent maintenant la couleur principale chantierBlue
//                 buildStatCard("Total", "${interventions.length}", chantierBlue, Icons.list),
//                 const SizedBox(width: 8),
//                 buildStatCard("Validées", "${_countValidated()}", chantierBlue, Icons.check_circle),
//                 const SizedBox(width: 8),
//                 buildStatCard("Brouillons", "${_countDrafts()}", chantierBlue, Icons.pending_actions),
//               ],
//             ),
//           ),

//           // Liste principale
//           Expanded(
//             child: interventions.isEmpty
//                 ? const Center(
//               child: Text(
//                 'Aucune donnée disponible',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//                 : ListView.builder(
//               itemCount: interventions.length,
//               itemBuilder: (context, index) {
//                 final item = interventions[index];
//                 final statut = _getStatutValidation(item['Validation_labo']);
//                 final couleur = _getCouleurStatut(item['Validation_labo']);
//                 final icon = _getIconStatut(item['Validation_labo']);
//                 final val = int.tryParse(item['Validation_labo']?.toString() ?? '0');
//                 final isValidated = val == 1;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 2,
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.all(16),
//                     leading: CircleAvatar(
//                       radius: 26,
//                       backgroundColor: chantierBlue.withOpacity(0.15),
//                       child: Icon(Icons.engineering, color: chantierBlue),
//                     ),
//                     title: Text(
//                       item['NumCommande'] ?? 'Commande inconnue',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("PV: ${item['pe_id'] ?? '—'}", style: TextStyle(color: Colors.grey[600])),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             Icon(_getIconStatut(item['Validation_labo']), size: 16, color: _getCouleurStatut(item['Validation_labo'])),
//                             const SizedBox(width: 6),
//                             Text(
//                               _getStatutValidation(item['Validation_labo']),
//                               style: TextStyle(color: _getCouleurStatut(item['Validation_labo']), fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (isValidated)

//                           IconButton(
//                             icon: const Icon(Icons.print, color: Colors.grey),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PreviewPVPage(pvData: item),
//                                 ),
//                               );
//                             },
//                           ),
//                         const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                       ],
//                     ),

//                     onTap: () {
//                       final val = int.tryParse(item['Validation_labo']?.toString() ?? '0');
//                       final isValidated = val == 1;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => InterventionsPage(
//                             canEdit: !isValidated,
//                             commandeData: item,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );

//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           await showDialog(
//             context: context,
//             builder: (context) => const ChoixPVDialog(),
//           );
//         },
//         backgroundColor: chantierBlue,
//         icon: const Icon(Icons.add),
//         label: const Text(""),
//       ),
//     );
//   }

//   // petites fonctions utilitaires pour remplir les cartes (exemple)
//   int _countValidated() {
//     try {
//       return interventions.where((i) {
//         final v = int.tryParse(i['Validation_labo']?.toString() ?? '');
//         return v == 1;
//       }).length;
//     } catch (_) {
//       return 0;
//     }
//   }

//   int _countDrafts() {
//     try {
//       return interventions.where((i) {
//         final v = int.tryParse(i['Validation_labo']?.toString() ?? '');
//         return v == 0 || v == null;
//       }).length;
//     } catch (_) {
//       return 0;
//     }
//   }
// }
