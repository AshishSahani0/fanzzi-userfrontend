import 'package:flutter/material.dart';
import 'package:frontenduser/channel/delete/channel_delete_button.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/owner/owner/channel_reports_page.dart';
import 'package:frontenduser/channel/subcriber/channel_subscribers_page.dart';

import 'package:frontenduser/channel/update/channel_edit_info_page.dart';
import 'package:frontenduser/core/channel_info_refresh_bus.dart';

class ChannelInfoMenu extends StatelessWidget {
  final ChannelModel channel;
  final bool isOwner;
  final int subscriberCount;
  final int adminCount;
  final int reportCount;

  const ChannelInfoMenu({
    super.key,
    required this.channel,
    required this.isOwner,
    this.subscriberCount = 0,
    this.adminCount = 0,
    this.reportCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================
        // 📊 MANAGEMENT
        // =====================
        if (isOwner) _section("Management"),

        if (isOwner && channel.type == "PAID")
          _menuTile(context, Icons.group, "Subscribers", subscriberCount, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChannelSubscribersPage(channelId: channel.id),
              ),
            );
          }),

        if (isOwner)
          _menuTile(
            context,
            Icons.star_border,
            "Administrators",
            adminCount,
            () {
              // TODO: admin list page
            },
          ),

        if (isOwner)
          _menuTile(context, Icons.edit, "Edit Channel Info", null, () async {
            final refreshed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChannelEditInfoPage(channel: channel),
              ),
            );

            if (refreshed == true && context.mounted) {
              ChannelInfoRefreshBus.notify(channel.id);
            }
          }),

        // =====================
        // 🚨 SAFETY
        // =====================
        if (isOwner) _section("Safety"),

        if (isOwner)
          _menuTile(
            context,
            Icons.report,
            "Reports",
            reportCount > 0 ? reportCount : null,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelReportsPage(channelId: channel.id),
                ),
              );
            },
          ),

        // =====================
        // ⚠️ DANGER ZONE
        // =====================
        if (isOwner) _section("Danger Zone"),

        if (isOwner) ChannelDeleteButton(channelId: channel.id),
      ],
    );
  }

  // ----------------------------------
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ----------------------------------
  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    int? count,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: danger ? Colors.red : Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: danger ? Colors.red : null)),
      trailing: count != null && count > 0
          ? Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
