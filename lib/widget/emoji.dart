import 'package:flutter/material.dart';

class EmojiList extends StatelessWidget {
  static const int emojiStart = 128512;
  static const int emojiEnd = 128591;
  final Function(String) onSelected;

  const EmojiList({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      cacheExtent: 50,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 50),
      itemBuilder: (context, index) {
        final unicode = emojiStart + index;
        return EmojiItem(
          unicode: unicode,
          onPressed: () {
            onSelected(String.fromCharCode(unicode));
          },
        );
      },
      itemCount: emojiEnd - emojiStart + 1,
    );
  }
}

class EmojiItem extends StatelessWidget {
  final int unicode;
  final VoidCallback? onPressed;

  const EmojiItem({super.key, required this.unicode, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Text(
        String.fromCharCode(unicode),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
