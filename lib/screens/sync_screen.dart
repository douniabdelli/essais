import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mgtrisque_visitepreliminaire/models/sync_history.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';
import 'package:mgtrisque_visitepreliminaire/widgets/custom_dialog.dart';
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
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.blue.withOpacity(0.1),
        child: Column(
          children: [
            Expanded(
              child: Consumer<Sync>(
                builder: (context, sync, Widget? child){
                  return sync.syncing
                      ? Lottie.asset(
                        'assets/animations/sync-data-animation.json',
                        width: size.width,
                      )
                      : Lottie.asset(
                        'assets/animations/completed-sync-animation.json',
                        width: size.width,
                        repeat: false,
                      );
                }),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Historique de synchronisation',
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
                                await Provider.of<Sync>(context, listen: false).setSyncing(true);
                                String? matricule = await storage.read(key: 'matricule');
                                String? password = await storage.read(key: 'password');
                                await Provider.of<Auth>(context, listen: false).getApiToken({'matricule': matricule, 'password': password});

                                late List invalidVisites = [];
                                invalidVisites = await Provider.of<Sync>(context, listen: false).getInvalidVisites(matricule);

                                if(invalidVisites.length > 0) await Provider.of<Sync>(context, listen: false).setCanSync(false);

                                if(await Provider.of<Sync>(context, listen: false).canSync){
                                  // sync all data (users, affaires, sites, visites)
                                  await Provider.of<Sync>(context, listen: false).syncData();
                                  // refresh data
                                  String? token = await storage.read(key: 'token');
                                  await Provider.of<Affaires>(context, listen: false).getData(token: token!);

                                  await Provider.of<Sync>(context, listen: false).setSyncing(false);
                                  await Provider.of<Sync>(context, listen: false).setCanSync(true);
                                }
                                else
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogBox(
                                          title: 'Avertissement',
                                          descriptions:
                                          'Les visites préléminaires des affaires/sites suivantes ne sont pas encore validées : \n' +
                                              invalidVisites
                                                  .map((e) => '\t▪  ' + e)
                                                  .join('\n') +
                                              '\nÊtes-vous sûr de vouloir synchroniser ceux qui sont valides seulement ?',
                                          text: 'text',
                                        );
                                      });
                              },
                              child: Consumer<Sync>(
                                builder: (context, sync, Widget? child) {
                                  return sync.syncing
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
                                      : Icon(
                                        Icons.sync_rounded,
                                        color: Colors.blueAccent,
                                      );
                                }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  Expanded(
                    child: Consumer<Sync>(
                      builder: (context, sync, Widget? child){
                        return SingleChildScrollView(
                          child: Container(
                            width: size.width * 2/3,
                            child: Timeline(
                              children: sync.getSyncHistoryData().map<Widget>(
                                    (e) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if(e['Affaires'] != null)
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.red.withOpacity(0.25),
                                                  child: Icon(
                                                    Icons.trending_down_rounded,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.0,),
                                              Expanded(
                                                child: RichText(
                                                  overflow: TextOverflow.clip,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Affaires : ',
                                                        style: TextStyle(
                                                          color: Colors.blueAccent,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15.0
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '${e['Affaires'] != null ? e['Affaires'].join(' - ') : '' }',
                                                        style: TextStyle(
                                                            color: Colors.black
                                                        ),
                                                      ),
                                                    ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if((e['Sites'] != null) && (e['Affaires'] != null))
                                          SizedBox(height: 5.0,),
                                        if(e['Sites'] != null)
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.red.withOpacity(0.25),
                                                  child: Icon(
                                                    Icons.trending_down_rounded,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.0,),
                                              Expanded(
                                                child: RichText(
                                                  overflow: TextOverflow.clip,
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Sites : ',
                                                          style: TextStyle(
                                                            color: Colors.blueAccent,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 15.0
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '${e['Sites'] != null ? e['Sites'].join(' - ') : '' }',
                                                          style: TextStyle(
                                                              color: Colors.black
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if((e['Visites'] != null) && ((e['Affaires'] != null) || e['Sites'] != null))
                                          SizedBox(height: 5.0,),
                                        if(e['Visites'] != null)
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.green.withOpacity(0.25),
                                                  child: Icon(
                                                    Icons.trending_up_rounded,
                                                    color: Colors.green,
                                                    size: 25.0,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 10.0,),
                                              Expanded(
                                                child: RichText(
                                                  overflow: TextOverflow.clip,
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Visites : ',
                                                          style: TextStyle(
                                                            color: Colors.blueAccent,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 15.0
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '${e['Visites'] != null ? e['Visites'].join(' - ') : '' }',
                                                          style: TextStyle(
                                                              color: Colors.black
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                              ).toList(),
                              indicators: sync.syncHistory
                                  .map<Widget>(
                                      (e) => Icon(Icons.history)
                                  )
                                  .toList(),
                              times: sync.getSyncHistoryDateTime().map<DateTime>((e) => e).toList(),
                            ),
                          ),
                        );
                      },
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
