import 'package:flutter/material.dart';
import 'package:geo_ref/app/pages/login/login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacementNamed(
        LoginPage.routeName,
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xff05820A),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
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
            Text('Powered'),
            const SizedBox(height: 5),
            const Text.rich(
              TextSpan(
                text: 'Via Brasil\nUFMT - VG\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
