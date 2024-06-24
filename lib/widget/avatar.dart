import 'package:flutter/material.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/model/chat_info.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class Avatar extends StatelessWidget {
  final String title;
  final String url;

  const Avatar({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: url.trim().isEmpty
          ? ColoredBox(
              color: context.theme.primaryColor,
              child: Center(
                child: Text(
                  title.length < 2 ? title : title.substring(0, 2),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          : Image.network(url.trim().replaceAll("/svg", "/jpg"), filterQuality: FilterQuality.medium),
    );
  }
}

class SessionAvatar extends StatefulWidget {
  final GlideSessionInfo session;

  const SessionAvatar({super.key, required this.session});

  @override
  State<SessionAvatar> createState() => _SessionAvatarState();
}

class _SessionAvatarState extends State<SessionAvatar> {
  String name = "";
  String url = "";
  ChatInfo? chatInfo;

  @override
  void initState() {
    setState(() {
      name = widget.session.title;
    });
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      try {
        final info = await ChatInfoManager.load(
          widget.session.type == SessionType.channel,
          widget.session.id,
        );
        setState(() {
          chatInfo = info;
        });
      } catch (e) {
        loge("_SessionAvatarState", e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Avatar(
      title: chatInfo?.name ?? widget.session.id,
      url: chatInfo?.avatar ?? "",
    );
  }
}
