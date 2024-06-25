part of 'session_page.dart';

class EmojiPopButton extends StatelessWidget {
  final Function(String) onSelected;

  const EmojiPopButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.emoji_emotions_outlined),
      itemBuilder: (c) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Emoji", style: context.theme.textTheme.labelSmall),
              SizedBox(
                width: 700,
                height: 300,
                child: EmojiList(
                  onSelected: (c) {
                    onSelected(c);
                    Navigator.of(context, rootNavigator: false).pop();
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class SessionMenuButton extends StatefulWidget {
  final String id;

  const SessionMenuButton({super.key, required this.id});

  @override
  State<SessionMenuButton> createState() => _SessionMenuButtonState();
}

class _SessionMenuButtonState extends State<SessionMenuButton> {
  late RenderBox rect;
  late Size size;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rect = context.findRenderObject() as RenderBox?;
      final size = rect!.size;
      setState(() {
        this.rect = rect;
        this.size = size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (c, p) => c.sessions[widget.id] != p.sessions[widget.id],
      builder: (c, s) {
        return PopupMenuButton(
          itemBuilder: (BuildContext context) =>
              menus(c, s.sessions[widget.id]!.settings),
          child: const Icon(Icons.more_horiz_rounded),
        );
      },
    );
  }

  menus(BuildContext c, SessionSettings settings) {
    return [
      PopupMenuItem(
        child: const Row(
          children: [
            Icon(Icons.edit_note_rounded),
            SizedBox(width: 12),
            Text("Edit Session")
          ],
        ),
        onTap: () {},
      ),
      PopupMenuItem(
        child: Row(
          children: [
            Icon(!settings.muted
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded),
            const SizedBox(width: 12),
            Text(settings.muted ? "Unmute" : "Mute"),
          ],
        ),
        onTap: () {
           SessionCubit.of(context).updateSessionSettings(
                widget.id,
                settings.copyWith(
                  muted: !settings.muted,
                ),
              );
        },
      ),
      PopupMenuItem(
        child: Row(
          children: [
            Icon(
              settings.pinned <= 0
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
            ),
            SizedBox(width: 12),
            Text(settings.pinned > 0 ? "Unpin" : "Pin")
          ],
        ),
        onTap: () {
          SessionCubit.of(context).updateSessionSettings(
                widget.id,
                settings.copyWith(
                  pinned: settings.pinned > 0
                      ? 0
                      : DateTime.now().millisecondsSinceEpoch,
                ),
              );
        },
      ),
      PopupMenuItem(
        child: Row(
          children: [
            const Icon(Icons.block_rounded),
            SizedBox(width: 12),
            Text(settings.blocked ? "Unblock" : "Block")
          ],
        ),
        onTap: () {
          SessionCubit.of(context).updateSessionSettings(
                widget.id,
                settings.copyWith(
                  blocked: !settings.blocked,
                ),
              );
        },
      ),
      PopupMenuItem(
        child: const Row(
          children: [
            Icon(Icons.delete_rounded),
            SizedBox(width: 12),
            Text("Delete")
          ],
        ),
        onTap: () {},
      ),
    ];
  }
}
