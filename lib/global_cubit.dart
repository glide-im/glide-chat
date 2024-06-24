import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

import 'model/chat_info.dart';

part 'global_state.dart';

final glide = Glide();

class GlobalCubit extends Cubit<GlobalState>
    implements SessionEventInterceptor {
  final tag = "GlobalCubit";

  GlobalCubit() : super(GlobalInitial());

  Future<GlobalState> init() async {
    await _init().forEach((log) {
      logd(tag, log);
    });
    return state;
  }

  static GlobalCubit of(BuildContext context) {
    return context.read();
  }

  void switchCompact() {
    emit(state.copyWith(compact: !state.compact));
  }

  void switchPlatform() {
    const ps = PlatformType.values;
    final p = state.platform;
    final i = (ps.indexOf(p) + 1) % ps.length;
    final pt = ps[i];
    emit(state.copyWith(platform: pt));
  }

  Future<dynamic> login(String account, String password) async {
    final bean = await glide.login(account, password);
    await _onLogin(bean).forEach((element) {
      logd(tag, "login=> $element");
    });
  }

  Future<dynamic> loginGuest() async {
    String name = "";
    for (var i = 0; i < 10; i++) {
      final rnd = Random().nextInt(26) + 97;
      name += String.fromCharCode(rnd);
    }
    final avatar = "https://api.dicebear.com/6.x/adventurer/svg?seed=$name";
    final bean = await glide.guestLogin(name, avatar);
    await _onLogin(bean).forEach((element) {
      logd(tag, "login guest=> $element");
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

  Future logout() async {
    await glide.logout();
    await UserCache.clear();
    await DbCache.clear();
  }

  Future<Session> createSession(String id, bool channel) async {
    final s = await glide.sessionManager
        .create(id, channel ? SessionType.channel : SessionType.chat);
    final ss = Session(info: s.info, settings: SessionSettings.def());
    state.sessions[id] = ss;
    return ss;
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

  Stream<String> _init() async* {
    if (state.initialized) {
      yield "already initialized";
      return;
    }
    stream.listen((event) {
      logd(tag, "state changed: $event");
    });
    yield "init start";

    PlatformType platform = PlatformType.mobile;
    if (kIsWeb) {
      platform = PlatformType.web;
    } else if (Platform.isAndroid || Platform.isIOS) {
      platform = PlatformType.mobile;
    } else {
      platform = PlatformType.desktop;
    }

    emit(state.copyWith(
      compact: platform == PlatformType.mobile,
      platform: platform,
    ));

    final sc = StreamController<List<int>>();
    sc.stream.listen((byte) {
      final log = utf8.decoder.convert(byte);
      if (log.trim().isEmpty) {
        return;
      }
      print(log);
    });
    Glide.setLogger(IOSink(sc));

    yield* glide.init().map((event) => "sdk init: $event");

    glide.states().listen((event) {
      emit(state.copyWith(state: event));
    });

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

    final uc = await UserCache.load();
    if (uc.token.isNotEmpty) {
      try {
        yield "token loaded, start token login";
        final ab = await glide.tokenLogin(uc.token);
        yield* _onLogin(ab);
      } catch (e, s) {
        yield "token login failed, $e, $s";
      }
    }
    emit(state.copyWith(initialized: true));
    yield "init done";
  }

  Stream<String> _onLogin(AuthBean bean) async* {

    final uc = await UserCache.load();
    uc.uid = bean.uid.toString();
    uc.name = bean.nickName ?? '';
    uc.token = bean.token!;
    await uc.save();

    await glide.sessionManager.whileInitialized();
    final ss = await glide.sessionManager.getSessions();
    final sessions = <String, Session>{};
    for (final s in ss) {
      final ns = Session(info: s.info, settings: SessionSettings.def());
      sessions[s.info.id] = ns;
    }

    emit(state.copyWith(
      sessions: sessions,
      logged: true,
      info: state.info.copyWith(
        name: bean.nickName,
        id: bean.uid.toString(),
      ),
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
    final s = se.id != state.currentSession && cm.from != state.info.id;
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
}
