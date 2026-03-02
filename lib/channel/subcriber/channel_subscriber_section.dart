import 'package:flutter/material.dart';
import 'package:frontenduser/channel/subcriber/channel_subscriber_api.dart';


class ChannelSubscriberSection extends StatefulWidget {
  final String channelId;

  /// Compact mode for AppBar
  final bool compact;

  const ChannelSubscriberSection({
    super.key,
    required this.channelId,
    this.compact = false,
  });

  @override
  State<ChannelSubscriberSection> createState() =>
      _ChannelSubscriberSectionState();
}

class _ChannelSubscriberSectionState
    extends State<ChannelSubscriberSection> {

  int subscriberCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final count =
          await ChannelSubscriberApi.fetchSubscriberCount(
              widget.channelId);

      if (!mounted) return;

      setState(() {
        subscriberCount = count;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // ⭐ Format large numbers
  String _format(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    }
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return "$count";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 18,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    /// ⭐ Compact (AppBar)
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16),
          const SizedBox(width: 4),
          Text(
            _format(subscriberCount),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }

    /// ⭐ Full section
    return Row(
      children: [
        const Icon(Icons.star),
        const SizedBox(width: 6),
        Text(
          "${_format(subscriberCount)} subscriber"
          "${subscriberCount == 1 ? '' : 's'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}