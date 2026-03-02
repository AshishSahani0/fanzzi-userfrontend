import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Wallet Balance"),
            SizedBox(height: 8),
            Text("₹12,450",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}