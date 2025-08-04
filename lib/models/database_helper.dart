import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budgetmate.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        type TEXT,
        category TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        name TEXT,
        currency TEXT,
        onboarding_completed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        targetAmount REAL,
        savedAmount REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE user_balance(
        id INTEGER PRIMARY KEY,
        balance REAL
      )
    ''');

    // Insert initial balance row with 0 balance
    await db.insert('user_balance', {'id': 1, 'balance': 0});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE user_settings ADD COLUMN onboarding_completed INTEGER DEFAULT 0',
      );
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          targetAmount REAL,
          savedAmount REAL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_balance(
          id INTEGER PRIMARY KEY,
          balance REAL
        )
      ''');

      // Insert initial balance row if not exists
      final count = Sqflite
          .firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_balance'));
      if (count == 0) {
        await db.insert('user_balance', {'id': 1, 'balance': 0});
      }
    }
  }

  // --- Transactions ---

  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  // --- User Settings ---

  Future<void> saveUserSettings(String name, String currency,
      {bool onboardingCompleted = false}) async {
    final db = await database;
    final existing =
    await db.query('user_settings', where: 'id = ?', whereArgs: [1]);

    final data = {
      'name': name,
      'currency': currency,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
    };

    if (existing.isEmpty) {
      await db.insert('user_settings', {'id': 1, ...data});
    } else {
      await db.update('user_settings', data, where: 'id = ?', whereArgs: [1]);
    }
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<bool> isOnboardingCompleted() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return (result.first['onboarding_completed'] ?? 0) == 1;
    }
    return false;
  }

  // --- Goals ---

  Future<int> insertGoal(Map<String, dynamic> goalData) async {
    final db = await database;
    return await db.insert('goals', goalData);
  }

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    return await db.query('goals');
  }

  Future<int> updateGoalSavedAmount(int id, double newSavedAmount) async {
    final db = await database;
    return await db.update('goals', {'savedAmount': newSavedAmount},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // --- User Balance ---

  Future<double> getBalance() async {
    final db = await database;
    final result = await db.query('user_balance', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first['balance'] as double;
    }
    return 0.0;
  }

  Future<int> updateBalance(double newBalance) async {
    final db = await database;
    return await db.update('user_balance', {'balance': newBalance},
        where: 'id = ?', whereArgs: [1]);
  }
}
