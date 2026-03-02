import 'package:flutter/material.dart';
import 'pinned_api.dart';

class PinnedBannerWidget extends StatefulWidget {
  final String channelId;
  final Function(List<String>) onPinnedLoaded;
  final VoidCallback onTap;
  final VoidCallback onViewAll;

  const PinnedBannerWidget({
    super.key,
    required this.channelId,
    required this.onPinnedLoaded,
    required this.onTap,
    required this.onViewAll,
  });

  @override
  State<PinnedBannerWidget> createState() =>
      _PinnedBannerWidgetState();
}

class _PinnedBannerWidgetState
    extends State<PinnedBannerWidget> {
  Map<String, dynamic>? bannerData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  Future<void> loadBanner() async {
    final data =
        await PinnedApi.getPinnedBanner(widget.channelId);

    if (!mounted) return;

    if (data != null) {
      final ids = (data["ids"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      widget.onPinnedLoaded(ids);
    }

    setState(() {
      bannerData = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || bannerData == null) {
      return const SizedBox.shrink();
    }

    final latest = bannerData!["latest"];
    final count = bannerData!["count"];

    return Material(
      color: Colors.amber.shade50,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.push_pin,
                  color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  latest["text"] ?? "Pinned post",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text("$count"),
              const SizedBox(width: 4),
              IconButton(
                onPressed: widget.onViewAll,
                icon: const Icon(Icons.open_in_new, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}