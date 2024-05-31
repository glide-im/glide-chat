import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/extensions.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/avatar.dart';
import 'package:glide_chat/widget/emoji.dart';
import 'package:glide_chat/widget/title_bar.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

import 'desktop.dart';

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
    if (!compact) {
      return body();
    }
    return Scaffold(
      appBar: AppBar(
        title: title(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          )
        ],
      ),
      body: body(),
    );
  }

  Widget title() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) => c.info.title != p.info.title,
      builder: (context, state) {
        return WithGlideStateText(title: Text(state.info.title));
      },
    );
  }

  Widget body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Adaptive(
          builder: (c) => const SizedBox(),
          L: (c) => SessionTitleBar(title: title(), session: session),
        ),
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
          builder: (c) => Material(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MessageInput(),
                  SizedBox(
                    height: 200,
                    child: EmojiList(
                      onSelected: (e) {
                        //
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          L: (c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: _MessageInput(),
          ),
        )
      ],
    );
  }

  Widget messages(List<GlideChatMessage> messages) {
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
                _ChatMessage(message: msg)
              else
                _ChipMessage(message: msg),
            ],
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1),
        ),
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final GlideChatMessage message;

  const _ChatMessage({super.key, required this.message});

  String get content => message.content.toString();

  bool get self => message.from == glide.uid();

  String get uid => message.from;

  String get abbr => message.from.substring(0, 2);

  String get leading {
    final d = DateTime.fromMillisecondsSinceEpoch(message.sendAt.toInt());
    return "${message.from}  ${d.hour}:${d.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: self
              ? null
              : InkWell(
                  onTap: self
                      ? null
                      : () {
                          AppRoutes.userProfile.go(context, arg: message.from);
                        },
                  child: Avatar(title: abbr, url: ""),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Align(
            alignment: self ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment:
                  self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  leading,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColorLight,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(content),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!self)
          const SizedBox(
            height: 40,
            width: 40,
          ),
      ],
    );
  }
}

class _MessageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Adaptive(builder: (c) {
          return IconButton(
            onPressed: () {
              //
            },
            icon: const Icon(Icons.emoji_emotions_outlined),
          );
        }, L: (c) {
          return EmojiPopButton(
            onSelected: (emoji) {
              context.read<_SessionCubit>().addEmoji(emoji);
            },
          );
        }),
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
        BlocBuilder<_SessionCubit, _SessionState>(
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
        ),
      ],
    );
  }

  Widget input() {
    return BlocBuilder<_SessionCubit, _SessionState>(
      buildWhen: (c, p) => c.blockInput != p.blockInput,
      builder: (context, state) {
        return TextField(
          controller: state.textController,
          enabled: !state.blockInput,
          textInputAction: TextInputAction.send,
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
}
