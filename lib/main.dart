import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app/pages/home/home_page.dart';
import 'app/pages/login/login_page.dart';
import 'app/pages/splash/splash_page.dart';

void main(List<String> args) {
  runApp(const GeoRefApp());
}

class GeoRefApp extends StatelessWidget {
  const GeoRefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Geo Ref',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        //home: const SplashPage(),
        initialRoute: SplashPage.routeName,
        routes: {
          SplashPage.routeName: (ctx) => const SplashPage(),
          LoginPage.routeName: (ctx) => const LoginPage(),
          HomePage.routeName: (ctx) => const HomePage(),
        },
      );
}
