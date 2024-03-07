// Storing data
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  Future<void> saveData(key , value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

// Retrieving data
  Future<String?> loadData(key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

// Checking if a key exists
  Future<bool> keyExists(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

// Removing data
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

// Clearing all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


