import 'package:glide_chat/cache/sqlite_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class BufferedSessionCache implements SessionListCache {
  static final _memoryCache = SessionListMemoryCache();
  late SessionListCache _memory;
  final tag = "SessionCache";

  BufferedSessionCache();

  @override
  Future init(String uid) async {
    await SQLiteCache.instance.init();
    _memory = SQLiteCache.instance.sessionCache;
    await _memory.init(uid);
  }

  @override
  Future<void> addSession(GlideSessionInfo session) async {
    await _memory.addSession(session);
  }

  @override
  Future clear() async {
    await _memory.clear();
  }

  @override
  Future<List<GlideSessionInfo>> getSessions() async {
    return await _memory.getSessions();
  }

  @override
  Future<void> removeSession(String id) async {
    await _memory.removeSession(id);
  }

  @override
  Future<void> setSessions(List<GlideSessionInfo> sessions) async {
    await _memory.setSessions(sessions);
  }

  @override
  Future<void> updateSession(GlideSessionInfo session) async {
    await _memory.updateSession(session);
  }
}

class BufferedMessageCache implements GlideMessageCache {
  late GlideMessageCache cache;

  @override
  Future init(String uid) async {
    await SQLiteCache.instance.init();
    cache = SQLiteCache.instance.messageCache;
    await cache.init(uid);
  }

  @override
  Future<void> addMessage(String sessionId, Message message) {
    return cache.addMessage(sessionId, message);
  }

  @override
  Future clear() {
    return cache.clear();
  }

  @override
  Future<Message?> getMessage(num mid) {
    return cache.getMessage(mid);
  }

  @override
  Future<List<Message>> getMessages(String sessionId) {
    return cache.getMessages(sessionId);
  }

  @override
  Future<bool> hasMessage(num mid) {
    return cache.hasMessage(mid);
  }

  @override
  Future<void> removeMessage(num id) {
    return cache.removeMessage(id);
  }

  @override
  Future<void> updateMessage(Message message) {
    return cache.updateMessage(message);
  }
}
