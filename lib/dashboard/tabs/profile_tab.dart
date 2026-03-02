import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontenduser/profile/user_api.dart';
import 'package:frontenduser/profile/media_api.dart';
import 'package:frontenduser/core/app_refresh_bus.dart';
import 'package:frontenduser/dashboard/tabs/setting_tab.dart';
import 'package:frontenduser/profile/profile_image.dart';
import '../../profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? user;
  bool loading = true;

  late TabController _tabController;
  StreamSubscription? _refreshSub;

  String get imageUrl => user?["profileImageUrl"] ?? "";
  String get name =>
      "${user?["firstName"] ?? ""} ${user?["lastName"] ?? ""}".trim();
  String get phone => user?["phone"] ?? "";
  String get username => user?["userName"] ?? "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadUser();

    _refreshSub = AppRefreshBus.stream.listen((key) {
      if (key == AppRefreshBus.user ||
          key == AppRefreshBus.profile ||
          key == "ALL") {
        loadUser();
      }
    });
  }

  Future<void> loadUser() async {
    setState(() => loading = true);
    final data = await UserApi.getMe();
    if (!mounted) return;

    setState(() {
      user = data;
      loading = false;
    });
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _uploadProfileImage(File file) async {
    final result = await MediaApi.uploadProfileImage(file);

    await UserApi.updateProfile({
      "profileImageKey": result["key"],
    });

    AppRefreshBus.notify(AppRefreshBus.profile);

    return result["url"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: loadUser,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _header(primary),
              const SizedBox(height: 16),
              _infoCard(),
              const SizedBox(height: 20),

              TabBar(
                controller: _tabController,
                labelColor: primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Posts"),
                  Tab(text: "Archived"),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _emptyPosts(),
                    _emptyPosts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(Color primary) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(
              top: 30, bottom: 28),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            border: Border.all(
              color: primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              ProfileImage(
                imageUrl: imageUrl,
                radius: 58,
                onUpload: _uploadProfileImage,
              ),
              const SizedBox(height: 14),
              Text(
                name.isEmpty ? "User" : name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text("online",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _actionChip(
                      Icons.camera_alt_outlined,
                      "Set Photo", () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Tap the profile photo to change"),
                      ),
                    );
                  }),
                  _actionChip(
                      Icons.edit_outlined,
                      "Edit Info", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const EditProfilePage(),
                      ),
                    );
                    loadUser();
                  }),
                  _actionChip(
                      Icons.settings_outlined,
                      "Settings", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SettingsPage(),
                      ),
                    );
                    loadUser();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INFO CARD =================

  Widget _infoCard() {
    final surface =
        Theme.of(context).colorScheme.surface;

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
          vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color:
                Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
                Icons.phone_outlined,
                color: Colors.grey),
            title: Text(phone),
            subtitle: const Text("Mobile"),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
                Icons.alternate_email,
                color: Colors.grey),
            title: Text("@$username"),
            subtitle:
                const Text("Username"),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY POSTS =================

  Widget _emptyPosts() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          "No posts yet...",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= ACTION CHIP =================

  Widget _actionChip(
      IconData icon,
      String label,
      VoidCallback onTap) {
    final surface =
        Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(
            vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color:
                  Colors.black.withOpacity(0.05),
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}