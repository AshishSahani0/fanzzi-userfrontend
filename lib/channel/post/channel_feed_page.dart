import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/pinned/pinned_banner_widget.dart';
import 'package:frontenduser/channel/pinned/pinned_posts_page.dart';
import 'package:frontenduser/channel/stars/user_member/buy_stars_sheet.dart';
import 'package:frontenduser/channel/stars/user_member/stars_api.dart';
import 'post_api.dart';
import 'post_model.dart';
import 'media_model.dart';
import 'post_card.dart';

// =======================================================
// FEED ITEM TYPES (MUST BE OUTSIDE STATE CLASS)
// =======================================================

abstract class FeedItem {}

class DateHeaderItem extends FeedItem {
  final DateTime date;
  DateHeaderItem(this.date);
}

class PostItem extends FeedItem {
  final PostModel post;
  PostItem(this.post);
}

// =======================================================
// CHANNEL FEED PAGE
// =======================================================

class ChannelFeedPage extends StatefulWidget {
  final String channelId;
  final ChannelModel channel;

  final Set<String> selectedPosts;
  final bool selectionMode;
  final Function(String) onToggleSelection;
  final VoidCallback onStartSelection;
  final bool isJoined;

  const ChannelFeedPage({
    super.key,
    required this.channelId,
    required this.channel,
    required this.isJoined,

    required this.selectedPosts,
    required this.selectionMode,
    required this.onToggleSelection,
    required this.onStartSelection,
  });

  @override
  State<ChannelFeedPage> createState() => ChannelFeedPageState();
}

class ChannelFeedPageState extends State<ChannelFeedPage> {
  List<PostModel> posts = [];

  int purchasedStars = 0;

  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;

  DateTime? lastTimestamp;
  final ScrollController _scroll = ScrollController();

  List<String> pinnedIds = [];
  int currentPinnedIndex = 0;

  final Map<String, GlobalKey> _postKeys = {};
  final GlobalKey _bannerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadPosts(initial: true);
    loadBalance();

