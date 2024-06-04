import 'package:flutter/material.dart';
import 'package:glide_chat/extensions.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/window_dragble.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindow extends StatelessWidget {
  final Widget child;

  const DesktopWindow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Material(
          elevation: 5,
          child: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.topCenter,
            children: [
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class WindowBar extends StatelessWidget {
  const WindowBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: WindowDraggable(
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class WindowBarActions extends StatelessWidget {
  const WindowBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptive(desktop: (c) => content(context));
  }

  Widget content(BuildContext context) {
    return IconTheme(
        data: const IconThemeData(size: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                WindowManager.instance.minimize();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Icon(Icons.horizontal_rule_rounded),
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              hoverColor: context.theme.colorScheme.error,
              onTap: () {
                WindowManager.instance.close();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Icon(Icons.close_rounded),
              ),
            )
          ],
        ));
  }
}
