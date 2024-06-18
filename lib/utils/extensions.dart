import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  void showToast(String message) {
    ScaffoldMessenger.of(this).showMaterialBanner(
        const MaterialBanner(content: Text("Banner"), actions: [
          SizedBox(),
        ]));
  }
}
