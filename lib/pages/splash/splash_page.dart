import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2));
    return Scaffold(
      backgroundColor: const Color(0xff05820A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.green.shade900,
            ),
          ],
        ),
      ),
    );
  }
}