    _scroll.addListener(() {
      if (_scroll.position.pixels <= 100 && !loadingMore) {
        loadPosts();
      }
    });
  }

  // =======================================================
  // SCROLL TO SPECIFIC POST (FOR PIN CYCLING)
  // =======================================================

  void scrollToPost(String postId) {
    final feedItems = _buildFeedItems();

    final index = feedItems.indexWhere(
      (item) => item is PostItem && item.post.id == postId,
    );

    if (index == -1) return;
    if (!_scroll.hasClients) return;

    // Approximate item height
    const double estimatedItemHeight = 320;

    final targetOffset = index * estimatedItemHeight;

    _scroll.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // =======================================================
  // CHECK + ENSURE PINNED POST IS LOADED
  // =======================================================

  bool isPostLoaded(String postId) {
    return posts.any((p) => p.id == postId);
  }

  Future<void> ensurePostLoaded(String postId) async {
    while (!isPostLoaded(postId) && hasMore) {
      await loadPosts();
    }
  }

  void handlePinnedTap() async {
    if (pinnedIds.isEmpty) return;

    final postId = pinnedIds[currentPinnedIndex];

    currentPinnedIndex++;
    if (currentPinnedIndex >= pinnedIds.length) {
      currentPinnedIndex = 0;
    }

    await ensurePostLoaded(postId);

    // Wait for rebuild
    await Future.delayed(const Duration(milliseconds: 50));

    scrollToPost(postId);
  }

  void setPinnedIds(List<String> ids) {
    pinnedIds = ids;
    currentPinnedIndex = 0;
  }

  void refreshPinnedBanner() {
    final state = _bannerKey.currentState as dynamic;
    state?.loadBanner();
  }

  // =======================================================
  // LOAD BALANCE
  // =======================================================

  Future<void> loadBalance() async {
    try {
      final balance = await StarsApi.getBalance();
      if (!mounted) return;

      setState(() {
        purchasedStars = balance.purchasedStars;
      });
    } catch (_) {}
  }

  // =======================================================
  // LOAD POSTS (Pagination)
  // =======================================================

  Future<void> loadPosts({bool initial = false}) async {
    if (!hasMore || loadingMore) return;

    loadingMore = true;

    final list = await PostApi.getPosts(
      widget.channelId,
      before: lastTimestamp,
    );

    if (!mounted) return;

    if (list.isEmpty) {
      hasMore = false;
    } else {
      final ordered = list.reversed.toList();
      lastTimestamp = list.last.createdAt;

      if (initial) {
        posts = ordered;
      } else {
        posts.insertAll(0, ordered);
      }
    }

    setState(() {
      loading = false;
      loadingMore = false;
    });

    if (initial) _scrollToBottom();
  }

  // =======================================================
  // DATE GROUPING
  // =======================================================

  List<FeedItem> _buildFeedItems() {
    List<FeedItem> items = [];
    DateTime? lastDate;

    for (final post in posts) {
      final date = DateTime(
        post.createdAt.year,
        post.createdAt.month,
        post.createdAt.day,
      );

      if (lastDate == null || date != lastDate) {
        items.add(DateHeaderItem(date));
        lastDate = date;
      }

      items.add(PostItem(post));
    }

    return items;
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          child: Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return "Today";
    if (date == yesterday) return "Yesterday";

    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${months[date.month]} ${date.day}";
  }

  // =======================================================
  // AUTO SCROLL
  // =======================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void replacePost(PostModel updated) {
    final index = posts.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      setState(() {
        posts[index] = updated;
      });
    }
  }

  // =======================================================
  // UNLOCK POST (Optimistic)
  // =======================================================

  Future<void> unlockPost(PostModel post) async {
    if (!(widget.channel.owner || widget.isJoined)) {
      return;
    }
    if (post.isUnlocked) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unlock Content"),
        content: Text("This post costs ${post.price} stars.\n\nProceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (purchasedStars < post.price) {
      _openBuySheet(post);
      return;
    }

    setState(() {
      purchasedStars -= post.price;

      final index = posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        posts[index] = PostModel(
          id: post.id,
          text: post.text,
          media: post.media,
          type: post.type,
          price: post.price,
          createdAt: post.createdAt,
          updatedAt: DateTime.now(),
          edited: true,
          views: post.views,
          isUnlocked: true,
        );
      }
    });

    try {
      await PostApi.unlockPost(post.id);
    } catch (_) {
      setState(() {
        purchasedStars += post.price;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unlock failed")));
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

  Future<void> deleteSelectedPostsFromParent(Set<String> ids) async {
    try {
      await PostApi.deleteMultiple(widget.channelId, ids.toList());

      setState(() {
        posts.removeWhere((p) => ids.contains(p.id));
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Posts deleted")));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Delete failed")));
    }
  }

  // =======================================================
  // SEND POST (Optimistic)
  // =======================================================

  Future<void> sendPost(Map data) async {
    final files = data["files"] as List<File>;
    final text = data["text"] as String;
    final isPaid = data["isPaid"] as bool;
    final price = data["price"] as int;

    final tempPost = PostModel(
      id: "temp_${DateTime.now().millisecondsSinceEpoch}",
      text: text,
      media: files
          .map(
            (f) => MediaModel(
              key: "",
              url: f.path,
              type: _detectLocalType(f.path),
            ),
          )
          .toList(),
      type: isPaid ? "PAID" : "FREE",
      price: price,
      createdAt: DateTime.now(),
      updatedAt: null,
      edited: false,
      views: 0,
      isUnlocked: !isPaid,
    );

    setState(() => posts.add(tempPost));
    _scrollToBottom();

    try {
      final uploadedMedia = await Future.wait(
        files.map((f) => PostApi.uploadMedia(f)),
      );

      final created = await PostApi.createPost(
        channelId: widget.channelId,
        text: text,
        media: uploadedMedia,
        type: isPaid ? "PAID" : "FREE",
        price: price,
      );

      setState(() {
        final index = posts.indexOf(tempPost);
        if (index != -1) {
          posts[index] = created;
        }
      });

      _scrollToBottom();
    } catch (_) {
      setState(() => posts.remove(tempPost));
    }
  }

  // =======================================================
  // BUILD
  // =======================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final feedItems = _buildFeedItems();

    return Container(
      color: const Color(0xFFE7F5E9),
      child: Column(
        children: [
          // ================= PINNED BANNER =================
          PinnedBannerWidget(
            key: _bannerKey,
            channelId: widget.channelId,
            onPinnedLoaded: setPinnedIds,
            onTap: handlePinnedTap,
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PinnedPostsPage(
                    channelId: widget.channelId,
                    isOwner: widget.channel.owner,
                  ),
                ),
              );
            },
          ),

          // ================= FEED =================
          Expanded(
            child: posts.isEmpty
                ? const Center(child: Text("No posts yet"))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: feedItems.length,
                    itemBuilder: (context, i) {
                      final item = feedItems[i];

                      // -------- DATE HEADER --------
                      if (item is DateHeaderItem) {
                        return _buildDateHeader(item.date);
                      }

                      // -------- POST ITEM --------
                      // -------- POST ITEM --------
                      if (item is PostItem) {
                        final post = item.post;
                        final isSelected = widget.selectedPosts.contains(
                          post.id,
                        );

                        _postKeys.putIfAbsent(post.id, () => GlobalKey());

                        // ============================================================
                        // 🔐 ACCESS CONTROL LOGIC
                        // ============================================================

                        final bool isOwner = widget.channel.owner;

                        // Owner OR joined user can interact
                        final bool canInteract = isOwner || widget.isJoined;

                        // Only owner can use selection mode
                        final bool canSelect = isOwner;

                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,

                          // LONG PRESS
                          onLongPress: () {
                            if (!canSelect) return;

                            widget.onStartSelection();
                            widget.onToggleSelection(post.id);
                          },

                          // TAP
                          onTap: () {
                            if (!canInteract) return;

                            if (widget.selectionMode && canSelect) {
                              widget.onToggleSelection(post.id);
                            }
                          },

                          child: Stack(
                            children: [
                              Container(
                                key: _postKeys[post.id],
                                child: PostCard(
                                  post: post,
                                  onUnlock: canInteract
                                      ? () => unlockPost(post)
                                      : null,
                                ),
                              ),

                              // ============================================================
                              // 🟦 SELECTION HIGHLIGHT (OWNER ONLY)
                              // ============================================================
                              if (isSelected && canSelect)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.blue.withOpacity(0.25),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _detectLocalType(String path) {
    final e = path.toLowerCase();

    if (e.endsWith(".mp4") || e.endsWith(".webm")) return "VIDEO";
    if (e.endsWith(".mp3") || e.endsWith(".wav")) return "AUDIO";
    if (e.endsWith(".pdf") || e.endsWith(".doc") || e.endsWith(".docx")) {
      return "DOCUMENT";
    }

    return "IMAGE";
  }
}
