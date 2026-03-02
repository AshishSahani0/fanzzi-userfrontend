import 'package:flutter/material.dart';
import 'package:frontenduser/channel/block/block_channel_model.dart';
import 'package:frontenduser/channel/block/channel_block_api.dart';

class BlockedChannelsPage extends StatefulWidget {
  const BlockedChannelsPage({super.key});

  @override
  State<BlockedChannelsPage> createState() =>
      _BlockedChannelsPageState();
}

class _BlockedChannelsPageState extends State<BlockedChannelsPage> {
  bool loading = true;
  List<BlockedChannel> blocked = [];
  Set<String> processing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ChannelBlockApi.getBlockedChannels();

      if (!mounted) return;

      setState(() {
        blocked = list;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _unblock(BlockedChannel channel) async {
    setState(() => processing.add(channel.id));

    try {
      await ChannelBlockApi.unblockChannel(channel.id);

      if (!mounted) return;

      setState(() {
        blocked.removeWhere((c) => c.id == channel.id);
        processing.remove(channel.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${channel.name} unblocked")),
      );
    } catch (_) {
      setState(() => processing.remove(channel.id));
    }
  }

  Widget _avatar(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.campaign),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blocked Channels")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : blocked.isEmpty
              ? const Center(child: Text("No blocked channels"))
              : ListView.separated(
                  itemCount: blocked.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final ch = blocked[i];
                    final busy = processing.contains(ch.id);

                    return ListTile(
                      leading: _avatar(ch.avatarUrl),

                      title: Text(
                        ch.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      trailing: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : TextButton(
                              onPressed: () => _unblock(ch),
                              child: const Text("Unblock"),
                            ),
                    );
                  },
                ),
    );
  }
}