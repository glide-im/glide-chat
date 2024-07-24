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
  final VoidCallback onTitleTap;

  const SessionBarDesktop({
    super.key,
    required this.title,
    required this.session,
    required this.onTitleTap,
  });

  bool get isChannel => session.info.type == SessionType.channel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(width: 16),
            titleBlock(context),
            const Spacer(),
            actionBlock(),
          ],
        ),
        const Spacer(),
        const Divider(),
      ],
    );
  }

  Widget actionBlock() {
    return PlatformAdaptive(
      desktop: (c) => Column(
        mainAxisSize: MainAxisSize.max,
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
    );
  }

  Widget titleBlock(BuildContext context) {
    return GestureDetector(
      onTap: onTitleTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ) ??
                  const TextStyle(),
              child: title,
            ),
            if (isChannel)
              Text("100 members", style: context.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
