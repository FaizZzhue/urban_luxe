import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const String _kCurrentUser = 'current_user';

  static String _kFullname(String u) => 'profile_fullname_$u';
  static String _kEmail(String u) => 'profile_email_$u';
  static String _kAvatar(String u) => 'profile_avatar_$u';

  static Future<void> setCurrentUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentUser, username);
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_kCurrentUser);
    if (u == null || u.isEmpty) return null;
    return u;
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUser);
  }

  static Future<void> saveSignupProfile({
    required String username,
    required String fullname,
    required String email,
  }) async {
    await updateFullname(username, fullname);
    await updateEmail(username, email);
  }

  static Future<void> updateFullname(String username, String fullname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFullname(username), fullname);
  }

  static Future<String> getFullname(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kFullname(username)) ?? '';
  }

  static Future<void> updateEmail(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail(username), email);
  }

  static Future<String> getEmail(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail(username)) ?? '';
  }

  static Future<void> saveAvatarBase64(String username, String base64) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatar(username), base64);
  }

  static Future<String> getAvatarBase64(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAvatar(username)) ?? '';
  }

  static Future<bool> renameUser({
    required String oldUsername,
    required String newUsername,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (oldUsername == newUsername) return true;

    final fn = prefs.getString(_kFullname(oldUsername)) ?? '';
    final em = prefs.getString(_kEmail(oldUsername)) ?? '';
    final av = prefs.getString(_kAvatar(oldUsername)) ?? '';

    await prefs.setString(_kFullname(newUsername), fn);
    await prefs.setString(_kEmail(newUsername), em);
    await prefs.setString(_kAvatar(newUsername), av);

    await prefs.remove(_kFullname(oldUsername));
    await prefs.remove(_kEmail(oldUsername));
    await prefs.remove(_kAvatar(oldUsername));

    final cur = prefs.getString(_kCurrentUser) ?? '';
    if (cur == oldUsername) {
      await prefs.setString(_kCurrentUser, newUsername);
    }

    return true;
  }

  static Future<void> clearProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFullname(username));
    await prefs.remove(_kEmail(username));
    await prefs.remove(_kAvatar(username));
  }
}