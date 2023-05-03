import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:mgtrisque_visitepreliminaire/screens/show_alert.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class VisiteScreen extends StatefulWidget {
  const VisiteScreen({Key? key}) : super(key: key);

  @override
  State<VisiteScreen> createState() => _VisiteScreenState();
}

class _VisiteScreenState extends State<VisiteScreen> {
  final _formKey = GlobalKey<FormState>();

  ImagePicker imagePicker = ImagePicker();

  _imageFromCamera() async {
    try {
      PickedFile? capturedImage = await imagePicker.getImage(source: ImageSource.camera);
      final File imagePath = File(capturedImage!.path);
      if (capturedImage == null)
        showAlert(
            bContext: context,
            title: "Error choosing file",
            content: "No file was selected");
      else
          Provider.of<GlobalProvider>(context, listen: false).setSiteImage = imagePath;
    } catch (e) {
      showAlert(
          bContext: context, title: "Error capturing image file", content: e.toString());
    }
  }

  _imageFromGallery() async {
    PickedFile? uploadedImage = await imagePicker.getImage(source: ImageSource.gallery);
    final File imagePath = File(uploadedImage!.path);

    if (uploadedImage == null)
      showAlert(
          bContext: context,
          title: "Error choosing file",
          content: "No file was selected");
    else
      Provider.of<GlobalProvider>(context, listen: false).setSiteImage = imagePath;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: Provider.of<GlobalProvider>(context, listen: false).selectedDate,
        firstDate: DateTime(1971),
        lastDate: DateTime(DateTime.now().year + 1));
    if (picked != null && picked != Provider.of<GlobalProvider>(context, listen: false).selectedDate)
        Provider.of<GlobalProvider>(context, listen: false).setSelectedDate = picked;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.redAccent.withOpacity(0.1),
      child: (Provider.of<GlobalProvider>(context, listen: true).selectedAffaire != '' && Provider.of<GlobalProvider>(context, listen: true).selectedSite != '')
        ? Column(
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
                            '${Provider.of<GlobalProvider>(context, listen: true).selectedDate.day} / '
                                '${Provider.of<GlobalProvider>(context, listen: true).selectedDate.month} / '
                                '${Provider.of<GlobalProvider>(context, listen: true).selectedDate.year}'
                        ),
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
                    currentStep: Provider.of<GlobalProvider>(context, listen: true).stepIndex,
                    controlsBuilder: (context, _) {
                      return Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if(Provider.of<GlobalProvider>(context, listen: true).stepIndex > 0)
                              ElevatedButton(
                                onPressed: () => {
                                  if (Provider.of<GlobalProvider>(context, listen: false).stepIndex > 0)
                                    Provider.of<GlobalProvider>(context, listen: false).setStepIndex =
                                        Provider.of<GlobalProvider>(context, listen: false).stepIndex - 1
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
                            if(Provider.of<GlobalProvider>(context, listen: true).stepIndex < 6)
                              ElevatedButton(
                                onPressed: () => {
                                  if (Provider.of<GlobalProvider>(context, listen: false).stepIndex < 6)
                                    Provider.of<GlobalProvider>(context, listen: false).setStepIndex =
                                        Provider.of<GlobalProvider>(context, listen: false).stepIndex + 1
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
                      Provider.of<GlobalProvider>(context, listen: false).setStepIndex = index;
                    },
                    type: StepperType.vertical,
                    steps: <Step>[
                      Step(
                          title: Text(
                            'Conditions du site',
                            style: TextStyle(
                                color: (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 0) ? Colors.blue : Colors.black,
                                fontSize: 18.0
                            ),
                          ),
                          content: Container(
    
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Terrain accessible
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Terrain accessible',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Oui',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainAccessibleController.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setTerrainAccessibleController = value;
                                                },

                                              ),
                                            ),
                                            Text('Oui'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Non',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainAccessibleController.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setTerrainAccessibleController = value;
                                                },
                                              ),
                                            ),
                                            Text('Non'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: Provider.of<GlobalProvider>(context, listen: true).terrainAccessibleInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Terrain cloturé
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Terrain clôturé',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainClotureController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainClotureController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainClotureController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainClotureController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).terrainClotureInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Terrain nu
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Terrain nu',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainNuController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainNuController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainNuController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainNuController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).terrainNuInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Terrain nu
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Présence de végétation',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceVegetationController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceVegetationController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceVegetationController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceVegetationController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).presenceVegetationInputController,
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
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 0,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 0)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 0) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Contraintes',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 1) ? Colors.blue : Colors.black,
                                fontSize: 18.0
                            ),
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
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Présence de pylônes',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presencePylonesController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresencePylonesController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presencePylonesController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresencePylonesController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).presencePylonesInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Existence de mitoyenneté (habitation)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Existence de mitoyenneté (habitation)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).existenceMitoyenneteHabitationController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setExistenceMitoyenneteHabitationController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).existenceMitoyenneteHabitationController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setExistenceMitoyenneteHabitationController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).existenceMitoyenneteHabitationInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Existence d'une voirie mitoyenneté
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Existence d\'une voirie mitoyenne',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).existenceVoirieMitoyenneteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setExistenceVoirieMitoyenneteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).existenceVoirieMitoyenneteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setExistenceVoirieMitoyenneteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).existenceVoirieMitoyenneteInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Présence de remblais
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Présence de remblais',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceRemblaisController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceRemblaisController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceRemblaisController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceRemblaisController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).presenceRemblaisInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Présence de sources, cours d\'eau ou cavité (Enquête chez les habitants)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Présence de sources, cours d\'eau ou cavité (Enquête chez les habitants)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceSourcesEauCaviteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceSourcesEauCaviteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceSourcesEauCaviteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceSourcesEauCaviteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).presenceSourcesEauCaviteInputController,
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
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Présence de talwegs',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceTalwegsController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceTalwegsController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).presenceTalwegsController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setPresenceTalwegsController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).presenceTalwegsInputController,
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
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 1,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 1)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 1) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Risques',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 2) ? Colors.blue : Colors.black,
                                fontSize: 18.0),
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
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Terrain inondable',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainInondableController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainInondableController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainInondableController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainInondableController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).terrainInondableInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Terrain en pente
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Terrain en pente',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainPenteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainPenteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrainPenteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrainPenteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).terrainPenteInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Risque d'instabilité
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Risque d\'instabilité',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Oui',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).risqueInstabiliteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setRisqueInstabiliteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).risqueInstabiliteController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setRisqueInstabiliteController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).risqueInstabiliteInputController,
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
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Terrassements entamés
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              'Terrassements entamés',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      value: 'Oui',
                                                      groupValue: Provider.of<GlobalProvider>(context, listen: true).terrassementsEntamesController.text,
                                                      onChanged: (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrassementsEntamesController = value;
                                                      }
                                                  ),
                                                ),
                                                Text('Oui'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Radio(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    value: 'Non',
                                                    groupValue: Provider.of<GlobalProvider>(context, listen: true).terrassementsEntamesController.text,
                                                    onChanged: (value) {
                                                      Provider.of<GlobalProvider>(context, listen: false).setTerrassementsEntamesController = value;
                                                    },
                                                  ),
                                                ),
                                                Text('Non'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: Provider.of<GlobalProvider>(context, listen: true).terrassementsEntamesInputController,
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
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 2,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 2)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 2) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Observations complémentaires',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 3) ? Colors.blue : Colors.black,
                                fontSize: 18.0),
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
                                      controller: Provider.of<GlobalProvider>(context, listen: true).observationsComplementairesInputController,
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
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 3,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 3)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 3) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Conclusion',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 4) ? Colors.blue : Colors.black,
                                fontSize: 18.0
                            ),
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
                                      child: Container(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Ce terrain présente-t-il des risques d\'instabilité lors des terrassements ?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Oui'),
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Oui',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).conclusion_1Controller.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setConclusion_1Controller = value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Non'),
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Non',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).conclusion_1Controller.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setConclusion_1Controller = value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Conclusion 2
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Y\'a-t-il nécessité d\'adresser un courrier au "Maitre d\'ouvrage" portant sur un risque encouru ?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Oui'),
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Oui',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).conclusion_2Controller.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setConclusion_2Controller = value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Non'),
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Radio(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                value: 'Non',
                                                groupValue: Provider.of<GlobalProvider>(context, listen: true).conclusion_2Controller.text,
                                                onChanged: (value) {
                                                  Provider.of<GlobalProvider>(context, listen: false).setConclusion_2Controller = value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
    
                                Divider(
                                  color: Colors.black26,
                                  thickness: 1.0,
                                  indent: 50.0,
                                  endIndent: 50.0,
                                  height: 20.0,
                                ),
    
                                // Conclusion 3
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Document(s) annexé(e)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Checkbox(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: Provider.of<GlobalProvider>(context, listen: true).conclusion_3Controller,
                                        onChanged: (bool? value) {
                                          Provider.of<GlobalProvider>(context, listen: false).setConclusion_3Controller = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 4,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 4)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 4) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Photo',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 5) ? Colors.blue : Colors.black,
                                fontSize: 18.0
                            ),
                          ),
                          content: Column(
                            children: [
                              Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                          'Photo du site',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                              if(Provider.of<GlobalProvider>(context, listen: false).siteImage != null)
                                Container(
                                  width: MediaQuery.of(context).size.width * 2 / 3,
                                  height: MediaQuery.of(context).size.width * 2 / 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: FileImage(Provider.of<GlobalProvider>(context, listen: false).siteImage),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.red, width: 1.5),
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(10.0),
                                              onTap: () {
                                                Provider.of<GlobalProvider>(context, listen: false).setSiteImage = null;
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 25.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if(Provider.of<GlobalProvider>(context, listen: false).siteImage != null)
                                SizedBox(height: 10.0),
                              Container(
                                width: MediaQuery.of(context).size.width * 2 / 3,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Color.fromRGBO(0, 0, 0, 0.1),
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                          ),
                                          child: Column(children: [
                                            Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 30,
                                              ),
                                            ),
                                            Text(
                                              "Prendre photo",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          ]),
                                          onPressed: () => {
                                            _imageFromCamera(),
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10.0,),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Color.fromRGBO(0, 0, 0, 0.1),
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                          ),
                                          child: Column(children: [
                                            Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Icon(
                                                Icons.photo_library_outlined,
                                                size: 30,
                                              ),
                                            ),
                                            Text(
                                              "Charger photo",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          ]),
                                          onPressed: () => {
                                            _imageFromGallery(),
                                          },
                                        ),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 5,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 5)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 5) ? StepState.complete : StepState.disabled)
                      ),
                      Step(
                          title: Text(
                            'Liste des présents',
                            style: TextStyle(
                                color:
                                (Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 6) ? Colors.blue : Colors.black,
                                fontSize: 18.0
                            ),
                          ),
                          content: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            'Liste des présents',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: IconButton(
                                          onPressed: (){
                                            showDialog(context: context, builder: (BuildContext context){
                                              return AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                                  elevation: 0.0,
                                                  insetPadding: EdgeInsets.zero,
                                                  titlePadding: EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 8.0
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Expanded(child: Text('Ajouter une personne')),
                                                      IconButton(
                                                        onPressed: (){
                                                          Provider.of<GlobalProvider>(context, listen: false).setPresentPersonFullName = null;
                                                          Provider.of<GlobalProvider>(context, listen: false).clearPresentPersonController();
                                                          Navigator.of(context).pop();
                                                        },
                                                        icon: Icon(
                                                            Icons.close,
                                                            color: Colors.red
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        constraints: BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Container(
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  'Personne tierce',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          DecoratedBox(
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(4.0),
                                                              boxShadow: <BoxShadow>[
                                                                BoxShadow(
                                                                  blurRadius: 1,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 10.0
                                                              ),
                                                              child: DropdownButton(
                                                                isExpanded: true,
                                                                items: Provider.of<GlobalProvider>(context, listen: false).thirdPerson
                                                                    .map<DropdownMenuItem<String>>((String value) {
                                                                  return DropdownMenuItem<String>(
                                                                    value: value,
                                                                    child: Text(value,),
                                                                  );
                                                                }).toList(),
                                                                value: Provider.of<GlobalProvider>(context, listen: true).presentPersonFullName,
                                                                onChanged: (String? newValue){
                                                                  Provider.of<GlobalProvider>(context, listen: false).setPresentPersonFullName = newValue!;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 30.0),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  'Nom complet',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          TextFormField(
                                                            controller: Provider.of<GlobalProvider>(context, listen: true).presentPersonController,
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
                                                                    width: 1.0
                                                                ),
                                                              ),
                                                            ),
                                                            style: TextStyle(
                                                              fontFamily: 'Arial',
                                                              fontSize: 15,
                                                              color: const Color(0xff707070),
                                                            ),
                                                            textAlign: TextAlign.start,
                                                            maxLines: 1,
                                                          ),
                                                        ]
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('Annuler'),
                                                      onPressed: (){
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresentPersonFullName = null;
                                                        Provider.of<GlobalProvider>(context, listen: false).clearPresentPersonController();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                        'Ajouter',
                                                        style: TextStyle(
                                                            color: Colors.white
                                                        ),
                                                      ),
                                                      onPressed: (){
                                                        Provider.of<GlobalProvider>(context, listen: false).addPersonnesTierces(
                                                          Provider.of<GlobalProvider>(context, listen: false).presentPersonController.text,
                                                          Provider.of<GlobalProvider>(context, listen: false).presentPersonFullName,
                                                        );
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresentPersonFullName = null;
                                                        Provider.of<GlobalProvider>(context, listen: false).clearPresentPersonController();
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.blue,
                                                      ),
                                                    ),
                                                  ]
                                              );
                                            });
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            size: 23.0,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          color: Colors.black,
                                          highlightColor: Colors.white,
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                              ListView.custom(
                                childrenDelegate: SliverChildBuilderDelegate(
                                      (context, ThirdPersonIndex) {
                                    return Container(
                                      height: 55.0,
                                      width: size.width,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 2.0
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 2.0
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${Provider.of<GlobalProvider>(context, listen: true).personnesTierces[ThirdPersonIndex].fullName}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.6),
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 1.0
                                                    ),
                                                    child: Text(
                                                      '${Provider.of<GlobalProvider>(context, listen: true).personnesTierces[ThirdPersonIndex].thirdPerson}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Material(
                                            type: MaterialType.transparency,
                                            child: Ink(
                                              child: InkWell(
                                                onTap: () {
                                                  Provider.of<GlobalProvider>(context, listen: false).removePersonnesTierces(ThirdPersonIndex);
                                                },
                                                child: Icon(
                                                    Icons.delete,
                                                    size: 20.0,
                                                    color: Colors.red.withOpacity(0.7)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(
                                              width: 0.0,
                                              color: Colors.red.withOpacity(0.6)
                                          )
                                      ),
                                    );
                                  },
                                  childCount: Provider.of<GlobalProvider>(context, listen: true).personnesTierces.length,
                                ),
                                shrinkWrap: true,
                              )
                            ],
                          ),
                          isActive: Provider.of<GlobalProvider>(context, listen: true).stepIndex >= 6,
                          state: (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 6)
                              ? StepState.editing
                              : ((Provider.of<GlobalProvider>(context, listen: true).stepIndex > 6) ? StepState.complete : StepState.disabled)
                      ),
                    ],
                  ),
                ),
              ),
              if(Provider.of<GlobalProvider>(context, listen: true).stepIndex == 6)
                Container(
                  margin: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1')
                        Material(
                        type: MaterialType.transparency,
                        child: Ink(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey, width: 1.5),
                            color: Colors.blueGrey.withOpacity(0.7),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () {
                              // todo: save form if visite hasn't been validated
                              print('+-------------- Save Button ---------------+');
                              Provider.of<GlobalProvider>(context, listen: false).submitForm();
                              _displayCustomMotionToast();
                            },
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                child: Row(
                                    children: [
                                      Image.asset('assets/images/save_icon.png', scale: 2.0,),
                                      SizedBox(width: 10.0),
                                      Text(
                                          'Sauvegarder',
                                          style: TextStyle(
                                              color: Colors.white
                                          )
                                      ),
                                    ]
                                )
                            ),
                          ),
                        ),
                      ),
                      if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1')
                        Material(
                        type: MaterialType.transparency,
                        child: Ink(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 1.5),
                            color: Colors.redAccent.withOpacity(0.7),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () {
                              // todo: save form if visite hasn't been validated
                              print('+-------------- Validate Button ---------------+');
                              Provider.of<GlobalProvider>(context, listen: false).validateForm();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/images/validate_icon.png', scale: 2.0,),
                                  SizedBox(width: 10.0),
                                  Text(
                                    'Valider',
                                      style: TextStyle(
                                        color: Colors.white
                                      )
                                  ),
                                ]
                              )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          )
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/unauthorized.png', scale: 1.5,),
                  SizedBox(height: 20.0),
                  Text(
                    "Vous devez sélectionner une affaire/site",
                      style: TextStyle(
                        color: Colors.redAccent.withOpacity(0.9),
                        fontWeight: FontWeight.w600
                      ),
                  ),
                ],
              )
            ),
          ]
        ),
    );
  }
  void _displayCustomMotionToast() {
    MotionToast(
      height: 50,
      width: MediaQuery.of(context).size.width * 4/5,
      icon: Icons.check_circle,
      primaryColor: Color.fromRGBO(183, 247, 196, 1.0),
      title: Text(
        'Succès',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text('Visite modifiée !'),
    ).show(context);
  }
}
