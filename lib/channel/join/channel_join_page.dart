import 'package:flutter/material.dart';
import 'channel_join_api.dart';

class ChannelJoinPage extends StatefulWidget {
  final String code;
  final bool isPublic;

  const ChannelJoinPage({
    super.key,
    required this.code,
    required this.isPublic,
  });

  @override
  State<ChannelJoinPage> createState() => _ChannelJoinPageState();
}

class _ChannelJoinPageState extends State<ChannelJoinPage> {
  bool _loading = true;
  String? _error;

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
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = "Unable to join channel";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text(
                _error ?? "",
                style: const TextStyle(color: Colors.red),
              ),
      ),
    );
  }
}