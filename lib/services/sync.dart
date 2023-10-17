import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/models/site.dart';
import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/visite.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';

class Sync extends ChangeNotifier {

  final storage = new FlutterSecureStorage();
  late SyncHistory _syncPoint;
  late List _syncHistory = [];
  late List _syncedAffaires = [];
  late List _syncedSites = [];
  late bool _syncing = false;
  late bool _canSync = true;

  get syncHistory => _syncHistory;
  set setHistory(value){
    _syncHistory = value;
    notifyListeners();
  }

  get syncing => _syncing;
  setSyncing(value){
    _syncing = value;
    notifyListeners();
  }

  get canSync => _canSync;
  setCanSync(value){
    _canSync = value;
    notifyListeners();
  }

  getSyncHistory() async {
    _syncHistory = await VisitePreliminaireDatabase.instance.getSyncHistory();
    notifyListeners();
  }

  List<DateTime> getSyncHistoryDateTime() {
    return _syncHistory.map<DateTime>((e) => e.syncedAt).toList();
  }

  getSyncHistoryData() {
    return _syncHistory.map((e) => jsonDecode(e.syncedData));
  }

  // Sync
  syncData() async {
    String? token = await storage.read(key: 'token');
    String? matricule = await storage.read(key: 'matricule');
    late String syncedData = '';
    syncedData = await syncAffaires(token, syncedData, matricule!);
    syncedData = await syncSites(token, syncedData);
    syncedData = await syncVisites(token, syncedData, matricule);
    if(syncedData != '') {
      if(syncedData[syncedData.length-1] != '}')
        syncedData += '}';
      _syncPoint = SyncHistory(
        matricule: matricule!,
        syncedAt: DateTime.now(),
        syncedData: syncedData,
      );
      await VisitePreliminaireDatabase.instance.createSync(_syncPoint);
    }
    _syncHistory = await VisitePreliminaireDatabase.instance.getSyncHistory();
  }

  // syncAffaires
  syncAffaires(token, syncedData, matricule) async {
    late List ids = [];
    late List<Affaire> _ids = [];
    _ids = await VisitePreliminaireDatabase.instance.getAffairesFromAffairesWhereMatricule(matricule);
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
          'ids': ids,
          'matricule': matricule
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
    _syncedAffaires = responseAffaire.data
        .map((data) => Affaire.fromJson(data))
        .toList();

    if(_syncedAffaires.length >0)
      if(syncedData == '')
        syncedData += '{"Affaires": [${_syncedAffaires.map((e) => '"'+e.Code_Affaire.toString()+'"').toList().join(",")}]';
      else
        syncedData += ', "Affaires": [${_syncedAffaires.map((e) => '"'+e.Code_Affaire.toString()+'"').toList().join(",")}]';

    return syncedData;
  }

  // syncSites
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
      if(syncedData == '')
        syncedData += '{"Sites": [${_syncedSites.map((e) => '"'+e.Code_Affaire.toString()+'/'+e.Code_site.toString()+'"').toList().join(",")}]';
      else
        syncedData += ', "Sites": [${_syncedSites.map((e) => '"'+e.Code_Affaire.toString()+'/'+e.Code_site.toString()+'"').toList().join(",")}]';

    return syncedData;
  }

  // syncVisites
  syncVisites(token, syncedData, matricule) async {
    late List ids = [];
    late List<Visite> _ids = [];
    _ids = (await VisitePreliminaireDatabase.instance.getAffairesSitesFromVisitesWhereMatricule(matricule)).cast<Visite>();
    ids = _ids.map((e) => {
      'Code_Affaire': e.Code_Affaire.toString(),
      'Code_site': e.Code_site.toString(),
    }).toList();
    print("1111 ${ids}");
    Dio.Response response = await dio()
        .post(
        '/visite-preleminaire/visites-to-be-synced',
        data: {
          'ids': ids,
        },
        options: Dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Charset': 'utf-8'
          },
        )
    );

    var visites = await VisitePreliminaireDatabase.instance.getVisitesWhereAffairesSites(response.data);

    visites = visites.toList();
    var fileName, fileNameArray, filePath;
    if(visites.length > 0) {
      visites = visites.map((visite) {
        filePath = visite['siteImage'];
        fileNameArray = visite['siteImage'].split('/').toList();
        fileName = fileNameArray[fileNameArray.length-1];
        return {
          ...visite,
          'siteImage': fileName,
          'siteImagePath': filePath
        };
      });
      visites = visites.toList();

      var formData = Dio.FormData();
      formData.fields.add(
        MapEntry('visites', jsonEncode(visites))
      );

      visites.forEach((visite) async {
        formData.files.add(
          MapEntry(
            '${visite['siteImage']}',
            await Dio.MultipartFile.fromFile(
              visite['siteImagePath'],
              filename: fileName,
            ),
          )
        );
      });

      Dio.Response responseVisites = await dio()
          .post(
          '/visite-preleminaire/sync-visites',
          data: formData,
          options: Dio.Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Charset': 'utf-8'
            },
          )
      );

      if(syncedData == '')
        syncedData += '{"Visites": [${visites.map((e) => '"'+e['Code_Affaire'].toString()+'/'+e['Code_site'].toString()+'"').toList().join(",")}]';
      else
        syncedData += ', "Visites": [${visites.map((e) => '"'+e['Code_Affaire'].toString()+'/'+e['Code_site'].toString()+'"').toList().join(",")}]';
    }

    return syncedData;
  }

  getInvalidVisites(matricule) async {
    late List<Visite> ids = [];
    ids = (await VisitePreliminaireDatabase.instance.getInvalidVisitesWhereMatricule(matricule)).cast<Visite>();
    return ids.map((e) => e.Code_Affaire.toString()+'/'+e.Code_site.toString()).toList();
  }

  bool isJSON(str) {
    try {
      jsonDecode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

}