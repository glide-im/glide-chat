// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_cache.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class MessageModel extends _MessageModel
    with RealmEntity, RealmObjectBase, RealmObject {
  MessageModel(
    int mid,
    String sid,
    int seq,
    String from,
    String to,
    int status,
    int type,
    String content,
    int sendAt,
    String cliMid,
  ) {
    RealmObjectBase.set(this, 'mid', mid);
    RealmObjectBase.set(this, 'sid', sid);
    RealmObjectBase.set(this, 'seq', seq);
    RealmObjectBase.set(this, 'from', from);
    RealmObjectBase.set(this, 'to', to);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'sendAt', sendAt);
    RealmObjectBase.set(this, 'cliMid', cliMid);
  }

  MessageModel._();

  @override
  int get mid => RealmObjectBase.get<int>(this, 'mid') as int;
  @override
  set mid(int value) => RealmObjectBase.set(this, 'mid', value);

  @override
  String get sid => RealmObjectBase.get<String>(this, 'sid') as String;
  @override
  set sid(String value) => RealmObjectBase.set(this, 'sid', value);

  @override
  int get seq => RealmObjectBase.get<int>(this, 'seq') as int;
  @override
  set seq(int value) => RealmObjectBase.set(this, 'seq', value);

  @override
  String get from => RealmObjectBase.get<String>(this, 'from') as String;
  @override
  set from(String value) => RealmObjectBase.set(this, 'from', value);

  @override
  String get to => RealmObjectBase.get<String>(this, 'to') as String;
  @override
  set to(String value) => RealmObjectBase.set(this, 'to', value);

  @override
  int get status => RealmObjectBase.get<int>(this, 'status') as int;
  @override
  set status(int value) => RealmObjectBase.set(this, 'status', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  int get sendAt => RealmObjectBase.get<int>(this, 'sendAt') as int;
  @override
  set sendAt(int value) => RealmObjectBase.set(this, 'sendAt', value);

  @override
  String get cliMid => RealmObjectBase.get<String>(this, 'cliMid') as String;
  @override
  set cliMid(String value) => RealmObjectBase.set(this, 'cliMid', value);

  @override
  Stream<RealmObjectChanges<MessageModel>> get changes =>
      RealmObjectBase.getChanges<MessageModel>(this);

  @override
  Stream<RealmObjectChanges<MessageModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<MessageModel>(this, keyPaths);

  @override
  MessageModel freeze() => RealmObjectBase.freezeObject<MessageModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'mid': mid.toEJson(),
      'sid': sid.toEJson(),
      'seq': seq.toEJson(),
      'from': from.toEJson(),
      'to': to.toEJson(),
      'status': status.toEJson(),
      'type': type.toEJson(),
      'content': content.toEJson(),
      'sendAt': sendAt.toEJson(),
      'cliMid': cliMid.toEJson(),
    };
  }

  static EJsonValue _toEJson(MessageModel value) => value.toEJson();
  static MessageModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'mid': EJsonValue mid,
        'sid': EJsonValue sid,
        'seq': EJsonValue seq,
        'from': EJsonValue from,
        'to': EJsonValue to,
        'status': EJsonValue status,
        'type': EJsonValue type,
        'content': EJsonValue content,
        'sendAt': EJsonValue sendAt,
        'cliMid': EJsonValue cliMid,
      } =>
        MessageModel(
          fromEJson(mid),
          fromEJson(sid),
          fromEJson(seq),
          fromEJson(from),
          fromEJson(to),
          fromEJson(status),
          fromEJson(type),
          fromEJson(content),
          fromEJson(sendAt),
          fromEJson(cliMid),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(MessageModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, MessageModel, 'MessageModel', [
      SchemaProperty('mid', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('sid', RealmPropertyType.string),
      SchemaProperty('seq', RealmPropertyType.int),
      SchemaProperty('from', RealmPropertyType.string),
      SchemaProperty('to', RealmPropertyType.string),
      SchemaProperty('status', RealmPropertyType.int),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('content', RealmPropertyType.string),
      SchemaProperty('sendAt', RealmPropertyType.int),
      SchemaProperty('cliMid', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class GlideSessionInfoModel extends _GlideSessionInfoModel
    with RealmEntity, RealmObjectBase, RealmObject {
  GlideSessionInfoModel(
    String id,
    String ticket,
    String to,
    String title,
    int unread,
    String lastMessage,
    int createAt,
    int updateAt,
    int lastReadAt,
    int lastReadSeq,
    int type,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'ticket', ticket);
    RealmObjectBase.set(this, 'to', to);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'unread', unread);
    RealmObjectBase.set(this, 'lastMessage', lastMessage);
    RealmObjectBase.set(this, 'createAt', createAt);
    RealmObjectBase.set(this, 'updateAt', updateAt);
    RealmObjectBase.set(this, 'lastReadAt', lastReadAt);
    RealmObjectBase.set(this, 'lastReadSeq', lastReadSeq);
    RealmObjectBase.set(this, 'type', type);
  }

  GlideSessionInfoModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get ticket => RealmObjectBase.get<String>(this, 'ticket') as String;
  @override
  set ticket(String value) => RealmObjectBase.set(this, 'ticket', value);

  @override
  String get to => RealmObjectBase.get<String>(this, 'to') as String;
  @override
  set to(String value) => RealmObjectBase.set(this, 'to', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  int get unread => RealmObjectBase.get<int>(this, 'unread') as int;
  @override
  set unread(int value) => RealmObjectBase.set(this, 'unread', value);

  @override
  String get lastMessage =>
      RealmObjectBase.get<String>(this, 'lastMessage') as String;
  @override
  set lastMessage(String value) =>
      RealmObjectBase.set(this, 'lastMessage', value);

  @override
  int get createAt => RealmObjectBase.get<int>(this, 'createAt') as int;
  @override
  set createAt(int value) => RealmObjectBase.set(this, 'createAt', value);

  @override
  int get updateAt => RealmObjectBase.get<int>(this, 'updateAt') as int;
  @override
  set updateAt(int value) => RealmObjectBase.set(this, 'updateAt', value);

  @override
  int get lastReadAt => RealmObjectBase.get<int>(this, 'lastReadAt') as int;
  @override
  set lastReadAt(int value) => RealmObjectBase.set(this, 'lastReadAt', value);

  @override
  int get lastReadSeq => RealmObjectBase.get<int>(this, 'lastReadSeq') as int;
  @override
  set lastReadSeq(int value) => RealmObjectBase.set(this, 'lastReadSeq', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  Stream<RealmObjectChanges<GlideSessionInfoModel>> get changes =>
      RealmObjectBase.getChanges<GlideSessionInfoModel>(this);

  @override
  Stream<RealmObjectChanges<GlideSessionInfoModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<GlideSessionInfoModel>(this, keyPaths);

  @override
  GlideSessionInfoModel freeze() =>
      RealmObjectBase.freezeObject<GlideSessionInfoModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'ticket': ticket.toEJson(),
      'to': to.toEJson(),
      'title': title.toEJson(),
      'unread': unread.toEJson(),
      'lastMessage': lastMessage.toEJson(),
      'createAt': createAt.toEJson(),
      'updateAt': updateAt.toEJson(),
      'lastReadAt': lastReadAt.toEJson(),
      'lastReadSeq': lastReadSeq.toEJson(),
      'type': type.toEJson(),
    };
  }

  static EJsonValue _toEJson(GlideSessionInfoModel value) => value.toEJson();
  static GlideSessionInfoModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'ticket': EJsonValue ticket,
        'to': EJsonValue to,
        'title': EJsonValue title,
        'unread': EJsonValue unread,
        'lastMessage': EJsonValue lastMessage,
        'createAt': EJsonValue createAt,
        'updateAt': EJsonValue updateAt,
        'lastReadAt': EJsonValue lastReadAt,
        'lastReadSeq': EJsonValue lastReadSeq,
        'type': EJsonValue type,
      } =>
        GlideSessionInfoModel(
          fromEJson(id),
          fromEJson(ticket),
          fromEJson(to),
          fromEJson(title),
          fromEJson(unread),
          fromEJson(lastMessage),
          fromEJson(createAt),
          fromEJson(updateAt),
          fromEJson(lastReadAt),
          fromEJson(lastReadSeq),
          fromEJson(type),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(GlideSessionInfoModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, GlideSessionInfoModel,
        'GlideSessionInfoModel', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('ticket', RealmPropertyType.string),
      SchemaProperty('to', RealmPropertyType.string),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('unread', RealmPropertyType.int),
      SchemaProperty('lastMessage', RealmPropertyType.string),
      SchemaProperty('createAt', RealmPropertyType.int),
      SchemaProperty('updateAt', RealmPropertyType.int),
      SchemaProperty('lastReadAt', RealmPropertyType.int),
      SchemaProperty('lastReadSeq', RealmPropertyType.int),
      SchemaProperty('type', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SessionSettingModel extends _SessionSettingModel
    with RealmEntity, RealmObjectBase, RealmObject {
  SessionSettingModel(
    String id,
    String settings,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'settings', settings);
  }

  SessionSettingModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get settings =>
      RealmObjectBase.get<String>(this, 'settings') as String;
  @override
  set settings(String value) => RealmObjectBase.set(this, 'settings', value);

  @override
  Stream<RealmObjectChanges<SessionSettingModel>> get changes =>
      RealmObjectBase.getChanges<SessionSettingModel>(this);

  @override
  Stream<RealmObjectChanges<SessionSettingModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<SessionSettingModel>(this, keyPaths);

  @override
  SessionSettingModel freeze() =>
      RealmObjectBase.freezeObject<SessionSettingModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'settings': settings.toEJson(),
    };
  }

  static EJsonValue _toEJson(SessionSettingModel value) => value.toEJson();
  static SessionSettingModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'settings': EJsonValue settings,
      } =>
        SessionSettingModel(
          fromEJson(id),
          fromEJson(settings),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SessionSettingModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, SessionSettingModel, 'SessionSettingModel', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('settings', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
