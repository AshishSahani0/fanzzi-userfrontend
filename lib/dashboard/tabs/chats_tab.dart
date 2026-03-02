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
  ChatsTabState createState() => ChatsTabState();
}

class ChatsTabState extends State<ChatsTab> {
  List<ChannelModel> allChats = [];
  bool loading = true;
  bool error = false;

  late StreamSubscription<String> _refreshSub;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    loadChats();

    _refreshSub = ChannelInfoRefreshBus.stream.listen((_) {
      if (mounted) loadChats();
    });
  }

  // ================= LOAD =================

  Future<void> loadChats() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = false;
    });

    try {
      final owned = await ChannelApi.getMyChannels();
      final joined = await ChannelApi.getJoinedChannels();

      final map = <String, ChannelModel>{};

      for (final c in [...owned, ...joined]) {
        map[c.id] = c;
      }

      final list = map.values.toList()
        ..sort((a, b) => b.id.compareTo(a.id));

      if (!mounted) return;

      setState(() {
        allChats = list;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  Future<void> reload() async => loadChats();

  // ================= CLEANUP =================

  @override
  void dispose() {
    _refreshSub.cancel();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: loading
          ? _loadingShimmer()
          : RefreshIndicator(
              onRefresh: loadChats,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (error) _errorState(),

                  if (!error && allChats.isEmpty) _emptyState(),

                  if (!error && allChats.isNotEmpty)
                    ...allChats.map(
                      (chat) => Column(
                        children: [
                          ChannelCard(
                            channel: chat,
                            onTap: () async {
                              final updated =
                                  await ChannelOpenHelper.open(
                                      context, chat);

                              if (updated == true) {
                                loadChats();
                              }
                            },
                          ),
                          const Divider(
                              height: 1, thickness: 0.4),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // ================= SHIMMER =================

  Widget _loadingShimmer() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 70,
              color: Colors.grey.shade400),
          const SizedBox(height: 18),
          const Text(
            "No chats yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join or create a channel to start chatting",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ERROR =================

  Widget _errorState() {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 60, color: Colors.redAccent),
          const SizedBox(height: 14),
          const Text(
            "Failed to load chats",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: loadChats,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}