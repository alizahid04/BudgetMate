import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetmate/models/database_helper.dart';
class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'PKR', 'symbol': '₨', 'flag': '🇵🇰'},
    {'code': 'EUR', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'INR', 'symbol': '₹', 'flag': '🇮🇳'},
  ];

  String _selectedCurrencyCode = 'USD';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your name."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await DatabaseHelper().saveUserSettings(name, _selectedCurrencyCode);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show error if saving fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save data: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Welcome!",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Tell us your name and preferred currency to personalize your experience.",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 30),

                    // Name TextField with floating label style
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: "Your Name",
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Color(0xFFF5F7FA),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFF00C853), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Currency label
                    Text(
                      "Select Currency",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Currency Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrencyCode,
                          isExpanded: true,
                          icon:
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                          items: _currencies.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency['code'],
                              child: Row(
                                children: [
                                  Text(
                                    currency['flag'] ?? '',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "${currency['code']} — ${currency['symbol']}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrencyCode = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: null,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00E676)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(minHeight: 56),
                            child: Text(
                              "Continue",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
