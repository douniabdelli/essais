import 'package:flutter/material.dart';

class VisiteScreen extends StatelessWidget {
  const VisiteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.red,
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
