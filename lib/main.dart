import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/get_started.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:mgtrisque_visitepreliminaire/services/sync.dart';
import 'package:mgtrisque_visitepreliminaire/services/visiteprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (context) => Auth()),
        ChangeNotifierProvider<GlobalProvider>(create: (context) => GlobalProvider()),
        ChangeNotifierProvider<Affaires>(create: (context) => Affaires()),
       // ChangeNotifierProvider<Sync>(create: (context) => Sync()),


      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeAuthData();
  }

  Future<void> _initializeAuthData() async {
    final token = await storage.read(key: 'token');
    final auth = Provider.of<Auth>(context, listen: false);
    String? isLocally = await storage.read(key: 'isLocally');
    if(isLocally == 'true')
      auth.setIsLocally = true;
    else
      auth.setIsLocally = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visite Préliminaire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GetStarted(),
    );
  }
}
