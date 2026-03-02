import 'package:flutter/material.dart';
import 'package:frontenduser/channel/createpage/channel_api.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/stars/creator/creator_earnings_api.dart';

class CreatorEarningsPage extends StatefulWidget {
  const CreatorEarningsPage({super.key});

  @override
  State<CreatorEarningsPage> createState() =>
      _CreatorEarningsPageState();
}

class _CreatorEarningsPageState
    extends State<CreatorEarningsPage> {

  List<ChannelModel> channels = [];
  Map<String, dynamic> summary = {};
  Map<String, Map<String, dynamic>> earningsByChannel = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =========================================================
  // ⭐ LOAD DATA
  // =========================================================

  Future<void> loadData() async {
    try {
      setState(() => loading = true);

      final results = await Future.wait([
        ChannelApi.getMyChannels(),
        CreatorEarningsApi.getSummary(),
        CreatorEarningsApi.getChannelEarnings(),
      ]);

      final channelList = results[0] as List<ChannelModel>;
      final summaryData =
          results[1] as Map<String, dynamic>;
      final earningsList =
          results[2] as List<Map<String, dynamic>>;

      final map = {
        for (var e in earningsList)
          (e["channelId"] ?? "") as String: e
      };

      if (!mounted) return;

      setState(() {
        channels = channelList;
        summary = summaryData;
        earningsByChannel = map;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load earnings: $e")),
      );
    }
  }

  // =========================================================
  // ⭐ SUMMARY GETTERS
  // =========================================================

  int get totalEarned =>
      summary["totalEarned"] ?? 0;

  int get monthlyEarned =>
      summary["monthlyEarned"] ?? 0;

  int get available =>
      summary["available"] ?? totalEarned;

  // =========================================================
  // ⭐ FORMAT LARGE NUMBERS
  // =========================================================

  String format(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    }
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toString();
  }

  // =========================================================
  // ⭐ BUILD UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creator Earnings"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  _summaryCard(),

                  const SizedBox(height: 18),

                  const Text(
                    "Channel Earnings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (channels.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "You haven't created any channels yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...channels.map(_channelTile).toList(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // ⭐ SUMMARY CARD
  // =========================================================

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [

          const Icon(
            Icons.monetization_on,
            size: 80,
            color: Colors.green,
          ),

          const SizedBox(height: 10),

          Text(
            "${format(totalEarned)} ⭐",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            "Total Earned",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [

              _miniStat(
                icon: Icons.calendar_month,
                label: "This Month",
                value: "${format(monthlyEarned)} ⭐",
                color: Colors.blue,
              ),

              _miniStat(
                icon: Icons.account_balance_wallet,
                label: "Available",
                value: "${format(available)} ⭐",
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // =========================================================
  // ⭐ CHANNEL TILE
  // =========================================================

  Widget _channelTile(ChannelModel channel) {
    final data = earningsByChannel[channel.id] ?? {};

    final earned = data["earnedStars"] ?? 0;
    final subscribers = data["subscribers"] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: channel.profileImageUrl != null
              ? NetworkImage(channel.profileImageUrl!)
              : null,
          child: channel.profileImageUrl == null
              ? Text(channel.name[0])
              : null,
        ),
        title: Text(channel.name),
        subtitle: Text("$subscribers subscribers"),
        trailing: Text(
          "${format(earned)} ⭐",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}