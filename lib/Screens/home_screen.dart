import 'package:budgetmate/Screens/setting_screen.dart';
import 'package:budgetmate/models/database_helper.dart';
import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String currencySymbol = '₨';
  double currentBalance = 0;
  double totalIncome = 0;
  double totalExpense = 0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadTransactions();
  }

  Future<void> loadUserData() async {
    final settings = await DatabaseHelper().getUserSettings();
    if (settings != null) {
      setState(() {
        userName = settings['name'] ?? '';
        currencySymbol = _getCurrencySymbol(settings['currency'] ?? 'USD');
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    if (hour < 21) return "Good evening";
    return "Good night";
  }

  Future<void> loadTransactions() async {
    final txs = await DatabaseHelper().getAllTransactions();
    double income = 0;
    double expense = 0;

    for (var tx in txs) {
      final amount = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }

    setState(() {
      transactions = txs;
      totalIncome = income;
      totalExpense = expense;
      currentBalance = income - expense;
    });
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'PKR':
        return '₨';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return '';
    }
  }

  Widget transactionRow(
      String title, String date, String amount, Color amountColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: amountColor.withOpacity(0.15),
            child: Icon(icon, color: amountColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(amount,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: amountColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isEmpty ? "User" : userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
        toolbarHeight: 100,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
        ),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${_getGreeting()},",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        )),
                    Text(displayName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Balance Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Balance",
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text("$currencySymbol ${currentBalance.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Income
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Income",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("$currencySymbol ${totalIncome.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    // Expense
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Expense",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("$currencySymbol ${totalExpense.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Transactions Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transactions History",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/history');
                  },
                  child: Text("See all",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700])),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                child: Text("No transactions found",
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.only(top: 5, bottom: 10),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final amount = (tx['amount'] as num).toDouble();
                final type = tx['type'] as String;
                final color =
                type == 'income' ? Colors.green : Colors.red;
                final sign = type == 'income' ? "+" : "-";
                final icon = type == 'income'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward;

                return transactionRow(
                  tx['title'],
                  tx['date'],
                  "$sign $currencySymbol${amount.toStringAsFixed(2)}",
                  color,
                  icon,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyAppBar(selectedIndex: 0),
    );
  }
}
