import 'dart:convert';

import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';

class SyncHistory {
  final String matricule;
  final DateTime syncedAt;
  final String syncedData;

  SyncHistory({
    required this.matricule,
    required this.syncedAt,
    required this.syncedData
  });

  factory SyncHistory.fromJson(Map<String, dynamic> json) =>
    SyncHistory(
      matricule: json['matricule'],
      syncedAt: DateTime.parse(json['syncedAt']),
      syncedData: json['syncedData'],
    );

  static Map<String, dynamic> toMap(SyncHistory model) =>
      <String, dynamic> {
        'matricule': model.matricule,
        'syncedAt': model.syncedAt,
        'syncedData': model.syncedData,
      };

  static String serialize(SyncHistory model) =>
      json.encode(SyncHistory.toMap(model));

  static List<SyncHistory> deserialize(String data) =>
      (json.decode(data) as List).map((i) => SyncHistory.fromJson(i)).toList();

}