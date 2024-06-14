import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteCache {
  late SessionListCache sessionCache;

  Future init() async {
    final db = sqlite3.open("c.db", mode: OpenMode.readWriteCreate);
    db.execute(_SQL.createTableSession);
    final sc = _SessionListSqliteCache(db: db);
    await sc.init();
    sessionCache = sc;
  }
}

class _SessionModel {
  final String id;
  final String ticket;
  final String to;
  final String title;
  final num unread;
  final String lastMessage;
  final num createAt;
  final num updateAt;
  final num lastReadAt;
  final num lastReadSeq;
  final int type;

  _SessionModel({
    required this.id,
    required this.ticket,
    required this.to,
    required this.title,
    required this.unread,
    required this.lastMessage,
    required this.createAt,
    required this.updateAt,
    required this.lastReadAt,
    required this.lastReadSeq,
    required this.type,
  });

  factory _SessionModel.create(GlideSessionInfo session) {
    return _SessionModel(
      id: session.id,
      ticket: session.ticket,
      to: session.to,
      title: session.title,
      unread: session.unread,
      lastMessage: session.lastMessage,
      createAt: session.createAt,
      updateAt: session.updateAt,
      lastReadAt: session.lastReadAt,
      lastReadSeq: session.lastReadSeq,
      type: session.type.index,
    );
  }

  factory _SessionModel.fromList(List<dynamic> list) {
    return _SessionModel(
      id: list[0] as String,
      ticket: list[1] as String,
      to: list[2] as String,
      title: list[3] as String,
      unread: list[4] as num,
      lastMessage: list[5] as String,
      createAt: list[6] as num,
      updateAt: list[7] as num,
      lastReadAt: list[8] as num,
      lastReadSeq: list[9] as num,
      type: list[10] as int,
    );
  }

  GlideSessionInfo toSession() {
    return GlideSessionInfo(
      id: id,
      ticket: ticket,
      to: to,
      title: title,
      unread: unread,
      lastMessage: lastMessage,
      createAt: createAt,
      updateAt: updateAt,
      lastReadAt: lastReadAt,
      lastReadSeq: lastReadSeq,
      type: SessionType.values[type],
    );
  }

  List<dynamic> toList() {
    return [
      id,
      ticket,
      to,
      title,
      unread,
      lastMessage,
      createAt,
      updateAt,
      lastReadAt,
      lastReadSeq,
      type,
    ];
  }
}

class _MessageModel {}

class _SQL {
  static const createTableSession = '''
  CREATE TABLE IF NOT EXISTS `session` (
    `id` TEXT NOT NULL PRIMARY KEY,
    `ticket` TEXT NOT NULL,
    `to` TEXT NOT NULL,
    `title` TEXT NOT NULL,
    `unread` INTEGER NOT NULL,
    `lastMessage` TEXT NOT NULL,
    `createAt` INTEGER NOT NULL,
    `updateAt` INTEGER NOT NULL,
    `lastReadAt` INTEGER NOT NULL,
    `lastReadSeq` INTEGER NOT NULL,
    `type` INTEGER NOT NULL
  );
  ''';
  static const insertSession = '''
  INSERT INTO session VALUES (?,?,?,?,?,?,?,?,?,?,?);
  ''';
  static const deleteSession = '''
  DELETE FROM session WHERE id = ?;
  ''';
  static const updateSession = '''
  UPDATE session SET ticket = ?, to = ?, title = ?, unread = ?, lastMessage = ?, createAt = ?, updateAt = ?, lastReadAt = ?, lastReadSeq = ?, type = ? WHERE id = ?;
  ''';
}

class _SessionListSqliteCache implements SessionListCache {
  final Database db;
  final tag = "SessionListSqliteCache";

  _SessionListSqliteCache({required this.db});

  Future init() async {
    db.execute(_SQL.createTableSession);
  }

  @override
  Future<void> addSession(GlideSessionInfo session) async {
    logd(tag, "add session");
    db.execute(_SQL.insertSession, _SessionModel.create(session).toList());
  }

  @override
  Future clear() async {
    db.execute("DROP TABLE session;");
  }

  @override
  Future<List<GlideSessionInfo>> getSessions() async {
    logd(tag, "get sessions");
    final result = db.select("SELECT * FROM session");
    List<GlideSessionInfo> sessions = [];
    for (var element in result.rows) {
      sessions.add(_SessionModel.fromList(element).toSession());
    }
    return sessions;
  }

  @override
  Future<void> removeSession(String id) async {
    logd(tag, "remove session");
    db.execute(_SQL.deleteSession, [id]);
  }

  @override
  Future<void> setSessions(List<GlideSessionInfo> sessions) async {
    logd(tag, "set sessions");
    for (var session in sessions) {
      await addSession(session);
    }
  }

  @override
  Future<void> updateSession(GlideSessionInfo session) async {
    logd(tag, "update session");
    final p = _SessionModel.create(session).toList();
    p.removeAt(0);
    db.execute(_SQL.updateSession, p);
  }
}
