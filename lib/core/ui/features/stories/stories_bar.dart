import 'package:flutter/material.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 8,
        itemBuilder: (_, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150"),
                ),
                SizedBox(height: 6),
                Text("Creator",
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}