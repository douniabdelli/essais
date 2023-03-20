import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/get_started.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = new FlutterSecureStorage();
  final Auth _auth = Auth();
  await _auth.checkLoggedUser();
  String? _isLoggedIn = await storage.read(key: 'isLoggedIn');
  String? _token = await storage.read(key: 'token');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Auth())],
      child: (_isLoggedIn != null)
          ? const MyApp(isLoggedIn: 'isLoggedIn',)
          : const MyApp(isLoggedIn: '',),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String isLoggedIn;
  const MyApp({
    required this.isLoggedIn,
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
      home: (widget.isLoggedIn == 'isLoggedIn') ? HomeScreen(title: 'Visite Préliminaire') : GetStarted(),
    );
  }
}
