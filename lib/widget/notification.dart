import 'package:flutter/material.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/avatar.dart';
import 'package:glide_chat/widget/user_info.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';
import 'package:in_app_notification/in_app_notification.dart';

import 'listener.dart';

class AppNotification extends StatelessWidget {
  final Widget child;

  const AppNotification({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      key: const Key('app_notification'),
      child: MessageListener(
        listener: (context, session, message) async {
          await InAppNotification.show(
            duration: const Duration(seconds: 2),
            child: SizedBox(
              width: double.infinity,
              child: Adaptive(
                builder: (c) => body(c, session, message),
                L: (c) => bodyL(c, session, message),
              ),
            ),
            context: context,
            onTap: () {
              SessionCubit.of(context).goSession(context, session.info);
            },
          );
        },
        child: child,
      ),
    );
  }

  Widget body(BuildContext context, Session session, Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: context.theme.cardColor,
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: SessionAvatar(session: session.info),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      session.info.title,
                      style: context.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    session.info.type == SessionType.channel
                        ? UserInfoBuilder(
                            uid: message.from,
                            builder: (c, ci) => Text(
                              "${ci.name}: ${message.content}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Text(
                            message.content,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget bodyL(BuildContext context, Session session, Message message) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.only(top: 64),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: context.theme.primaryColorLight,
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: SessionAvatar(session: session.info),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        session.info.title,
                        style: context.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      session.info.type == SessionType.channel
                          ? UserInfoBuilder(
                        uid: message.from,
                        builder: (c, ci) => Text(
                          "${ci.name}: ${message.content}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                          : Text(
                        message.content,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
