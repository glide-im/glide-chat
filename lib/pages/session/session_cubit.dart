part of 'session_page.dart';

class _SessionState {
  final GlideSessionInfo info;
  final List<GlideChatMessage> messages;
  final bool initialized;
  final bool blockInput;
  final String sendError;
  final TextEditingController textController;
  final bool showSend;
  final bool typing;

  _SessionState({
    required this.info,
    required this.messages,
    required this.initialized,
    required this.blockInput,
    required this.sendError,
    required this.textController,
    required this.showSend,
    required this.typing,
  });

  factory _SessionState.initial(GlideSessionInfo info) {
    return _SessionState(
      info: info,
      messages: [],
      initialized: false,
      blockInput: false,
      typing: false,
      showSend: false,
      sendError: "",
      textController: TextEditingController(),
    );
  }

  _SessionState copyWith({
    GlideSessionInfo? info,
    List<GlideChatMessage>? messages,
    bool? initialized,
    bool? blockInput,
    String? sendError,
    TextEditingController? textController,
    bool? showSend,
    bool? typing,
  }) {
    return _SessionState(
      info: info ?? this.info,
      messages: messages ?? this.messages,
      initialized: initialized ?? this.initialized,
      blockInput: blockInput ?? this.blockInput,
      sendError: sendError ?? this.sendError,
      textController: textController ?? this.textController,
      showSend: showSend ?? this.showSend,
      typing: typing ?? this.typing,
    );
  }
}

class _SessionCubit extends Cubit<_SessionState> {
  late GlideSession session;
  List<StreamSubscription> sps = [];
  StreamController tc = StreamController();

  _SessionCubit(GlideSessionInfo info) : super(_SessionState.initial(info)) {
    init();
  }

  Future init() async {
    session = (await glide.sessionManager.get(state.info.id))!;
    state.textController.addListener(() {
      final text = state.textController.text;
      if (text.isNotEmpty != state.showSend) {
        emit(state.copyWith(showSend: text.isNotEmpty));
      }
      if (session.info.type == SessionType.chat) {
        session.sendTypingEvent();
      }
    });
    final sp = session.messages().listen((event) {
      emit(state.copyWith(messages: [event, ...state.messages]));
    });
    final sp2 = session.onTypingChanged().listen((event) {
      emit(state.copyWith(typing: event));
    });
    sps.add(sp);
    sps.add(sp2);
    final history = await session.history();
    emit(state.copyWith(messages: [...history.reversed]));
  }

  void addEmoji(String emoji) {
    final pos = state.textController.selection.end;
    final text = state.textController.text;
    if (pos < 0) {
      state.textController.text = text + emoji;
      return;
    }
    state.textController.text =
        text.substring(0, pos) + emoji + text.substring(pos);
    state.textController.selection = TextSelection.fromPosition(
      TextPosition(offset: pos + emoji.length),
    );
  }

  void sendMessage() async {
    final content = state.textController.text;
    emit(state.copyWith(
      blockInput: true,
      sendError: "",
    ));
    try {
      await Future.delayed(const Duration(seconds: 1)); // todo test
      await session.sendTextMessage(content);
      state.textController.clear();
    } catch (e) {
      if (e is GlideException) {
        emit(state.copyWith(sendError: e.message));
      } else {
        emit(state.copyWith(sendError: e.toString()));
      }
    } finally {
      emit(state.copyWith(
        blockInput: false,
      ));
    }
  }

  @override
  Future<void> close() async {
    for (var element in sps) {
      element.cancel();
    }
    return super.close();
  }
}
