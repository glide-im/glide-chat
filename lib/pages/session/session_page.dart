import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/extensions.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/avatar.dart';
import 'package:glide_chat/widget/emoji.dart';
import 'package:glide_chat/widget/title_bar.dart';
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
  late GlobalCubit cubit;

  @override
  void initState() {
    setState(() {
      cubit = GlobalCubit.of(context);
      cubit.setCurrentSession(widget.session.info.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    cubit.setCurrentSession("");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_SessionCubit>(
      key: ValueKey(widget.session),
      create: (context) => _SessionCubit(widget.session.info),
      child: _SessionPage(session: widget.session),
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
      body: body(),
    );
  }

  PreferredSizeWidget titleBar(BuildContext context, bool compact) {
    if (compact) {
      return AppBar(
        title: title(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          )
        ],
      );
    } else {
      return PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Row(
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
              child: title(),
            ),
            const Spacer(),
            PlatformAdaptive(
              desktop: (c) => IconTheme(
                data: const IconThemeData(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const WindowBarActions(),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SessionMenuButton(id: session.info.id),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              web: (c) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SessionMenuButton(id: session.info.id),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget title() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) => c.info.title != p.info.title,
      builder: (context, state) {
        return WithGlideStateText(
          title: Row(
            children: [
              Text(state.info.title),
              const SizedBox(width: 12),
              BlocBuilder<_SessionCubit, _SessionState>(
                buildWhen: (c, p) => c.typing != p.typing,
                builder: (context, state) {
                  if (!state.typing) {
                    return const SizedBox();
                  }
                  return Text(
                    "Typing...",
                    style: context.textTheme.labelMedium,
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: BlocBuilder<_SessionCubit, _SessionState>(
            buildWhen: (c, p) => c.messages != p.messages,
            builder: (context, state) {
              if (state.messages.isEmpty) {
                return const Center(
                  child: Text("No messages yet..."),
                );
              }
              return messages(state.messages);
            },
          ),
        ),
        Adaptive(
          builder: (c) => const MessageInputMobile(),
          L: (c) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: MessageInput(),
          ),
        )
      ],
    );
  }

  Widget messages(List<Message> messages) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: messages.length,
        reverse: true,
        itemBuilder: (ctx, index) {
          final msg = messages[index];
          return Column(
            children: [
              const SizedBox(height: 12),
              if (msg.type == 1 || msg.type == 11)
                BlocBuilder<_SessionCubit, _SessionState>(
                  buildWhen: (c, p) =>
                      c.messageState[msg.mid] != p.messageState[msg.mid],
                  builder: (context, state) {
                    return _ChatMessage(message: msg, type: session.info.type);
                  },
                )
              else
                _ChipMessage(message: msg),
            ],
          );
        },
      ),
    );
  }
}
