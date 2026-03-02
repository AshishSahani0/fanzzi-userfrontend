import 'package:flutter/material.dart';

import '../../dashboard/user_dashboard.dart';
import '../config/api_client.dart';
import '../../core/services/session_service.dart';
import 'start_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    /// 🔥 Logo Fade Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    bool loggedIn = await SessionService.isLoggedIn();

    if (!loggedIn) {
      if (!mounted) return;
      _goStart();
      return;
    }

    bool expired = await SessionService.isTokenExpired();

    if (expired) {
      bool refreshed = await ApiClient.forceRefreshToken();

      if (!refreshed) {
        await SessionService.logout();

        if (!mounted) return;
        _goStart();
        return;
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const UserDashboard(),
      ),
    );
  }

  void _goStart() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const StartPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        /// 🔷 Premium Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔷 App Logo
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.black26,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    size: 60,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(height: 28),

                /// 🔷 App Name
                const Text(
                  "Fanzzi",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Creators • Chats • Premium Content",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                /// 🔷 Loading Indicator
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}