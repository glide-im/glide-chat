part of 'session_page.dart';

final today = DateTime.now().copyWith(
  hour: 0,
  minute: 0,
  second: 0,
  millisecond: 0,
);
final yesterday = today.add(const Duration(days: -1));
final day2Ago = today.add(const Duration(days: -2));
final day3Ago = today.add(const Duration(days: -3));

String getDisplayTime(DateTime d) {
  if (d.isBefore(day3Ago)) {
    return d.toIso8601String().substring(11, 16);
  }
  if (d.isBefore(day2Ago)) {
    return "2 days ago";
  }
  if (d.isBefore(today)) {
    return "Yesterday at ${d.toIso8601String().substring(11, 16)}";
  }
  return d.toIso8601String().substring(11, 16);
}

class _ChatMessage extends StatelessWidget {
  final Message message;
  final SessionType type;

  const _ChatMessage({super.key, required this.message, required this.type});

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
        _avatar(context),
        const SizedBox(width: 8),
        Expanded(child: _messageBody(context)),
        const SizedBox(width: 8),
        if (!self)
          const SizedBox(
            height: 40,
            width: 40,
          ),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    return SizedBox(
      key: ValueKey(uid),
      height: 40,
      width: 40,
      child: self
          ? null
          : Adaptive(
              builder: (c) => InkWell(
                onTap: () {
                  AppRoutes.userProfile.go(context, arg: message.from);
                },
                child: UserInfoBuilder(
                  uid: uid,
                  builder: (c, info) => Avatar(
                    key: ValueKey(info.id),
                    title: abbr,
                    url: info.avatar,
                  ),
                ),
              ),
              L: (c) => InkWell(
                onTap: () async {
                  Session? ss = SessionCubit.of(context).getSession(uid);
                  ss ??=
                      await SessionCubit.of(context).createSession(uid, false);
                  if (!context.mounted) return;
                  SessionCubit.of(context).setCurrentSession(uid);
                },
                child: UserInfoBuilder(
                  uid: uid,
                  builder: (c, info) => Avatar(
                    key: ValueKey(info.id),
                    title: abbr,
                    url: info.avatar,
                  ),
                ),
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
        if (type == SessionType.channel) return const SizedBox();
        return const Icon(Icons.check_rounded, color: Colors.green, size: 18);
      case MessageStatus.received:
        if (type == SessionType.channel) return const SizedBox();
        return const Icon(Icons.done_all_outlined,
            color: Colors.green, size: 18);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline_rounded,
            color: Colors.red, size: 18);
      default:
        return const SizedBox();
    }
  }

  Widget _messageBody(BuildContext context) {
    return Column(
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            status(context),
            if (self) const SizedBox(width: 4),
            Flexible(child: messageBox(context)),
          ],
        ),
        UserInfoBuilder(
          uid: uid,
          builder: (c, info) => Text(
            self ? datetime : "${info.name} $datetime",
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget messageBox(BuildContext context) {
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
      child: textContent(),
    );
  }

  Widget imageContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
        minWidth: 100,
        maxWidth: 300,
        maxHeight: 200,
      ),
      child: Image.network(
        message.content,
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

  Widget textContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: SelectableText(
        contextMenuBuilder: null,
        displayMessage,
      ),
    );
  }
}

class _ChipMessage extends StatelessWidget {
  final GlideChatMessage message;

  const _ChipMessage({super.key, required this.message});

  bool get self => message.content == glide.uid();

  String get content {
    switch (message.type) {
      case 100:
        return "${self ? "you" : message.content} joined the chat";
      case 101:
        return "${self ? "you" : message.content} left to chat";
      default:
        return "${message.type}-${message.content}";
    }
  }

  bool get isSystem => message.type == 100 || message.type == 101;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.only(top: 2, left: 8, right: 8, bottom: 4),
        decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(18)),
        child: !isSystem
            ? Text(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )
            : UserInfoBuilder(
                uid: message.content,
                builder: (c, info) {
                  return Text(
                    "${self ? "you" : info.name} ${message.type == 100 ? 'joined' : 'left'} the chat",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
      ),
    );
  }
}
