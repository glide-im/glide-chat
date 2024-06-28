part of 'session_page.dart';

class MessageInput extends StatelessWidget {
  final VoidCallback? onEmojiClick;

  const MessageInput({super.key, this.onEmojiClick});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.theme.colorScheme.surface,
      child: build2(context),
    );
  }

  Widget build2(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Adaptive(
          builder: (c) {
            return IconButton(
              onPressed: () {
                onEmojiClick?.call();
              },
              icon: BlocBuilder<_SessionCubit, _SessionState>(
                buildWhen: (c, p) => c.showEmoji != p.showEmoji,
                builder: (context, state) {
                  return Icon(state.showEmoji
                      ? Icons.keyboard_hide_rounded
                      : Icons.emoji_emotions_outlined);
                },
              ),
            );
          },
          L: (c) {
            return EmojiPopButton(
              onSelected: (emoji) {
                context.read<_SessionCubit>().addEmoji(emoji);
              },
            );
          },
        ),
        Expanded(child: input()),
        BlocListener<_SessionCubit, _SessionState>(
          listenWhen: (c, p) => c.blockInput != p.blockInput,
          listener: (context, state) {
            if (state.sendError.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.sendError)),
              );
            }
          },
          child: Container(),
        ),
        fileButton(),
        sendButton(),
        voiceButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget input() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) =>
          c.blockInput != p.blockInput || c.focusNode != p.focusNode,
      builder: (context, state) {
        return TextField(
          controller: state.textController,
          enabled: !state.blockInput,
          textInputAction: TextInputAction.send,
          focusNode: state.focusNode,
          decoration: InputDecoration(
            hintText: "Message",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          onSubmitted: (v) {
            context.read<_SessionCubit>().sendMessage();
          },
        );
      },
    );
  }

  Widget sendButton() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) =>
          c.blockInput != p.blockInput || c.showSend != p.showSend,
      builder: (context, state) {
        if (!state.showSend) {
          return const SizedBox();
        }
        return IconButton(
          onPressed: () {
            context.read<_SessionCubit>().sendMessage();
          },
          icon: state.blockInput
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 4),
                )
              : const Icon(Icons.send_rounded),
        );
      },
    );
  }

  Widget fileButton() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) =>
          c.blockInput != p.blockInput || c.showSend != p.showSend,
      builder: (context, state) {
        if (state.showSend) {
          return const SizedBox();
        }
        return IconButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              File file = File(result.files.single.path!);
              logd("tag", file.path);
              if (context.mounted) context.read<_SessionCubit>().sendFile(file);
            } else {
              // User canceled the picker
            }
          },
          icon: state.blockInput
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 4),
                )
              : const Icon(Icons.attach_file_rounded),
        );
      },
    );
  }

  Widget voiceButton() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) =>
          c.blockInput != p.blockInput || c.showSend != p.showSend,
      builder: (context, state) {
        if (state.showSend) {
          return const SizedBox();
        }
        return IconButton(
          onPressed: () {
            //
          },
          icon: state.blockInput
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 4),
                )
              : const Icon(Icons.keyboard_voice_rounded),
        );
      },
    );
  }
}
