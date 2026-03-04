import 'package:flutter/material.dart';

import 'package:frontenduser/channel/status/channel_status_viewer_page.dart';
import 'package:frontenduser/channel/status/status_avatar.dart';


import '../model/channel_model.dart';
import 'owner/channel_info_page.dart';
import 'channel_owner_menu.dart';

class ChannelAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ChannelModel channel;

  /// ✅ Selection Mode
  final bool selectionMode;
  final int selectedCount;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  final VoidCallback? onPin;

  const ChannelAppBar({
    super.key,
    required this.channel,
    this.selectionMode = false,
    this.selectedCount = 0,
    this.onCancelSelection,
    this.onDelete,
    this.onEdit,
    this.onShare,
    this.onPin,
  });

  @override
  State<ChannelAppBar> createState() => _ChannelAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChannelAppBarState extends State<ChannelAppBar> {
  @override
  Widget build(BuildContext context) {
    /// ===============================
    /// 🔵 SELECTION MODE
    /// ===============================
    if (widget.selectionMode) {
      return AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 1,

        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancelSelection,
        ),

        title: Text(
          "${widget.selectedCount} selected",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        actions: [
          /// 📌 Pin (only if exactly 1 selected)
          if (widget.selectedCount == 1)
            IconButton(
              icon: const Icon(Icons.push_pin),
              tooltip: "Pin Post",
              onPressed: widget.onPin,
            ),

          /// ✏ Edit (only if exactly 1 selected)
          if (widget.selectedCount == 1)
            IconButton(icon: const Icon(Icons.edit), onPressed: widget.onEdit),

          /// 🔗 Share
          IconButton(icon: const Icon(Icons.share), onPressed: widget.onShare),

          /// 🗑 Delete
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Posts?"),
                  content: Text(
                    widget.selectedCount == 1
                        ? "Are you sure you want to delete this post?"
                        : "Are you sure you want to delete ${widget.selectedCount} posts?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                widget.onDelete?.call();
              }
            },
          ),
        ],
      );
    }

    /// ===============================
    /// 🟢 NORMAL MODE (UNCHANGED)
    /// ===============================
    return AppBar(
      backgroundColor: Colors.blue.shade700,
      titleSpacing: 0,

      title: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelInfoPage(channel: widget.channel),
            ),
          );
        },
        child: Row(
          children: [
            /// ⭐ Avatar + Status
            StatusAvatar(
              imageUrl: widget.channel.profileImageUrl,
              fallbackText: widget.channel.name[0],
              hasStatus: widget.channel.hasActiveStatus,
              radius: 18,
              onTap: () {
                if (widget.channel.hasActiveStatus) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChannelStatusViewerPage(channelId: widget.channel.id),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChannelInfoPage(channel: widget.channel),
                    ),
                  );
                }
              },
            ),

            const SizedBox(width: 10),

            /// ⭐ Name + Member Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.channel.memberCount} member${widget.channel.memberCount == 1 ? '' : 's'}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: [ChannelOwnerMenu(channel: widget.channel)],
    );
  }
}
