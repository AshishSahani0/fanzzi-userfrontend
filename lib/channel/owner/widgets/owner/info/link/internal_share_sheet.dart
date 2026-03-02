import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../model/channel_model.dart';
import 'invite_service.dart';

class InternalShareSheet {
  static void open(
    BuildContext context,
    ChannelModel channel,
    List<ChannelModel> joinedChannels,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _Sheet(
        channel: channel,
        joinedChannels: joinedChannels,
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  final ChannelModel channel;
  final List<ChannelModel> joinedChannels;

  const _Sheet({
    required this.channel,
    required this.joinedChannels,
  });

  @override
  Widget build(BuildContext context) {
    final link = channel.inviteLink!;

    // ✅ FILTER: remove the channel being shared
    final targets = joinedChannels
        .where((c) => c.id != channel.id)
        .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Share to joined channels",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ EMPTY STATE (after filtering)
          if (targets.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No other joined channels available",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          // ✅ TARGET CHANNEL LIST
          if (targets.isNotEmpty)
            Expanded(
              child: ListView(
                children: targets.map((target) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.campaign),
                    ),
                    title: Text(target.name),
                    subtitle: const Text("Tap to send invite"),
                    onTap: () {
                      InviteService.sendToChannel(
                        targetChannelId: target.id,
                        inviteChannel: channel,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invite sent ✅"),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

          // ✅ COPY LINK BUTTON (always visible)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text("Copy invite link"),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: link),
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invite link copied ✅"),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}