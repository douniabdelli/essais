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
  String? _token = await storage.read(key: 'token');

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
                  ? const MyApp(isLoggedIn: 'isLoggedIn', isNotFirstTime: 'isNotFirstTime',)
                  : const MyApp(isLoggedIn: 'isLoggedIn', isNotFirstTime: '',)
            )
          : (
              (_isNotFirstTime != null)
                  ? const MyApp(isLoggedIn: '', isNotFirstTime: 'isNotFirstTime',)
                  : const MyApp(isLoggedIn: '', isNotFirstTime: '',)
            ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String isLoggedIn;
  final String isNotFirstTime;
  const MyApp({
    required this.isLoggedIn,
    required this.isNotFirstTime,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visite Préliminaire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: (widget.isLoggedIn == 'isLoggedIn')
          ? (
              (widget.isNotFirstTime == 'isNotFirstTime')
                  ? HomeScreen(isNotFirstTime: 'isNotFirstTime')
                  : HomeScreen(isNotFirstTime: '')
            )
          : (
              (widget.isNotFirstTime == 'isNotFirstTime')
                  ? LoginScreen(isNotFirstTime: 'isNotFirstTime')
                  : GetStarted(isNotFirstTime: '')
          ),
    );
  }
}
