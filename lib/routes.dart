import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glide_chat/pages/home/home_page.dart';
import 'package:glide_chat/pages/login_page.dart';
import 'package:glide_chat/pages/session/session_page.dart';
import 'package:glide_chat/pages/user_profile_page.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/notification.dart';

enum AppRoutes {
  home,
  session,
  userProfile,
  login;

  static final _routeClean = [];

  static final _routeReplace = [
    AppRoutes.login,
    AppRoutes.home,
  ];

  static Future pop(BuildContext context, {dynamic result}) async {
    return Navigator.pop(context, result);
  }

  Future go(BuildContext context, {dynamic arg}) async {
    final clean = _routeClean.contains(this);
    final replace = _routeReplace.contains(this);

    if (clean) {
      await Navigator.pushNamedAndRemoveUntil(context, name, (route) => false,
          arguments: arg);
      return Future.value();
    }
    if (replace) {
      await Navigator.pushReplacementNamed(context, name, arguments: arg);
      return Future.value();
    }
    return Navigator.pushNamed(context, name, arguments: arg);
  }

  static Route<dynamic>? routeFactory(RouteSettings settings) {
    final routeName = settings.name;
    final Function? routeBuilder = appRoutes[routeName];
    logd('route', 'build route=>$routeName');

    if (routeBuilder == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const Text("Not Found"),
      );
    }
    final arg = settings.arguments;
    if (arg != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return _globalWrap(context, routeBuilder(context, arg: arg));
        },
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => _globalWrap(context, routeBuilder(context)),
    );
  }

  static Widget _globalWrap(BuildContext context, Widget child) {
    return AppNotification(
      child: ColoredBox(
        color: context.theme.scaffoldBackgroundColor,
        child: child,
      ),
    );
  }
}

typedef RouteBuilder = Widget Function(BuildContext context);

final Map<String, RouteBuilder> appRoutes = {
  AppRoutes.home.name: (c) => const HomePage(),
  AppRoutes.session.name: (c, {arg}) => SessionPage(session: arg),
  AppRoutes.login.name: (c) => const LoginPage(),
  AppRoutes.userProfile.name: (c, {arg}) => UserProfilePage(id: arg as String),
};
