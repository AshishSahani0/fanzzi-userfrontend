import 'package:flutter/material.dart';
import 'package:frontenduser/channel/status/channel_status_api.dart';
import 'channel_status_view_model.dart';

class ChannelStatusViewsPage extends StatefulWidget {

  final String channelId;
  final String statusId;

  const ChannelStatusViewsPage({
    super.key,
    required this.channelId,
    required this.statusId,
  });

  @override
  State<ChannelStatusViewsPage> createState() =>
      _ChannelStatusViewsPageState();
}

class _ChannelStatusViewsPageState
    extends State<ChannelStatusViewsPage> {

  List<ChannelStatusViewModel> viewers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {

    try {

      final v = await ChannelStatusApi.getViewers(
        widget.channelId,
        widget.statusId,
      );

      if (!mounted) return;

      setState(() {
        viewers = v;
        loading = false;
      });

    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [

          /// Drag handle (Instagram style)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text(
            "Seen by",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : viewers.isEmpty
                    ? const Center(
                        child: Text(
                          "No views yet",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: viewers.length,
                        itemBuilder: (_, i) {

                          final v = viewers[i];

                          return ListTile(

                            /// PROFILE IMAGE
                            leading: CircleAvatar(
                              backgroundImage: v.viewerProfile != null
                                  ? NetworkImage(v.viewerProfile!)
                                  : null,
                              child: v.viewerProfile == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),

                            /// USER NAME
                            title: Text(
                              v.viewerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            /// VIEW TIME
                            subtitle: Text(
                              _formatTime(v.viewedAt),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";

    return "${diff.inDays}d ago";
  }
}