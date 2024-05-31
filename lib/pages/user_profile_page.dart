import 'package:flutter/material.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

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
      appBar: AppBar(elevation: 0, backgroundColor:Colors.green.shade600 ,),
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
          GlideSessionInfo? ss =
              GlobalCubit.of(context).getSession(widget.id)?.info;
          ss ??= await GlobalCubit.of(context).createSession(widget.id, false);
          if (!context.mounted) return;
          AppRoutes.session.go(context, arg: ss);
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
          color: Colors.green.shade600,
          height: 300,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "user nickname",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "uid: $id",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        )
      ],
    );
  }
}
