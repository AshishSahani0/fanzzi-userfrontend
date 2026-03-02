import 'package:flutter/material.dart';
import 'package:frontenduser/channel/pinned/pinned_api.dart';
import 'package:frontenduser/channel/post/channel_feed_page.dart';
import 'package:frontenduser/channel/post/edit_post_page.dart';
import 'package:frontenduser/channel/post/post_model.dart';
import '../../model/channel_model.dart';

import '../channel_appbar.dart';
import '../channel_background.dart';
import '../broadcast_input_bar.dart';
import 'package:frontenduser/core/ui/glass_container.dart';

class ManageChannelPage extends StatefulWidget {
  final ChannelModel channel;

  const ManageChannelPage({super.key, required this.channel});

  @override
  State<ManageChannelPage> createState() => _ManageChannelPageState();
}

class _ManageChannelPageState extends State<ManageChannelPage> {
  final GlobalKey<ChannelFeedPageState> _feedKey =
      GlobalKey<ChannelFeedPageState>();

  /// ✅ Selection state moved here (PARENT CONTROLS IT)
  Set<String> selectedPosts = {};
  bool selectionMode = false;

  void startSelection() {
    if (!selectionMode) {
      setState(() {
        selectionMode = true;
      });
    }
  }

  void toggleSelection(String postId) {
    setState(() {
      if (selectedPosts.contains(postId)) {
        selectedPosts.remove(postId);
        if (selectedPosts.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedPosts.add(postId);
      }
    });
  }

  void cancelSelection() {
    setState(() {
      selectedPosts.clear();
      selectionMode = false;
    });
  }

  void deleteSelected() async {
    if (selectedPosts.isEmpty) return;

    await _feedKey.currentState?.deleteSelectedPostsFromParent(selectedPosts);

    setState(() {
      selectedPosts.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelAppBar(
        channel: widget.channel,
        selectionMode: selectionMode,
        selectedCount: selectedPosts.length,
        onCancelSelection: cancelSelection,
        onDelete: deleteSelected,
        onPin: () async {
  if (selectedPosts.length != 1) return;

  final postId = selectedPosts.first;

  try {
    await PinnedApi.pinPost(widget.channel.id, postId);

    final feedState = _feedKey.currentState;

    if (feedState != null) {
      final index =
          feedState.posts.indexWhere((p) => p.id == postId);

      if (index != -1) {
        // 🔥 Update post locally
        feedState.posts[index] =
            feedState.posts[index].copyWith(
          pinned: true,
          pinnedAt: DateTime.now(),
        );
      }

      // 🔥 Force feed rebuild
      feedState.setState(() {});

      // 🔥 Refresh banner safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        feedState.refreshPinnedBanner();
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post pinned")),
    );

    cancelSelection();
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to pin post")),
    );
  }
},

        onEdit: () async {
          if (selectedPosts.length != 1) return;

          final postId = selectedPosts.first;

          final post = _feedKey.currentState?.posts.firstWhere(
            (p) => p.id == postId,
          );

          if (post == null) return;

          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditPostPage(channelId: widget.channel.id, post: post),
            ),
          );

          if (updated != null && updated is PostModel) {
            _feedKey.currentState?.replacePost(updated);
          }

          cancelSelection();
        },
        onShare: () {},
      ),
      backgroundColor: Colors.transparent,
      body: ChannelBackground(
        child: Stack(
          children: [
            // ================= FEED =================
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: ChannelFeedPage(
                  key: _feedKey,
                  channelId: widget.channel.id,
                  channel: widget.channel,
                  isJoined: true,

                  /// ✅ Pass selection state down
                  selectedPosts: selectedPosts,
                  selectionMode: selectionMode,
                  onStartSelection: startSelection,
                  onToggleSelection: toggleSelection,
                ),
              ),
            ),

            // ================= BROADCAST BAR =================
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: SafeArea(
                top: false,
                child: GlassContainer(
                  borderRadius: 26,
                  blur: 20,
                  padding: EdgeInsets.zero,
                  child: BroadcastInputBar(
                    channelId: widget.channel.id,
                    onPost: (data) {
                      _feedKey.currentState?.sendPost(data);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
