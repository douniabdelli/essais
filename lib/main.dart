import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/get_started.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = new FlutterSecureStorage();
  final Auth _auth = Auth();
  await _auth.checkLoggedUser();
  String? _isLoggedIn = await storage.read(key: 'isLoggedIn');
  String? _isNotFirstTime = await storage.read(key: 'isNotFirstTime');
  final String? _token = await storage.read(key: 'token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => GlobalProvider()),
        ChangeNotifierProvider(create: (context) => Affaires()),
      ],
      child: (_isLoggedIn != null)
          ? (
          (_isNotFirstTime != null)
              ? MyApp(isLoggedIn: 'isLoggedIn', isNotFirstTime: 'isNotFirstTime', token: _token ?? '')
              : MyApp(isLoggedIn: 'isLoggedIn', isNotFirstTime: '', token: _token ?? '')
      )
          : (
          (_isNotFirstTime != null)
              ? MyApp(isLoggedIn: '', isNotFirstTime: 'isNotFirstTime', token: _token ?? '')
              : MyApp(isLoggedIn: '', isNotFirstTime: '', token: _token ?? '')
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String isLoggedIn;
  final String isNotFirstTime;
  final String token;
  const MyApp({
    required this.isLoggedIn,
    required this.isNotFirstTime,
    required this.token,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isReady = false;

  @override
  void initState(){
    loadData();
    super.initState();
  }

  void loadData() async {
    final storage = new FlutterSecureStorage();
    if(widget.token != null && widget.token != '') {
      final String? matricule = await storage.read(key: 'matricule');
      final String? password = await storage.read(key: 'password');
      if(matricule != null && password != null)
        String? token = await Provider.of<Auth>(context, listen: false).login(credentials: {'matricule': matricule, 'password': password});
      await Provider.of<Affaires>(context, listen: false).getAffaires(token: widget.token);
    }
    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visite Préliminaire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: (widget.isLoggedIn == 'isLoggedIn' && isReady)
          ? (
              (widget.isNotFirstTime == 'isNotFirstTime' && isReady)
                  ? HomeScreen(isNotFirstTime: 'isNotFirstTime')
                  : HomeScreen(isNotFirstTime: '')
            )
          : (
              (widget.isNotFirstTime == 'isNotFirstTime' && isReady)
                  ? LoginScreen(isNotFirstTime: 'isNotFirstTime')
                  : GetStarted(isNotFirstTime: '')
          ),
    );
  }
}
