import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class SessionCache implements SessionListCache {
  // static final _memoryCache = SessionListMemoryCache();
  final SessionListCache _memory;

  SessionCache({required SessionListCache cache}) : _memory = cache;

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
