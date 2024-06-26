import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';

class GlideApp extends StatefulWidget {
  const GlideApp({super.key});

  @override
  State<GlideApp> createState() => _GlideAppState();
}

class _GlideAppState extends State<GlideApp> {
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
    return BlocListener<GlobalCubit, GlobalState>(
      listenWhen: (c, p) => c.logged != p.logged,
      listener: (context, state) {
        if (state.logged) {
          logd("tag", "logged in");
        }
      },
      child: Adaptive(
        builder: (c) => build2(context, true),
        L: (c) => build2(context, false),
      ),
    );
  }

  Widget build2(BuildContext context, bool compact) {
    return MaterialApp(
      title: 'Glide Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.cyan.shade700,
          onPrimary: compact ? Colors.white : Colors.black,
          secondary: Colors.green,
          onSecondary: Colors.white,
          tertiary: Colors.blue,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.grey.shade200,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        menuTheme: const MenuBarThemeData(
          style: MenuStyle(
            surfaceTintColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          surfaceTintColor: Colors.white,
          iconColor: Colors.grey,
        ),
        textTheme: TextTheme(
          labelSmall: TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        primaryColorLight: Colors.cyan.shade50,
        primaryColorDark: Colors.cyan.shade900,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        iconTheme: const IconThemeData(color: Colors.grey),
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          color: Colors.cyan.shade800,
          elevation: 2,
          centerTitle: true,
          shadowColor: Colors.grey,
        ),
        dividerColor: Colors.grey.shade200,
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
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
                  minimumSize: const MaterialStatePropertyAll(
                    Size(double.infinity, 60),
                  ),
                  iconSize: const MaterialStatePropertyAll(26),
                  padding: const MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
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
