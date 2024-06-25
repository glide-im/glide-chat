part of 'global_cubit.dart';

enum PlatformType {
  desktop,
  mobile,
  web;
}

class GlobalState {
  final String token;
  final bool initialized;
  final GlideState state;
  final bool compact;
  final ChatInfo info;
  final bool logged;
  final PlatformType platform;

  GlobalState({
    required this.token,
    required this.initialized,
    required this.state,
    required this.compact,
    required this.info,
    required this.platform,
    required this.logged,
  });

  GlobalState copyWith({
    String? token,
    GlideState? state,
    bool? initialized,
    bool? compact,
    ChatInfo? info,
    bool? logged,
    PlatformType? platform,
  }) {
    return GlobalState(
      state: state ?? this.state,
      token: token ?? this.token,
      initialized: initialized ?? this.initialized,
      compact: compact ?? this.compact,
      info: info ?? this.info,
      logged: logged ?? this.logged,
      platform: platform ?? this.platform,
    );
  }

  @override
  String toString() {
    return 'GlobalState{initialized: $initialized, state: $state, compact: $compact, info: $info, logged: $logged, platform: $platform}';
  }
}

final class GlobalInitial extends GlobalState {
  GlobalInitial({
    super.token = "",
    super.state = GlideState.init,
    super.initialized = false,
    super.compact = true,
    super.info = ChatInfo.empty,
    super.platform = PlatformType.desktop,
    super.logged = false,
  });
}
