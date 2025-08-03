import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const _keyName = 'user_name';
  static const _keyCurrency = 'user_currency';

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  static Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currencyCode);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency);
  }
}
