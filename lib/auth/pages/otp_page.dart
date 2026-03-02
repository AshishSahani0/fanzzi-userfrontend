import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../../core/error/error_handler.dart';
import '../../core/services/auth_service.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
  final String countryCode;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.resendToken,
    required this.countryCode,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late String verificationId;
  int? resendToken;

  final otpController = TextEditingController();

  bool isLoading = false;
  bool resendLoading = false;

  int cooldown = 60; // ⭐ Start immediately
  Timer? timer;

  @override
  void initState() {
    super.initState();

    verificationId = widget.verificationId;
    resendToken = widget.resendToken;

    startCooldown(); // ⭐ START TIMER ON OPEN
  }

  // 🔁 Cooldown Timer
  void startCooldown() {
    timer?.cancel(); // safety

    cooldown = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      setState(() {
        cooldown--;

        if (cooldown <= 0) {
          t.cancel();
        }
      });
    });
  }

  // ✅ VERIFY OTP
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final user = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final firebaseToken =
          await user.user!.getIdToken();

      await AuthService.backendLogin(
        firebaseToken!,
        widget.countryCode,
        context,
      );

    } catch (e) {
      String message = "OTP verification failed";

      if (e is FirebaseAuthException) {
        message = e.message ?? message;
      } else if (e is DioException) {
        message = getErrorMessage(e);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() => isLoading = false);
  }

  // 🔄 RESEND OTP
  Future<void> resendOtp() async {
    if (cooldown > 0) return;

    setState(() => resendLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: resendToken,

      verificationCompleted: (_) {},

      verificationFailed: (e) {
        setState(() => resendLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Resend failed")),
        );
      },

      codeSent: (id, token) {
        setState(() {
          resendLoading = false;
          verificationId = id;
          resendToken = token;
        });

        startCooldown(); // ⭐ restart timer

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent")),
        );
      },

      codeAutoRetrievalTimeout: (_) {
        setState(() => resendLoading = false);
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            Text(
              "Code sent to ${widget.phoneNumber}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// 🔷 OTP INPUT
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                counterText: "",
                hintText: "------",
              ),
            ),

            const SizedBox(height: 20),

            /// 🚀 VERIFY BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify"),
              ),
            ),

            const SizedBox(height: 25),

            /// ⏱ TIMER + RESEND UI
            Column(
              children: [

                Text(
                  cooldown > 0
                      ? "Resend available in $cooldown sec"
                      : "Didn't receive the code?",
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 6),

                TextButton(
                  onPressed:
                      (cooldown > 0 || resendLoading)
                          ? null
                          : resendOtp,
                  child: resendLoading
                      ? const CircularProgressIndicator()
                      : const Text("Resend Code"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}