import 'package:flutter/material.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/widget/avatar.dart';
import 'package:glide_chat/widget/user_info.dart';

class UserProfilePage extends StatefulWidget {
  final String id;

  const UserProfilePage({super.key, required this.id});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool notification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.primaryColor,
      ),
      body: Column(
        children: [
          _Header(id: widget.id),
          const SizedBox(height: 12),
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Row(
          //     children: [
          //       Text("Casual User", style: TextStyle(fontSize: 16)),
          //       Spacer(),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text("Notifications", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                    value: notification,
                    onChanged: (v) {
                      setState(() {
                        notification = v;
                      });
                    }),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text("Rule", style: TextStyle(fontSize: 16)),
                Spacer(),
                Text("Friend", style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await SessionCubit.of(context).goSessionOrCreate(context, widget.id);
        },
        child: const Icon(Icons.message_rounded),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String id;

  const _Header({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Container(
          color: context.theme.primaryColor,
          height: 300,
        ),
        UserInfoBuilder(
          uid: id,
          builder: (c, ui) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Avatar(title: ui.name, url: ui.avatar),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ui.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "uid: $id",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
