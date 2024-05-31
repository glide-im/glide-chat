import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String title;
  final String url;

  const Avatar({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: Center(
        child: Text(
          title.length < 2 ? title : title.substring(0, 2),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
