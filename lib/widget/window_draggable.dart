import 'package:flutter/widgets.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:window_manager/window_manager.dart';

class WindowDraggable extends StatelessWidget {
  final Widget child;

  const WindowDraggable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptive(
      desktop: (c) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          WindowManager.instance.startDragging();
        },
        child: child,
      ),
      def: (c) => child,
    );
  }
}
