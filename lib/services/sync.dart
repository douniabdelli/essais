import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';

class Sync extends ChangeNotifier {
  final storage = new FlutterSecureStorage();
  late SyncHistory _syncPoint;
  late List<SyncHistory> _syncHistory = [];
  late List _syncedAffaires = [];
  late List _syncedSites = [];

  get syncHistory => _syncPoint;
  set setSyncHistory(value){
    _syncPoint = value;
    notifyListeners();
  }

  // todo: Sync
  syncData() async {
    String? token = await storage.read(key: 'token');
    String? matricule = await storage.read(key: 'matricule');
    late String syncedData = '';
    syncedData = await syncAffaires(token, syncedData);
    syncedData = await syncSites(token, syncedData);
    syncedData = await syncVisites(token, syncedData);
    print('*** SyncData : ${syncedData} ***');
    if(syncedData != '') {
      _syncPoint = SyncHistory(
        matricule: matricule!,
        syncedAt: DateTime.now(),
        syncedData: syncedData,
      );
      print('*** SyncPoint : ${_syncPoint.matricule} ***');
      await VisitePreliminaireDatabase.instance.createSync(_syncPoint);
    }
    _syncHistory = await VisitePreliminaireDatabase.instance.getSyncHistory();
    print('SyncHistory : ${_syncHistory}');
  }

  // todo: syncAffaires
  syncAffaires(token, syncedData) async {
    late List ids = [];
    late List<Affaire> _ids = [];
    _ids = await VisitePreliminaireDatabase.instance.getAffairesFromAffaires();
    ids = _ids.map((e) =>
          {
            'Code_Affaire': e.Code_Affaire.toString(),
            'matricule': e.matricule.toString()
          }
        ).toList();
    Dio.Response responseAffaire = await dio()
        .post(
        '/visite-preleminaire/sync-affaires',
        data: {
          'ids': ids
        },
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createAffaires(responseAffaire.data.map((data) => Affaire.fromJson(data)).toList());
    _syncedAffaires = responseAffaire.data.map((data) => Affaire.fromJson(data)).toList();
    if(_syncedAffaires.length >0)
      syncedData += '*** Affaires : ${_syncedAffaires.map((e) => e.Code_Affaire).toString()}';

    return syncedData;
  }

  // todo: syncSites
  syncSites(token, syncedData) async {
    late List ids = [];
    late List notInIds = [];
    late List<Affaire> _ids = [];
    late List<Site> _notInIds = [];
    _ids = await VisitePreliminaireDatabase.instance.getAffairesFromAffaires();
    _notInIds = await VisitePreliminaireDatabase.instance.getAffairesFromSites();
    ids = _ids.map((e) => e.Code_Affaire).toList();
    notInIds = _notInIds.map((e) => e.Code_Affaire).toList();
    Dio.Response responseSite = await dio()
        .post(
        '/visite-preleminaire/sync-sites',
        data: {
          'ids': ids,
          'notInIds': notInIds,
        },
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );
    await VisitePreliminaireDatabase.instance.createSites(responseSite.data.map((data) => Site.fromJson(data)).toList());
    _syncedSites = responseSite.data.map((data) => Site.fromJson(data)).toList();
    if(_syncedAffaires.length >0)
      syncedData += '*** Sites : ${_syncedSites.map((e) => e.Code_site).toString()}';

    return syncedData;
  }

  // todo: syncVisites
  syncVisites(token, syncedData) async {

    return syncedData;
  }

}