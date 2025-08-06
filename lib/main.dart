import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetmate/models/database_helper.dart';
import 'Screens/home_screen.dart';
import 'Screens/name_input_screen.dart';
import 'Screens/Add_Transaction_screen.dart';
import 'Screens/goals_screen.dart';
import 'Screens/history_screen.dart';
import 'Screens/setting_screen.dart';
import 'Screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
    if (!onboardingSeen) {
      return const StartScreen();
    }
    final settings = await DatabaseHelper().getUserSettings();
    final name = settings?['name'] as String?;

    if (name == null || name.isEmpty) {
      return const NameInputScreen();
    }
    return const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: snapshot.data,
          routes: {
            // '/': (context) => const StartScreen(),
            '/home': (context) => const HomePage(),
            '/name': (context) => const NameInputScreen(),
            '/history': (context) => const AllTransactionsPage(),
            '/Transaction': (context) => AddTransactionPage(
              onTransactionAdded: () {
                print('Transaction added!');
              },
            ),
            '/Goal': (context) => const GoalsPage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
