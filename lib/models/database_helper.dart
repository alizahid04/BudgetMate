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
      version: 3,
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE user_settings ADD COLUMN onboarding_completed INTEGER DEFAULT 0');
    }
  }

  // Insert a transaction record
  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('transactions', data);
  }

  // Get all transactions ordered by date descending
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  // Save or update user settings including onboarding status
  Future<void> saveUserSettings(String name, String currency, {bool onboardingCompleted = false}) async {
    final db = await database;
    final existing = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);

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

  // Retrieve user settings if present
  Future<Map<String, dynamic>?> getUserSettings() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Check if onboarding is completed by reading onboarding_completed flag
  Future<bool> isOnboardingCompleted() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return (result.first['onboarding_completed'] ?? 0) == 1;
    }
    return false;
  }
}
