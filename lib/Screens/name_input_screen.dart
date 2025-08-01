import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameInputScreen extends StatelessWidget {
  const NameInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final TextEditingController _nameController = TextEditingController();

    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with smooth animation
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "What's your name?",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // Subtitle for better context
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 700),
                child: Text(
                  "We'll use this to personalize your experience",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Enhanced TextField with focus effects
              Focus(
                onFocusChange: (hasFocus) {
                  // Handle focus changes if needed
                },
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF00C853),
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.025,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.06),

              // Elevated button with hover and press effects
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        String enteredName = _nameController.text.trim();
                        if (enteredName.isEmpty) {
                          // Add subtle shake animation for empty input
                          // You can use packages like flutter_animate for this
                          return;
                        }
                        print("User name: $enteredName");
                        // Navigate or store name here
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
                        "Continue",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
