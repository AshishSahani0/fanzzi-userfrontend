import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:camera/camera.dart';
import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/auth/pages/splash_page.dart';
import 'package:frontenduser/auth/pages/start_page.dart';
import 'package:frontenduser/channel/deep_link/channel_link_handler.dart';
import 'package:frontenduser/channel/join/channel_join_page.dart';
import 'package:frontenduser/dashboard/user_dashboard.dart';



/// ⭐ Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

/// ⭐ Global Camera List (VERY IMPORTANT)
late List<CameraDescription> globalCameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Initialize Firebase
  await Firebase.initializeApp();

  /// 🔥 Firebase Emulator (Dev Only)
  if (!kReleaseMode) {
    await FirebaseAuth.instance
        .useAuthEmulator("10.0.2.2", 9099);
  }

  /// 🔥 Initialize API Client
  await ApiClient.init();

  ApiClient.onLogout = () {
    navigatorKey.currentState!
        .pushNamedAndRemoveUntil("/start", (_) => false);
  };

  /// 🔥 VERY IMPORTANT — Initialize Cameras BEFORE runApp
  try {
    globalCameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera initialization error: $e");
    globalCameras = [];
  }

  runApp(const LinkoraApp());
}

class LinkoraApp extends StatefulWidget {
  const LinkoraApp({super.key});

  @override
  State<LinkoraApp> createState() =>
      _LinkoraAppState();
}

class _LinkoraAppState extends State<LinkoraApp> {
  @override
  void initState() {
    super.initState();

    /// 📎 Start Deep Link Listener ONCE
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      ChannelLinkHandler.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      themeMode: ThemeMode.system,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),

      routes: {
        "/start": (_) => const StartPage(),
        "/dashboard": (_) => const UserDashboard(),

        "/join": (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return ChannelJoinPage(
            code: args["code"],
            isPublic: args["isPublic"],
          );
        },
      },

      home: const SplashPage(),
    );
  }
}