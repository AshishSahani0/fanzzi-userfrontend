import 'package:flutter/material.dart';
import 'package:frontenduser/channel/api/channel_report_api.dart';

class ReportChannelDialog extends StatefulWidget {
  final String channelId;

  const ReportChannelDialog({super.key, required this.channelId});

  @override
  State<ReportChannelDialog> createState() => _ReportChannelDialogState();
}

class _ReportChannelDialogState extends State<ReportChannelDialog> {
  String selectedReason = "SPAM";
  final TextEditingController controller = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      await ChannelReportApi.reportChannel(
        widget.channelId,
        selectedReason,
        controller.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 Report submitted")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ You already reported this channel"),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Report Channel"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedReason,
            items: const [
              DropdownMenuItem(value: "SPAM", child: Text("Spam")),
              DropdownMenuItem(value: "ABUSE", child: Text("Abuse")),
              DropdownMenuItem(value: "FAKE", child: Text("Fake / Scam")),
              DropdownMenuItem(value: "NSFW", child: Text("Adult Content")),
              DropdownMenuItem(value: "COPYRIGHT", child: Text("Copyright")),
              DropdownMenuItem(value: "OTHER", child: Text("Other")),
            ],
            onChanged: (v) => setState(() => selectedReason = v!),
            decoration: const InputDecoration(labelText: "Reason"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Additional details (optional)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Report"),
        ),
      ],
    );
  }
}