import 'package:flutter/material.dart';
import 'package:frontenduser/channel/stars/user_member/stars_api.dart';
import 'package:frontenduser/channel/stars/user_member/stars_balance_model.dart';
import 'buy_stars_sheet.dart';

class BuyStarsPage extends StatefulWidget {
  const BuyStarsPage({super.key});

  @override
  State<BuyStarsPage> createState() => _BuyStarsPageState();
}

class _BuyStarsPageState extends State<BuyStarsPage> {
  StarsBalance? balance;
  bool loading = true;
  bool buying = false;

  @override
  void initState() {
    super.initState();
    loadBalance();
  }

  // =========================================================
  // ⭐ LOAD BALANCE
  // =========================================================

  Future<void> loadBalance() async {
    try {
      final b = await StarsApi.getBalance(); // ✅ FIXED

      if (!mounted) return;

      setState(() {
        balance = b;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load balance")),
      );
    }
  }

  // =========================================================
  // ⭐ BUY STARS
  // =========================================================

  Future<void> buy(int amount) async {
    if (buying) return;

    setState(() => buying = true);

    try {
      final newBalance = await StarsApi.buy(amount); // ✅ FIXED

      if (!mounted) return;

      setState(() {
        balance = newBalance; // API now returns full balance
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Purchased $amount ⭐")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase failed")),
      );
    } finally {
      if (mounted) setState(() => buying = false);
    }
  }

  // =========================================================
  // ⭐ BUY SHEET
  // =========================================================

  void _openBuySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => BuyStarsSheet(onBuy: buy),
    );
  }

  // =========================================================
  // ⭐ FORMAT LARGE NUMBERS
  // =========================================================

  String _format(int value) {
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
    final purchased = balance?.purchasedStars ?? 0;
    final earned = balance?.earnedStars ?? 0;
    final total = balance?.totalStars ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Fanzzi Stars"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBalance,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  const SizedBox(height: 20),

                  const Icon(
                    Icons.star_rounded,
                    size: 120,
                    color: Colors.amber,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Fanzzi Stars",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Buy stars to unlock content and support creators",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 28),

                  _buildBalanceCard(purchased, earned, total),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // ⭐ BALANCE CARD
  // =========================================================

  Widget _buildBalanceCard(
      int purchased, int earned, int total) {
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star,
                  color: Colors.amber, size: 30),
              const SizedBox(width: 6),
              Text(
                _format(total),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            "Total Stars",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: buying ? null : _openBuySheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: buying
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Buy Stars",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}