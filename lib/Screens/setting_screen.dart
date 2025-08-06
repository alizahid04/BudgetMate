import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedCurrency = 'PKR';
  bool _isDarkMode = false;

  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'INR'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _selectedCurrency = prefs.getString('currency') ?? 'PKR';
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text.trim());
    await prefs.setString('currency', _selectedCurrency);
    await prefs.setBool('darkMode', _isDarkMode);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("User Profile", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),

          Text("Currency", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(labelText: 'Preferred Currency'),
            items: _currencies.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          Text("Theme & Appearance", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
            child: const Text("Save Settings"),
          ),

          const Divider(height: 32),

          ListTile(
            title: const Text("About"),
            subtitle: const Text("BudgetMate v1.0\nMade with ❤️ in Flutter."),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
      bottomNavigationBar: MyAppBar(selectedIndex: 3),
    );
  }
}
