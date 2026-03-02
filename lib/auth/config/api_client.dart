import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/services/session_service.dart';
import '../../core/device/device_service.dart';

class ApiClient {
  static late Dio dio;
  static late PersistCookieJar cookieJar;

  static Function()? onLogout;

  static const String mediaBaseUrl =
    "https://cdn.fanzzi.com";

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    cookieJar = PersistCookieJar(
      storage: FileStorage("${dir.path}/cookies"),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:6392",
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          final token = await SessionService.getToken();

          if (token != null) {
            options.headers["Authorization"] =
                "Bearer $token";
          }

          final deviceId =
              await DeviceService.getDeviceId();

          options.headers["X-Device-Id"] = deviceId;

          handler.next(options);
        },

        onError: (error, handler) async {

          if (error.response?.statusCode == 401) {

            bool refreshed =
                await forceRefreshToken();

            if (refreshed) {
              final req = error.requestOptions;

              final token =
                  await SessionService.getToken();

              req.headers["Authorization"] =
                  "Bearer $token";

              final response = await dio.fetch(req);
              return handler.resolve(response);
            }

            await SessionService.logout();
            onLogout?.call();
          }

          handler.next(error);
        },
      ),
    );
  }

  // 🔄 CALL /auth/user/refresh
  static Future<bool> forceRefreshToken() async {
    try {
      final deviceId =
          await DeviceService.getDeviceId();

      final res = await dio.post(
        "/auth/user/refresh",
        options: Options(
          headers: {"X-Device-Id": deviceId},
        ),
      );

      await SessionService.saveToken(
          res.data["accessToken"]);

      return true;
    } catch (_) {
      return false;
    }
  }

  static String buildPublicUrl(String? key) {
  if (key == null || key.isEmpty) return "";

  // Remove accidental leading slash
  final cleanKey =
      key.startsWith("/") ? key.substring(1) : key;

  return "$mediaBaseUrl/$cleanKey";
}
}