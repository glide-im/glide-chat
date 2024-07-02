import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/model/chat_info.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

import 'global_cubit.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState>
    implements SessionEventInterceptor {
  final String tag = "SessionCubit";

  SessionCubit() : super(SessionState.init()) {
    stream.listen((event) {
      logd(tag, "[Updated] $event");
    });
  }

  static SessionCubit of(BuildContext context) {
    return context.read();
  }

  Future init() async {
    if (state.initialized) {
      return;
    }
    glide.setSessionEventInterceptor(this);
    glide.setSessionCache(DbCache.instance.session);
    glide.setMessageCache(DbCache.instance.message);

    glide.sessionManager.events().listen((event) {
      try {
        _onSessionEvent(event);
      } catch (e, s) {
        loge(tag, e);
      }
    });
    initSession();
  }

  void updateSessionSettings(String id, SessionSettings settings) async {
    final sessions = {...state.sessions};
    sessions[id] = sessions[id]!.copyWith(settings: settings);
    final json = jsonEncode(settings.toMap());
    await DbCache.instance.session.setSetting(id, json);
    emit(state.copyWith(
      sessions: sessions,
      sessionVersion: state.sessionVersion + 1,
    ));
  }

  Session? getSession(String id) {
    return state.sessions[id];
  }

  Future toggleMute(String id) async {
    final settings = state.sessions[id]!.settings;
    final ns = settings.copyWith(muted: !settings.muted);
    updateSessionSettings(id, ns);
  }

  Future togglePin(String id) async {
    SessionSettings settings = state.sessions[id]!.settings;
    if (settings.pinned == 0) {
      settings =
          settings.copyWith(pinned: DateTime.now().millisecondsSinceEpoch);
    } else {
      settings = settings.copyWith(pinned: 0);
    }
    updateSessionSettings(id, settings);
  }

  Future toggleBlock(String id) async {
    final settings = state.sessions[id]!.settings;
    final ns = settings.copyWith(blocked: !settings.blocked);
    updateSessionSettings(id, ns);
  }

  Future deleteSession(String id) async {
    final current = state.currentSession == id ? "" : state.currentSession;
    await glide.sessionManager.delete(id, false);
    final sessions = {...state.sessions};
    sessions.remove(id);
    emit(state.copyWith(
      currentSession: current,
      sessions: sessions,
      sessionVersion: state.sessionVersion + 1,
    ));
  }

  Future<Session> createSession(String id, bool channel) async {
    final s = await glide.sessionManager
        .create(id, channel ? SessionType.channel : SessionType.chat);
    final ss = Session(info: s.info, settings: await _getSessionSetting(id));
    state.sessions[id] = ss;
    return ss;
  }

  Future goSessionOrCreate(BuildContext context, String uid) async {
    if (state.sessions.containsKey(uid)) {
      return goSession(context, state.sessions[uid]!.info);
    }
    final session = await createSession(uid, false);
    return goSession(context, session.info);
  }

  Future goSession(BuildContext context, GlideSessionInfo session) async {
    final cubit = SessionCubit.of(context);
    if (GlobalCubit.of(context).state.compact) {
      AppRoutes.session.go(context, arg: cubit.getSession(session.id)!);
    } else {
      SessionCubit.of(context).setCurrentSession(session.id);
    }
  }

  void setCurrentSession(String id) async {
    emit(state.copyWith(currentSession: id));
    if (id.isEmpty) {
      return;
    }
    final session = state.sessions[id]!;
    final sessions = {...state.sessions};
    sessions[id] = session.copyWith(info: session.info.copyWith(unread: 0));

    emit(state.copyWith(sessions: sessions));
    final s = await glide.sessionManager.get(id);
    await s?.clearUnread();
  }

  void initSession() async {
    await glide.sessionManager.whileInitialized();
    final ss = await glide.sessionManager.getSessions();
    final sessions = <String, Session>{};
    for (final s in ss) {
      final st = await _getSessionSetting(s.info.id);
      final ns = Session(info: s.info, settings: st);
      sessions[s.info.id] = ns;
    }
    emit(state.copyWith(
      sessions: sessions,
      initialized: true,
    ));
  }

  Future<SessionSettings> _getSessionSetting(String id) async {
    final ss = await DbCache.instance.session.getSetting(id);
    if (ss == null) {
      return SessionSettings.def();
    }
    return SessionSettings.fromMap(jsonDecode(ss));
  }

  void _onSessionEvent(SessionEvent event) async {
    final session = await glide.sessionManager.get(event.id);
    final ses = {...state.sessions};
    switch (event.type) {
      case SessionEventType.sessionAdded:
        final st = await _getSessionSetting(event.id);
        ses[session!.info.id] = Session(info: session.info, settings: st);
        emit(state.copyWith(sessions: ses));
        if (session.info.id == 'the_world_channel') {
          session.sendTextMessage("Hi");
        }
        break;
      case SessionEventType.sessionRemoved:
        ses.remove(event.id);
        emit(state.copyWith(sessions: ses));
        break;
      case SessionEventType.sessionUpdated:
        final old = ses[event.id] ??
            Session(
              info: session!.info,
              settings: await _getSessionSetting(event.id),
            );
        ses[session!.info.id] = old.copyWith(info: session.info);
        break;
    }
    emit(state.copyWith(
      sessions: ses,
      sessionVersion: state.sessionVersion + 1,
    ));
  }

  @override
  int onIncrementUnread(GlideSessionInfo se, Message cm) {
    final s = se.id != state.currentSession && cm.from != glide.uid();
    return s ? 1 : 0;
  }

  @override
  Message? onInterceptMessage(GlideSessionInfo si, Message cm) {
    return cm;
  }

  @override
  Future<GlideSessionInfo?> onSessionCreate(GlideSessionInfo si) async {
    ChatInfo? chatInfo;
    try {
      switch (si.type) {
        case SessionType.chat:
          chatInfo = await ChatInfoManager.load(false, si.id);
        case SessionType.channel:
          chatInfo = await ChatInfoManager.load(true, si.id);
      }
    } catch (e) {
      loge(tag, e);
    }
    return si.copyWith(title: chatInfo?.name);
  }

  @override
  Future<String?> onUpdateLastMessage(GlideSessionInfo si, Message cm) async {
    String content = "";
    switch (cm.type) {
      case ChatMessageType.markdown:
      case ChatMessageType.text:
        content = cm.content;
        break;
      case ChatMessageType.image:
        content = "[Image]";
        break;
      case ChatMessageType.file:
        content = "[File]";
        break;
      case ChatMessageType.location:
        content = "[Location]";
        break;
      case ChatMessageType.voice:
        content = "[Voice]";
        break;
      case ChatMessageType.video:
        content = "[Video]";
        break;
      case ChatMessageType.custom:
        content = "[Message]";
      case ChatMessageType.enter:
        final from = await ChatInfoManager.load(false, cm.from);
        content = "${from.name} joined the channel";
        break;
      case ChatMessageType.leave:
        final from = await ChatInfoManager.load(false, cm.from);
        content = "${from.name} left the channel";
        break;
      case ChatMessageType.unknown:
        content = "[Unknown]";
        break;
    }
    if (si.type == SessionType.channel) {
      if (cm.from == glide.uid()) {
        content = "Me: $content";
      } else if (cm.from != 'system') {
        final from = await ChatInfoManager.load(false, cm.from);
        content = "${from.name}: $content";
      }
    } else {
      if (cm.from == glide.uid()) {
        content = "Me: $content";
      }
    }
    return content;
  }
}
