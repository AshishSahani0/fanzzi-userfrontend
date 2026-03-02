import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/createpage/create_channel_page.dart';
import 'package:frontenduser/channel/search/channel_search_page.dart';
import 'package:frontenduser/dashboard/tabs/chats_tab.dart';
import 'package:frontenduser/dashboard/tabs/profile_tab.dart';
import 'package:frontenduser/dashboard/tabs/setting_tab.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  final List<String> titles = ["Chats", "Camera", "Settings", "Profile"];

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = const [ChatsTab(), SizedBox(), SettingsPage(), ProfilePage()];
  }

  void openCamera() async {
    setState(() => currentIndex = 1);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateChannelPage()),
    );

    if (mounted) setState(() => currentIndex = 0);
  }

  void openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChannelSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          titles[currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: openSearch),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _glassNavBar(primary),
        ),
      ),
    );
  }

  // =========================================================
  // GLASS NAV BAR
  // =========================================================

  Widget _glassNavBar(Color primary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(38, 255, 255, 255), // 0.15
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color.fromARGB(64, 255, 255, 255), // 0.25
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 25,
                offset: const Offset(0, 10),
                color: Color.fromARGB(
                  64,
                  primary.red,
                  primary.green,
                  primary.blue,
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabItem(Icons.chat_bubble_rounded, "Chats", 0),
              _cameraItem(primary),
              _tabItem(Icons.settings_rounded, "Settings", 2),
              _tabItem(Icons.person_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TAB ITEM
  // =========================================================

  Widget _tabItem(IconData icon, String label, int index) {
    final primary = Theme.of(context).colorScheme.primary;
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromARGB(38, primary.red, primary.green, primary.blue)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primary : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primary : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CAMERA BUTTON
  // =========================================================

  Widget _cameraItem(Color primary) {
    return GestureDetector(
      onTap: openCamera,
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              primary,
              Color.fromARGB(
                200,
                (primary.r * 255).round(),
                (primary.g * 255).round(),
                (primary.b * 255).round(),
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 8),
              color: Color.fromARGB(
                128,
                (primary.r * 255).round(),
                (primary.g * 255).round(),
                (primary.b * 255).round(),
              ),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
