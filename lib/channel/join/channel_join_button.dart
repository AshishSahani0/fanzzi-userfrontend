import 'package:flutter/material.dart';
import 'package:frontenduser/channel/block/channel_block_api.dart';
import 'package:frontenduser/channel/join/channel_join_api.dart';
import 'package:frontenduser/channel/member_count/channel_membership_api.dart';

class ChannelJoinButton extends StatefulWidget {
  final String channelId;
  final String code;        // slug or token
  final bool isPublic;      // ✅ NEW
  final VoidCallback? onJoined;

  const ChannelJoinButton({
    super.key,
    required this.channelId,
    required this.code,
    required this.isPublic,
    this.onJoined,
  });

  @override
  State<ChannelJoinButton> createState() =>
      _ChannelJoinButtonState();
}

class _ChannelJoinButtonState extends State<ChannelJoinButton> {
  bool loading = true;
  bool blocked = false;
  bool joined = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
  try {
    final results = await Future.wait([
      ChannelBlockApi.isBlocked(widget.channelId),
      ChannelMembershipApi.isMember(widget.channelId),
    ]);

    blocked = results[0] as bool;
    joined = results[1] as bool;
  } catch (_) {}

  if (!mounted) return;

  setState(() => loading = false);
}

  // =========================================================
  // ➕ JOIN CHANNEL
  // =========================================================

  Future<void> _join() async {
    setState(() => loading = true);

    try {
      if (widget.isPublic) {
        await ChannelJoinApi.joinBySlug(widget.code);
      } else {
        await ChannelJoinApi.joinByToken(widget.code);
      }

      if (!mounted) return;

      setState(() {
        joined = true;
        loading = false;
      });

      widget.onJoined?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined Channel ✅")),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to join channel")),
      );
    }
  }

  // =========================================================
  // 🔓 UNBLOCK CHANNEL
  // =========================================================

  Future<void> _unblock() async {
    setState(() => loading = true);

    try {
      await ChannelBlockApi.unblockChannel(widget.channelId);

      if (!mounted) return;

      setState(() {
        blocked = false;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Channel unblocked ✅")),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  String get _text {
    if (loading) return "Please wait...";
    if (blocked) return "Unblock Channel";
    if (joined) return "Joined";
    return "Join Channel";
  }

  VoidCallback? get _action {
    if (loading || joined) return null;
    if (blocked) return _unblock;
    return _join;
  }

  Color get _color {
    if (blocked) return Colors.orange;
    if (joined) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(14),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _action,
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _text,
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}