import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_chat/utils/extensions.dart';

import 'avatar.dart';

class SessionListView extends StatefulWidget {
  const SessionListView({super.key});

  @override
  State<SessionListView> createState() => _SessionListViewState();
}

class _SessionListViewState extends State<SessionListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: BlocBuilder<SessionCubit, SessionState>(
        buildWhen: (c, p) =>
            c.sessionVersion != p.sessionVersion ||
            c.initialized != p.initialized,
        builder: (context, state) {
          if (!state.initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sessions.isEmpty) {
            return const Center(
              child: Text("No sessions yet...", style: TextStyle(fontSize: 16)),
            );
          }
          final sessions = state.sessionListSorted();
          final key = sessions.map((e) => e.info.id).join();
          return ListView.builder(
            key: Key(key),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return BlocBuilder<SessionCubit, SessionState>(
                buildWhen: (c, p) =>
                    c.currentSession != p.currentSession &&
                    (c.currentSession == session.info.id ||
                        p.currentSession == session.info.id),
                builder: (context, state) {
                  return _Session(
                    session: session,
                    selected: state.currentSession == session.info.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Session extends StatelessWidget {
  final Session session;
  final bool selected;

  const _Session({required this.session, required this.selected});

  String get updateAt {
    final date = DateTime.fromMicrosecondsSinceEpoch(
        session.info.updateAt.toInt() * 1000);
    if (date.isToday()) {
      return date.timeString();
    } else if (date.isYesterday()) {
      return "Yesterday";
    } else {
      return date.dateString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? color = selected ? context.theme.primaryColorLight : null;
    if (session.settings.pinned > 0 && color == null) {
      color = context.theme.hoverColor.withAlpha(8);
    }
    return GestureDetector(
      onSecondaryTap: () {
        // show menu
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
          child: build2(context),
        ),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        isThreeLine: false,
        leading: SizedBox(
          height: 40,
          width: 40,
          child: SessionAvatar(session: session.info),
        ),
        trailing: trailing(context),
        title: Text(
          session.info.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          session.info.lastMessage,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
      onTap: () {
        SessionCubit.of(context).goSession(context, session.info);
      },
    );
  }

  Widget? trailing(BuildContext context) {
    Widget? badge;
    if (session.settings.blocked) {
      badge = const Icon(Icons.block, color: Colors.grey, size: 16);
    } else {
      if (session.settings.muted) {
        badge = const Icon(Icons.volume_off, color: Colors.grey, size: 16);
      } else {
        final unread = session.info.unread;
        badge = unread > 0 ? _UnreadCount(count: unread) : null;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          updateAt,
          style: TextStyle(
            fontSize: 12,
            color: context.theme.hintColor,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (session.settings.pinned > 0)
                const Icon(Icons.push_pin, color: Colors.grey, size: 16),
              if (badge != null) badge,
            ],
          ),
        ),
      ],
    );
  }
}

class _UnreadCount extends StatelessWidget {
  final num count;

  const _UnreadCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
          const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          "$count",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
