import 'package:flutter/material.dart';
import 'package:frontenduser/channel/api/channel_report_admin_api.dart';
import 'package:frontenduser/channel/model/channel_report_model.dart';

class ChannelReportsPage extends StatefulWidget {
  final String channelId;

  const ChannelReportsPage({super.key, required this.channelId});

  @override
  State<ChannelReportsPage> createState() => _ChannelReportsPageState();
}

class _ChannelReportsPageState extends State<ChannelReportsPage> {
  late Future<List<ChannelReportModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ChannelReportAdminApi
        .fetchReports(widget.channelId)
        .timeout(const Duration(seconds: 10));
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Channel Reports")),
      body: FutureBuilder<List<ChannelReportModel>>(
        future: _future,
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return _errorState(context, snapshot.error.toString());
          }

          // 📭 Empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No reports yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final reports = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = reports[i];

                return ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: Row(
                    children: [
                      _reasonChip(r.reason),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(r.reportedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: r.description.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(r.description),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              "Failed to load reports",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 Reason badge
  Widget _reasonChip(String reason) {
    final color = switch (reason) {
      "ABUSE" => Colors.red,
      "FAKE" => Colors.orange,
      "SPAM" => Colors.purple,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        reason,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}