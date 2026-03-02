class StarsBalance {
  final int purchasedStars;
  final int earnedStars;
  final int totalStars;

  StarsBalance({
    required this.purchasedStars,
    required this.earnedStars,
    required this.totalStars,
  });

  factory StarsBalance.fromJson(Map<String, dynamic> json) {
    return StarsBalance(
      purchasedStars: json["purchasedStars"] ?? 0,
      earnedStars: json["earnedStars"] ?? 0,
      totalStars: json["totalStars"] ?? 0,
    );
  }
}