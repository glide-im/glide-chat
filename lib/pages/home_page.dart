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
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalCubit, GlobalState>(
      bloc: BlocProvider.of<GlobalCubit>(context),
      listenWhen: (previous, current) =>
          previous.initialized != current.initialized,
      listener: (c, s) {
        if (s.info == UserInfo.empty) {
          AppRoutes.login.go(context);
        }
      },
      child: Scaffold(
        body: BlocBuilder<GlobalCubit, GlobalState>(
          buildWhen: (c, p) => c.initialized != p.initialized,
          builder: (context, state) {
            if (!state.initialized) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.info == UserInfo.empty) {
              return const SizedBox();
            }
            return Adaptive(
              builder: (c) => const HomePageMobile(),
              L: (c) => const HomePageDesktop(),
            );
          },
        ),
      ),
    );
  }
}

class HomePageMobile extends StatelessWidget {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        width: 260,
        height: double.infinity,
        color: Colors.white,
        child: const ProfileContent(),
      ),
      appBar: barMobile(),
      floatingActionButton: Adaptive(
        L: (c) => null,
        builder: (c) {
          return BlocBuilder<GlobalCubit, GlobalState>(
            buildWhen: (previous, current) => previous.state != current.state,
            builder: (context, state) {
              if (state.state == GlideState.init) {
                return const SizedBox();
              }
              return FloatingActionButton(
                onPressed: () async {
                  //
                },
                child: const Icon(Icons.add_rounded),
              );
            },
          );
        },
      ),
      body: const SessionListView(),
    );
  }

  AppBar barMobile() {
    return AppBar(
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: const WithGlideStateText(title: Text("Glide")),
    );
  }
}

class HomePageDesktop extends StatelessWidget {
  const HomePageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _SessionListBar(),
              const Divider(),
              Expanded(
                child: BlocBuilder<GlobalCubit, GlobalState>(
                  buildWhen: (c, p) => c.initialized != p.initialized,
                  builder: (context, state) {
                    if (!state.initialized) {
                      return Center(
                        child: IconButton(
                          onPressed: () async {
                            await context.read<GlobalCubit>().login();
                          },
                          icon: const Icon(Icons.replay_circle_filled_rounded),
                        ),
                      );
                    }
                    return const SessionListView();
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: BlocBuilder<GlobalCubit, GlobalState>(
            buildWhen: (c, p) => c.currentSession != p.currentSession,
            builder: (context, state) {
              final session =
                  GlobalCubit.of(context).getSession(state.currentSession);
              if (session == null) {
                return const SizedBox();
              }
              return SessionPage(session: session);
            },
          ),
        )
      ],
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
