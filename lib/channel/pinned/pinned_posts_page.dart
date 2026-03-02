import 'package:flutter/material.dart';
import 'package:frontenduser/channel/post/post_card.dart';
import 'package:frontenduser/channel/post/post_model.dart';
import 'package:frontenduser/channel/stars/user_member/buy_stars_sheet.dart';
import 'package:frontenduser/channel/stars/user_member/stars_api.dart';
import 'pinned_api.dart';
import '../post/post_api.dart';

class PinnedPostsPage extends StatefulWidget {
  final String channelId;
  final bool isOwner; // 🔥 ADD THIS

  const PinnedPostsPage({
    super.key,
    required this.channelId,
    required this.isOwner,
  });

  @override
  State<PinnedPostsPage> createState() => _PinnedPostsPageState();
}

class _PinnedPostsPageState extends State<PinnedPostsPage> {
  List<PostModel> posts = [];
  bool loading = true;
  int purchasedStars = 0;

  // 🔥 Selection
  Set<String> selectedPosts = {};
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    loadPinned();
    loadBalance();
  }

  // ================= LOAD PINNED =================
  Future<void> loadPinned() async {
    final data = await PinnedApi.getAllPinned(widget.channelId);

    if (!mounted) return;

    setState(() {
      posts = data;
      loading = false;
    });
  }

  // ================= LOAD BALANCE =================
  Future<void> loadBalance() async {
    try {
      final balance = await StarsApi.getBalance();
      if (!mounted) return;

      setState(() {
        purchasedStars = balance.purchasedStars;
      });
    } catch (_) {}
  }

  // ================= SELECTION =================
  void startSelection(String postId) {
    if (!widget.isOwner) return;

    setState(() {
      selectionMode = true;
      selectedPosts.add(postId);
    });
  }

  void toggleSelection(String postId) {
    if (!widget.isOwner) return;

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
      selectionMode = false;
      selectedPosts.clear();
    });
  }

  // ================= UNPIN =================
  Future<void> unpinSelected() async {
    if (selectedPosts.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unpin Posts?"),
        content: Text(
          selectedPosts.length == 1
              ? "Unpin this post?"
              : "Unpin ${selectedPosts.length} posts?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Unpin"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (final id in selectedPosts) {
        await PinnedApi.unpinPost(widget.channelId, id);
      }

      setState(() {
        posts.removeWhere((p) => selectedPosts.contains(p.id));
        selectedPosts.clear();
        selectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post unpinned")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to unpin")),
      );
    }
  }

  // ================= UNLOCK =================
  Future<void> unlockPost(PostModel post) async {
    if (post.isUnlocked) return;

    if (purchasedStars < post.price) {
      _openBuySheet(post);
      return;
    }

    setState(() {
      purchasedStars -= post.price;

      final index = posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        posts[index] = post.copyWith(isUnlocked: true);
      }
    });

    try {
      await PostApi.unlockPost(post.id);
    } catch (_) {
      setState(() {
        purchasedStars += post.price;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unlock failed")),
      );
    }
  }

  void _openBuySheet(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BuyStarsSheet(
        onBuy: (amount) async {
          final newBalance = await StarsApi.buy(amount);

          setState(() {
            purchasedStars = newBalance.purchasedStars;
          });

          if (purchasedStars >= post.price) {
            unlockPost(post);
          }
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            selectionMode ? Colors.blue.shade700 : null,
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: cancelSelection,
              )
            : null,
        title: Text(
          selectionMode
              ? "${selectedPosts.length} selected"
              : "Pinned Posts",
        ),
        actions: selectionMode && widget.isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.push_pin),
                  onPressed: unpinSelected,
                ),
              ]
            : null,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text("No pinned posts"))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: posts.length,
                  itemBuilder: (_, i) {
                    final post = posts[i];
                    final isSelected =
                        selectedPosts.contains(post.id);

                    return GestureDetector(
                      onLongPress: widget.isOwner
                          ? () => startSelection(post.id)
                          : null,
                      onTap: selectionMode && widget.isOwner
                          ? () => toggleSelection(post.id)
                          : () => unlockPost(post),
                      child: Stack(
                        children: [
                          PostCard(
                            post: post,
                            onUnlock: () => unlockPost(post),
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                color: Colors.blue.withOpacity(0.25),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}