import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/database_helper.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> with SingleTickerProviderStateMixin {
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

      if (selectedRange == 'Weekly' && now.difference(txDate).inDays > 7) return false;
      if (selectedRange == 'Monthly' && now.month != txDate.month) return false;
      if (selectedRange == 'Yearly' && now.year != txDate.year) return false;

      if (selectedType != 'All' && tx['type'] != selectedType.toLowerCase()) return false;

      return true;
    }).toList();
  }

  double get totalIncome {
    return filteredTransactions
        .where((tx) => tx['type'] == 'income')
        .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
  }

  double get totalExpense {
    return filteredTransactions
        .where((tx) => tx['type'] == 'expense')
        .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Range Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: selectedRange,
                    underline: const SizedBox(),
                    items: ['All', 'Weekly', 'Monthly', 'Yearly']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14))))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRange = value!);
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: selectedType,
                    underline: const SizedBox(),
                    items: ['All', 'Income', 'Expense']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14))))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Summary',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade800)),
                    const SizedBox(height: 40),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green.shade400,
                              value: totalIncome == 0 ? 1 : totalIncome,
                              title: totalIncome == 0 ? '' : '\$${totalIncome.toStringAsFixed(0)}',
                              titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            PieChartSectionData(
                              color: Colors.red.shade400,
                              value: totalExpense == 0 ? 1 : totalExpense,
                              title: totalExpense == 0 ? '' : '\$${totalExpense.toStringAsFixed(0)}',
                              titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLegendDot(Colors.green.shade400, 'Income'),
                        const SizedBox(width: 16),
                        _buildLegendDot(Colors.red.shade400, 'Expense'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 10),

          // --- Transaction List ---
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(child: Text("No transactions found", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])))
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                final isIncome = tx['type'] == 'income';
                final dateFormatted = DateTime.tryParse(tx['date']) ?? DateTime.now();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        title: Text(
                          tx['title'] ?? '',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text(
                          "${dateFormatted.month}/${dateFormatted.day}/${dateFormatted.year}",
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                        ),
                        trailing: Text(
                          "${isIncome ? '+' : '-'} \$${(tx['amount'] as num).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
      bottomNavigationBar: const MyAppBar(selectedIndex: 1),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
      ],
    );
  }
}
