import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/extensions.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/widget/emoji.dart';
import 'package:glide_chat/widget/title_bar.dart';

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

class SessionTitleBar extends StatelessWidget {
  final Widget title;
  final Session session;

  const SessionTitleBar(
      {super.key, required this.title, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DefaultTextStyle(
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
            child: WithGlideStateText(title: title),
          ),
          const Spacer(),
          _MenuButton(id: session.info.id)
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String id;

  const _MenuButton({required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (c, p) => c.sessions[id] != p.sessions[id],
      builder: (c, s) {
        final settings = s.sessions[id]!.settings;
        return PopupMenuButton(itemBuilder: (c) {
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
                c.read<GlobalCubit>().updateSessionSettings(
                      id,
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
                    settings.pinned > 0
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                  ),
                  SizedBox(width: 12),
                  Text(settings.pinned > 0 ? "Unpin" : "Pin")
                ],
              ),
              onTap: () {
                c.read<GlobalCubit>().updateSessionSettings(
                      id,
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
                c.read<GlobalCubit>().updateSessionSettings(
                      id,
                      settings.copyWith(
                        muted: !settings.blocked,
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
        });
      },
    );
  }
}
