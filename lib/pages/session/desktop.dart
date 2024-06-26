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

class SessionBarDesktop extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Session session;

  const SessionBarDesktop({
    super.key,
    required this.title,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
          child: title,
        ),
        const Spacer(),
        PlatformAdaptive(
          desktop: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const WindowBarActions(),
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 4),
                child: SessionMenuButton(id: session.info.id, compat: true),
              ),
            ],
          ),
          web: (c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SessionMenuButton(id: session.info.id, compat: false),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
