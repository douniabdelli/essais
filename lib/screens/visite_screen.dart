import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mgtrisque_visitepreliminaire/screens/show_alert.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'dart:io';
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
      Provider.of<GlobalProvider>(context, listen: false).setCapturedImage = capturedImage;

      if (capturedImage == null)
        showAlert(
            bContext: context,
            title: "Error choosing file",
            content: "No file was selected");
      else
        Provider.of<GlobalProvider>(context, listen: false).setSiteImage = capturedImage.path;
    } catch (e) {
      showAlert(
          bContext: context, title: "Error capturing image file", content: e.toString());
    }
  }

  _imageFromGallery() async {
    PickedFile? uploadedImage = await imagePicker.getImage(source: ImageSource.gallery);
    Provider.of<GlobalProvider>(context, listen: false).setCapturedImage = uploadedImage;

    if (uploadedImage == null)
      showAlert(
          bContext: context,
          title: "Error choosing file",
          content: "No file was selected");
    else
      Provider.of<GlobalProvider>(context, listen: false).setSiteImage = uploadedImage.path;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Provider.of<GlobalProvider>(context, listen: false).selectedDate,
      firstDate: DateTime(1971),
      lastDate: DateTime(DateTime.now().year + 1),
    );
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
      child: (
          (Provider.of<GlobalProvider>(context, listen: true).selectedAffaire != '' && Provider.of<GlobalProvider>(context, listen: true).selectedSite != '')
              &&
          (['Consultation', 'Rédacteur'].contains(Provider.of<Auth>(context, listen: true).user?.role))
      )
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
                    onPressed: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1') 
                      ? () => _selectDate(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Row(
                      children: [
                        Text(
                            '${Provider.of<GlobalProvider>(context, listen: true).selectedDate.day} / '
                                '${Provider.of<GlobalProvider>(context, listen: true).selectedDate.month.toString().padLeft(2, '0')} / '
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
                                onPressed: canGoToNextStep(Provider.of<GlobalProvider>(context, listen: false).stepIndex)
                                    ? () => {
                                      if (Provider.of<GlobalProvider>(context, listen: false).stepIndex < 6)
                                        Provider.of<GlobalProvider>(context, listen: false).setStepIndex =
                                            Provider.of<GlobalProvider>(context, listen: false).stepIndex + 1
                                    }
                                    : null,
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setTerrainAccessibleController = value;
                                                  }
                                                  : null,
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setTerrainAccessibleController = value;
                                                  }
                                                  : null,
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
                                  enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrainClotureController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                       Provider.of<GlobalProvider>(context, listen: false).setTerrainClotureController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                        ? (value) {
                                                          Provider.of<GlobalProvider>(context, listen: false).setTerrainNuController = value;
                                                        }
                                                    : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                        ? (value) {
                                                          Provider.of<GlobalProvider>(context, listen: false).setTerrainNuController = value;
                                                        }
                                                        : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceVegetationController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceVegetationController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresencePylonesController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresencePylonesController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                       ? (value) {
                                                          Provider.of<GlobalProvider>(context, listen: false).setExistenceMitoyenneteHabitationController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setExistenceMitoyenneteHabitationController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setExistenceVoirieMitoyenneteController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setExistenceVoirieMitoyenneteController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceRemblaisController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                          ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceRemblaisController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceSourcesEauCaviteController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceSourcesEauCaviteController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceTalwegsController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setPresenceTalwegsController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrainInondableController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrainInondableController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrainPenteController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrainPenteController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setRisqueInstabiliteController = value;
                                                      }
                                                      : null,
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setRisqueInstabiliteController = value;
                                                      }
                                                      : null,
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                      onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                        ? (value) {
                                                          Provider.of<GlobalProvider>(context, listen: false).setTerrassementsEntamesController = value;
                                                        }
                                                        : null
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
                                                    onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                      ? (value) {
                                                        Provider.of<GlobalProvider>(context, listen: false).setTerrassementsEntamesController = value;
                                                      }
                                                      : null
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                      enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setConclusion_1Controller = value;
                                                  }
                                                  : null,
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setConclusion_1Controller = value;
                                                  }
                                                  : null,
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setConclusion_2Controller = value;
                                                  }
                                                  : null,
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
                                                onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                                  ? (value) {
                                                    Provider.of<GlobalProvider>(context, listen: false).setConclusion_2Controller = value;
                                                  }
                                                  : null,
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
                                        onChanged: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
                                          ? (bool? value) {
                                            Provider.of<GlobalProvider>(context, listen: false).setConclusion_3Controller = value;
                                          }
                                          : null,
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
                              if(Provider.of<GlobalProvider>(context, listen: false).siteImage != null && Provider.of<GlobalProvider>(context, listen: false).siteImage != '')
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
                                              image: FileImage(File(Provider.of<GlobalProvider>(context, listen: false).siteImage)),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
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
                              if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
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
                                      if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
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
                                                              enabled: (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1'),
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
                                          if(Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1' && Provider.of<Auth>(context, listen: true).user?.modification == '1')
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
              if(
                (Provider.of<GlobalProvider>(context, listen: true).stepIndex == 6) && (Provider.of<GlobalProvider>(context, listen: true).validCRVPIng != '1')
                  &&
                (Provider.of<Auth>(context, listen: true).user?.modification == '1' && Provider.of<Auth>(context, listen: true).user?.insertion == '1')
                      &&
                Provider.of<GlobalProvider>(context, listen: true).personnesTierces.isNotEmpty
              )
                Container(
                  margin: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(Provider.of<GlobalProvider>(context, listen: true).visiteExistes)
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
                                Provider.of<GlobalProvider>(context, listen: false).validateForm();
                                Provider.of<GlobalProvider>(context, listen: false).setValidCRVPIng = '1';
                                _showSnackBar(context, 'Validation', 'Le formulaire à été validé !');
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
                            onTap: () async {
                              Provider.of<GlobalProvider>(context, listen: false).submitForm();
                              await Provider.of<GlobalProvider>(context, listen: false).setVisiteExistes();
                              _showSnackBar(context, 'Enregistrement', 'Le formulaire à été enregistré !');
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
                    ],
                  ),
                )
            ],
          )
        : (['Consultation', 'Rédacteur'].contains(Provider.of<Auth>(context, listen: true).user?.role))
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 30.0,
                ),
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
                    Lottie.asset(
                      'assets/animations/opps-animation.json',
                      width: size.width * 1/2,
                      height: size.width * 1/2,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      "Vous devez sélectionner un(e) Affaire/Site pour continuer !",
                        style: TextStyle(
                            color: Color.fromRGBO(204, 25, 131, 1.0),
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0
                        ),
                    ),
                  ],
                )
              ),
            ]
          )
          :  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 30.0,
                    ),
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
                        Lottie.asset(
                          'assets/animations/forbidden-animation.json',
                          width: size.width * 1/2,
                          height: size.width * 1/2,
                        ),
                        Text(
                          "Vous n'avez pas assez de privilèges pour consulter cette visite !",
                          style: TextStyle(
                              color: Color.fromRGBO(204, 25, 131, 1.0),
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0
                          ),
                        ),
                      ],
                    )
                ),
              ]
           )
    );
  }

  void _showSnackBar(BuildContext context, String title, String msg) {
    final materialBanner = MaterialBanner(
      elevation: 10000,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: msg,
        contentType: ContentType.success,
        inMaterialBanner: true,
        color: Colors.green,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    Future.delayed(Duration(milliseconds: 3000), () {
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner();
    });

  }

  bool canGoToNextStep(stepIndex) {
    if(Provider.of<GlobalProvider>(context, listen: true).visiteExistes)
      return true;
    
    switch(stepIndex){
      case 0:
        if(
          Provider.of<GlobalProvider>(context, listen: true).terrainAccessibleController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainAccessibleInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainClotureController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainClotureInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainNuController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainNuInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceVegetationController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceVegetationInputController.text == ''
        )
          return false;
        break;
      case 1:
        if(
          Provider.of<GlobalProvider>(context, listen: true).presencePylonesController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presencePylonesInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).existenceMitoyenneteHabitationController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).existenceMitoyenneteHabitationInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).existenceVoirieMitoyenneteController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).existenceVoirieMitoyenneteInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceRemblaisController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceRemblaisInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceSourcesEauCaviteController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceSourcesEauCaviteInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceTalwegsController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).presenceTalwegsInputController.text == ''
        )
          return false;
        break;
      case 2:
        if(
          Provider.of<GlobalProvider>(context, listen: true).terrainInondableController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainInondableInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainPenteController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrainPenteInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).risqueInstabiliteController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).risqueInstabiliteInputController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrassementsEntamesController.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).terrassementsEntamesInputController.text == ''
        )
          return false;
        break;
      case 3:
        if(
          Provider.of<GlobalProvider>(context, listen: true).observationsComplementairesInputController.text == ''
        )
          return false;
        break;
      case 4:
        if(
          Provider.of<GlobalProvider>(context, listen: true).conclusion_1Controller.text == '' ||
          Provider.of<GlobalProvider>(context, listen: true).conclusion_2Controller.text == ''
        )
          return false;
        break;
      case 5:
        if(
          Provider.of<GlobalProvider>(context, listen: true).siteImage == null ||
          Provider.of<GlobalProvider>(context, listen: true).siteImage == ''
        )
          return false;
        break;
    }

    return true;
  }
}
