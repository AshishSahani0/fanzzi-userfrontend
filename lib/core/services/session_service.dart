import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  static const storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await storage.write(key: "accessToken", value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: "accessToken");
  }

  static Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }

  static Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if (token == null) return true;
    return JwtDecoder.isExpired(token);
  }

  static Future<bool> hasValidSession() async {
    String? token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  static Future<String?> getRole() async {
    String? token = await getToken();
    if (token == null) return null;
    return JwtDecoder.decode(token)["role"];
  }

  static Future<void> logout() async {
    await storage.deleteAll();
  }

  static Future<void> clearAll() async {
  await storage.deleteAll();
}
}