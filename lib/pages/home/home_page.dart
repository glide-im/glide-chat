import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/extensions.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/model/user_info.dart';
import 'package:glide_chat/pages/profile_content.dart';
import 'package:glide_chat/pages/session/session_page.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/dialog.dart';
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
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    initApp().then((value) {
      setState(() {
        loading = false;
      });
    }).catchError((e) {
      setState(() {
        error = e.toString();
      });
    });
  }

  Future initApp() async {
    final state = await GlobalCubit.of(context)
        .init()
        .timeout(const Duration(seconds: 10));
    if (state.info == UserInfo.empty) {
      if (context.mounted) AppRoutes.login.go(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (error.isNotEmpty) Text(error)
          ],
        ),
      );
    }
    return Adaptive(
      builder: (c) => const HomePageMobile(),
      L: (c) => const HomePageDesktop(),
    );
  }
}

class _SessionListBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                showBottomSheet(
                  elevation: 9,
                  context: context,
                  backgroundColor:
                      context.theme.bottomSheetTheme.backgroundColor,
                  builder: (c) => const BottomSheetWrap(
                    child: ProfileContent(),
                  ),
                );
              },
              icon: const Icon(Icons.menu_rounded)),
          const SizedBox(width: 12),
          const Expanded(child: WithGlideStateText(title: Text("Glide"))),
        ],
      ),
    );
  }
}
