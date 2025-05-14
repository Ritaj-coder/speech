import 'package:flutter/material.dart';
import 'package:speech/main_screen.dart';

void main() {
  runApp(const Speech());
}

class Speech extends StatelessWidget {
  const Speech({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MainScreen.routename,

      routes: {
        MainScreen.routename : (context) => MainScreen()
      },
    );
  }
}
