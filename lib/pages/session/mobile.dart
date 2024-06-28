part of 'session_page.dart';

class MessageInputMobile extends StatelessWidget {
  const MessageInputMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageInput(
              onEmojiClick: () {
                final cubit = context.read<_SessionCubit>();
                FocusScope.of(context).unfocus();
                cubit.setEmojiVisibility(!cubit.state.showEmoji);
              },
            ),
            BlocBuilder<_SessionCubit, _SessionState>(
              buildWhen: (c, p) => c.showEmoji != p.showEmoji,
              builder: (context, state) {
                if (!state.showEmoji) {
                  return const SizedBox();
                }
                return SizedBox(
                  height: 200,
                  child: EmojiList(
                    onSelected: (e) {
                      context.read<_SessionCubit>().addEmoji(e);
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class SessionBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Session session;

  const SessionBarMobile({
    super.key,
    required this.title,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final statusHeight = MediaQuery.of(context).padding.top;
    return Material(
      color: context.theme.colorScheme.primary,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Padding(
          padding: EdgeInsets.only(top: statusHeight),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              BackButton(color: context.theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: context.theme.colorScheme.onPrimary,
                ),
                child: title,
              ),
              const Spacer(),
              const SizedBox(width: 16),
              SessionMenuButton(id: session.info.id, compat: false),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
