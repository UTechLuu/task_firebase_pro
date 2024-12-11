import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';

class SharedPrefs {
  static const String checkAccess = 'checkAccess';
  static const String userKey = 'user';

  static late SharedPreferences _prefs;

  static Future<void> initialise() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isAccessed => _prefs.getBool(checkAccess) ?? false;
  //get lấy về 
  //set để nó hiển thị lên UI

  static set isAccessed(bool value) => _prefs.setBool(checkAccess, value);

  static bool get isLogin {
    String? data = _prefs.getString(userKey);
    if (data == null) return false;
    return true;
  }

  static UserModel? get user {
    String? data = _prefs.getString(userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static set user(UserModel? user) {
    _prefs.setString(userKey, jsonEncode(user?.toJson()));
  }

  static removeSeason() {
    _prefs.remove(userKey);
  }
}
