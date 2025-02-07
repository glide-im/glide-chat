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

import '../model/chat_info.dart';

part 'global_state.dart';

final glide = Glide();

class GlobalCubit extends Cubit<GlobalState> {
  final tag = "GlobalCubit";

  GlobalCubit() : super(GlobalInitial());

  Future<GlobalState> init() async {
    if (state.initialized) {
      return state;
    }
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

  Future logout() async {
    await glide.logout();
    await UserCache.clear();
    await DbCache.clear();
  }

  @override
  Future<void> close() {
    logw(tag, ">>>>>> closed");
    return super.close();
  }

  Stream<String> _init() async* {
    stream.listen((event) {
      logd(tag, "state changed: $event");
    });
    yield "init start";

    PlatformType platform = PlatformType.mobile;
    if (kIsWeb) {
      platform = PlatformType.web;
    } else if (Platform.isAndroid || Platform.isIOS) {
      platform = PlatformType.mobile;
    } else if (Platform.isMacOS) {
      platform = PlatformType.macos;
    } else if (Platform.isWindows) {
      platform = PlatformType.windows;
    } else if (Platform.isLinux) {
      platform = PlatformType.desktop;
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

    final uc = await UserCache.load();
    if (uc.token.isNotEmpty) {
      try {
        yield "token loaded, start token login";
        final ab = await glide.api.auth.loginToken(uc.token);
        await glide.initCache(ab.uid.toString());
        await glide.connect(ab);
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

    emit(state.copyWith(
      logged: true,
      info: state.info.copyWith(
        name: bean.nickName,
        id: bean.uid.toString(),
      ),
    ));
  }
}
