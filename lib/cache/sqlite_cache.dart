import 'dart:async';
import 'dart:convert';

import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteCache {
  late SessionListCache sessionCache;
  late SessionSettingCache sessionSettingCache;
  late GlideMessageCache messageCache;

  static Database? _db;

  String _uid = "";

  static const tag = "SQLiteCache";

  static final instance = SQLiteCache();

  Future init(String uid) async {
    if (uid.isEmpty) {
      throw "user not logged in";
    }
    if (SQLiteCache.instance._uid == uid && _db != null) {
      return;
    }
    // check init
    if (_db != null) {
      _db?.dispose();
    }
    final dir = (await getTemporaryDirectory()).absolute.path;
    final db = "$dir/$uid.sqlite";
    logd(tag, "init db: $db");
    _db = sqlite3.open(db, mode: OpenMode.readWriteCreate);
    _db!.execute(_SQL.createTableSession);
    _db!.execute(_SQL.createTableSessionSetting);
    sessionSettingCache = SessionSettingCache(db: _db!);
    sessionCache = _SessionListSqliteCache(db: _db!);
    messageCache = _MessageSQLiteCache(db: _db!);
    _uid = uid;
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
  final String avatar;

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
    required this.avatar,
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
      avatar: "",
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
      avatar: list[11] as String,
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

  List<Object?> toList() {
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
      avatar,
    ];
  }
}

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
    `type` INTEGER NOT NULL,
    `avatar` TEXT NOT NULL
  );
  ''';
  static const deleteTableSession = '''
  DROP TABLE IF EXISTS `session`;
  ''';
  static const insertSession = '''
  INSERT INTO session VALUES (?,?,?,?,?,?,?,?,?,?,?,?);
  ''';
  static const selectSession = '''
  SELECT * FROM session WHERE id = ?;
  ''';
  static const selectAllSession = '''
  SELECT * FROM session;
  ''';
  static const deleteSession = '''
  DELETE FROM session WHERE id = ?;
  ''';
  static const updateSession = '''
  UPDATE `session` SET 
  `ticket`=?, `to`=?, `title`=?, `unread`=?, `lastMessage`=?, `createAt`=?, `updateAt`=?, `lastReadAt`=?, `lastReadSeq`=?, `type`=?, `avatar`=?
  WHERE `id` = ?;
  ''';
  static const createTableSessionSetting = '''
  CREATE TABLE IF NOT EXISTS `session_setting` (
    `id` TEXT NOT NULL PRIMARY KEY,
    `setting` TEXT NOT NULL
  );
  ''';
  static const updateSessionSetting = '''
  INSERT OR REPLACE INTO `session_setting` (`id`, `setting`) VALUES (?, ?);
  ''';
  static const selectSessionSetting = '''
  SELECT * FROM `session_setting` WHERE `id` = ?;
  ''';
  static const deleteSessionSetting = '''
  DROP TABLE IF EXISTS `session_setting`;
  ''';
}

class _SessionListSqliteCache implements SessionListCache {
  final Database db;
  final tag = "SessionListSqliteCache";

  _SessionListSqliteCache({required this.db});

  @override
  Future init(String uid) async {
    logd(tag, "init session sqlite table, uid: $uid");
    db.execute(_SQL.createTableSession);
  }

  @override
  Future<void> addSession(GlideSessionInfo session) async {
    db.execute(_SQL.insertSession, _SessionModel.create(session).toList());
  }

  @override
  Future clear() async {
    db.execute(_SQL.deleteTableSession);
  }

  @override
  Future<List<GlideSessionInfo>> getSessions() async {
    final result = db.select(_SQL.selectAllSession);
    List<GlideSessionInfo> sessions = [];
    for (var element in result.rows) {
      sessions.add(_SessionModel.fromList(element).toSession());
    }
    return sessions;
  }

  @override
  Future<void> removeSession(String id) async {
    db.execute(_SQL.deleteSession, [id]);
  }

  @override
  Future<void> setSessions(List<GlideSessionInfo> sessions) async {
    for (var session in sessions) {
      await addSession(session);
    }
  }

  @override
  Future<void> updateSession(GlideSessionInfo session) async {
    final p = _SessionModel.create(session).toList();
    final id = p.removeAt(0);
    p.add(id);
    db.execute(_SQL.updateSession, p);
  }
}

class _MessageSQLiteCache implements GlideMessageCache {
  final Database db;
  final tag = "MessageSQLiteCache";

  _MessageSQLiteCache({required this.db});

  @override
  Future init(String uid) async {
    logd(tag, "init message sqlite table, uid: $uid");
    db.execute('''
     CREATE TABLE IF NOT EXISTS `message` (
    `status` INTEGER NOT NULL,
    `mid` INTEGER NOT NULL PRIMARY KEY,
    `cli_mid` TEXT NOT NULL,
    `type` INTEGER NOT NULL,
    `from` TEXT NOT NULL,
    `to` TEXT NOT NULL,
    `seq` INTEGER NOT NULL,
    `send_at` INTEGER NOT NULL,
    `content` TEXT NOT NULL,
    `session_id` TEXT NOT NULL
    );
    ''');
  }

  @override
  Future<void> addMessage(String sessionId, Message message) async {
    logd(tag, "insert message, $sessionId ${message.mid}");
    String content;
    if (!message.type.isTextBody()) {
      content = const JsonEncoder().convert(message.content);
    } else {
      content = message.content as String;
    }
    db.execute("""
    INSERT INTO `message` VALUES (?,?,?,?,?,?,?,?,?,?);
    """, [
      message.status.value,
      message.mid,
      message.cliMid,
      message.type.value,
      message.from,
      message.to,
      message.seq,
      message.sendAt,
      content,
      sessionId,
    ]);
  }

  @override
  Future<List<Message>> getMessages(String sessionId) async {
    final res =
        db.select("SELECT * FROM `message` WHERE `session_id`=?;", [sessionId]);
    final ms = <Message>[];
    for (var row in res.rows) {
      final status = MessageStatus.valueOf(row[0] as int);
      final type = ChatMessageType.of(row[3] as num);
      dynamic content = row[8] as String;
      if (!type.isTextBody()) {
        content = const JsonDecoder().convert(content);
      }
      final m = Message(
        status: status,
        mid: row[1] as num,
        cliMid: row[2] as String,
        type: type,
        from: row[4] as String,
        to: row[5] as String,
        seq: row[6] as num,
        sendAt: row[7] as num,
        content: content,
      );
      if (m.validate()) {
        ms.add(m);
      } else {
        logw(tag, 'invalid message: $m');
      }
    }
    return ms;
  }

  @override
  Future clear() async {
    db.execute("DROP TABLE `message`;");
  }

  @override
  Future<Message?> getMessage(num mid) async {
    final res =
        db.select("SELECT * FROM `message` WHERE `mid`=?;", [mid]).firstOrNull;
    if (res == null) {
      return null;
    }
    final row = res.values;
    final status = MessageStatus.valueOf(row[0] as int);
    final type = ChatMessageType.of(row[3] as int);
    dynamic content = row[8] as String;
    if (!type.isTextBody()) {
      content = const JsonDecoder().convert(content);
    }
    return Message(
      status: status,
      mid: row[1] as num,
      cliMid: row[2] as String,
      type: type,
      from: row[4] as String,
      to: row[5] as String,
      seq: row[6] as num,
      sendAt: row[7] as num,
      content: content,
    );
  }

  @override
  Future<bool> hasMessage(num mid) async {
    final res = db.select(
        "SELECT COUNT(`mid`) FROM `message` WHERE `mid`=?;", [mid]).firstOrNull;
    if (res?.values.first == 0) {
      return false;
    }
    return true;
  }

  @override
  Future<void> removeMessage(num id) async {
    db.execute("DELETE FROM `message` WHERE `mid`=?;", [id]);
  }

  @override
  Future<void> updateMessage(Message message) async {
    dynamic cnt = message.content;
    if (!message.type.isTextBody()) {
      cnt = const JsonEncoder().convert(cnt);
    }
    db.execute("""
     UPDATE `message` SET  
     `status`=?, `cli_mid`=?, `type`=?, `from`=?, `to`=?, `seq`=?, `send_at`=?, `content`=?
     WHERE `mid`=?;
    """, [
      message.status.value,
      message.cliMid,
      message.type.value,
      message.from,
      message.to,
      message.seq,
      message.sendAt,
      cnt,
      message.mid,
    ]);
  }
}

class SessionSettingCache {
  final Database db;

  SessionSettingCache({required this.db});

  Future<String> getSessionSetting(String id) async {
    final result = db.select(_SQL.selectSessionSetting, [id]).firstOrNull;
    return result?.values[1] as String? ?? "";
  }

  Future updateSessionSetting(String id, String setting) async {
    db.execute(_SQL.updateSessionSetting, [id, setting]);
  }

  Future clearAllSessionSetting() async {
    db.execute(_SQL.deleteSessionSetting);
  }
}
