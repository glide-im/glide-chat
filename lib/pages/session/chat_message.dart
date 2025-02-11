part of 'session_page.dart';

String getDisplayTime(DateTime d) {
  if (d.isToday()) {
    return d.timeString();
  } else if (d.isYesterday()) {
    return "Yesterday ${d.timeString()}";
  } else {
    return d.dateString();
  }
}

class _ChatMessage extends StatelessWidget {
  final Message message;
  final SessionType sessionType;

  const _ChatMessage({
    super.key,
    required this.message,
    required this.sessionType,
  });

  String get displayMessage => message.content.toString();

  bool get self => message.from == glide.uid();

  String get uid => message.from;

  String get abbr => message.from.substring(0, 2);

  String get datetime {
    final d = DateTime.fromMillisecondsSinceEpoch(message.sendAt.toInt());
    return getDisplayTime(d);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!self) _ChatMessageAvatar(uid: uid),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  status(context),
                  if (self) const SizedBox(width: 4),
                  Flexible(
                    child: ChatMessageContainer(
                      self: self,
                      child: body(),
                    ),
                  ),
                ],
              ),
              infoText(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (!self) const SizedBox(height: 40, width: 40),
      ],
    );
  }

  Widget body() {
    switch (message.type) {
      case ChatMessageType.text:
      case ChatMessageType.markdown:
        return _TextBody(text: message.content.toString());
      case ChatMessageType.file:
        return _FileBody(content: message.content);
      case ChatMessageType.image:
        return _ImageBody(image: message.content);
      case ChatMessageType.voice:
        return _VoiceBody(content: message.content);
      default:
        return _UnknownBody(message: message);
    }
  }

  Widget infoText() {
    return UserInfoBuilder(
      key: ValueKey(uid),
      uid: uid,
      builder: (c, info) => Text(
        self ? datetime : "${info.name} $datetime",
        style: c.textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget status(BuildContext context) {
    if (!self) return const SizedBox();
    switch (message.status) {
      case MessageStatus.pending:
        return const Icon(Icons.access_time_outlined, size: 18);
      case MessageStatus.sent:
        if (sessionType == SessionType.channel) return const SizedBox();
        return const Icon(Icons.check_rounded, color: Colors.green, size: 18);
      case MessageStatus.received:
        if (sessionType == SessionType.channel) return const SizedBox();
        return const Icon(Icons.done_all_outlined,
            color: Colors.green, size: 18);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline_rounded,
            color: Colors.red, size: 18);
      default:
        return const SizedBox();
    }
  }
}

class _VoiceBody extends StatelessWidget {
  final dynamic content;

  const _VoiceBody({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _FileBody extends StatefulWidget {
  final dynamic content;

  const _FileBody({super.key, required this.content});

  @override
  State<_FileBody> createState() => _FileBodyState();
}

class _FileBodyState extends State<_FileBody> {
  FileMessageBody? body;

  String get sizeDisplay {
    if (body == null) return "-";
    if (body!.size < 1024) {
      return "${body!.size} bytes";
    }
    if (body!.size < 1024 * 1024) {
      return "${(body!.size / 1024).toStringAsFixed(2)} KB";
    }
    return "${(body!.size / 1024 / 1024).toStringAsFixed(2)} MB";
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      body = FileMessageBody.fromMap(widget.content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surface,
      key: ValueKey(widget.content),
      // constraints: const BoxConstraints(maxWidth: 200),
      width: 140,
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12, left: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  body?.name ?? "Unknown",
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sizeDisplay,
                  style: context.theme.textTheme.bodySmall,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget icon() {
    switch (body?.type) {
      case FileMessageType.document:
        return const Icon(Icons.insert_drive_file_rounded, size: 48);
      case FileMessageType.audio:
        return const Icon(Icons.audiotrack_rounded, size: 48);
      case FileMessageType.video:
        return const Icon(Icons.videocam_rounded, size: 48);
      case FileMessageType.image:
        return const Icon(Icons.image_rounded, size: 48);
      default:
        return const Icon(Icons.file_present_rounded, size: 48);
    }
  }
}

class _TextBody extends StatelessWidget {
  final String text;

  const _TextBody({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: SelectableText(
        // contextMenuBuilder: null,
        text,
      ),
    );
  }
}

class _UnknownBody extends StatelessWidget {
  final Message message;

  const _UnknownBody({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Text(
        "Unknown Message Type",
        style: context.theme.textTheme.bodySmall,
      ),
    );
  }
}

class _ImageBody extends StatelessWidget {
  final String image;

  const _ImageBody({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
        minWidth: 100,
        maxWidth: 300,
        maxHeight: 200,
      ),
      child: Image.network(
        image,
        errorBuilder: (c, w, e) => Icon(
          Icons.error_outline_rounded,
          color: c.theme.colorScheme.error,
        ),
        loadingBuilder: (c, w, e) {
          return Stack(
            alignment: Alignment.center,
            children: [
              w,
              if (e != null) const CircularProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}

class ChatMessageContainer extends StatelessWidget {
  final Widget child;
  final bool self;

  const ChatMessageContainer({
    super.key,
    required this.self,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(16);
    return Material(
      borderRadius: self
          ? const BorderRadius.only(
              topRight: r,
              topLeft: Radius.circular(6),
              bottomLeft: r,
              bottomRight: Radius.circular(2),
            )
          : const BorderRadius.only(
              topLeft: r,
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(2),
              bottomRight: r,
            ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: context.theme.primaryColorLight,
      elevation: 1,
      child: child,
    );
  }
}

class _ChatMessageAvatar extends StatelessWidget {
  final String uid;

  const _ChatMessageAvatar({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey(uid),
      height: 40,
      width: 40,
      child: Adaptive(
        builder: (c) => InkWell(
          onTap: () {
            AppRoutes.userProfile.go(context, arg: uid);
          },
          child: UserInfoBuilder(
            uid: uid,
            builder: (c, info) => Avatar(
              key: ValueKey(info.id),
              title: info.name,
              url: info.avatar,
            ),
          ),
        ),
        L: (c) => InkWell(
          onTap: () async {
            Session? ss = SessionCubit.of(context).getSession(uid);
            ss ??= await SessionCubit.of(context).createSession(uid, false);
            if (!context.mounted) return;
            SessionCubit.of(context).setCurrentSession(uid);
          },
          child: UserInfoBuilder(
            uid: uid,
            builder: (c, info) => Avatar(
              key: ValueKey(info.id),
              title: info.name,
              url: info.avatar,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatefulWidget {
  final Message message;

  const _Chip({super.key, required this.message});

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  String content = "";
  ChatInfo? chatInfo;

  bool get self => widget.message.content == glide.uid();

  bool get isLeaveEnter =>
      widget.message.type == ChatMessageType.leave ||
      widget.message.type == ChatMessageType.enter;

  @override
  void initState() {
    super.initState();
    updateContent();
    if (isLeaveEnter) {
      chatInfo = ChatInfoManager.get(false, widget.message.content);
      if (chatInfo == null) {
        ChatInfoManager.loadOrUnknown(false, widget.message.content).then((value) {
          setState(() {
            chatInfo = value;
          });
          updateContent();
        });
      }
    }
  }

  void updateContent() {
    if (isLeaveEnter) {
      setState(() {
        if (widget.message.type == ChatMessageType.enter) {
          content = "${self ? "you" : widget.message.content} joined the chat";
        } else {
          content = "${self ? "you" : widget.message.content} left to chat";
        }
      });
    } else {
      content = "${widget.message.type}-${widget.message.content}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.only(top: 2, left: 8, right: 8, bottom: 4),
        decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(18)),
        child: Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
