import 'package:flutter/material.dart';
import 'package:frontenduser/channel/join/channel_join_api.dart';
import 'package:frontenduser/channel/member_count/channel_membership_api.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/post/channel_feed_page.dart';

import '../../join/channel_join_bottom_bar.dart';
import 'widgets/channel_member_appbar.dart';


class ChannelMemberPage extends StatefulWidget {
  final ChannelModel channel;

  const ChannelMemberPage({super.key, required this.channel});

  @override
  State<ChannelMemberPage> createState() => _ChannelMemberPageState();
}

class _ChannelMemberPageState extends State<ChannelMemberPage> {
  bool joined = false;
  bool joining = false;

 @override
void initState() {
  super.initState();
  _loadMembership();
}

Future<void> _loadMembership() async {
  try {
    final result =
        await ChannelMembershipApi.isMember(widget.channel.id);

    if (!mounted) return;

    setState(() {
      joined = result;
    });
  } catch (_) {}
}

  Future<void> joinChannel() async {
  if (joining) return;

  setState(() => joining = true);

  try {
    await ChannelJoinApi.joinByChannelId(widget.channel.id);

    if (!mounted) return;

    setState(() {
      joined = true;
      joining = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Joined channel ✅")),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() => joining = false);

    String message = "Join failed";

    if (e.toString().contains("429")) {
      message = "Please wait before rejoining.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

  void openGift() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Gifts feature coming soon")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelMemberAppBar(channel: widget.channel),
      body: Stack(
  children: [
    Positioned.fill(
      child: ChannelFeedPage(
        channelId: widget.channel.id,
        channel: widget.channel,
        isJoined: joined,
        selectedPosts: const {},
        selectionMode: false,
        onStartSelection: () {},
        onToggleSelection: (_) {},
      ),
    ),

    Align(
      alignment: Alignment.bottomCenter,
      child: ChannelJoinBottomBar(
        joined: joined,
        joining: joining,
        joinText: widget.channel.type == "PAID"
            ? "Join (Subscription Required)"
            : "Join Channel",
        onJoin: joinChannel,
        onGift: openGift,
      ),
    ),
  ],
),
    );
  }
}
