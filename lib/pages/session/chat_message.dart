part of 'session_page.dart';

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
    return "${d.hour}:${d.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _avatar(context),
        const SizedBox(width: 8),
        Expanded(child: content(context)),
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
                  builder: (c, info) => Avatar(title: abbr, url: info.avatar),
                ),
              ),
              L: (c) => InkWell(
                onTap: () async {
                  Session? ss =  SessionCubit.of(context).getSession(uid);
                  ss ??=
                      await SessionCubit.of(context).createSession(uid, false);
                  if (!context.mounted) return;
                  SessionCubit.of(context).setCurrentSession(uid);
                },
                child: UserInfoBuilder(
                  uid: uid,
                  builder: (c, info) => Avatar(title: abbr, url: info.avatar),
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

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        UserInfoBuilder(
          uid: uid,
          builder: (c, info) => Text(
            self ? datetime : "${info.name} $datetime",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            status(context),
            const SizedBox(width: 8),
            Flexible(child: messageBox(context)),
          ],
        ),
      ],
    );
  }

  Widget messageBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.theme.primaryColorLight,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: SelectableText(
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
