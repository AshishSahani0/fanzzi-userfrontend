import 'package:flutter/material.dart';
import 'package:frontenduser/channel/member_count/channel_membercount_api.dart';
import 'package:frontenduser/channel/member_count/channel_membership_api.dart';

class ChannelMemberSection extends StatefulWidget {
  final String channelId;

  /// ⭐ If true → compact style for AppBar
  final bool compact;

  const ChannelMemberSection({
    super.key,
    required this.channelId,
    this.compact = false,
  });

  @override
  State<ChannelMemberSection> createState() =>
      _ChannelMemberSectionState();
}

class _ChannelMemberSectionState
    extends State<ChannelMemberSection> {

  bool isMember = false;
  int memberCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ChannelMembershipApi.isMember(widget.channelId),
        ChannelMemberCountApi.fetch(widget.channelId),
      ]);

      if (!mounted) return;

      setState(() {
        isMember = results[0] as bool;
        memberCount = results[1] as int;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _leaveChannel() async {
    await ChannelMembershipApi.leaveChannel(widget.channelId);

    if (!mounted) return;

    setState(() {
      isMember = false;
      memberCount = (memberCount - 1).clamp(0, 999999);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Left channel")),
    );
  }

  // ⭐ Format large numbers (1.2K, 3.4M)
  String _formatCount(int count) {
    if (count >= 1000000) return "${(count / 1000000).toStringAsFixed(1)}M";
    if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)}K";
    return "$count";
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // ⭐ COMPACT MODE (AppBar usage)
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group, size: 18),
          const SizedBox(width: 4),
          Text(
            _formatCount(memberCount),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }

    // ⭐ FULL MODE (Page/Header usage)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// 👥 MEMBER COUNT
        Row(
          children: [
            const Icon(Icons.group),
            const SizedBox(width: 6),
            Text(
              "${_formatCount(memberCount)} "
              "member${memberCount == 1 ? '' : 's'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        /// 🚪 LEAVE BUTTON
        if (isMember)
          TextButton.icon(
            onPressed: _leaveChannel,
            icon: const Icon(Icons.exit_to_app),
            label: const Text("Leave"),
          ),
      ],
    );
  }
}