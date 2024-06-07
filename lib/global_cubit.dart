import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

import 'model/user_info.dart';

part 'global_state.dart';

final glide = Glide();

const token =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTgzNjAzNzAsInVpZCI6NTQ2MzkzLCJkZXZpY2UiOi0xLCJ2ZXIiOjEsImFwcF9pZCI6MX0.57f3GUHnxVMddwxkxp2XD0hiveSY5Jgs9ZM5_U-3sS8";

class GlobalCubit extends Cubit<GlobalState>
    implements SessionEventInterceptor {
  final tag = "GlobalCubit";

  GlobalCubit() : super(GlobalInitial()) {
    _init();
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

  Future login() async {
    // final bean = await glide.guestLogin("", "test");
    final bean = await glide.tokenLogin(token);
    emit(state.copyWith(
      info: state.info.copyWith(
        name: bean.nickName,
        id: bean.uid.toString(),
      ),
    ));
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
  }

  Future<GlideSessionInfo> createSession(String id, bool channel) async {
    final s = await glide.sessionManager
        .create(id, channel ? SessionType.channel : SessionType.chat);
    return s.info;
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

  void _init() async {
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

    glide.states().listen((event) {
      emit(state.copyWith(state: event));
    });

    glide.setSessionEventInterceptor(this);

    await glide.init();
    await glide.sessionManager.whileInitialized();
    glide.sessionManager.events().listen((event) {
      try {
        _onSessionEvent(event);
      } catch (e, s) {
        loge(tag, e);
      }
    });

    // todo remove
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(initialized: true));
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
  int onIncrementUnread(GlideSessionInfo se, GlideChatMessage cm) {
    final s = se.id != state.currentSession && cm.from != state.info.id;
    return s ? 1 : 0;
  }

  @override
  GlideChatMessage? onInterceptMessage(
      GlideSessionInfo si, GlideChatMessage cm) {
    return cm;
  }

  @override
  GlideSessionInfo? onSessionCreate(GlideSessionInfo si) {
    return si;
  }
}
