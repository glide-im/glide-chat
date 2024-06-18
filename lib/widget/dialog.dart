import 'package:flutter/material.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/logger.dart';

class BottomSheetWrap extends StatelessWidget {
  final Widget child;

  const BottomSheetWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: CloseButton(
            style: context.theme.iconButtonTheme.style,
            onPressed: () {
              AppRoutes.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

extension LoadingDialogExt on BuildContext {
  Future<void> loading(Future future) async {
    LoadingDialog.show(this);
    try {
      await future;
    } catch (e) {
      loge("LoadingDialogExt", e);
      rethrow;
    } finally {
      LoadingDialog.hide(this);
    }
  }
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const LoadingDialog(),
    );
  }

  static Future<void> hide(BuildContext context) async {
    await AppRoutes.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
