import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class _SessionListCache2 extends SessionCache {
  final _settings = <String, String>{};

  @override
  Future<String?> getSetting(String id) async {
    return _settings[id];
  }

  @override
  Future setSetting(String id, String value) async {
    _settings[id] = value;
  }
}

class CacheFactory {
  static SessionCache createSessionListCache() {
    return _SessionListCache2();
  }

  static GlideMessageCache createMessageCache() {
    return GlideMessageMemoryCache();
  }
}
