class AppConfig {
  static const bool isProd = false;

  static String get baseUrl =>
      isProd
          ? "https://api.yourdomain.com"
          : "http://10.0.2.2:6392";
}