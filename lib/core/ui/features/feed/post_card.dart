import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text("Premium Post 🔒",
                style:
                    TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Subscribe to unlock content"),
          ],
        ),
      ),
    );
  }
}