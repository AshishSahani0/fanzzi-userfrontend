import 'package:flutter/material.dart';
import 'package:frontenduser/channel/block/channel_block_api.dart';
import 'package:frontenduser/channel/join/channel_join_api.dart';
import 'package:frontenduser/channel/membership/channel_membership_api.dart';

class ChannelJoinButton extends StatefulWidget {
  final String channelId;
  final String code;
  final bool isPublic;
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

class _ChannelJoinButtonState
    extends State<ChannelJoinButton> {

  final ValueNotifier<_JoinState> _state =
      ValueNotifier(_JoinState.loading);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final blocked =
          await ChannelBlockApi.isBlocked(widget.channelId);

      if (blocked) {
        _state.value = _JoinState.blocked;
        return;
      }

      final member =
          await ChannelMembershipApi.isMember(widget.channelId);

      _state.value =
          member ? _JoinState.joined : _JoinState.ready;
    } catch (_) {
      _state.value = _JoinState.ready;
    }
  }

  Future<void> _join() async {
    if (_state.value != _JoinState.ready) return;

    _state.value = _JoinState.loading;

    try {
      if (widget.isPublic) {
        await ChannelJoinApi.joinBySlug(widget.code);
      } else {
        await ChannelJoinApi.joinByToken(widget.code);
      }

      _state.value = _JoinState.joined;
      widget.onJoined?.call();
    } catch (_) {
      _state.value = _JoinState.ready;
    }
  }

  Future<void> _unblock() async {
    _state.value = _JoinState.loading;

    try {
      await ChannelBlockApi.unblockChannel(widget.channelId);
      _state.value = _JoinState.ready;
    } catch (_) {
      _state.value = _JoinState.blocked;
    }
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_JoinState>(
      valueListenable: _state,
      builder: (_, state, __) {
        final isLoading = state == _JoinState.loading;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : state == _JoinState.blocked
                        ? _unblock
                        : state == _JoinState.ready
                            ? _join
                            : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color(state),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_text(state)),
              ),
            ),
          ),
        );
      },
    );
  }

  String _text(_JoinState state) {
    switch (state) {
      case _JoinState.loading:
        return "Please wait...";
      case _JoinState.blocked:
        return "Unblock Channel";
      case _JoinState.joined:
        return "Joined";
      case _JoinState.ready:
      default:
        return "Join Channel";
    }
  }

  Color _color(_JoinState state) {
    switch (state) {
      case _JoinState.blocked:
        return Colors.orange;
      case _JoinState.joined:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}

enum _JoinState {
  loading,
  blocked,
  joined,
  ready,
}