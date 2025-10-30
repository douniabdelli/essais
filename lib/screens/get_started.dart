import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';
import 'package:provider/provider.dart';

class GetStarted extends StatefulWidget {
  GetStarted({Key? key}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final storage = new FlutterSecureStorage();
  final Auth _auth = Auth();
  String? isLoggedIn;
  String? isNotFirstTime;

  void loadData() async {
    await _auth.checkLoggedUser();
    isLoggedIn = await storage.read(key: 'isLoggedIn');
    isNotFirstTime = await storage.read(key: 'isNotFirstTime');
    final String? token = await storage.read(key: 'token');

    if (token != null && token != '') {
      await Provider.of<Affaires>(context, listen: false).getData(token: token);
     // await Provider.of<Sync>(context, listen: false).getSyncHistory();
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(isNotFirstTime: isNotFirstTime ?? ''),
          ));
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f0e1), 
      body: Center(
        child: Image.asset(
          "assets/images/mgt_logo.png",
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
