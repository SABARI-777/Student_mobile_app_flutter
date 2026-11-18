
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Create SharedPreferences instance
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // Save a string
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Read a string
  Future<String?> getString(String key) async {
    return await _prefs.getString(key);
  }

  // Save a boolean
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Read a boolean
  Future<bool?> getBool(String key) async {
    return await _prefs.getBool(key);
  }

  // Remove a particular value
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
