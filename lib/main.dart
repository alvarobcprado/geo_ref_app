import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_ref/pages/home/home_page.dart';
import 'package:geo_ref/pages/login/login_page.dart';

import 'pages/splash/splash_page.dart';

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
        home: const SplashPage(),
        //initialRoute: HomePage.routeName,
        routes: {
          LoginPage.routeName: (ctx) => const LoginPage(),
          HomePage.routeName: (ctx) => const HomePage(),
        },
      );
}
