import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _logger =
    Logger(level: kDebugMode ? Level.all : Level.off, printer: SimplePrinter    ());

void logd(String tag, dynamic msg) {
  _logger.d("$tag $msg");
}

void loge(String tag, dynamic msg, [dynamic e]) {
  _logger.e("$tag $msg", error: e);
}

void logw(String tag, dynamic msg) {
  _logger.w("$tag $msg");
}

void _log(String tag, String level, dynamic msg) {
  if (kDebugMode) {
    print("${_time()} $level/$tag: $msg");
  }
}

String _time() {
  final now = DateTime.now();
  return "${now.hour}:${now.minute}:${now.second}";
}

void mark([String m = '']) {
  final now = DateTime.now();
  final time = "${now.hour}:${now.minute}:${now.second}";
  final where =
      StackTrace.current.toString().split("\n")[1].replaceAll('#1      ', '');
  _logger.t("$where${m.trim().isEmpty ? '' : '\n=>$m'}");
}
