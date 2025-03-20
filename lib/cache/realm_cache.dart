import 'dart:convert';

import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:realm/realm.dart';

part 'realm_cache.realm.dart';

class RealmCache {
  late SessionCache sessionCache;
  late GlideMessageCache messageCache;

  static const tag = "MongoCache";

  Realm? realm;
  String _uid = '';

  static final instance = RealmCache();

  Future init(String uid) async {
    if (uid == _uid && realm != null) {
      return;
    }
    final config = Configuration.local(
      [
        MessageModel.schema,
        GlideSessionInfoModel.schema,
        SessionSettingModel.schema,
      ],
      schemaVersion: 1,
      path: "$uid.realm",
    );
    realm = Realm(config);
    sessionCache = _SessionListRealmCache(realm: realm!);
    messageCache = _MessageRealmCache(realm: realm!);
    _uid = uid;
  }
}

@RealmModel()
class _MessageModel {
  @PrimaryKey()
  late int mid;
  late String sid;
  late int seq;
  late String from;
  late String to;
  late int status;
  late int type;
  late String content;
  late int sendAt;
  late String cliMid;
}

@RealmModel()
class _GlideSessionInfoModel {
  @PrimaryKey()
  late String id;
  late String ticket;
  late String to;
  late String title;
  late int unread;
  late String lastMessage;
  late int createAt;
  late int updateAt;
  late int lastReadAt;
  late int lastReadSeq;
  late int type;
}

@RealmModel()
class _SessionSettingModel {
  @PrimaryKey()
  late String id;
  late String settings;
}

String _toJsonString(dynamic obj) {
  if (obj is String) {
    return obj;
  } else if (obj is Map) {
    return jsonEncode(obj);
  } else {
    throw Exception("not support type: $obj");
  }
}

extension _Ext on MessageModel {
  Message toMessage() {
    final typ = MessageType.typeOf(type) ?? UnknownMessageType(type);
    return Message(
      mid: mid,
      seq: seq,
      from: from,
      to: to,
      type: typ,
      content: typ.decode(content),
      sendAt: sendAt,
      cliMid: cliMid,
    );
  }
}

extension _Ext1 on Message {
  MessageModel toModel(String sid) {
    return MessageModel(
      mid.toInt(),
      sid,
      seq.toInt(),
      from,
      to,
      status.value,
      type.type,
      _toJsonString(type.encode(content)),
      sendAt.toInt(),
      cliMid,
    );
  }
}

extension _Ext2 on GlideSessionInfo {
  GlideSessionInfoModel toModel() {
    return GlideSessionInfoModel(
      id,
      ticket,
      to,
      title,
      unread.toInt(),
      lastMessage,
      createAt.toInt(),
      updateAt.toInt(),
      lastReadAt.toInt(),
      lastReadSeq.toInt(),
      type.index,
    );
  }
}

extension _Ext0 on GlideSessionInfoModel {
  GlideSessionInfo toSessionInfo() {
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
}

class _SessionListRealmCache implements SessionCache {
  final Realm realm;

  _SessionListRealmCache({required this.realm});

  @override
  Future<void> addSession(GlideSessionInfo session) async {
    realm.write(() {
      realm.add<GlideSessionInfoModel>(session.toModel());
    });
  }

  @override
  Future clear() async {
    realm.write(() {
      realm.deleteAll<GlideSessionInfoModel>();
    });
  }

  @override
  Future<List<GlideSessionInfo>> getSessions() async {
    final result = realm.all<GlideSessionInfoModel>();
    final sessions = <GlideSessionInfo>[];
    for (var element in result) {
      sessions.add(element.toSessionInfo());
    }
    return sessions;
  }

  @override
  Future init(String uid) async {
    //
  }

  @override
  Future<void> removeSession(String id) async {
    final r = realm.find<GlideSessionInfoModel>(id);
    if (r != null) {
      realm.write(() {
        realm.delete(r);
      });
    }
  }

  @override
  Future<void> setSessions(List<GlideSessionInfo> sessions) async {
    for (var session in sessions) {
      await addSession(session);
    }
  }

  @override
  Future<void> updateSession(GlideSessionInfo session) async {
    realm.write(() {
      realm.add(session.toModel(), update: true);
    });
  }

  @override
  Future<String?> getSetting(String id) async {
    return realm.find<SessionSettingModel>(id)?.settings;
  }

  @override
  Future setSetting(String id, String value) async {
    realm.write(() {
      realm.add(SessionSettingModel(id, value));
    });
  }
}

class _MessageRealmCache implements GlideMessageCache {
  final Realm realm;

  _MessageRealmCache({required this.realm});

  @override
  Future<void> addMessage(String sessionId, Message message) async {
    realm.write(() {
      realm.add(message.toModel(sessionId), update: true);
    });
  }

  @override
  Future clear() async {
    realm.write(() {
      realm.deleteAll<MessageModel>();
    });
  }

  @override
  Future<Message?> getMessage(num mid) async {
    final r = realm.find<MessageModel>(mid);
    return r?.toMessage();
  }

  @override
  Future<List<Message>> getMessages(String sessionId) async {
    final rs = realm.all<MessageModel>().query("sid == '$sessionId'");
    final messages = <Message>[];
    for (var r in rs) {
      messages.add(r.toMessage());
    }
    return messages;
  }

  @override
  Future<bool> hasMessage(num mid) async {
    return await getMessage(mid) != null;
  }

  @override
  Future init(String uid) async {
    //
  }

  @override
  Future<void> removeMessage(num id) async {
    final r = realm.find<MessageModel>(id);
    if (r != null) {
      realm.write(() {
        realm.delete(r);
      });
    }
  }

  @override
  Future<void> updateMessage(Message message) async {
    final r = realm.find<MessageModel>(message.mid);
    if (r == null) {
      throw Exception('update message not found');
    }
    realm.write(() {
      realm.add(message.toModel(r.sid), update: true);
    });
  }
}
