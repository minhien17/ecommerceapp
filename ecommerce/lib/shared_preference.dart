import 'package:shared_preferences/shared_preferences.dart';

class SPrefCache {
  static const KEY_USERID = 'USERID';
  static const KEY_USERNAME = 'USERNAME';
  static const KEY_EMAIL = 'EMAIL';
  static const KEY_IMAGE = 'USER_IMAGE';
}

class SharedPreferenceUtil {
  // save

  static Future saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.KEY_USERID, token);
  }

  static Future saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.KEY_USERNAME, username);
  }

  static Future saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.KEY_EMAIL, email);
  }

  static Future saveImage(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.KEY_IMAGE, imageUrl);
  }

  // get

  static Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.KEY_USERNAME) ?? '';
  }

  static Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.KEY_EMAIL) ?? '';
  }

  static Future<String> getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.KEY_IMAGE) ?? '';
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.KEY_USERID) ?? '';
  }

  // clear
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SPrefCache.KEY_USERID);
  }
}
