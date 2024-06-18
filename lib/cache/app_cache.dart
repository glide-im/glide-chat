import 'package:glide_chat/cache/session_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbCache {
  SessionListCache session = BufferedSessionCache();
  GlideMessageCache message = BufferedMessageCache();
  static const tag = "AppCache";

  static final DbCache _instance = DbCache();

  static DbCache get instance => _instance;

  static Stream<String> init(String uid) async* {
    //
  }
}

class UserCache {
  String token;
  String uid;
  String name;

  UserCache({required this.token, required this.uid, required this.name});

  static Future<UserCache> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final uid = prefs.getString("uid") ?? "";
    final name = prefs.getString("name") ?? "";
    return UserCache(token: token, uid: uid, name: name);
  }

  Future save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString("uid", uid);
    prefs.setString("name", name);
  }
}
