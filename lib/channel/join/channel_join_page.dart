import 'package:flutter/material.dart';
import 'channel_join_api.dart';

class ChannelJoinPage extends StatefulWidget {
  final String code;
  final bool isPublic; // ✅ NEW

  const ChannelJoinPage({
    super.key,
    required this.code,
    required this.isPublic,
  });

  @override
  State<ChannelJoinPage> createState() => _ChannelJoinPageState();
}

class _ChannelJoinPageState extends State<ChannelJoinPage> {
  @override
  void initState() {
    super.initState();
    _join();
  }

  Future<void> _join() async {
    try {
      if (widget.isPublic) {
        await ChannelJoinApi.joinBySlug(widget.code);
      } else {
        await ChannelJoinApi.joinByToken(widget.code);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined Channel ✅")),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to join channel")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}