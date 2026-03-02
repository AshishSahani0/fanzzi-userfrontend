import 'package:frontenduser/auth/config/api_client.dart';
import 'stars_balance_model.dart';

class StarsApi {

  // =============================
  // ⭐ GET BALANCE
  // =============================
  static Future<StarsBalance> getBalance() async {
    final res =
        await ApiClient.dio.get("/api/stars/balance");

    return StarsBalance.fromJson(res.data);
  }

  // =============================
  // ⭐ BUY STARS
  // =============================
  static Future<StarsBalance> buy(int amount) async {
    await ApiClient.dio.post(
      "/api/stars/buy",
      queryParameters: {"amount": amount},
    );

    // After buying → reload balance
    return await getBalance();
  }
}