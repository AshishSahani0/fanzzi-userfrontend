import 'package:flutter/material.dart';
import 'package:frontenduser/core/channel_info_refresh_bus.dart';

import '../../model/channel_model.dart';
import '../../createpage/channel_api.dart';
import '../../api/channel_report_admin_api.dart';
import '../../subcriber/channel_subscriber_api.dart';
import '../widgets/owner/info/channel_info_header.dart';
import '../widgets/owner/info/link/channel_invite_tile.dart';
import '../widgets/owner/info/channel_info_menu.dart';

class ChannelInfoPage extends StatefulWidget {
  final ChannelModel channel;

  const ChannelInfoPage({super.key, required this.channel});

  @override
  State<ChannelInfoPage> createState() => _ChannelInfoPageState();
}

class _ChannelInfoPageState extends State<ChannelInfoPage> {
  List<ChannelModel> joinedChannels = [];
  bool loading = true;

  // 🚨 reports
  int reportCount = 0;
  bool reportLoading = false;

  // 💎 subscribers
  int subscriberCount = 0;
  bool subscriberLoading = false;

  @override
  @override
  void initState() {
    super.initState();
    _loadJoinedChannels();

    if (widget.channel.owner) {
      _loadReportCount();
      _loadSubscriberCount();
    }

    ChannelInfoRefreshBus.stream.listen((id) {
      if (id == widget.channel.id && mounted) {
        _refreshAll(); // 🔥 auto reload everything
      }
    });
  }

  // 🔗 Joined channels (invite tile support)
  Future<void> _loadJoinedChannels() async {
    try {
      final list = await ChannelApi.getJoinedChannels();
      setState(() {
        joinedChannels = list;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  // 🚨 Report count (OWNER ONLY)
  Future<void> _loadReportCount() async {
    setState(() => reportLoading = true);

    try {
      final count = await ChannelReportAdminApi.fetchReportCount(
        widget.channel.id,
      );

      setState(() {
        reportCount = count;
        reportLoading = false;
      });
    } catch (_) {
      setState(() => reportLoading = false);
    }
  }

  // 💎 Subscriber count (PAID + OWNER ONLY)
  Future<void> _loadSubscriberCount() async {
    if (widget.channel.type != "PAID") return;

    setState(() => subscriberLoading = true);

    try {
      final count = await ChannelSubscriberApi.fetchSubscriberCount(
        widget.channel.id,
      );

      setState(() {
        subscriberCount = count;
        subscriberLoading = false;
      });
    } catch (_) {
      setState(() => subscriberLoading = false);
    }
  }

  // 🔄 Pull-to-refresh
  Future<void> _refreshAll() async {
    await Future.wait([
      _loadJoinedChannels(),
      if (widget.channel.owner) _loadReportCount(),
      if (widget.channel.owner && widget.channel.type == "PAID")
        _loadSubscriberCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ✅ Header
            ChannelInfoHeader(channel: widget.channel),

            // ✅ Invite tile
            SliverToBoxAdapter(
              child: ChannelInviteTile(
                channel: widget.channel,
                joinedChannels: joinedChannels,
              ),
            ),

            // ✅ OWNER MENU (FULL CHANNEL PASSED)
            SliverToBoxAdapter(
              child: ChannelInfoMenu(
                channel: widget.channel, // 🔥 FIX
                isOwner: widget.channel.owner,
                subscriberCount: subscriberLoading ? 0 : subscriberCount,
                reportCount: reportLoading ? 0 : reportCount,
                adminCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
