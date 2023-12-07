import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;

  const CustomDialogBox({Key? key, required this.title, required this.descriptions, required this.text,}) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> with SingleTickerProviderStateMixin {
  final storage = new FlutterSecureStorage();
  late double _padding = 20;
  late double _avatarRadius = 45;
  late bool forceSyncing = false;
  late AnimationController controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..forward()
    ..addListener(() {
      if (controller.isCompleted) {
        controller.repeat();
      }
    });

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: _padding,
              top: _avatarRadius + _padding,
              right: _padding,
              bottom: _padding
          ),
          margin: EdgeInsets.only(top: _avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(_padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(fontSize: 30,fontWeight: FontWeight.w600, color: Colors.red),
              ),
              SizedBox(height: 15,),
              Text(
                widget.descriptions,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 22,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () async {
                        setState(() => forceSyncing = true);
                        await Provider.of<Sync>(context, listen: false).setCanSync(false);
                        await Provider.of<Sync>(context, listen: false).syncData();
                        String? token = await storage.read(key: 'token');
                        await Provider.of<Affaires>(context, listen: false).getData(token: token!);
                        await Provider.of<Sync>(context, listen: false).setSyncing(false);
                        await Provider.of<Sync>(context, listen: false).setCanSync(true);
                        setState(() => forceSyncing = false);
                        Navigator.of(context).pop();
                      },
                      child: forceSyncing 
                          ? AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) =>
                                Transform.rotate(
                                  angle: controller.value * 2.0 *
                                      (-math.pi),
                                  child: child,
                                ),
                            child: Icon(
                              Icons.sync_rounded,
                              color: Colors.blueAccent,
                            ),
                          )
                          : Text(
                            'Synchroniser quand même',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () async {
                        await Provider.of<Sync>(context, listen: false).setSyncing(false);
                        await Provider.of<Sync>(context, listen: false).setCanSync(true);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white
                        ),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: _padding,
          right: _padding,
          child: Lottie.asset(
              'assets/animations/alert-animation.json',
              width: 120,
              height: 120
          ),
        ),
      ],
    );
  }
}