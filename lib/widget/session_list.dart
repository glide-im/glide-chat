import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

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
      child: BlocBuilder<GlobalCubit, GlobalState>(
        buildWhen: (c, p) => c.sessionVersion != p.sessionVersion,
        builder: (context, state) {
          if (state.sessions.isEmpty) {
            return const Center(
              child: Text("No sessions yet...", style: TextStyle(fontSize: 16)),
            );
          }
          final sessions = state.sessions.values.toList();
          sessions.sort((a, b) => (b.info.updateAt - a.info.updateAt).toInt());

          final key = sessions.map((e) => e.info.id).join();
          return ListView.builder(
            key: Key(key),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return BlocBuilder<GlobalCubit, GlobalState>(
                buildWhen: (c, p) =>
                    c.currentSession != p.currentSession &&
                    (c.currentSession == session.info.id ||
                        p.currentSession == session.info.id),
                builder: (context, state) {
                  return _Session(
                    session: session.info,
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
  final GlideSessionInfo session;
  final bool selected;

  const _Session({required this.session, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: () {
        // show menu
      },
      child: ColoredBox(
        color: selected ? context.theme.primaryColorLight : Colors.transparent,
        child: build2(context),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return InkWell(
      child: ListTile(
        isThreeLine: false,
        leading: SizedBox(
          height: 40,
          width: 40,
          child: SessionAvatar(session: session),
        ),
        trailing:
            session.unread > 0 ? _UnreadCount(count: session.unread) : null,
        title: Text(
          session.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          session.lastMessage,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
      onTap: () {
        final cubit = GlobalCubit.of(context);
        if (cubit.state.compact) {
          AppRoutes.session.go(context, arg: cubit.getSession(session.id)!);
        } else {
          GlobalCubit.of(context).setCurrentSession(session.id);
        }
      },
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
