import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

typedef Listener = void Function(
    BuildContext context, Session session, Message message);

class MessageListener extends StatefulWidget {
  final Widget child;
  final Listener listener;

  const MessageListener({
    super.key,
    required this.listener,
    required this.child,
  });

  @override
  State<MessageListener> createState() => _MessageListenerState();
}

class _MessageListenerState extends State<MessageListener> {
  StreamSubscription? sp;

  @override
  void initState() {
    super.initState();
    sp = glide
        .messageStream()
        .where(
          (event) => event.type == 1 && event.from != glide.uid(),
        )
        .listen((event) {
      final id = event.to != glide.uid() ? event.to : event.from;
      final cubit = SessionCubit.of(context);
      if (id == cubit.state.currentSession) return;
      final session = cubit.getSession(id);
      if (session == null) return;
      widget.listener(context, session, event);
    });
  }

  @override
  void dispose() {
    sp?.cancel();
    sp = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
