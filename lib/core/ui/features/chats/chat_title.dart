import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundImage:
            NetworkImage("https://i.pravatar.cc/150"),
      ),
      title: Text("Creator Name",
          style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("New premium post 🔥"),
      trailing: Text("12:30 PM"),
    );
  }
}