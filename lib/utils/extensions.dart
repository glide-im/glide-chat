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

extension DateExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day - 1;
  }

  bool isTomorrow() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day + 1;
  }

  String toShortString() {
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString()}";
  }

  String timeString() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String dateString() {
    return "${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}";
  }

  String dateTimeString() {
    return "${dateString()} ${timeString()}";
  }
}
