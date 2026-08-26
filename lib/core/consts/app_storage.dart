import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLoggedIn(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool('isLoggedIn', value);
  }

  static bool isLoggedIn() {
    _ensureInitialized();
    return _prefs!.getBool('isLoggedIn') ?? false;
  }

  static Future<void> clearLoggedIn() async {
    _ensureInitialized();
    await _prefs!.remove('isLoggedIn');
  }

  static void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception("AppStorage not initialized. Call AppStorage.init() first.");
    }
  }
}
