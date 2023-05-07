import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:provider/provider.dart';

class GetStarted extends StatefulWidget {
  GetStarted({
    Key? key,
  }) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final storage = new FlutterSecureStorage();
  final Auth _auth = Auth();
  late bool isReady = false;
  String? isLoggedIn;
  String? isNotFirstTime;

  void loadData() async {
    await _auth.checkLoggedUser();
    isLoggedIn = await storage.read(key: 'isLoggedIn');
    isNotFirstTime = await storage.read(key: 'isNotFirstTime');
    final String? token = await storage.read(key: 'token');

    if(token != null && token != '')
      await Provider.of<Affaires>(context, listen: false).getAffaires(token: token);
      // final String? matricule = await storage.read(key: 'matricule');
      // final String? password = await storage.read(key: 'password');
      // if(matricule != null && password != null)
      //   String? token = await Provider.of<Auth>(context, listen: false).login(credentials: {'matricule': matricule, 'password': password});

    Future.delayed(new Duration(milliseconds: 2500), () {
      if(isLoggedIn == 'loggedIn')
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(isNotFirstTime: isNotFirstTime ?? ''),
            )
        );
      else
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(isNotFirstTime: isNotFirstTime ?? ''
              ),
            )
        );
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffe4e9f9),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   'assets/images/visite_preliminaire.png',
                    //   scale: 1.2,
                    // ),
                    Lottie.asset(
                      'assets/animations/area-map-animation.json',
                      width: 100.0,
                      height: 100.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'Visite Préliminaire',
                        style: TextStyle(
                          fontFamily: 'Malgun Gothic',
                          fontSize: 25,
                          color: const Color(0xff707070),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    width: MediaQuery.of(context).size.width * 9 / 10,
                    height: MediaQuery.of(context).size.width * 9 / 10,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/engineers.png'),
                        fit: BoxFit.fill,
                        colorFilter: new ColorFilter.mode(
                          Colors.black,
                          BlendMode.dstIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      margin: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage(
                            'assets/images/mgt_logo.png',
                          ),
                          fit: BoxFit.scaleDown,
                          scale: 1.8
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
