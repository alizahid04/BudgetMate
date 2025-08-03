import 'package:budgetmate/Screens/home_screen.dart';
import 'package:budgetmate/Screens/name_input_screen.dart';
import 'package:flutter/material.dart';
import 'Screens/history_screen.dart';
import 'Screens/start_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) =>  NameInputScreen(),
        '/home': (context) => HomePage(),
        // '/name': (context) => const NameInputScreen(),
         '/history': (context) =>  AllTransactionsPage(),
        // '/goals': (context) =>  GoalsPage(),

      },
    );
  }
}
