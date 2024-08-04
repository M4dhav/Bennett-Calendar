import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bennett_cal/home.dart';

void main() {
  runApp(const MyApp(
    title: 'Bennett Calculater',
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // Your theme settings
          ),
      home: HomePage(),
    );
  }
}
