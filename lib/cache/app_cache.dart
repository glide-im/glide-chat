import 'package:glide_chat/cache/session_cache.dart';
import 'package:glide_chat/cache/sqlite_cache.dart';
import 'package:glide_chat/utils/logger.dart';

class AppCache {
  late SessionCache sessionCache;
  static const tag = "AppCache";

  static final AppCache _instance = AppCache();

  static AppCache get instance => _instance;

  static Stream<String> init() async* {
    final sqliteCache = SQLiteCache();
    try {
      await sqliteCache.init();
      instance.sessionCache = SessionCache(cache: sqliteCache.sessionCache);
      yield "$tag sqlite init done";
    } catch (e) {
      loge(tag, e);
    }

  }
}
