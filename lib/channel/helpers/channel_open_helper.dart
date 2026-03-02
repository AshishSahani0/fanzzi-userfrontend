import 'package:flutter/material.dart';
import '../model/channel_model.dart';

import '../owner/owner/manage_channel_page.dart';
import '../pages/member/channel_member_page.dart'; // ✅ New Merged Page

class ChannelOpenHelper {
  static Future<bool?> open(BuildContext context, ChannelModel channel) async {

    // ✅ Owner → Manage Page
    if (channel.owner == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManageChannelPage(channel: channel),
        ),
      );
      return false;
    }

    // ✅ Member → Viewer Page
    if (channel.member == true) {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelMemberPage(channel: channel),
        ),
      );
    }

    // ✅ Not Member → Join Preview Page
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChannelMemberPage(channel: channel),
      ),
    );
  }
}
