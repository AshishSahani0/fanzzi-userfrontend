import 'package:flutter/material.dart';
import 'package:frontenduser/channel/join/channel_join_api.dart';
import 'package:frontenduser/channel/membership/channel_membership_api.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/post/channel_feed_page.dart';

import '../../join/channel_join_bottom_bar.dart';
import 'widgets/channel_member_appbar.dart';

class ChannelMemberPage extends StatefulWidget {
  final ChannelModel channel;

  const ChannelMemberPage({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelMemberPage> createState() => _ChannelMemberPageState();
}

class _ChannelMemberPageState extends State<ChannelMemberPage> {

  late ChannelModel _channel;
  bool joining = false;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    _loadMembership();
  }

  /// 🔹 Keep membership check, but sync into _channel
  Future<void> _loadMembership() async {
    try {
      final result =
          await ChannelMembershipApi.isMember(_channel.id);

      if (!mounted) return;

      setState(() {
        _channel = _channel.copyWith(member: result);
      });

    } catch (_) {}
  }

  Future<void> joinChannel() async {
    if (joining) return;

    setState(() => joining = true);

    try {
      final updated =
          await ChannelJoinApi.joinByChannelId(_channel.id);

      if (!mounted) return;

      setState(() {
        _channel = updated;   // 🔥 Replace entire object
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gifts feature coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelMemberAppBar(channel: _channel),

      body: Stack(
        children: [

          Positioned.fill(
            child: ChannelFeedPage(
              channelId: _channel.id,      // 🔥 use _channel
              channel: _channel,           // 🔥 use _channel
              isJoined: _channel.member,   // 🔥 single source
              selectedPosts: const {},
              selectionMode: false,
              onStartSelection: () {},
              onToggleSelection: (_) {},
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ChannelJoinBottomBar(
              joined: _channel.member,     // 🔥 no separate bool
              joining: joining,
              joinText: _channel.type == "PAID"
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