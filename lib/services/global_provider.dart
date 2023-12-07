import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/third_person.dart';
import 'package:mgtrisque_visitepreliminaire/models/visite.dart';
import 'package:path_provider/path_provider.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _selectedAffaire = '';
  late String _controlleur = '';
  late String _projet = '';
  late String _adresse = '';
  late String _nom_direction = '';
  late String _code_agence = '';
  late String _nom_agence = '';
  late String _tel = '';
  late String _fax = '';
  late String _email = '';
  late int? _selectedAffaireIndex = null;
  late String _selectedSite = '';
  late int _currentIndex = 1;
  late DateTime _dateVisite = DateTime.now();
  final _present_person_full_name = TextEditingController();
  late String? _present_person_controller = null;
  late int _stepIndex = 0;
  late DateTime _selectedDate = DateTime.now();
  var _siteImage = null;
  var _capturedImage;
  late List<String> _thirdPerson = [
    'Maitre d\'ouvrage',
    'maitre d\'oeuvre',
    'laboratoire',
    'BET',
    'Entreprise de réalisation'
  ];

  bool _visiteExistes = false;
  bool get visiteExistes => _visiteExistes;
  setVisiteExistes() async {
    _visiteExistes = await VisitePreliminaireDatabase.instance.checkExistanceVisite(_selectedAffaire, _selectedSite);
    notifyListeners();
  }

  final _terrainAccessibleController = TextEditingController();
  final _terrainAccessibleInputController = TextEditingController();

  final _terrainClotureController = TextEditingController();
  final _terrainClotureInputController = TextEditingController();

  final _terrainNuController = TextEditingController();
  final _terrainNuInputController = TextEditingController();

  final _presenceVegetationController = TextEditingController();
  final _presenceVegetationInputController = TextEditingController();

  final _presencePylonesController = TextEditingController();
  final _presencePylonesInputController = TextEditingController();

  final _existenceMitoyenneteHabitationController = TextEditingController();
  final _existenceMitoyenneteHabitationInputController = TextEditingController();

  final _existenceVoirieMitoyenneteController = TextEditingController();
  final _existenceVoirieMitoyenneteInputController = TextEditingController();

  final _presenceRemblaisController = TextEditingController();
  final _presenceRemblaisInputController = TextEditingController();

  final _presenceSourcesEauCaviteController = TextEditingController();
  final _presenceSourcesEauCaviteInputController = TextEditingController();

  final _presenceTalwegsController = TextEditingController();
  final _presenceTalwegsInputController = TextEditingController();

  final _terrainInondableController = TextEditingController();
  final _terrainInondableInputController = TextEditingController();

  final _terrainPenteController = TextEditingController();
  final _terrainPenteInputController = TextEditingController();

  final _risqueInstabiliteController = TextEditingController();
  final _risqueInstabiliteInputController = TextEditingController();

  final _terrassementsEntamesController = TextEditingController();
  final _terrassementsEntamesInputController = TextEditingController();

  final _observationsComplementairesInputController = TextEditingController();

  final _conclusion_1Controller = TextEditingController();
  final _conclusion_2Controller = TextEditingController();
  late bool _conclusion_3Controller = false;

  late String _ValidCRVPIng = '';

  late List _personnesTierces = [];

  List get personnesTierces  {
    return _personnesTierces;
  }
  void addPersonnesTierces(thirdPerson, fullName){
    _personnesTierces.add(ThirdPerson(thirdPerson: thirdPerson, fullName: fullName));
    notifyListeners();
  }
  void removePersonnesTierces(index){
    _personnesTierces.removeAt(index);
    notifyListeners();
  }

  String get screenTitle => _screenTitle;
  set setScreenTitle(value) {
    _screenTitle = value;
    notifyListeners();
  }

  String get validCRVPIng => _ValidCRVPIng;
  set setValidCRVPIng(value) {
    _ValidCRVPIng = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  DateTime get dateVisite => _dateVisite;
  set setDateVisite(value) {
    _dateVisite = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  int get currentIndex => _currentIndex;
  set setCurrentIndex(value) {
    _currentIndex = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  int get selectedAffaireIndex => _selectedAffaireIndex!;
  set setSelectedAffaireIndex(value) {
    _selectedAffaireIndex = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  String get selectedAffaire => _selectedAffaire;
  set setSelectedAffaire(value) {
    _selectedAffaire = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////


  String get selectedSite => _selectedSite;
  setSelectedSite(value) async {
    _selectedSite = value;
    await setVisiteExistes();
    if(value != ''){
      var visisteExists = await VisitePreliminaireDatabase
          .instance
          .checkExistanceVisite(_selectedAffaire, _selectedSite);

      if(visisteExists) {
        var visite = await VisitePreliminaireDatabase
            .instance
            .getVisite(_selectedAffaire, _selectedSite);
        var user = await VisitePreliminaireDatabase
            .instance
            .getUserByMatricule(visite.matricule);
        var affaire = await VisitePreliminaireDatabase
            .instance
            .getAffaire(visite.Code_Affaire);
        _controlleur = user.nom +' '+ user.prenom;
        _projet = affaire.IntituleAffaire;
        _adresse = affaire.adresse;
        _nom_direction = affaire.Nom_DR;
        _code_agence = affaire.code_agence;
        _nom_agence = affaire.nom_agence;
        _tel = affaire.tel;
        _fax = affaire.fax;
        _email = affaire.email;
        await prepareVisiteFormData(visite);
      } else
        resetVisiteForm();
      _currentIndex = 2;
      _screenTitle = 'Visite Préliminaire';
    }
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  int get stepIndex => _stepIndex;
  set setStepIndex(value) {
    _stepIndex = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  DateTime get selectedDate => _selectedDate;
  set setSelectedDate(value) {
    _selectedDate = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  get controlleur => _controlleur;
  get projet => _projet;
  get adresse => _adresse;
  get code_agence => _code_agence;
  get nom_direction => _nom_direction;
  get nom_agence => _nom_agence;
  get tel => _tel;
  get fax => _fax;
  get email => _email;

  get siteImage => _siteImage;
  set setSiteImage(value) {
    _siteImage = value;
    notifyListeners();
  }

  get capturedImage => _capturedImage;
  set setCapturedImage(value) {
    _capturedImage = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  get thirdPerson => _thirdPerson;
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presentPersonFullName => _present_person_full_name;
  set setPresentPersonFullName(value) {
    _present_person_full_name.text = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  String? get presentPersonController => _present_person_controller;
  set setPresentPersonController(value) {
    _present_person_controller = value;
    notifyListeners();
  }
  clearPresentPersonController() {
    _present_person_controller = null;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrainAccessibleController => _terrainAccessibleController;
  set setTerrainAccessibleController(value) {
    _terrainAccessibleController.text = value;
    notifyListeners();
  }
  clearTerrainAccessibleController() {
    _terrainAccessibleController.clear();
    notifyListeners();
  }

  TextEditingController get terrainAccessibleInputController => _terrainAccessibleInputController;
  clearTerrainAccessibleInputController() {
    _terrainAccessibleInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrainClotureController => _terrainClotureController;
  set setTerrainClotureController(value) {
    _terrainClotureController.text = value;
    notifyListeners();
  }
  clearTerrainClotureController() {
    _terrainClotureController.clear();
    notifyListeners();
  }

  TextEditingController get terrainClotureInputController => _terrainClotureInputController;
  clearTerrainClotureInputController() {
    _terrainClotureInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrainNuController => _terrainNuController;
  set setTerrainNuController(value) {
    _terrainNuController.text = value;
    notifyListeners();
  }
  clearTerrainNuController() {
    _terrainNuController.clear();
    notifyListeners();
  }

  TextEditingController get terrainNuInputController => _terrainNuInputController;
  clearTerrainvInputController() {
    _terrainNuInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presenceVegetationController => _presenceVegetationController;
  set setPresenceVegetationController(value) {
    _presenceVegetationController.text = value;
    notifyListeners();
  }
  clearPresenceVegetationController() {
    _presenceVegetationController.clear();
    notifyListeners();
  }

  TextEditingController get presenceVegetationInputController => _presenceVegetationInputController;
  clearPresenceVegetationInputController() {
    _presenceVegetationInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presencePylonesController => _presencePylonesController;
  set setPresencePylonesController(value) {
    _presencePylonesController.text = value;
    notifyListeners();
  }
  clearPresencePylonesController() {
    _presencePylonesController.clear();
    notifyListeners();
  }

  TextEditingController get presencePylonesInputController => _presencePylonesInputController;
  clearPresencePylonesInputController() {
    _presencePylonesInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get existenceMitoyenneteHabitationController => _existenceMitoyenneteHabitationController;
  set setExistenceMitoyenneteHabitationController(value) {
    _existenceMitoyenneteHabitationController.text = value;
    notifyListeners();
  }
  clearExistenceMitoyenneteHabitationController() {
    _existenceMitoyenneteHabitationController.clear();
    notifyListeners();
  }

  TextEditingController get existenceMitoyenneteHabitationInputController => _existenceMitoyenneteHabitationInputController;
  clearExistenceMitoyenneteHabitationInputController() {
    _existenceMitoyenneteHabitationInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get existenceVoirieMitoyenneteController => _existenceVoirieMitoyenneteController;
  set setExistenceVoirieMitoyenneteController(value) {
    _existenceVoirieMitoyenneteController.text = value;
    notifyListeners();
  }
  clearExistenceVoirieMitoyenneteController() {
    _existenceVoirieMitoyenneteController.clear();
    notifyListeners();
  }

  TextEditingController get existenceVoirieMitoyenneteInputController => _existenceVoirieMitoyenneteInputController;
  clearExistenceVoirieMitoyenneteInputController() {
    _existenceVoirieMitoyenneteInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presenceRemblaisController => _presenceRemblaisController;
  set setPresenceRemblaisController(value) {
    _presenceRemblaisController.text = value;
    notifyListeners();
  }
  clearPresenceRemblaisController() {
    _presenceRemblaisController.clear();
    notifyListeners();
  }

  TextEditingController get presenceRemblaisInputController => _presenceRemblaisInputController;
  clearPresenceRemblaisInputController() {
    _presenceRemblaisInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presenceSourcesEauCaviteController => _presenceSourcesEauCaviteController;
  set setPresenceSourcesEauCaviteController(value) {
    _presenceSourcesEauCaviteController.text = value;
    notifyListeners();
  }
  clearPresenceSourcesEauCaviteController() {
    _presenceSourcesEauCaviteController.clear();
    notifyListeners();
  }

  TextEditingController get presenceSourcesEauCaviteInputController => _presenceSourcesEauCaviteInputController;
  clearPresenceSourcesEauCaviteInputController() {
    _presenceSourcesEauCaviteInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presenceTalwegsController => _presenceTalwegsController;
  set setPresenceTalwegsController(value) {
    _presenceTalwegsController.text = value;
    notifyListeners();
  }
  clearPresenceTalwegsController() {
    _presenceTalwegsController.clear();
    notifyListeners();
  }

  TextEditingController get presenceTalwegsInputController => _presenceTalwegsInputController;
  clearPresenceTalwegsInputController() {
    _presenceTalwegsInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrainInondableController => _terrainInondableController;
  set setTerrainInondableController(value) {
    _terrainInondableController.text = value;
    notifyListeners();
  }
  clearTerrainInondableController() {
    _terrainInondableController.clear();
    notifyListeners();
  }

  TextEditingController get terrainInondableInputController => _terrainInondableInputController;
  clearTerrainInondableInputController() {
    _terrainInondableInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrainPenteController => _terrainPenteController;
  set setTerrainPenteController(value) {
    _terrainPenteController.text = value;
    notifyListeners();
  }
  clearTerrainPenteController() {
    _terrainPenteController.clear();
    notifyListeners();
  }

  TextEditingController get terrainPenteInputController => _terrainPenteInputController;
  clearTerrainPenteInputController() {
    _terrainPenteInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get risqueInstabiliteController => _risqueInstabiliteController;
  set setRisqueInstabiliteController(value) {
    _risqueInstabiliteController.text = value;
    notifyListeners();
  }
  clearRisqueInstabiliteController() {
    _risqueInstabiliteController.clear();
    notifyListeners();
  }

  TextEditingController get risqueInstabiliteInputController => _risqueInstabiliteInputController;
  clearRisqueInstabiliteInputController() {
    _risqueInstabiliteInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get terrassementsEntamesController => _terrassementsEntamesController;
  set setTerrassementsEntamesController(value) {
    _terrassementsEntamesController.text = value;
    notifyListeners();
  }
  clearTerrassementsEntamesController() {
    _terrassementsEntamesController.clear();
    notifyListeners();
  }

  TextEditingController get terrassementsEntamesInputController => _terrassementsEntamesInputController;
  clearTerrassementsEntamesInputController() {
    _terrassementsEntamesInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get observationsComplementairesInputController => _observationsComplementairesInputController;
  clearObservationsComplementairesInputController() {
    _observationsComplementairesInputController.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get conclusion_1Controller => _conclusion_1Controller;
  set setConclusion_1Controller(value) {
    _conclusion_1Controller.text = value;
    notifyListeners();
  }
  clearConclusion_1Controller() {
    _conclusion_1Controller.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get conclusion_2Controller => _conclusion_2Controller;
  set setConclusion_2Controller(value) {
    _conclusion_2Controller.text = value;
    notifyListeners();
  }
  clearConclusion_2Controller() {
    _conclusion_2Controller.clear();
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  bool get conclusion_3Controller => _conclusion_3Controller;
  set setConclusion_3Controller(value) {
    _conclusion_3Controller = value;
    notifyListeners();
  }
  clearConclusion_3Controller() {
    _conclusion_3Controller = false;
    notifyListeners();
  }
///////////////////////////////////////////////////////////////////////////////////////
// resetVisiteForm
  void resetVisiteForm(){
    _stepIndex = 0;
    _selectedDate = DateTime.now();
    _siteImage = null;
    _present_person_full_name.clear();
    _present_person_controller = null;
    _terrainAccessibleController.clear();
    _terrainAccessibleInputController.clear();
    _terrainClotureController.clear();
    _terrainClotureInputController.clear();
    _terrainNuController.clear();
    _terrainNuInputController.clear();
    _presenceVegetationController.clear();
    _presenceVegetationInputController.clear();
    _presencePylonesController.clear();
    _presencePylonesInputController.clear();
    _existenceMitoyenneteHabitationController.clear();
    _existenceMitoyenneteHabitationInputController.clear();
    _existenceVoirieMitoyenneteController.clear();
    _existenceVoirieMitoyenneteInputController.clear();
    _presenceRemblaisController.clear();
    _presenceRemblaisInputController.clear();
    _presenceSourcesEauCaviteController.clear();
    _presenceSourcesEauCaviteInputController.clear();
    _presenceTalwegsController.clear();
    _presenceTalwegsInputController.clear();
    _terrainInondableController.clear();
    _terrainInondableInputController.clear();
    _terrainPenteController.clear();
    _terrainPenteInputController.clear();
    _risqueInstabiliteController.clear();
    _risqueInstabiliteInputController.clear();
    _terrassementsEntamesController.clear();
    _terrassementsEntamesInputController.clear();
    _observationsComplementairesInputController.clear();
    _conclusion_1Controller.clear();
    _conclusion_2Controller.clear();
    _conclusion_3Controller = false;
    _ValidCRVPIng = '0';
    _personnesTierces = [];
  }

///////////////////////////////////////////////////////////////////////////////////////
// prepareVisiteFormData
  prepareVisiteFormData(visite) async {
    _stepIndex = 0;
    _present_person_full_name.clear();
    _present_person_controller = null;
    // Editables
    _selectedDate = visite.VisitSiteDate != 'null' ? DateTime.parse(visite.VisitSiteDate) : DateTime.now();
    _siteImage = (visite.siteImage != '' || visite.siteImage != null) ? visite.siteImage : null;
    _terrainAccessibleController.text = visite.VisitSite_Btn_terrain_accessible == '1' ? 'Oui' : (visite.VisitSite_Btn_terrain_accessible == '0' ? 'Non' : '');
    _terrainAccessibleInputController.text = visite.VisitSiteterrain_accessible == 'null' ? '' : visite.VisitSiteterrain_accessible;
    _terrainClotureController.text = visite.VisitSite_Btn_terrain_cloture == '1' ? 'Oui' : (visite.VisitSite_Btn_terrain_cloture == '0' ? 'Non' : '');
    _terrainClotureInputController.text = visite.VisitSiteterrain_cloture == 'null' ? '' : visite.VisitSiteterrain_cloture;
    _terrainNuController.text = visite.VisitSite_Btn_terrain_nu == '1' ? 'Oui' : (visite.VisitSite_Btn_terrain_nu == '0' ? 'Non' : '');
    _terrainNuInputController.text = visite.VisitSiteterrain_nu == 'null' ? '' : visite.VisitSiteterrain_nu;
    _presenceVegetationController.text = visite.VisitSite_Btn_presence_vegetation == '1' ? 'Oui' : (visite.VisitSite_Btn_presence_vegetation == '0' ? 'Non' : '');
    _presenceVegetationInputController.text = visite.VisitSitePresVeget == 'null' ? '' : visite.VisitSitePresVeget;
    _presencePylonesController.text = visite.VisitSite_Btn_presence_pylones == '1' ? 'Oui' : (visite.VisitSite_Btn_presence_pylones == '0' ? 'Non' : '');
    _presencePylonesInputController.text = visite.VisitSite_presence_pylones == 'null' ? '' : visite.VisitSite_presence_pylones;
    _existenceMitoyenneteHabitationController.text = visite.VisitSite_Btn_existance_mitoyntehab == '1' ? 'Oui' : (visite.VisitSite_Btn_existance_mitoyntehab == '0' ? 'Non' : '');
    _existenceMitoyenneteHabitationInputController.text = visite.VisitSiteExistantsvoisin == 'null' ? '' : visite.VisitSiteExistantsvoisin;
    _existenceVoirieMitoyenneteController.text = visite.VisitSite_Btn_existance_voirie_mitoyenne == '1' ? 'Oui' : (visite.VisitSite_Btn_existance_voirie_mitoyenne == '0' ? 'Non' : '');
    _existenceVoirieMitoyenneteInputController.text = visite.VisitSite_existance_voirie_mitoyenne == 'null' ? '' : visite.VisitSite_existance_voirie_mitoyenne;
    _presenceRemblaisController.text = visite.VisitSite_Btn_presence_remblais == '1' ? 'Oui' : (visite.VisitSite_Btn_presence_remblais == '0' ? 'Non' : '');
    _presenceRemblaisInputController.text = visite.VisitSitePresDepotremblai == 'null' ? '' : visite.VisitSitePresDepotremblai;
    _presenceSourcesEauCaviteController.text = visite.VisitSite_Btn_presence_sources_cours_eau_cavite == '1' ? 'Oui' : (visite.VisitSite_Btn_presence_sources_cours_eau_cavite == '0' ? 'Non' : '');
    _presenceSourcesEauCaviteInputController.text = visite.VisitSiteEngHabitant == 'null' ? '' : visite.VisitSiteEngHabitant;
    _presenceTalwegsController.text = visite.VisitSite_Btn_presence_talwegs == '1' ? 'Oui' : (visite.VisitSite_Btn_presence_talwegs == '0' ? 'Non' : '');
    _presenceTalwegsInputController.text = visite.visitesitePresDepotremblai == 'null' ? '' : visite.visitesitePresDepotremblai;
    _terrainInondableController.text = visite.VisitSite_Btn_terrain_inondable == '1' ? 'Oui' : (visite.VisitSite_Btn_terrain_inondable == '0' ? 'Non' : '');
    _terrainInondableInputController.text = visite.VisitSite_terrain_inondable == 'null' ? '' : visite.VisitSite_terrain_inondable;
    _terrainPenteController.text = visite.VisitSite_Btn_terrain_enpente == '1' ? 'Oui' : (visite.VisitSite_Btn_terrain_enpente == '0' ? 'Non' : '');
    _terrainPenteInputController.text = visite.VisitSite_terrain_enpente == 'null' ? '' : visite.VisitSite_terrain_enpente;
    _risqueInstabiliteController.text = visite.VisitSite_Btn_risque_InstabiliteGlisTerrain == '1' ? 'Oui' : (visite.VisitSite_Btn_risque_InstabiliteGlisTerrain == '0' ? 'Non' : '');
    _risqueInstabiliteInputController.text = visite.VisitSite_risque_InstabiliteGlisTerrain == 'null' ? '' : visite.VisitSite_risque_InstabiliteGlisTerrain;
    _terrassementsEntamesController.text = visite.VisitSite_Btn_terrassement_entame == '1' ? 'Oui' : (visite.VisitSite_Btn_terrassement_entame == '0' ? 'Non' : '');
    _terrassementsEntamesInputController.text = visite.VisitSite_terrassement_entame == 'null' ? '' : visite.VisitSite_terrassement_entame;
    _observationsComplementairesInputController.text = visite.VisitSiteAutre == 'null' ? '' : visite.VisitSiteAutre;
    _conclusion_1Controller.text = visite.VisitSite_Btn_Presence_risque_instab_terasmt == '1' ? 'Oui' : (visite.VisitSite_Btn_Presence_risque_instab_terasmt == '0' ? 'Non' : '');
    _conclusion_2Controller.text = visite.VisitSite_Btn_necessite_courrier_MO_risque_encouru == '1' ? 'Oui' : (visite.VisitSite_Btn_necessite_courrier_MO_risque_encouru == '0' ? 'Non' : '');
    _conclusion_3Controller = visite.VisitSite_Btn_doc_annexe == 'Oui' ? true : false;
    _ValidCRVPIng = visite.ValidCRVPIng == '1' ? '1' : '0';
    _personnesTierces = visite.VisitSite_liste_present != 'null'
        ? ( isJSON(visite.VisitSite_liste_present)
              ? ThirdPerson.deserialize(visite.VisitSite_liste_present) as List
              : []
          )
        : [];
  }
///////////////////////////////////////////////////////////////////////////////////////
// prepareVisiteFormData
  submitForm() async {
    final storage = new FlutterSecureStorage();
    String? matricule = await storage.read(key: 'matricule');

    late String? siteImagePath = null, path;
    final File image;
    if(_capturedImage != null){
      final File imageFile = File(_capturedImage.path);
      Directory appDir = await getApplicationDocumentsDirectory();
      path = appDir.path;
      siteImagePath = path + '/' + _selectedAffaire + '_' + _selectedSite + '_' + 'image' + p.extension(imageFile.path);
      image = await imageFile.copy(siteImagePath);
    }
    else if(_capturedImage != null && (siteImage != null || siteImage != ''))
      await File(siteImage).delete();

    var visitesData = [
      new Visite(
          Code_Affaire: _selectedAffaire,
          Code_site: _selectedSite,
          matricule: matricule!,
          siteImage: (siteImagePath != null) ? siteImagePath : '',
          VisitSiteDate: _selectedDate.toString(),
          VisitSite_Btn_terrain_accessible: _terrainAccessibleController.text,
          VisitSiteterrain_accessible: _terrainAccessibleInputController.text,
          VisitSite_Btn_terrain_cloture: _terrainClotureController.text,
          VisitSiteterrain_cloture: _terrainClotureInputController.text,
          VisitSite_Btn_terrain_nu: _terrainNuController.text,
          VisitSiteterrain_nu: _terrainNuInputController.text,
          VisitSite_Btn_presence_vegetation: _presenceVegetationController.text,
          VisitSitePresVeget: _presenceVegetationInputController.text,
          VisitSite_Btn_presence_pylones: _presencePylonesController.text,
          VisitSite_presence_pylones: _presencePylonesInputController.text,
          VisitSite_Btn_existance_mitoyntehab: _existenceMitoyenneteHabitationController.text,
          VisitSiteExistantsvoisin: _existenceMitoyenneteHabitationInputController.text,
          VisitSite_Btn_existance_voirie_mitoyenne: _existenceVoirieMitoyenneteController.text,
          VisitSite_existance_voirie_mitoyenne: _existenceVoirieMitoyenneteInputController.text,
          VisitSite_Btn_presence_remblais: _presenceRemblaisController.text,
          VisitSitePresDepotremblai: _presenceRemblaisInputController.text,
          VisitSite_Btn_presence_sources_cours_eau_cavite: presenceSourcesEauCaviteController.text,
          VisitSiteEngHabitant: _presenceSourcesEauCaviteInputController.text,
          VisitSite_Btn_presence_talwegs: _presenceTalwegsController.text,
          visitesitePresDepotremblai: _presenceTalwegsInputController.text,
          VisitSite_Btn_terrain_inondable: _terrainInondableController.text,
          VisitSite_terrain_inondable: _terrainInondableInputController.text,
          VisitSite_Btn_terrain_enpente: _terrainPenteController.text,
          VisitSite_terrain_enpente: _terrainPenteInputController.text,
          VisitSite_Btn_risque_InstabiliteGlisTerrain: _risqueInstabiliteController.text,
          VisitSite_risque_InstabiliteGlisTerrain: _risqueInstabiliteInputController.text,
          VisitSite_Btn_terrassement_entame: _terrassementsEntamesController.text,
          VisitSite_terrassement_entame: _terrassementsEntamesInputController.text,
          VisitSiteAutre: _observationsComplementairesInputController.text,
          VisitSite_Btn_Presence_risque_instab_terasmt: _conclusion_1Controller.text,
          VisitSite_Btn_necessite_courrier_MO_risque_encouru: _conclusion_2Controller.text,
          VisitSite_Btn_doc_annexe: _conclusion_3Controller ? '1' : '0',
          VisitSite_liste_present: jsonEncode(_personnesTierces),
          ValidCRVPIng: '0'
      )
    ];
    var existsVisite = await VisitePreliminaireDatabase.instance.checkExistanceVisite(_selectedAffaire, _selectedSite);
    if(existsVisite)
      await VisitePreliminaireDatabase.instance.updateVisite(visitesData);
    else
      await VisitePreliminaireDatabase.instance.createVisites(visitesData);
    notifyListeners();
  }

///////////////////////////////////////////////////////////////////////////////////////
// prepareVisiteFormData
  void validateForm() async {
    await VisitePreliminaireDatabase.instance.validateVisite(_selectedAffaire, _selectedSite);
    notifyListeners();
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