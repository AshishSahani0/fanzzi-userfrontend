import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'otp_page.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  String fullPhoneNumber = "";
  String countryCode = "IN";

  bool isLoading = false;

  int cooldown = 0;
  Timer? timer;

  void startCooldown() {
    cooldown = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        cooldown--;
        if (cooldown == 0) t.cancel();
      });
    });
  }

  Future<void> sendOtp() async {
    if (fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }

    if (cooldown > 0) return;

    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,

      verificationCompleted: (_) {},

      verificationFailed: (e) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "OTP failed")),
        );
      },

      codeSent: (id, token) {
        setState(() => isLoading = false);
        startCooldown();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              verificationId: id,
              phoneNumber: fullPhoneNumber,
              resendToken: token,
              countryCode: countryCode,
            ),
          ),
        );
      },

      codeAutoRetrievalTimeout: (_) {
        setState(() => isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 TITLE
              const Text(
                "Login with Phone",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your mobile number to continue.\nWe will send you a verification code.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              /// 🔷 PHONE INPUT CARD
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      color: Colors.black.withAlpha(20),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IntlPhoneField(
                  initialCountryCode: "IN",
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Phone Number",
                  ),
                  onChanged: (phone) {
                    fullPhoneNumber = phone.completeNumber;
                  },
                  onCountryChanged: (c) {
                    countryCode = c.code;
                  },
                ),
              ),

              const SizedBox(height: 28),

              /// 🚀 SEND OTP BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed:
                      (isLoading || cooldown > 0)
                          ? null
                          : sendOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          cooldown > 0
                              ? "Wait $cooldown sec"
                              : "Send Verification Code",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔒 TRUST TEXT
              const Center(
                child: Text(
                  "Secure login • No spam • Privacy first",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}