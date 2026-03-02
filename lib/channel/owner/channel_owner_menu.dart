import 'package:flutter/material.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/channel_owner_control_sheet.dart';
import '../model/channel_model.dart';


class ChannelOwnerMenu extends StatelessWidget {
  final ChannelModel channel;

  const ChannelOwnerMenu({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        ChannelOwnerControlSheet.open(context, channel);
      },
    );
  }
}