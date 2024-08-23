import 'package:shared_preferences/shared_preferences.dart';

class Storage{
  static Future<void> saveApiKey(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("apiKey", key);
  }

    static Future<String?> getApiKey() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("apiKey");
  }
}