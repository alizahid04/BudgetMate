import 'package:budgetmate/Screens/name_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00C853).withOpacity(0.3),
                Color(0xFFF9F9F9).withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  "assets/images/on_boarding.png",
                  fit: BoxFit.cover,
                  height: screenHeight * 0.4,
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  "Spend Smarter",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.09,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
                Text(
                  "Save More",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.09,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.75, screenHeight * 0.08),
                    shadowColor: Color(0xFF00E676),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

