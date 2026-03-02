import 'package:flutter/material.dart';
import '../features/camera/camera_button.dart';

class FanzziNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final VoidCallback onCamera;

  const FanzziNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.chat, "Chats", 0),
          CameraButton(onTap: onCamera),
          _item(Icons.explore, "Feed", 1),
          _item(Icons.person, "Profile", 2),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final selected = index == i;

    return GestureDetector(
      onTap: () => onTap(i),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(icon,
              color:
                  selected ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? Colors.blue
                      : Colors.grey)),
        ],
      ),
    );
  }
}