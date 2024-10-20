import 'package:flutter/material.dart';
import 'package:bennett_cal/home.dart';
import 'package:sizer/sizer.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const MyApp(
    title: 'Bennett Calculater',
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return OKToast(
        child: MaterialApp(
          title: 'ScheduleSyncBU',
          theme: ThemeData(
              // Your theme settings
              ),
          home: HomePage(),
        ),
      );
    });
  }
}
