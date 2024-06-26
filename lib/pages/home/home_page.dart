import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/bloc/session_state.dart';
import 'package:glide_chat/pages/profile_content.dart';
import 'package:glide_chat/pages/session/session_page.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/session_list.dart';
import 'package:glide_chat/widget/title_bar.dart';
import 'package:glide_chat/widget/window.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

part 'desktop.dart';

part 'mobile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final cubit = GlobalCubit.of(context);
    final sessionCubit = SessionCubit.of(context);
    sessionCubit.init().then((value) => cubit.init()).then((value) {
      if (!cubit.state.logged) {
        logd("HomePage", "not logged in");
        AppRoutes.login.go(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (c, p) =>
          c.initialized != p.initialized || c.logged != p.logged,
      builder: (ctx, state) {
        if (!state.initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!state.logged) {
          return const Center(child: CircularProgressIndicator());
        }
        return Adaptive(
          builder: (c) => HomePageMobile(),
          L: (c) => HomePageDesktop(),
        );
      },
    );
  }
}

class _SessionListBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _SessionListBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu_rounded)),
          const SizedBox(width: 12),
          const Expanded(
            child: WithGlideStateText(
              title: Text(
                "Glide Chat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
