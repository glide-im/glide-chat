import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class SessionState {
  final Map<String, Session> sessions;
  final String currentSession;
  final num sessionVersion;
  final bool initialized;

  SessionState({
    required this.sessions,
    required this.currentSession,
    required this.sessionVersion,
    required this.initialized,
  });

  factory SessionState.init() {
    return SessionState(
      sessions: {},
      currentSession: "",
      sessionVersion: 0,
      initialized: false,
    );
  }

  List<Session> sessionListSorted() {
    final sessions = this.sessions.values.toList();
    sessions.sort((a, b) => a.compareTo(b));
    return sessions;
  }

  SessionState copyWith({
    Map<String, Session>? sessions,
    String? currentSession,
    num? sessionVersion,
    bool? initialized,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      sessionVersion: sessionVersion ?? this.sessionVersion,
      initialized: initialized ?? this.initialized,
    );
  }

  @override
  String toString() {
    return 'SessionState{sessions: $sessions, currentSession: $currentSession, sessionVersion: $sessionVersion, initialized: $initialized}';
  }
}

class Session implements Comparable<Session> {
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

  @override
  int compareTo(Session other) {
    final pinned = other.settings.pinned.compareTo(settings.pinned);
    if (pinned != 0) {
      return pinned;
    }
    return other.info.updateAt.compareTo(info.updateAt);
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

  Map<String, dynamic> toMap() {
    return {
      'muted': muted,
      'pinned': pinned,
      'remark': remark,
      'blocked': blocked,
    };
  }

  factory SessionSettings.fromMap(Map<String, dynamic> map) {
    return SessionSettings(
      muted: map['muted'] as bool,
      pinned: map['pinned'] as num,
      remark: map['remark'] as String,
      blocked: map['blocked'] as bool,
    );
  }
}
