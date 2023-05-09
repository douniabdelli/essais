import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/widgets/time_line.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> with SingleTickerProviderStateMixin {
  final storage = new FlutterSecureStorage();
  late bool syncing = false;
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
    syncing = false;
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
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.blue.withOpacity(0.1),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: syncing
                  ? Lottie.asset(
                    'assets/animations/sync-data-animation.json',
                    width: size.width,
                  )
                  : Lottie.asset(
                    'assets/animations/completed-sync-animation.json',
                    width: size.width,
                    repeat: false,
                  ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Synchronisation',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      SizedBox.fromSize(
                        size: Size(32, 32),
                        child: ClipOval(
                          child: Material(
                            color: Colors.blueAccent.withOpacity(0.2),
                            child: InkWell(
                              splashColor: Colors.blueAccent.withOpacity(0.4),
                              onTap: () async {
                                // todo:
                                setState(() => syncing = true);
                                //setState(() => syncing = !syncing);
                                String? matricule = await storage.read(key: 'matricule');
                                String? password = await storage.read(key: 'password');
                                await Provider.of<Auth>(context, listen: false).getApiToken({'matricule': matricule, 'password': password});
                                // todo: sync all data (users, affaires, sites, visites)
                                Future.delayed(const Duration(seconds: 1), () {
                                  setState(() => syncing = false);
                                });
                              },
                              child: syncing
                                  ? AnimatedBuilder(
                                      animation: controller,
                                      builder: (context, child) => Transform.rotate(
                                        angle:  controller.value * 2.0 * (-math.pi),
                                        child: child,
                                      ),
                                      child: Icon(
                                        Icons.sync_rounded,
                                        color: Colors.blueAccent,
                                      ),
                                    )
                                  : Icon(
                                      Icons.sync_rounded,
                                      color: Colors.blueAccent,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: size.width * 2/3,
                      child: Timeline(
                        children: <Widget>[
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                          Container(height: 50, color: Colors.blueAccent.withOpacity(0.2)),
                        ],
                        indicators: <Widget>[
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                          Icon(Icons.history),
                        ],
                        times: <DateTime>[
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
