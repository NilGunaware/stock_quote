import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserService {
  static const String _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    return userData != null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
} 