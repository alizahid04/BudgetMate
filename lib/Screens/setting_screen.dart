import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetmate/models/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedCurrencyCode = 'USD';

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'PKR', 'symbol': '₨', 'flag': '🇵🇰'},
    {'code': 'EUR', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'INR', 'symbol': '₹', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper().getUserSettings();
    if (settings != null) {
      setState(() {
        _nameController.text = (settings['name'] as String?) ?? '';
        _selectedCurrencyCode = (settings['currency'] as String?) ?? 'USD';
      });
    }
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await DatabaseHelper().saveUserSettings(
        name,
        _selectedCurrencyCode,
        onboardingCompleted: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF00C853),
        elevation: 6,
        shadowColor: Colors.green.withOpacity(0.4),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        children: [
          _buildSectionTitle('User Profile'),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle('Currency'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrencyCode,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                items: _currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['code'],
                    child: Row(
                      children: [
                        Text(
                          currency['flag'] ?? '',
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${currency['code']} — ${currency['symbol']}',
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
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              shadowColor: Colors.green.withOpacity(0.4),
            ),
            child: Text(
              'Save Settings',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 44),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 32),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF00C853), size: 28),
            ),
            title: Text(
              'About',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              'BudgetMate v1.0\nDeveloper: Muhammad Ali',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              // Optional: Show about dialog or navigate to another page
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: MyAppBar(selectedIndex: 3),
    );
  }
}
