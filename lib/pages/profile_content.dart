import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/model/user_info.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/widget/avatar.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: BlocBuilder<GlobalCubit, GlobalState>(
            buildWhen: (c, p) => c.info != p.info,
            builder: (context, state) {
              return _Header(info: state.info);
            },
          ),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.account_circle_rounded),
          child: const Text("Profile"),
          onPressed: () {
            AppRoutes.userProfile.go(context, arg: "uid");
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.privacy_tip_rounded),
          child: const Text("Privacy"),
          onPressed: () {
            // todo
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.style_rounded),
          child: SizedBox(
            height: 50,
            width: 160,
            child: Row(
              children: [
                const Text("Compact"),
                const Spacer(),
                BlocBuilder<GlobalCubit, GlobalState>(
                  buildWhen: (c, p) => c.compact != p.compact,
                  builder: (context, state) {
                    return Switch(
                        value: state.compact,
                        onChanged: (v) {
                          GlobalCubit.of(context).switchCompact();
                        });
                  },
                )
              ],
            ),
          ),
          onPressed: () {
            GlobalCubit.of(context).switchCompact();
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout_rounded),
          child: const Text("Logout"),
          onPressed: () {
            context.read<GlobalCubit>().logout();
          },
        ),
        const SizedBox(height: 100)
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final UserInfo info;

  const _Header({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Avatar(
              title: info.name,
              url: info.avatar,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            info.name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            "uid:${info.id}",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
