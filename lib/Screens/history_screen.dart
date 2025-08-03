import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/database_helper.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  String selectedRange = 'All';
  String selectedType = 'All';

  List<Map<String, dynamic>> allTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllTransactions();
    setState(() {
      allTransactions = data;
    });
  }

  List<Map<String, dynamic>> get filteredTransactions {
    final now = DateTime.now();

    return allTransactions.where((tx) {
      final txDate = DateTime.tryParse(tx['date'] ?? '') ?? now;

      // Filter by time range
      if (selectedRange == 'Weekly' && now.difference(txDate).inDays > 7) return false;
      if (selectedRange == 'Monthly' && now.month != txDate.month) return false;
      if (selectedRange == 'Yearly' && now.year != txDate.year) return false;

      // Filter by type
      if (selectedType != 'All' && tx['type'] != selectedType.toLowerCase()) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedRange,
                  items: ['All', 'Weekly', 'Monthly', 'Yearly']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedRange = value!);
                  },
                ),
                DropdownButton<String>(
                  value: selectedType,
                  items: ['All', 'Income', 'Expense']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(child: Text("No transactions found", style: GoogleFonts.poppins()))
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                final isIncome = tx['type'] == 'income';
                final dateFormatted = DateTime.tryParse(tx['date']) ?? DateTime.now();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        tx['title'] ?? '',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        "${dateFormatted.month}/${dateFormatted.day}/${dateFormatted.year}",
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        "${isIncome ? '+' : '-'} \$${(tx['amount'] as num).toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyAppBar(selectedIndex: 1),
    );
  }
}
