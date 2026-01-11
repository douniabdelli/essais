import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/models/class_Beton.dart';
import 'package:mgtrisque_visitepreliminaire/models/commande.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mgtrisque_visitepreliminaire/models/interventions.dart';
import 'package:mgtrisque_visitepreliminaire/services/dio.dart';

class InterventionFormManager {
  final storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchFormulations(String codeCommande) async {
    try {
      final token = await storage.read(key: 'token');
      final resp = await dio().get(
        '/essais/get_formulation_beton/$codeCommande',
        options: Options(headers: {'Authorization': token != null ? 'Bearer $token' : ''}),
      );
      if (resp.statusCode == 200) {
        final data = resp.data;
        
        if (data == null) return [];
        if (data is Map && data['pvs_fb'] is List) {
          return List<Map<String, dynamic>>.from(data['pvs_fb']);
        }
        
        if (data is Map && data['firstPv'] is Map) {
          return [Map<String, dynamic>.from(data['firstPv'])];
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('fetchFormulations error: $e');
      return [];
    }
  }

  Future<Interventions> fetchInterventions() async {
    debugPrint('fetchInterventions: enter');
    final token = await storage.read(key: 'token');
    debugPrint('fetchInterventions: token read -> ${token == null ? "null" : (token.length > 12 ? token.substring(0,12) + "..." : token)}');

    if (token == null || token.isEmpty) {
      debugPrint('fetchInterventions: token missing or empty');
      throw Exception("Aucun token trouvé, veuillez vous reconnecter.");
    }

    Map<String, dynamic> _toMap(dynamic item) {
      if (item == null) return {};
      if (item is Map) return Map<String, dynamic>.from(item);
      if (item is String) {
        try {
          final decoded = json.decode(item);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {
          return {'label': item};
        }
      }
      return {};
    }

    List<dynamic> _norm(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw;
      if (raw is Map) return raw.values.toList();
      if (raw is String) {
        try {
          final d = json.decode(raw);
          if (d is List) return d;
          if (d is Map) return d.values.toList();
        } catch (_) {}
      }
      return [];
    }

    try {
      final base = dio().options.baseUrl;
      debugPrint('fetchInterventions: calling dio GET /essais/interventions_setpdataBeton (baseUrl="$base")');
      final response = await dio().get(
        '/essais/interventions_setpdataBeton',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('fetchInterventions: statusCode=${response.statusCode}');
      try {
        debugPrint('fetchInterventions: raw response.data=${jsonEncode(response.data)}');
      } catch (e) {
        debugPrint('fetchInterventions: unable to jsonEncode response.data -> $e (type=${response.data.runtimeType})');
      }

      if (response.statusCode == 200) {
        final data = response.data ?? {};
        debugPrint('fetchInterventions: data type ${data.runtimeType}');

        final rawCommandes = _norm(data['commandes']);
        final rawBeton = _norm(data['beton']);
        final rawElementPredefini = _norm(data['elementPredefini']);
        final rawModes = _norm(data['modesProduction']);
        final rawCarrieres = _norm(data['carrieres']);
        final rawTypesCiment = _norm(data['types_ciments']);
        final rawTypesAdjuvants = _norm(data['types_adjuvants']);
        final rawTypesEprouvettes = _norm(data['types_eprouvettes']);

        debugPrint('fetchInterventions: raw lengths -> commandes:${rawCommandes.length}, beton:${rawBeton.length}, elementPredefini:${rawElementPredefini.length}, modes:${rawModes.length}, carrieres:${rawCarrieres.length}');

        final commandes = <Commande>[];
        for (var item in rawCommandes) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) {
              commandes.add(Commande.fromJson(m));
            } else {
              debugPrint('fetchInterventions: skip commande empty map for item=$item (type=${item.runtimeType})');
            }
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse Commande -> $e\n$st\nitem=$item');
          }
        }

        final betons = <ClasseBeton>[];
        for (var item in rawBeton) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) betons.add(ClasseBeton.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse ClasseBeton -> $e\n$st\nitem=$item');
          }
        }

        final elementPredef = <ElementPredefini>[];
        for (var item in rawElementPredefini) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) elementPredef.add(ElementPredefini.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse ElementPredefini -> $e\n$st\nitem=$item');
          }
        }

        final ModePro = <ModesProduction>[];
        for (var item in rawModes) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) ModePro.add(ModesProduction.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse ModesProduction -> $e\n$st\nitem=$item');
          }
        }

        final carrieres = <ClasseCarrieres>[];
        for (var item in rawCarrieres) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) carrieres.add(ClasseCarrieres.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse ClasseCarrieres -> $e\n$st\nitem=$item');
          }
        }

        final typeciment = <TypeCiments>[];
        for (var item in rawTypesCiment) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) typeciment.add(TypeCiments.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse TypeCiments -> $e\n$st\nitem=$item');
          }
        }

        final typeAdjuvant = <TypeAdjuvants>[];
        for (var item in rawTypesAdjuvants) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) typeAdjuvant.add(TypeAdjuvants.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse TypeAdjuvants -> $e\n$st\nitem=$item');
          }
        }

        final typeEprouvette = <TypeEprouvettes>[];
        for (var item in rawTypesEprouvettes) {
          try {
            final m = _toMap(item);
            if (m.isNotEmpty) typeEprouvette.add(TypeEprouvettes.fromJson(m));
          } catch (e, st) {
            debugPrint('fetchInterventions: failed parse TypeEprouvettes -> $e\n$st\nitem=$item');
          }
        }

        debugPrint('fetchInterventions: parsed counts -> commandes:${commandes.length}, betons:${betons.length}, elementPredef:${elementPredef.length}');

        return Interventions(
          commandes: commandes,
          betons: betons,
          elementPredefini: elementPredef,
          modePro: ModePro,
          carrieres: carrieres,
          typeciment: typeciment,
          typeAdjuvant: typeAdjuvant,
          typeEprouvette: typeEprouvette,
          // default/empty values for the additional fields
          intervention: <String, dynamic>{},
          affaire: <String, dynamic>{},
          chargeAffaire: <String, dynamic>{},
          elementsouvrages: <Elemouvrage>[],
          constituants: <Constituant>[],
          eprouvettes: <Eprouvette>[],
          series: <Map<String, dynamic>>[],
          //interventionuser: <String, dynamic>{},
        );
      } else {
        debugPrint('fetchInterventions: non-200 status -> ${response.statusCode}');
        throw Exception("Erreur ${response.statusCode}: ${response.data}");
      }
    } catch (e, st) {
      debugPrint('fetchInterventions: exception -> $e\n$st');
      rethrow;
    }
  }
}