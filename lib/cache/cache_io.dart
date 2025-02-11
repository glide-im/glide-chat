import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/cache/session_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class CacheFactory {
  static SessionCache createSessionListCache() {
    return BufferedSessionCache();
  }

  static GlideMessageCache createMessageCache() {
    return BufferedMessageCache();
  }
}
