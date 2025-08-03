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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating tables...');
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
        currency TEXT
      )
    ''');
    print('Tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from $oldVersion to $newVersion');
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE user_settings(
          id INTEGER PRIMARY KEY,
          name TEXT,
          currency TEXT
        )
      ''');
      print('user_settings table created in upgrade');
    }
  }

  // TRANSACTIONS METHODS

  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(int id, Map<String, dynamic> newData) async {
    final db = await database;
    return await db.update('transactions', newData, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByType(String type) async {
    final db = await database;
    return await db.query('transactions', where: 'type = ?', whereArgs: [type]);
  }

  // USER SETTINGS METHODS

  Future<void> saveUserSettings(String name, String currency) async {
    final db = await database;
    try {
      final existing = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
      if (existing.isEmpty) {
        await db.insert('user_settings', {'id': 1, 'name': name, 'currency': currency});
        print('Inserted new user_settings: $name, $currency');
      } else {
        await db.update('user_settings', {'name': name, 'currency': currency}, where: 'id = ?', whereArgs: [1]);
        print('Updated existing user_settings: $name, $currency');
      }
    } catch (e) {
      print('Error in saveUserSettings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      print('Fetched user settings: ${result.first}');
      return result.first;
    }
    print('No user settings found');
    return null;
  }
}
