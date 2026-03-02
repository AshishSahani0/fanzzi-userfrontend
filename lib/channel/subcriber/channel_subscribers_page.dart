import 'package:flutter/material.dart';
import 'package:frontenduser/channel/subcriber/channel_subscriber_api.dart';
import 'package:frontenduser/channel/model/channel_subscriber_model.dart';
import 'package:frontenduser/channel/subcriber/subscriber_card.dart';

class ChannelSubscribersPage extends StatefulWidget {
  final String channelId;

  const ChannelSubscribersPage({
    super.key,
    required this.channelId,
  });

  @override
  State<ChannelSubscribersPage> createState() =>
      _ChannelSubscribersPageState();
}

class _ChannelSubscribersPageState
    extends State<ChannelSubscribersPage> {

  List<ChannelSubscriberModel> subscribers = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadSubscribers();
  }

  Future<void> loadSubscribers() async {
    try {
      final list =
          await ChannelSubscriberApi.getSubscribers(widget.channelId);

      if (!mounted) return;

      setState(() {
        subscribers = list;
        loading = false;
        error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribers"),
      ),

      body: RefreshIndicator(
        onRefresh: loadSubscribers,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error) {
      return const Center(
        child: Text("Failed to load subscribers"),
      );
    }

    if (subscribers.isEmpty) {
      return const Center(
        child: Text(
          "No subscribers yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        /// ⭐ COUNT HEADER
        Text(
          "${subscribers.length} subscriber"
          "${subscribers.length == 1 ? '' : 's'}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        /// ⭐ HORIZONTAL LIST
        buildHorizontalList(subscribers),

        const SizedBox(height: 24),

        /// ⭐ OPTIONAL GRID VIEW (Telegram-style)
        const Text(
          "All Subscribers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        buildGrid(subscribers),
      ],
    );
  }

  Widget buildHorizontalList(List<ChannelSubscriberModel> list) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (_, index) {
          return SubscriberCard(subscriber: list[index]);
        },
      ),
    );
  }

  Widget buildGrid(List<ChannelSubscriberModel> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) {
        return SubscriberCard(subscriber: list[index]);
      },
    );
  }
}