import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Lottie.asset(
        'assets/success_animation.json',
        fit: BoxFit.cover,
      ),
    );
  }
}
