import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_dart_sdk/glide_dart_sdk.dart';

class WithGlideStateText extends StatelessWidget {
  final Widget title;

  const WithGlideStateText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (previous, current) => previous.state != current.state,
      builder: (context, state) {
        String label;
        switch (state.state) {
          case GlideState.init:
            label = "Not Login";
            break;
          case GlideState.disconnected:
            label = "Offline";
            break;
          case GlideState.connecting:
            label = "Connecting...";
            break;
          case GlideState.connected:
            return title;
        }
        return Text(label);
      },
    );
  }
}
