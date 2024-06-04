part of 'session_page.dart';

class MessageInputMobile extends StatefulWidget {
  const MessageInputMobile({super.key});

  @override
  State<MessageInputMobile> createState() => _MessageInputMobileState();
}

class _MessageInputMobileState extends State<MessageInputMobile> {
  bool showEmoji = false;

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
                setState(() {
                  showEmoji = !showEmoji;
                });
              },
            ),
            if (showEmoji)
              SizedBox(
                height: 200,
                child: EmojiList(
                  onSelected: (e) {
                    context.read<_SessionCubit>().addEmoji(e);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
