import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> with SingleTickerProviderStateMixin {
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
                              onTap: () {
                                // todo:
                                // setState(() => syncing = true);
                                setState(() => syncing = !syncing);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
