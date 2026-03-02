import 'package:flutter/material.dart';

class ChannelInfoTabs extends StatelessWidget {
  const ChannelInfoTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Gifts"),
              Tab(text: "Media"),
              Tab(text: "Files"),
              Tab(text: "Links"),
            ],
          ),

          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                Center(child: Text("🎁 Gifts Coming Soon")),
                Center(child: Text("📷 Media")),
                Center(child: Text("📁 Files")),
                Center(child: Text("🔗 Links")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
