import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pages/splash/splash_page.dart';

void main(List<String> args) {
  runApp(const GeoRefApp());
}

class GeoRefApp extends StatelessWidget {
  const GeoRefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Geo Ref',
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
        routes: {},
      );
}
