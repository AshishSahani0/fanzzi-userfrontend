import 'package:flutter/material.dart';
import 'phone_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,

        /// 🔷 Soft startup gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFF8FAFF),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            child: Column(
              children: [

                SizedBox(height: h * 0.06),

                /// 🔥 APP LOGO
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF2563EB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.blue.withAlpha(70),
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),

                const SizedBox(height: 36),

                /// ⭐ TITLE
                const Text(
                  "Welcome to Fanzzi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 14),

                /// ⭐ SUBTITLE
                const Text(
                  "Chat • Channels • Premium Content\nEarn from your audience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                /// 🔥 FEATURE CARD
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,
                        color: Colors.black.withAlpha(20),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FeatureBubble(
                        icon: Icons.chat_bubble_outline,
                        label: "Chat",
                      ),
                      FeatureBubble(
                        icon: Icons.groups_outlined,
                        label: "Channels",
                      ),
                      FeatureBubble(
                        icon: Icons.lock_outline,
                        label: "Paid",
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// 🚀 PRIMARY CTA
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhonePage(),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(22),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Continue with Phone",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// 🔒 TRUST TEXT
                const Text(
                  "Secure OTP Login • No Spam • Privacy First",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🔷 FEATURE BUBBLE

class FeatureBubble extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureBubble({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF2563EB),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}