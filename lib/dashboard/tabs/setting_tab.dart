import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontenduser/profile/user_api.dart';
import 'package:frontenduser/profile/media_api.dart';
import 'package:frontenduser/channel/stars/creator/creator_earnings_page.dart';
import 'package:frontenduser/core/services/auth_service.dart';
import 'package:frontenduser/channel/createpage/create_channel_page.dart';
import 'package:frontenduser/channel/block/blocked_channels_page.dart';
import 'package:frontenduser/dashboard/pages/privacy_policy_page.dart';
import 'package:frontenduser/profile/profile_image.dart';
import 'package:frontenduser/channel/stars/user_member/buy_stars_page.dart';
import 'package:frontenduser/channel/createpage/channel_api.dart';
import '../../profile/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? user;
  bool loading = true;
  bool hasChannels = false;

  String get imageUrl => user?["profileImageUrl"] ?? "";
  String get userName => user?["userName"] ?? "User";
  String get phone => user?["phone"] ?? "";

  @override
  void initState() {
    super.initState();
    loadUser();
    checkCreatorStatus();
  }

  Future<void> loadUser() async {
    final data = await UserApi.getMe();
    if (!mounted) return;

    setState(() {
      user = data;
      loading = false;
    });
  }

  Future<void> checkCreatorStatus() async {
    try {
      final channels = await ChannelApi.getMyChannels();
      if (!mounted) return;

      setState(() {
        hasChannels = channels.isNotEmpty;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isPage = Navigator.canPop(context);

    Widget body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        _profileHeader(),
        const SizedBox(height: 36),

        _sectionTitle("General"),
        const SizedBox(height: 14),
        _settingsCard([
          _tile(Icons.person_rounded, Colors.blue, "Account",
              "Number, Username, Bio", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ).then((_) => loadUser());
          }),
          _tile(Icons.block_rounded, Colors.red,
              "Blocked Channels", "Channels you have blocked", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BlockedChannelsPage(),
              ),
            );
          }),
          _tile(Icons.lock_outline_rounded, Colors.green,
              "Privacy & Security", "Last seen, profile privacy", () {}),
          _tile(Icons.notifications_outlined, Colors.orange,
              "Notifications", "Sounds, badges", () {}),
          _tile(Icons.storage_rounded, Colors.blueGrey,
              "Data & Storage", "Media settings", () {}),
          _tile(Icons.language_rounded, Colors.purple,
              "Language", "English", () {}),
        ]),

        const SizedBox(height: 36),

        _sectionTitle("Creator"),
        const SizedBox(height: 14),
        _settingsCard([
          _tile(Icons.star_rounded, Colors.orange,
              "Fanzzi Stars", "Buy and use stars", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BuyStarsPage(),
              ),
            );
          }),
          if (hasChannels)
            _tile(Icons.monetization_on_rounded, Colors.green,
                "Creator Earnings", "View earnings dashboard", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatorEarningsPage(),
                ),
              );
            }),
          _tile(Icons.add_box_rounded, Colors.blue,
              "Create Channel", "", () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateChannelPage(),
              ),
            );

            await checkCreatorStatus();
            if (!mounted) return;

            if (result != null &&
                result is Map &&
                result["goToChats"] == true) {
              Navigator.of(context).pop({
                "goToChats": true,
                "refresh": true,
              });
            }
          }),
        ]),

        const SizedBox(height: 36),

        _sectionTitle("Support"),
        const SizedBox(height: 14),
        _settingsCard([
          _tile(Icons.help_outline_rounded, Colors.orange,
              "Help", "Ask a question", () {}),
          _tile(Icons.privacy_tip_outlined, Colors.green,
              "Privacy Policy", "", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrivacyPolicyPage(),
              ),
            );
          }),
        ]),

        const SizedBox(height: 36),

        _settingsCard([
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: const Icon(Icons.logout_rounded,
                color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => AuthService.logout(context),
          ),
        ]),

        const SizedBox(height: 50),
      ],
    );

    if (isPage) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: body),
      );
    }

    return SafeArea(child: body);
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader() {
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.10),
                primary.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: primary.withOpacity(0.15),
            ),
          ),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ProfileImage(
                      imageUrl: imageUrl,
                      radius: 54,
                      onUpload: (file) async {
                        final result =
                            await MediaApi.uploadProfileImage(file);

                        await UserApi.updateProfile({
                          "profileImageKey": result["key"],
                        });

                        await loadUser();
                        return result["url"] ?? "";
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          phone,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // ================= SETTINGS CARD =================

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ================= TILE =================

  Widget _tile(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle:
          subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: Colors.grey.shade600,
      ),
    );
  }
}