import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/global_cubit.dart';

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

class PlatformAdaptive extends StatelessWidget {
  final Widget? Function(BuildContext context)? mobile;
  final Widget? Function(BuildContext context)? desktop;
  final Widget? Function(BuildContext context)? web;
  final Widget? Function(BuildContext context)? def;

  const PlatformAdaptive(
      {super.key, this.mobile, this.desktop, this.web, this.def});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (c, p) => c.platform != p.platform,
      builder: (context, state) {
        switch (state.platform) {
          case PlatformType.desktop:
            return desktop?.call(context) ?? default_(context);
          case PlatformType.mobile:
            return mobile?.call(context) ?? default_(context);
          case PlatformType.web:
            return web?.call(context) ?? default_(context);
        }
      },
    );
  }

  Widget default_(BuildContext context) {
    return def?.call(context) ?? const SizedBox();
  }
}
