import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/dashboard/widgets/channel_card.dart';

import '../../channel/createpage/channel_api.dart';
import '../../channel/helpers/channel_open_helper.dart';
import '../../core/channel_info_refresh_bus.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  List<ChannelModel> _chats = [];
  bool _loading = true;
  bool _error = false;

  late final StreamSubscription<String> _refreshSub;

  @override
  void initState() {
    super.initState();
    _loadChats();

    _refreshSub = ChannelInfoRefreshBus.stream.listen((_) {
      if (mounted) _loadChats();
    });
  }

  @override
  void dispose() {
    _refreshSub.cancel();
    super.dispose();
  }

  // ================= LOAD =================

  Future<void> _loadChats() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      // 🚀 Parallel execution
      final results = await Future.wait([
        ChannelApi.getMyChannels(),
        ChannelApi.getJoinedChannels(),
      ]);

      final owned = results[0] as List<ChannelModel>;
      final joined = results[1] as List<ChannelModel>;

      // Remove duplicates
      final map = <String, ChannelModel>{
        for (final c in [...owned, ...joined]) c.id: c
      };

      final list = map.values.toList();

      // Sort by active status → fallback by id
      list.sort((a, b) {
        if (a.hasActiveStatus != b.hasActiveStatus) {
          return b.hasActiveStatus ? 1 : -1;
        }
        return b.id.compareTo(a.id);
      });

      if (!mounted) return;

      setState(() {
        _chats = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _reload() async => _loadChats();

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (_loading) return _loadingShimmer();

    return RefreshIndicator(
      onRefresh: _reload,
      child: _error
          ? _errorState()
          : _chats.isEmpty
              ? _emptyState()
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.4),
                  itemBuilder: (_, index) {
                    final chat = _chats[index];

                    return ChannelCard(
                      channel: chat,
                      onTap: () async {
                        final updated =
                            await ChannelOpenHelper.open(context, chat);

                        if (updated == true) {
                          _loadChats();
                        }
                      },
                    );
                  },
                ),
    );
  }

  // ================= SHIMMER =================

  Widget _loadingShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const CircleAvatar(radius: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 12,
                        width: 120,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Icon(Icons.forum_outlined, size: 70, color: Colors.grey),
        SizedBox(height: 18),
        Center(
          child: Text(
            "No chats yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            "Join or create a channel to start chatting",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ================= ERROR =================

  Widget _errorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 180),
        const Icon(Icons.error_outline,
            size: 60, color: Colors.redAccent),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            "Failed to load chats",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: _loadChats,
            child: const Text("Retry"),
          ),
        ),
      ],
    );
  }
}