import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/model/chat_info.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/avatar.dart';
import 'package:glide_chat/widget/emoji.dart';
import 'package:glide_chat/widget/title_bar.dart';
import 'package:glide_chat/widget/user_info.dart';
import 'package:glide_chat/widget/window.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

part 'chat_message.dart';

part 'desktop.dart';

part 'message_input.dart';

part 'mobile.dart';

part 'session_cubit.dart';

class SessionPage extends StatefulWidget {
  final Session session;

  const SessionPage({super.key, required this.session});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late SessionCubit cubit;
  bool exitSessionOnDispose = true;

  @override
  void initState() {
    setState(() {
      exitSessionOnDispose =
          GlobalCubit.of(context).state.platform == PlatformType.mobile;
      cubit = SessionCubit.of(context);
      cubit.setCurrentSession(widget.session.info.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (exitSessionOnDispose) {
      cubit.setCurrentSession("");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_SessionCubit>(
      key: ValueKey(widget.session),
      create: (context) => _SessionCubit(widget.session.info),
      child: _SessionPage(
        key: ValueKey(widget.session),
        session: widget.session,
      ),
    );
  }
}

class _SessionPage extends StatelessWidget {
  final Session session;

  const _SessionPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Adaptive(
      builder: (c) => build2(c, true),
      L: (c) => build2(c, false),
    );
  }

  Widget build2(BuildContext context, bool compact) {
    return Scaffold(
      appBar: titleBar(context, compact),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/bg_chat.jpg",
            repeat: ImageRepeat.repeat,
          ),
          body(context),
        ],
      ),
    );
  }

  PreferredSizeWidget titleBar(BuildContext context, bool compact) {
    if (compact) {
      return SessionBarMobile(title: title(), session: session);
    } else {
      return SessionBarDesktop(
        key: Key(session.info.id),
        title: title(),
        session: session,
      );
    }
  }

  Widget title() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) => c.info.title != p.info.title,
      builder: (context, state) {
        return WithGlideStateText(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(state.info.title),
              const SizedBox(width: 12),
              typingState(),
            ],
          ),
        );
      },
    );
  }

  Widget typingState() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) => c.typing != p.typing,
      builder: (context, state) {
        if (!state.typing) {
          return const SizedBox();
        }
        return Text(
          "Typing...",
          style: TextStyle(
            fontSize: 10,
            color: context.theme.colorScheme.onPrimary,
          ),
        );
      },
    );
  }

  Widget body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              context.read<_SessionCubit>().setEmojiVisibility(false);
            },
            child: BlocBuilder<_SessionCubit, _SessionState>(
              buildWhen: (c, p) => c.messages != p.messages,
              builder: (context, state) {
                if (!state.initialized) {
                  return const SizedBox();
                }
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet...",
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  );
                }
                return SessionMessageList(
                  messages: state.messages,
                  sessionType: session.info.type,
                );
              },
            ),
          ),
        ),
        Adaptive(
          builder: (c) => const MessageInputMobile(),
          L: (c) => const MessageInput(),
        )
      ],
    );
  }
}

class SessionMessageList extends StatelessWidget {
  final List<Message> messages;
  final SessionType sessionType;

  const SessionMessageList({
    super.key,
    required this.messages,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      reverse: true,
      itemBuilder: (ctx, index) {
        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: item(msg),
        );
      },
    );
  }

  Widget item(Message msg) {
    switch (msg.type) {
      case ChatMessageType.enter:
      case ChatMessageType.leave:
        return _Chip(message: msg);
      default:
        return BlocBuilder<_SessionCubit, _SessionState>(
          buildWhen: (c, p) =>
              c.messageState[msg.mid] != p.messageState[msg.mid],
          builder: (context, state) {
            return _ChatMessage(
              key: ValueKey(msg),
              message: msg,
              sessionType: sessionType,
            );
          },
        );
    }
  }
}

class SessionMenuButton extends StatelessWidget {
  final String id;
  final bool compat;

  const SessionMenuButton({super.key, required this.id, required this.compat});

  @override
  Widget build(BuildContext context) {
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fixedSize: const MaterialStatePropertyAll(null),
          minimumSize: const MaterialStatePropertyAll(Size.zero),
          iconColor: MaterialStateProperty.all(
            context.theme.colorScheme.onPrimary,
          ),
        ),
      ),
      child: BlocBuilder<SessionCubit, SessionState>(
        buildWhen: (c, p) => c.sessionVersion != p.sessionVersion,
        builder: (c, s) {
          return PopupMenuButton(
            itemBuilder: (ctx) => menus(ctx, s.sessions[id]!.settings),
            iconSize: compat ? 18 : null,
          );
        },
      ),
    );
  }

  menus(BuildContext context, SessionSettings settings) {
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
            Icon(settings.muted
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded),
            const SizedBox(width: 12),
            Text(settings.muted ? "Unmute" : "Mute"),
          ],
        ),
        onTap: () {
          SessionCubit.of(context).toggleMute(id);
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
            const SizedBox(width: 12),
            Text(settings.pinned > 0 ? "Unpin" : "Pin")
          ],
        ),
        onTap: () {
          SessionCubit.of(context).togglePin(id);
        },
      ),
      PopupMenuItem(
        child: Row(
          children: [
            const Icon(Icons.block_rounded),
            const SizedBox(width: 12),
            Text(settings.blocked ? "Unblock" : "Block")
          ],
        ),
        onTap: () {
          SessionCubit.of(context).toggleBlock(id);
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
        onTap: () {
          SessionCubit.of(context).deleteSession(id);
        },
      ),
    ];
  }
}
