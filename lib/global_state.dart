part of 'global_cubit.dart';

enum PlatformType {
  desktop,
  mobile,
  web;
}

class GlobalState {
  final String token;
  final Map<String, Session> sessions;
  final GlideState state;
  final String currentSession;
  final bool initialized;
  final bool compact;
  final ChatInfo info;
  final bool logged;
  final num sessionVersion;
  final PlatformType platform;

  GlobalState({
    required this.token,
    required this.sessions,
    required this.state,
    required this.currentSession,
    required this.initialized,
    required this.compact,
    required this.info,
    required this.sessionVersion,
    required this.platform,
    required this.logged,
  });

  GlobalState copyWith({
    String? token,
    Map<String, Session>? sessions,
    GlideState? state,
    String? currentSession,
    bool? initialized,
    bool? compact,
    ChatInfo? info,
    bool? logged,
    num? sessionVersion,
    PlatformType? platform,
  }) {
    return GlobalState(
      token: token ?? this.token,
      sessions: sessions ?? this.sessions,
      state: state ?? this.state,
      currentSession: currentSession ?? this.currentSession,
      initialized: initialized ?? this.initialized,
      compact: compact ?? this.compact,
      info: info ?? this.info,
      logged: logged ?? this.logged,
      sessionVersion: sessionVersion ?? this.sessionVersion,
      platform: platform ?? this.platform,
    );
  }

  @override
  String toString() {
    return 'GlobalState{token: ${token.isNotEmpty}, sessions: ${sessions.length}, state: $state, currentSession: $currentSession, initialized: $initialized, compact: $compact, info: $info, logged: $logged, sessionVersion: $sessionVersion, platform: $platform}';
  }
}

final class GlobalInitial extends GlobalState {
  GlobalInitial({
    super.token = "",
    super.sessions = const {},
    super.state = GlideState.init,
    super.currentSession = "",
    super.initialized = false,
    super.compact = true,
    super.info = ChatInfo.empty,
    super.sessionVersion = 0,
    super.platform = PlatformType.desktop,
    super.logged = false,
  });
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
