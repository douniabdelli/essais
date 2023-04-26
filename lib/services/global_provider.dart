import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/db/visite_preliminaire_database.dart';
import 'package:mgtrisque_visitepreliminaire/models/third_person.dart';

class GlobalProvider extends ChangeNotifier {
  late String _screenTitle = 'Affaires';
  late String _selectedAffaire = '';
  late String _selectedSite = '';
  late int _currentIndex = 1;
  late DateTime _dateVisite = DateTime.now();
  late String? _present_person_full_name = null;
  final _present_person_controller = TextEditingController();
  late int _stepIndex = 0;
  DateTime _selectedDate = DateTime.now();
  var _siteImage = null;
  late List<String> _thirdPerson = [
    'Maitre d\'ouvrage',
    'maitre d\'oeuvre',
    'laboratoire',
    'BET',
    'Entreprise de réalisation'
  ];

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
  String get selectedAffaire => _selectedAffaire;
  set setSelectedAffaire(value) {
    _selectedAffaire = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  String get selectedSite => _selectedSite;
  set setSelectedSite(value) {
    _selectedSite = value;
    if(value != ''){
      var visite = VisitePreliminaireDatabase.instance.getVisite(_selectedAffaire, _selectedSite);
      print('*-----* ${visite}');
      if(visite != null)
        prepareVisiteFormData(visite);
      else 
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
  get siteImage => _siteImage;
  set setSiteImage(value) {
    _siteImage = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  get thirdPerson => _thirdPerson;
////////////////////////////////////////////////////////////////////////////////////////////
  String? get presentPersonFullName => _present_person_full_name;
  set setPresentPersonFullName(value) {
    _present_person_full_name = value;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////////
  TextEditingController get presentPersonController => _present_person_controller;
  clearPresentPersonController() {
    _present_person_controller.clear();
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
    _present_person_full_name = null;
    _present_person_controller.clear();
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
  }

///////////////////////////////////////////////////////////////////////////////////////
// prepareVisiteFormData
  void prepareVisiteFormData(visite){
    _stepIndex = 0;
    _selectedDate = DateTime.now();
    _siteImage = null;
    _present_person_full_name = null;
    _present_person_controller.clear();
    _terrainAccessibleController.text = 'Oui';
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
  }

}