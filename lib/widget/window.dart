import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/window_draggable.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindow extends StatefulWidget {
  final Widget child;

  const DesktopWindow({super.key, required this.child});

  @override
  State<DesktopWindow> createState() => _DesktopWindowState();
}

class _DesktopWindowState extends State<DesktopWindow> with WindowListener {
  static const tag = "_DesktopWindowState";
  bool fullscreen = false;

  @override
  void initState() {
    WindowManager.instance.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      fullscreen = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      fullscreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: fullscreen ? EdgeInsets.zero : const EdgeInsets.all(16),
      child: Container(
        decoration: fullscreen
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
        clipBehavior: fullscreen ? Clip.none : Clip.antiAliasWithSaveLayer,
        child: Material(
          elevation: fullscreen ? 0 : 5,
          child: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.topCenter,
            children: [
              widget.child,
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTapDown: (d) {
                    WindowManager.instance
                        .startResizing(ResizeEdge.bottomRight);
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: SizedBox(height: 10, width: 10),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTapDown: (d) {
                    WindowManager.instance.startResizing(ResizeEdge.bottomLeft);
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownLeft,
                    child: SizedBox(height: 10, width: 10),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: GestureDetector(
                  onTapDown: (d) {
                    WindowManager.instance.startResizing(ResizeEdge.topLeft);
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeUpLeft,
                    child: SizedBox(height: 10, width: 10),
                  ),
                ),
              )
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

  static bool pinTop = false;

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
                pinTop = !pinTop;
                WindowManager.instance.setAlwaysOnTop(!pinTop);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Icon(Icons.push_pin_outlined),
                ),
              ),
            ),
            const SizedBox(width: 2),
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
