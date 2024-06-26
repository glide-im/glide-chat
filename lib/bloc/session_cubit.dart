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
    implements SessionEventInterceptor, GlideEventListener {
  final String tag = "SessionCubit";

  SessionCubit() : super(SessionState.init());

  static SessionCubit of(BuildContext context) {
    return context.read();
  }

  Future init() async {
    if (state.initialized) {
      return;
    }
    glide.setEventListener(this);
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
  }

  void updateSessionSettings(String id, SessionSettings settings) {
    final sessions = {...state.sessions};
    sessions[id] = sessions[id]!.copyWith(settings: settings);
    emit(state.copyWith(sessions: sessions));
  }

  Session? getSession(String id) {
    return state.sessions[id];
  }

  Future<Session> createSession(String id, bool channel) async {
    final s = await glide.sessionManager
        .create(id, channel ? SessionType.channel : SessionType.chat);
    final ss = Session(info: s.info, settings: SessionSettings.def());
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
      final ns = Session(info: s.info, settings: SessionSettings.def());
      sessions[s.info.id] = ns;
    }
    emit(state.copyWith(
      sessions: sessions,
      initialized: true,
    ));
  }

  void _onSessionEvent(SessionEvent event) async {
    final session = await glide.sessionManager.get(event.id);
    final ses = {...state.sessions};
    switch (event.type) {
      case SessionEventType.sessionAdded:
        ses[session!.info.id] =
            Session(info: session.info, settings: SessionSettings.def());
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
            Session(info: session!.info, settings: SessionSettings.def());
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
  void onCacheLoaded() {
    initSession();
  }
}
