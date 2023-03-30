import 'package:flutter/material.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.blue,
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
