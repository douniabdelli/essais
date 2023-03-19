import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/screens/get_started.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => Auth())
  ],
    child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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


