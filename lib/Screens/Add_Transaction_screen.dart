import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add this in pubspec.yaml

import '../models/database_helper.dart';

class AddTransactionPage extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  const AddTransactionPage({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'Income';
  String _category = 'General';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'General',
    'Food',
    'Transport',
    'Entertainment',
    'Health',
    'Salary',
    'Shopping',
    'Others',
  ];

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        _showError('Please enter a valid positive amount.');
        return;
      }

      final data = {
        'title': _titleController.text.trim(),
        'amount': amount,
        'type': _type.toLowerCase(),
        'category': _category,
        'date': _selectedDate.toIso8601String(),
      };

      await DatabaseHelper().insertTransaction(data);
      widget.onTransactionAdded();
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.green.shade600, // header background color
            onPrimary: Colors.white, // header text color
            onSurface: Colors.black87, // body text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.green.shade600),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(12));
    final inputBorder = OutlineInputBorder(borderRadius: borderRadius);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF00C853),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title),
                  border: inputBorder,
                  enabledBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 18),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: inputBorder,
                  enabledBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an amount';
                  }
                  final n = double.tryParse(value);
                  if (n == null || n <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  prefixIcon: const Icon(Icons.swap_vert),
                  border: inputBorder,
                  enabledBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                ),
                items: ['Income', 'Expense']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 18),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: inputBorder,
                  enabledBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 18),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: borderRadius,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                    ),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTransaction,
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Save Transaction',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.greenAccent.shade100,
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
