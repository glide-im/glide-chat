import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/app.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/bloc/session_cubit.dart';
import 'package:glide_chat/widget/window.dart';
import 'package:glide_chat/widget/window_draggable.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WindowManager w = WindowManager.instance;
  await w.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    title: "Glide Chat",
    titleBarStyle: TitleBarStyle.hidden,
    skipTaskbar: false,
    windowButtonVisibility: true,
  );
  w.waitUntilReadyToShow(windowOptions, () async {
    // await w.setMinimumSize(const Size(700, 500));
    await w.setMinimumSize(const Size(300, 400));
    await w.setBackgroundColor(Colors.transparent);
    await w.show();
    await w.focus();
    if (Platform.isWindows) {
      await w.setAsFrameless();
    }
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => GlobalCubit()),
        BlocProvider(create: (ctx) => SessionCubit()),
      ],
      child: const DesktopWindow(
        child: WindowDraggable(child: GlideApp()),
      ),
    ),
  );
}
