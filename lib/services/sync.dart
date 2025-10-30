// import 'dart:convert';
// import 'dart:io' as io;
// import 'dart:io';
// import 'package:dio/dio.dart' as Dio;
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
// import 'package:mgtrisque_visitepreliminaire/models/site.dart';
// import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
// import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
//
// import 'package:mgtrisque_visitepreliminaire/services/dio.dart';
// import 'package:intl/intl.dart';
// class Sync extends ChangeNotifier {
//
//   final storage = new FlutterSecureStorage();
//   late SyncHistory _syncPoint;
//   late List _syncHistory = [];
//   late List _syncedAffaires = [];
//   late List _syncedSites = [];
//   late bool _syncing = false;
//   late bool _canSync = true;
//
//   get syncHistory => _syncHistory;
//
//   set setHistory(value) {
//     _syncHistory = value;
//     notifyListeners();
//   }
//
//   get syncing => _syncing;
//
//   setSyncing(value) {
//     _syncing = value;
//     notifyListeners();
//   }
//
//   get canSync => _canSync;
//
//   setCanSync(value) {
//     _canSync = value;
//     notifyListeners();
//   }
//
//   getSyncHistory() async {
//     _syncHistory = await VisitePreliminaireDatabase.instance.getSyncHistory();
//     notifyListeners();
//   }
//
//   List<DateTime> getSyncHistoryDateTime() {
//     return _syncHistory.map<DateTime>((e) => e.syncedAt).toList();
//   }
//
//   getSyncHistoryData() {
//     return _syncHistory.map((e) => jsonDecode(e.syncedData));
//   }
//
//   // Sync
//   syncData() async {
//     String? token = await storage.read(key: 'token');
//     String? matricule = await storage.read(key: 'matricule');
//     if (token == null || matricule == null) {
//       print('Token ou matricule manquant');
//       return;
//     }
//     late String syncedData = '';
//     Map<String, dynamic> syncMap = {};
//     syncedData = await syncAffaires(token, syncedData, matricule!);
//     syncedData = await syncSites(token, syncedData);
//
//
//     if (syncedData != '') {
//       if (syncedData[syncedData.length - 1] != '}')
//         syncedData += '}';
//       _syncPoint = SyncHistory(
//         matricule: matricule!,
//         syncedAt: DateTime.now(),
//         syncedData: syncedData,
//       );
//       await VisitePreliminaireDatabase.instance.createSync(_syncPoint);
//     }
//     _syncHistory = await VisitePreliminaireDatabase.instance.getSyncHistory();
//   }
//
//   // syncAffaires
//   syncAffaires(token, syncedData, matricule) async {
//     late List ids = [];
//     late List<Affaire> _ids = [];
//     _ids = await VisitePreliminaireDatabase.instance
//         .getAffairesFromAffairesWhereMatricule(matricule);
//     ids = _ids.map((e) =>
//     {
//       'Code_Affaire': e.Code_Affaire.toString(),
//       'matricule': e.matricule.toString()
//     }
//     ).toList();
//     Dio.Response responseAffaire = await dio()
//         .post(
//         '/visite-preleminaire/sync-affaires',
//         data: {
//           'ids': ids,
//           'matricule': matricule
//         },
//         options: Dio.Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//             'Charset': 'utf-8'
//           },
//         )
//     );
//     await VisitePreliminaireDatabase.instance.createAffaires(
//         responseAffaire.data.map((data) => Affaire.fromJson(data)).toList());
//     _syncedAffaires = responseAffaire.data
//         .map((data) => Affaire.fromJson(data))
//         .toList();
//
//     if (_syncedAffaires.length > 0)
//       if (syncedData == '')
//         syncedData += '{"Affaires": [${_syncedAffaires.map((e) => '"' +
//             e.Code_Affaire.toString() + '"').toList().join(",")}]';
//       else
//         syncedData += ', "Affaires": [${_syncedAffaires.map((e) => '"' +
//             e.Code_Affaire.toString() + '"').toList().join(",")}]';
//
//     return syncedData;
//   }
//
//   // syncSites
//   syncSites(token, syncedData) async {
//     late List ids = [];
//     late List notInIds = [];
//     late List<Affaire> _ids = [];
//     late List<Site> _notInIds = [];
//     _ids = await VisitePreliminaireDatabase.instance.getAffairesFromAffaires();
//     _notInIds =
//     await VisitePreliminaireDatabase.instance.getAffairesFromSites();
//     ids = _ids.map((e) => e.Code_Affaire).toList();
//     notInIds = _notInIds.map((e) => e.Code_Affaire).toList();
//     Dio.Response responseSite = await dio()
//         .post(
//         '/visite-preleminaire/sync-sites',
//         data: {
//           'ids': ids,
//           'notInIds': notInIds,
//         },
//         options: Dio.Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//             'Charset': 'utf-8'
//           },
//         )
//     );
//     await VisitePreliminaireDatabase.instance.createSites(
//         responseSite.data.map((data) => Site.fromJson(data)).toList());
//     _syncedSites =
//         responseSite.data.map((data) => Site.fromJson(data)).toList();
//     if (_syncedAffaires.length > 0)
//       if (syncedData == '')
//         syncedData +=
//         '{"Sites": [${_syncedSites.map((e) => '"' + e.Code_Affaire.toString() +
//             '/' + e.Code_site.toString() + '"')
//             .toList()
//             .join(",")}]';
//       else
//         syncedData +=
//         ', "Sites": [${_syncedSites.map((e) => '"' + e.Code_Affaire.toString() +
//             '/' + e.Code_site.toString() + '"')
//             .toList()
//             .join(",")}]';
//
//     return syncedData;
//   }
//
//
//   late List _syncedWebVisites = [];
//
// }