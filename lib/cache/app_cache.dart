import 'dart:convert';

import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/cache/cache_io.dart' if (dart.library.html) 'package:glide_chat/cache/cache_web.dart';
import 'package:glide_chat/model/chat_info.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionCache extends SessionListMemoryCache {
  Future<String?> getSetting(String id);

  Future setSetting(String id, String value);
}

class AppCache {
  SessionCache session = CacheFactory.createSessionListCache();
  GlideMessageCache message = CacheFactory.createMessageCache();
  static const tag = "AppCache";

  static final AppCache _instance = AppCache();

  static AppCache get instance => _instance;

  static Stream<String> init(String uid) async* {
    //
  }

  static Future clear() async {
    await instance.session.clear();
    await instance.message.clear();
  }
}

class ChatInfoManager {
  static final Map<String, ChatInfo> _cache = {};
  static const tag = "ChatInfoManager";

  ChatInfoManager();

  static _key(bool channel, String id) {
    return "i_${channel ? "ch" : "user"}_$id";
  }

  static Future<ChatInfo> loadOrUnknown(bool channel, String id) async {
    try {
      return await load(channel, id);
    } catch (e) {
      return ChatInfo(id: id, name: id, avatar: "", lastSee: 0);
    }
  }

  static Future<ChatInfo> load(bool channel, String id) async {
    // logd(tag, "load=>channel:$channel, id:$id");
    if (id.isEmpty || id == "system") {
      return ChatInfo(id: id, name: id, avatar: "", lastSee: 0);
    }

    final key = _key(channel, id);
    ChatInfo? c = _cache[key];
    if (c != null) {
      return c;
    }
    if (channel) {
      return ChatInfo(id: id, name: id, avatar: "", lastSee: 0);
    } else {
      if (id == "system") {
        c = ChatInfo(id: id, name: "system", avatar: "", lastSee: 0);
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(key);
      if (json != null) {
        c = ChatInfo.fromMap(jsonDecode(json));
      } else {
        final us = await glide.api.user.getUserInfo([int.parse(id)]);
        if (us.isEmpty) {
          c = ChatInfo(id: id, name: id, avatar: "", lastSee: 0);
        } else {
          final ui = us.first;
          c = ChatInfo(id: id, name: ui.nickName, avatar: ui.avatar, lastSee: 0);
        }
      }
      _cache[key] = c;
      await prefs.setString(key, jsonEncode(c.toMap()));
      return c;
    }
  }

  static ChatInfo? get(bool channel, String id) {
    final key = _key(channel, id);
    return _cache[key];
  }

  static Future clear() async {
    _cache.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys().forEach((element) {
      if (element.startsWith("i_")) {
        prefs.remove(element);
      }
    });
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

  static Future clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("uid");
    prefs.remove("name");
  }
}
