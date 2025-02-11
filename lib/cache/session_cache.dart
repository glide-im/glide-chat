import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/cache/sqlite_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

abstract class SessionSettingCache {
  Future<String?> getSetting(String id);

  Future setSetting(String id, String value);
}

class BufferedSessionCache implements SessionCache {
  static final _memoryCache = SessionListMemoryCache();
  SessionListCache? _memory;
  final tag = "SessionCache";

  BufferedSessionCache();

  @override
  Future init(String uid) async {
    await SQLiteCache.instance.init(uid);
    _memory = SQLiteCache.instance.sessionCache;
    await _memory?.init(uid);
  }

  @override
  Future<void> addSession(GlideSessionInfo session) async {
    await _memory?.addSession(session);
  }

  @override
  Future clear() async {
    await _memory?.clear();
  }

  @override
  Future<List<GlideSessionInfo>> getSessions() async {
    return await _memory!.getSessions();
  }

  @override
  Future<void> removeSession(String id) async {
    await _memory!.removeSession(id);
  }

  @override
  Future<void> setSessions(List<GlideSessionInfo> sessions) async {
    await _memory!.setSessions(sessions);
  }

  @override
  Future<void> updateSession(GlideSessionInfo session) async {
    await _memory!.updateSession(session);
  }

  @override
  Future<String?> getSetting(String id) async {
    final r = await SQLiteCache.instance.sessionSettingCache.getSessionSetting(id);
    return r.isEmpty ? null : r;
  }

  @override
  Future setSetting(String id, String value) async {
    await SQLiteCache.instance.sessionSettingCache.updateSessionSetting(id, value);
  }
}

class BufferedMessageCache implements GlideMessageCache {
  GlideMessageCache? cache;

  @override
  Future init(String uid) async {
    await SQLiteCache.instance.init(uid);
    cache = SQLiteCache.instance.messageCache;
    await cache?.init(uid);
  }

  @override
  Future<void> addMessage(String sessionId, Message message) async {
    await cache?.addMessage(sessionId, message);
  }

  @override
  Future clear() async {
    await cache?.clear();
  }

  @override
  Future<Message?> getMessage(num mid) {
    return cache!.getMessage(mid);
  }

  @override
  Future<List<Message>> getMessages(String sessionId) {
    return cache!.getMessages(sessionId);
  }

  @override
  Future<bool> hasMessage(num mid) {
    return cache!.hasMessage(mid);
  }

  @override
  Future<void> removeMessage(num id) async {
    await cache?.removeMessage(id);
  }

  @override
  Future<void> updateMessage(Message message) async {
    cache?.updateMessage(message);
  }
}
