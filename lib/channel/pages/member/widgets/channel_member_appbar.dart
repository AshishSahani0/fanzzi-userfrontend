import 'package:flutter/material.dart';
import 'package:frontenduser/channel/member_count/channel_member_section.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_page.dart';
import 'channel_member_menu.dart';

class ChannelMemberAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final ChannelModel channel;

  const ChannelMemberAppBar({super.key, required this.channel});

  @override
  State<ChannelMemberAppBar> createState() =>
      _ChannelMemberAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChannelMemberAppBarState
    extends State<ChannelMemberAppBar> {

  bool get _showSubscribeButton {
    return widget.channel.member == true &&
        widget.channel.type == "PAID" &&
        widget.channel.subscribed == false &&
        widget.channel.owner == false;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade700,
      titleSpacing: 0,

      /// ⭐ Telegram-style clickable header
      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChannelInfoPage(channel: widget.channel),
            ),
          );
        },
        child: Row(
          children: [
            const SizedBox(width: 8),

            /// ⭐ Avatar
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.channel.profileImageUrl != null
                  ? NetworkImage(widget.channel.profileImageUrl!)
                  : null,
              child: widget.channel.profileImageUrl == null
                  ? Text(widget.channel.name[0].toUpperCase())
                  : null,
            ),

            const SizedBox(width: 10),

            /// ⭐ Name + Member Count (Reusable)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// ⭐ MEMBER COUNT WIDGET
                  ChannelMemberSection(
                    channelId: widget.channel.id,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: [

        /// 🔥 SUBSCRIBE BUTTON (Paid channels only)
        if (_showSubscribeButton)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _openSubscribeSheet(context),
              child: const Text(
                "Subscribe",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ChannelMemberMenu(channel: widget.channel),
      ],
    );
  }

  /// ⭐ Subscription Bottom Sheet
  void _openSubscribeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subscribe to ${widget.channel.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Unlock full content access",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${widget.channel.monthlyPrice} / month",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Call subscribe API
                    },
                    child: const Text("Confirm"),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}