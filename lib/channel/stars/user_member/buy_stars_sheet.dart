import 'package:flutter/material.dart';

class BuyStarsSheet extends StatelessWidget {
  final Function(int amount) onBuy;

  const BuyStarsSheet({
    super.key,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// ⭐ Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          /// ⭐ Title
          const Text(
            "Buy Stars",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Choose a pack to purchase",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 18),

          /// ⭐ Purchase Options
          _pack(context, 100, "Most Popular", Colors.blue),
          _pack(context, 500, "Best Value", Colors.green),
          _pack(context, 1000, "", Colors.orange),
          _pack(context, 5000, "Mega Pack", Colors.purple),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// ⭐ Pack Card
  Widget _pack(
    BuildContext context,
    int amount,
    String badge,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pop(context);
          onBuy(amount);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black12,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [

              /// ⭐ Star Icon
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 28,
              ),

              const SizedBox(width: 12),

              /// ⭐ Amount
              Expanded(
                child: Text(
                  "$amount Stars",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// ⭐ Badge (optional)
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 10),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}