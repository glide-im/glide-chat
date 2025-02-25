import 'package:flutter/material.dart';
import 'package:glide_chat/pages/home/home_page.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/widget/adaptive.dart';

class GlideApp extends StatelessWidget {
  const GlideApp({super.key});

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
      debugShowCheckedModeBanner: false,
      theme: _themeData(compact),
      initialRoute: AppRoutes.home.name,
      onGenerateRoute: AppRoutes.routeFactory,
    );
  }
}

ThemeData _themeData(bool compact) => ThemeData(
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Inter', 'Microsoft YaHei', 'Noto Sans SC', 'Roboto'],
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.cyan.shade700,
        onPrimary: compact ? Colors.white : Colors.black,
        secondary: Colors.green,
        secondaryContainer: Colors.green.shade100,
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
          surfaceTintColor: WidgetStatePropertyAll(Colors.white),
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
        contentPadding: compact ? null : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
      ),
      menuButtonTheme: compact
          ? null
          : MenuButtonThemeData(
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(
                  Size(double.infinity, 60),
                ),
                iconSize: const WidgetStatePropertyAll(26),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                shape: WidgetStatePropertyAll(
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
    );
