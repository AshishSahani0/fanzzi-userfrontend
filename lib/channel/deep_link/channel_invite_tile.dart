import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/channel_model.dart';
import 'channel_qr_popup.dart';
import 'internal_share_sheet.dart';

class ChannelInviteTile extends StatelessWidget {
  final ChannelModel channel;
  final List<ChannelModel> joinedChannels;

  const ChannelInviteTile({
    super.key,
    required this.channel,
    this.joinedChannels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final link = channel.inviteLink;

    return ListTile(
      leading: const Icon(Icons.link, color: Colors.blue),

      title: Text(
        link ?? "Invite link not available",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(
        channel.owner ? "Share your channel" : "Copy invite link",
      ),

      trailing: IconButton(
        icon: const Icon(Icons.qr_code),
        onPressed: link == null
            ? null
            : () => ChannelQrPopup.open(context, link),
      ),

      onTap: () {
        if (link == null || link.isEmpty) return;

        // 👑 OWNER → internal share of THEIR channel
        if (channel.owner) {
          InternalShareSheet.open(
            context,
            channel,
            joinedChannels,
          );
          return;
        }

        // 👤 USER → copy only
        Clipboard.setData(ClipboardData(text: link));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invite link copied ✅")),
        );
      },
    );
  }
}