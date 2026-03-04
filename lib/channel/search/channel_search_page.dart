import 'package:flutter/material.dart';
import 'package:frontenduser/channel/helpers/channel_open_helper.dart';
import 'package:frontenduser/channel/search/channel_search_api.dart';

import '../model/channel_model.dart';

class ChannelSearchPage extends StatefulWidget {
  const ChannelSearchPage({super.key});

  @override
  State<ChannelSearchPage> createState() => _ChannelSearchPageState();
}

class _ChannelSearchPageState extends State<ChannelSearchPage> {
  List<ChannelModel> joinedChannels = [];
  List<ChannelModel> publicChannels = [];

  String query = "";
  bool loading = false;

 Future<void> search(String text) async {
  query = text.trim();

  if (query.isEmpty) {
    setState(() {
      publicChannels = [];
      loading = false;
    });
    return;
  }

  setState(() => loading = true);

  try {
    final result =
        await ChannelSearchApi.searchPublic(query);

    if (!mounted) return;

    setState(() {
      publicChannels = result;
      loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Search failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Channels")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search channels...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: search,
            ),
          ),

          if (loading) const LinearProgressIndicator(),

          Expanded(
  child: ListView(
    children: [
      if (publicChannels.isNotEmpty) ...[
        _sectionTitle("Channels"),
        ...publicChannels.map(_channelTile),
      ],

      if (!loading &&
          publicChannels.isEmpty &&
          query.isNotEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("No channels found ❌"),
          ),
        ),
    ],
  ),
),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _channelTile(ChannelModel channel) {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage:
          channel.profileImageUrl != null
              ? NetworkImage(channel.profileImageUrl!)
              : null,
      child: channel.profileImageUrl == null
          ? Text(channel.name[0].toUpperCase())
          : null,
    ),
    title: Text(channel.name),
    subtitle: channel.joined
        ? const Text("Already Joined ✅")
        : const Text("Public Channel 🌍"),
    trailing: channel.joined
        ? const Icon(Icons.check, color: Colors.green)
        : const Icon(Icons.add, color: Colors.blue),
    onTap: () {
      ChannelOpenHelper.open(context, channel);
    },
  );
}
}