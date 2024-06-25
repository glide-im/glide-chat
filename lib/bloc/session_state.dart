import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class SessionState {
  final Map<String, Session> sessions;
  final String currentSession;
  final num sessionVersion;

  SessionState({
    required this.sessions,
    required this.currentSession,
    required this.sessionVersion,
  });

  factory SessionState.init() {
    return SessionState(
      sessions: {},
      currentSession: "",
      sessionVersion: 0,
    );
  }

  SessionState copyWith({
    Map<String, Session>? sessions,
    String? currentSession,
    num? sessionVersion,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      sessionVersion: sessionVersion ?? this.sessionVersion,
    );
  }
}

class Session {
  final GlideSessionInfo info;
  final SessionSettings settings;

  Session({required this.info, required this.settings});

  Session copyWith({
    GlideSessionInfo? info,
    SessionSettings? settings,
  }) {
    return Session(
      info: info ?? this.info,
      settings: settings ?? this.settings,
    );
  }
}

class SessionSettings {
  final bool muted;
  final num pinned;
  final String remark;
  final bool blocked;

  SessionSettings({
    required this.muted,
    required this.pinned,
    required this.remark,
    required this.blocked,
  });

  factory SessionSettings.def() {
    return SessionSettings(muted: false, pinned: 0, remark: "", blocked: false);
  }

  SessionSettings copyWith({
    bool? muted,
    num? pinned,
    String? remark,
    bool? blocked,
  }) {
    return SessionSettings(
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      remark: remark ?? this.remark,
      blocked: blocked ?? this.blocked,
    );
  }
}
