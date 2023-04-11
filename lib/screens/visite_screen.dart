import 'package:flutter/material.dart';

class VisiteScreen extends StatefulWidget {
  const VisiteScreen({Key? key}) : super(key: key);

  @override
  State<VisiteScreen> createState() => _VisiteScreenState();
}

class _VisiteScreenState extends State<VisiteScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  int _stepIndex = 0;
  late String _terrain_accessible = '';
  // todo: using textEditingController
  //final _terrain_accessible = TextEditingController();
  final _terrain_accessible_input_controller = TextEditingController();


  late String _terrain_cloture = '';
  final _terrain_cloture_input_controller = TextEditingController();

  late String _terrain_nu = '';
  final _terrain_nu_input_controller = TextEditingController();

  late String _presence_vegetation = '';
  final _presence_vegetation_input_controller = TextEditingController();

  late String _presence_pylones = '';
  final _presence_pylones_input_controller = TextEditingController();

  late String _existence_mitoyennete_habitation = '';
  final _existence_mitoyennete_habitation_input_controller = TextEditingController();

  late String _existence_voirie_mitoyennete = '';
  final _existence_voirie_mitoyennete_input_controller = TextEditingController();

  late String _presence_remblais = '';
  final _presence_remblais_input_controller = TextEditingController();

  late String _presence_sources_eau_cavite = '';
  final _presence_sources_eau_cavite_input_controller = TextEditingController();

  late String _terrain_inondable = '';
  final _terrain_inondable_input_controller = TextEditingController();

  late String _terrain_pente = '';
  final _terrain_pente_input_controller = TextEditingController();

  late String _risque_instabilite = '';
  final _risque_instabilite_input_controller = TextEditingController();

  late String _terrassements_entames = '';
  final _terrassements_entames_input_controller = TextEditingController();

  final _observations_complementaires_input_controller = TextEditingController();

  late String _conclusion_1 = '';
  late String _conclusion_2 = '';
  late bool _conclusion_3 = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1971),
        lastDate: DateTime(DateTime.now().year + 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Visite effectuée le :',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 20.0,
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Row(
                  children: [
                    Text(
                        '${selectedDate.day} / ${selectedDate.month} / ${selectedDate.year}'),
                    SizedBox(
                      width: 10.0,
                    ),
                    Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Stepper(
                currentStep: _stepIndex,
                controlsBuilder: (context, _) {
                  return Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(_stepIndex > 0)
                          ElevatedButton(
                            onPressed: () => {
                              if (_stepIndex > 0)
                                setState(() {
                                  _stepIndex -= 1;
                                })
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).secondaryHeaderColor),
                            child: Row(
                              children: [
                                Icon(Icons.navigate_before,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 10.0),
                                Text('Précédant',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ],
                            ),
                        ),
                        if(_stepIndex < 5)
                          ElevatedButton(
                            onPressed: () => {
                              if (_stepIndex < 5)
                                setState(() {
                                  _stepIndex += 1;
                                })
                            },
                            child: Row(
                              children: [
                                Text('Suivant'),
                                SizedBox(width: 10.0),
                                Icon(Icons.navigate_next),
                              ],
                            ),
                        ),
                      ],
                    ),
                  );
                },
                onStepTapped: (int index) {
                  setState(() {
                    _stepIndex = index;
                  });
                },
                type: StepperType.vertical,
                steps: <Step>[
                  Step(
                      title: Text(
                        'Conditions du site',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 0) ? Colors.blue : Colors.black),
                      ),
                      content: Container(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Terrain accessible
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Text(
                                            'Terrain accessible',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Oui'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: _terrain_accessible,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_accessible = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Non'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: _terrain_accessible,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_accessible = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: _terrain_accessible_input_controller,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Color(0xff707070),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xff707070),
                                            width: 1.5
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: const Color(0xff707070),
                                    ),
                                    textAlign: TextAlign.start,
                                    minLines: 1,
                                    maxLines: 2,
                                  ),
                                ],
                              ),

                              // Terrain cloturé
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Text(
                                            'Terrain clôturé',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Oui'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: _terrain_cloture,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_cloture = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Non'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: _terrain_cloture,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_cloture = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: _terrain_cloture_input_controller,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Color(0xff707070),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xff707070),
                                            width: 1.5
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: const Color(0xff707070),
                                    ),
                                    textAlign: TextAlign.start,
                                    minLines: 1,
                                    maxLines: 2,
                                  ),
                                ],
                              ),

                              // Terrain nu
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Text(
                                            'Terrain nu',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Oui'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: _terrain_nu,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_nu = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Non'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: _terrain_nu,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _terrain_nu = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: _terrain_nu_input_controller,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Color(0xff707070),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xff707070),
                                            width: 1.5
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: const Color(0xff707070),
                                    ),
                                    textAlign: TextAlign.start,
                                    minLines: 1,
                                    maxLines: 2,
                                  ),
                                ],
                              ),

                              // Terrain nu
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Text(
                                            'Présence de végétation',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Oui'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: _presence_vegetation,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _presence_vegetation = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Transform.scale(
                                                scale: 0.8,
                                                child: ListTile(
                                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                  horizontalTitleGap: -5.0,
                                                  title: const Text('Non'),
                                                  leading: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: _presence_vegetation,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _presence_vegetation = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: _presence_vegetation_input_controller,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Color(0xff707070),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xff707070),
                                            width: 1.5
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: const Color(0xff707070),
                                    ),
                                    textAlign: TextAlign.start,
                                    minLines: 1,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                      isActive: _stepIndex >= 0,
                      state: (_stepIndex == 0)
                          ? StepState.editing
                          : ((_stepIndex > 0) ? StepState.complete : StepState.disabled)
                  ),
                  Step(
                      title: Text(
                        'Contraintes',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 1) ? Colors.blue : Colors.black),
                      ),
                      content: Container(
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Présence de pylônes
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Présence de pylônes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _presence_pylones,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_pylones = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _presence_pylones,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_pylones = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _presence_pylones_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Existence de mitoyenneté (habitation)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Existence de mitoyenneté (habitation)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _existence_mitoyennete_habitation,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _existence_mitoyennete_habitation = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _existence_mitoyennete_habitation,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _existence_mitoyennete_habitation = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _existence_mitoyennete_habitation_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Existence d'une voirie mitoyenneté
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Existence d\'une voirie mitoyenneté',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _existence_voirie_mitoyennete,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _existence_voirie_mitoyennete = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _existence_voirie_mitoyennete,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _existence_voirie_mitoyennete = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _existence_voirie_mitoyennete_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Présence de remblais
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Présence de remblais',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _presence_remblais,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_remblais = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _presence_remblais,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_remblais = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _presence_remblais_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Présence de sources, cours d\'eau ou cavité (Enquête chez les habitants)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Présence de sources, cours d\'eau ou cavité (Enquête chez les habitants)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _presence_sources_eau_cavite,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_sources_eau_cavite = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _presence_sources_eau_cavite,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _presence_sources_eau_cavite = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _presence_sources_eau_cavite_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      isActive: _stepIndex >= 1,
                      state: (_stepIndex == 1)
                          ? StepState.editing
                          : ((_stepIndex > 1) ? StepState.complete : StepState.disabled)
                  ),
                  Step(
                      title: Text(
                        'Risques',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 2) ? Colors.blue : Colors.black),
                      ),
                      content: Container(
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Terrain inondable
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Terrain inondable',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _terrain_inondable,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrain_inondable = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _terrain_inondable,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrain_inondable = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _terrain_inondable_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Terrain en pente
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Terrain en pente',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _terrain_pente,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrain_pente = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _terrain_pente,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrain_pente = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _terrain_pente_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Risque d'instabilité
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Risque d\'instabilité',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _risque_instabilite,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _risque_instabilite = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _risque_instabilite,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _risque_instabilite = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _risque_instabilite_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                            // Terrassements entamés
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Text(
                                          'Terrassements entamés',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Oui'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Oui',
                                                  groupValue: _terrassements_entames,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrassements_entames = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Transform.scale(
                                              scale: 0.8,
                                              child: ListTile(
                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                horizontalTitleGap: -5.0,
                                                title: const Text('Non'),
                                                leading: Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Non',
                                                  groupValue: _terrassements_entames,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _terrassements_entames = value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _terrassements_entames_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      isActive: _stepIndex >= 2,
                      state: (_stepIndex == 2)
                          ? StepState.editing
                          : ((_stepIndex > 2) ? StepState.complete : StepState.disabled)
                  ),
                  Step(
                      title: Text(
                        'Observations complémentaires',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 3) ? Colors.blue : Colors.black),
                      ),
                      content: Container(
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Observations complémentaires
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    'Observations complémentaires',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _observations_complementaires_input_controller,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Color(0xff707070),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: Color(0xff707070),
                                          width: 1.5
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 15,
                                    color: const Color(0xff707070),
                                  ),
                                  textAlign: TextAlign.start,
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isActive: _stepIndex >= 3,
                      state: (_stepIndex == 3)
                          ? StepState.editing
                          : ((_stepIndex > 3) ? StepState.complete : StepState.disabled)
                  ),
                  Step(
                      title: Text(
                        'Conclusion',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 4) ? Colors.blue : Colors.black),
                      ),
                      content: Container(
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Conclusion 1
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: Text(
                                      'Ce terrain présente-t-il des risques d\'instabilité lors des terrassements ?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.8,
                                        child: ListTile(
                                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                          horizontalTitleGap: -5.0,
                                          title: const Text('Oui'),
                                          leading: Radio(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            value: 'Oui',
                                            groupValue: _conclusion_1,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _conclusion_1 = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: ListTile(
                                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                          horizontalTitleGap: -5.0,
                                          title: const Text('Non'),
                                          leading: Radio(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            value: 'Non',
                                            groupValue: _conclusion_1,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _conclusion_1 = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Conclusion 2
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: Text(
                                      'Y\'a-t-il nécessité d\'adresser un courrier au <<Maitre d\'ouvrage>> portant sur un risque encouru ?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.8,
                                        child: ListTile(
                                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                          horizontalTitleGap: -5.0,
                                          title: const Text('Oui'),
                                          leading: Radio(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            value: 'Oui',
                                            groupValue: _conclusion_2,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _conclusion_2 = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: ListTile(
                                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                          horizontalTitleGap: -5.0,
                                          title: const Text('Non'),
                                          leading: Radio(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            value: 'Non',
                                            groupValue: _conclusion_2,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _conclusion_2 = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Conclusion 3
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: Text(
                                      'Document(s) annexé(e)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Checkbox(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: _conclusion_3,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _conclusion_3 = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isActive: _stepIndex >= 4,
                      state: (_stepIndex == 4)
                          ? StepState.editing
                          : ((_stepIndex > 4) ? StepState.complete : StepState.disabled)
                  ),
                  Step(
                      title: Text(
                        'Photos',
                        style: TextStyle(
                            color:
                                (_stepIndex >= 5) ? Colors.blue : Colors.black),
                      ),
                      content: Text('Photos'),
                      isActive: _stepIndex >= 5,
                      state: (_stepIndex == 5)
                          ? StepState.editing
                          : ((_stepIndex > 5) ? StepState.complete : StepState.disabled)
                  ),
                ],
              ),
            ),
          ),
          if(_stepIndex == 4)
            Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1.5),
                      color: Colors.redAccent.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.save,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
