import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_actions.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_description.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_header.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_tabs.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/link/channel_invite_tile.dart';


class ChannelInfoPage extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoPage({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // Telegram Header
          SliverToBoxAdapter(
            child: ChannelInfoHeader(channel: channel),
          ),

          // Action Buttons (Unmute, Gift, Share, Leave)
          SliverToBoxAdapter(
            child: ChannelInfoActions(channel: channel),
          ),


          SliverToBoxAdapter(
  child: ChannelInfoDescription(channel: channel),
),
          // Invite Link Tile
          SliverToBoxAdapter(
            child: ChannelInviteTile(channel: channel),
          ),

          // Tabs Section (Gifts, Media, Files...)
          SliverToBoxAdapter(
            child: ChannelInfoTabs(),
          ),
        ],
      ),
    );
  }
}
