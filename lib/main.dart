import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';

void main() {
  runApp(
    BlocProvider<GlobalCubit>(
      create: (context) => GlobalCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final rb = context.findRenderObject() as RenderBox?;
    if (rb?.hasSize == true) {
      logd("tag", "width: ${rb!.size.width}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Adaptive(
      builder: (c) => build2(context, true),
      L: (c) => build2(context, false),
    );
  }

  Widget build2(BuildContext context, bool compact) {
    return MaterialApp(
      title: 'Glide Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          color: Colors.green,
          elevation: 2,
          centerTitle: true,
          shadowColor: Colors.grey,
        ),
        dividerColor: Colors.grey.shade200,
        cardTheme: CardTheme(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        dividerTheme: const DividerThemeData(
          thickness: 1,
          space: 1,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: compact
              ? null
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
        menuButtonTheme: compact
            ? null
            : MenuButtonThemeData(
                style: ButtonStyle(
                  minimumSize:
                      const MaterialStatePropertyAll(Size(double.infinity, 60)),
                  iconSize: const MaterialStatePropertyAll(26),
                  padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
        // filledButtonTheme: const FilledButtonThemeData(
        //   style: ButtonStyle(
        //     shape: MaterialStatePropertyAll(
        //       RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(8)),
        //       ),
        //     ),
        //   ),
        // ),
      ),
      initialRoute: AppRoutes.home.name,
      onGenerateRoute: AppRoutes.routeFactory,
    );
  }
}
