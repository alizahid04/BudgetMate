import 'package:budgetmate/Screens/home_screen.dart';
import 'package:budgetmate/Screens/name_input_screen.dart';
import 'package:flutter/material.dart';
import 'Screens/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) =>  HomePage(),
        // '/home': (context) => const HomePage(),
        // '/name': (context) => const NameInputScreen(),
      },
    );
  }
}
