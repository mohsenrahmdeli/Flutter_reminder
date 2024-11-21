import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static const String remindersKey = 'reminders';

  static Future<void> saveReminders(
      List<Map<String, dynamic>> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(reminders);
    await prefs.setString(remindersKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getString('reminders');
    if (reminders != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(reminders));
    }
    return [];
  }
}
