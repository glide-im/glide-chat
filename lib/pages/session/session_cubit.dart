part of 'session_page.dart';

class _SessionState {
  final GlideSessionInfo info;
  final List<Message> messages;
  final Map<num, num> messageState;
  final bool initialized;
  final bool blockInput;
  final String sendError;
  final TextEditingController textController;
  final bool showSend;
  final bool typing;
  final bool showEmoji;
  final FocusNode focusNode;

  _SessionState({
    required this.messageState,
    required this.info,
    required this.messages,
    required this.initialized,
    required this.blockInput,
    required this.sendError,
    required this.textController,
    required this.showSend,
    required this.typing,
    required this.showEmoji,
    required this.focusNode,
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
        messageState: {},
        showEmoji: false,
        focusNode: FocusNode());
  }

  _SessionState copyWith({
    GlideSessionInfo? info,
    List<Message>? messages,
    Map<num, num>? messageState,
    bool? initialized,
    bool? blockInput,
    String? sendError,
    TextEditingController? textController,
    bool? showSend,
    bool? typing,
    bool? showEmoji,
    FocusNode? focusNode,
  }) {
    return _SessionState(
      info: info ?? this.info,
      messages: messages ?? this.messages,
      messageState: messageState ?? this.messageState,
      initialized: initialized ?? this.initialized,
      blockInput: blockInput ?? this.blockInput,
      sendError: sendError ?? this.sendError,
      textController: textController ?? this.textController,
      showSend: showSend ?? this.showSend,
      typing: typing ?? this.typing,
      showEmoji: showEmoji ?? this.showEmoji,
      focusNode: focusNode ?? this.focusNode,
    );
  }
}

class _SessionCubit extends Cubit<_SessionState> {
  late GlideSession session;
  List<StreamSubscription> sps = [];
  StreamController tc = StreamController();

  final tag = "SessionCubit";

  _SessionCubit(GlideSessionInfo info) : super(_SessionState.initial(info)) {
    init();
  }

  Future init() async {
    session = (await glide.sessionManager.get(state.info.id))!;
    state.focusNode.addListener(() {
      if (state.focusNode.hasFocus) {
        setEmojiVisibility(false);
      }
    });
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
      logd(tag, "typing: $event");
      emit(state.copyWith(typing: event));
    });
    final sp3 = session.messageEvent().listen((event) {
      final index =
          state.messages.indexWhere((m) => m.mid == event.message.mid);
      if (index < 0) {
        return;
      }
      if (state.messageState[event.message.mid] == event.message.status.index) {
        return;
      }
      logd(tag, "message status update: $event");
      state.messageState[event.message.mid] = event.message.status.index;
      state.messages[index] = event.message;
      emit(state.copyWith(
        messages: [...state.messages],
        messageState: {...state.messageState},
      ));
    });
    sps.add(sp);
    sps.add(sp2);
    sps.add(sp3);
    final history = await session.history();
    emit(state.copyWith(
      messages: [...history.reversed],
      initialized: true,
    ));
  }

  void setEmojiVisibility(bool show) {
    emit(state.copyWith(showEmoji: show));
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

  void sendFile(File file) async {
    try {
      final name = file.path.split(Platform.pathSeparator).last;
      final size = await file.length();
      final body = FileMessageBody(
        name: name,
        url: file.path,
        size: size,
        type: FileMessageType.unknown,
      );
      await session.sendFileMessage(body);
    } catch (e, s) {
      logd(tag, s);
    }
  }

  void sendMessage() async {
    final content = state.textController.text;
    emit(state.copyWith(
      blockInput: true,
      sendError: "",
    ));
    try {
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
        showEmoji: false,
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
