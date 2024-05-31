import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/global_cubit.dart';

class Adaptive extends StatelessWidget {
  final Widget? Function(BuildContext context)? S;
  final Widget? Function(BuildContext context)? L;
  final Widget? Function(BuildContext context) builder;

  const Adaptive({super.key, this.S, this.L, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (c, p) => c.compact != p.compact,
      builder: (context, state) {
        final b = state.compact ? S : L;
        if (b != null) {
          return b(context) ?? const SizedBox();
        }
        return builder(context) ?? const SizedBox();
      },
    );
  }
}