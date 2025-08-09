import 'package:budgetmate/Screens/shared_widgets/bottom_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/database_helper.dart';

class Goal {
  final int id;
  final String title;
  final double targetAmount;
  double savedAmount;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Goal> goals = [];
  double userBalance = 0.0;
  String currencySymbol = '₹'; // fallback default
  bool isLoading = true;

  static const Color _primaryGreen = Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final userSettings = await dbHelper.getUserSettings();
    if (userSettings != null && userSettings['currency'] != null) {
      currencySymbol = userSettings['currency'];
    }

    final goalMaps = await dbHelper.getAllGoals();
    final currentBalance = await _calculateCurrentBalance();

    setState(() {
      goals = goalMaps
          .map((g) => Goal(
        id: g['id'] as int,
        title: g['title'] as String,
        targetAmount: g['targetAmount'] as double,
        savedAmount: g['savedAmount'] as double,
      ))
          .toList()
        ..sort((a, b) => b.id.compareTo(a.id));

      userBalance = currentBalance;
      isLoading = false;
    });
  }

  Future<double> _calculateCurrentBalance() async {
    final txns = await dbHelper.getAllTransactions();
    double balance = 0.0;
    for (var tx in txns) {
      final amount = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'income') {
        balance += amount;
      } else if (tx['type'] == 'expense') {
        balance -= amount;
      }
    }
    return balance;
  }

  void _addGoal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create New Goal',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.flag_outlined, color: _primaryGreen),
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primaryGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money, color: _primaryGreen),
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primaryGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _primaryGreen.withOpacity(0.4),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final target = double.tryParse(targetController.text);
                  if (title.isNotEmpty && target != null && target > 0) {
                    await dbHelper.insertGoal({
                      'title': title,
                      'targetAmount': target,
                      'savedAmount': 0.0,
                    });
                    Navigator.pop(context);
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid title and amount'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _addMoneyToGoal(Goal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Money to "${goal.title}"', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Enter amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                if (amount > userBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient balance!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                if (goal.savedAmount + amount > goal.targetAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cannot add more than target amount ($currencySymbol${goal.targetAmount.toStringAsFixed(0)})',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                await dbHelper.insertTransaction({
                  'title': 'Goal: ${goal.title}',
                  'amount': amount,
                  'type': 'expense',
                  'category': 'Goal',
                  'date': DateTime.now().toIso8601String(),
                });
                final newSavedAmount = goal.savedAmount + amount;
                await dbHelper.updateGoalSavedAmount(goal.id, newSavedAmount);
                await _loadData();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    double progress = (goal.savedAmount / goal.targetAmount).clamp(0, 1).toDouble();
    final isComplete = progress >= 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: _primaryGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(goal.title,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              if (isComplete)
                const Icon(Icons.check_circle, color: _primaryGreen, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target: $currencySymbol${goal.targetAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
              Text('Saved: $currencySymbol${goal.savedAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
               value: progress,
              minHeight: 12,
              color: _primaryGreen,
              backgroundColor: Colors.green.shade100,
            ),
          ),
          const SizedBox(height: 16),
          if (!isComplete)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _addMoneyToGoal(goal),
                icon: const Icon(Icons.add),
                label: const Text('Add Money'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                  shadowColor: _primaryGreen.withOpacity(0.6),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
        backgroundColor: _primaryGreen,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : Column(
        children: [
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: _primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Current Balance: $currencySymbol${userBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16, color: Colors.green.shade900),
                ),
              ],
            ),
          ),
          Expanded(
            child: goals.isEmpty
                ? Center(
              child: Text(
                'No goals added yet. Tap + to add one!',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) => _buildGoalCard(goals[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add New Goal',
      ),
      bottomNavigationBar: const MyAppBar(selectedIndex: 2),
    );
  }
}
