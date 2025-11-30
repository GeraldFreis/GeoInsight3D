
import 'package:flutter/material.dart';
import './homepage.dart'; // the app viewing page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "GeoInsight3D",
        home: const HomePage(),
      );
    }
}