import 'package:flutter/material.dart';
import 'package:glide_chat/cache/app_cache.dart';
import 'package:glide_chat/model/chat_info.dart';
import 'package:glide_chat/utils/logger.dart';

class UserInfoBuilder extends StatefulWidget {
  final Function(BuildContext context, ChatInfo info) builder;
  final String uid;

  const UserInfoBuilder({super.key, required this.uid, required this.builder});

  @override
  State<UserInfoBuilder> createState() => _UserInfoBuilderState();
}

class _UserInfoBuilderState extends State<UserInfoBuilder> {
  late ChatInfo info = const ChatInfo(id: "", name: "", avatar: "", lastSee: 0);

  @override
  void initState() {
    final ci = ChatInfoManager.get(false, widget.uid);
    setState(() {
      info = ChatInfo(
        id: widget.uid,
        name: ci?.name ?? widget.uid,
        avatar: ci?.avatar ?? "",
        lastSee: ci?.lastSee ?? 0,
      );
    });
    if (ci == null) {
      ChatInfoManager.load(false, widget.uid).then((value) {
        setState(() {
          info = value;
        });
      }).catchError((e) {
        loge("_UserInfoBuilderState", e);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, info);
  }
}
