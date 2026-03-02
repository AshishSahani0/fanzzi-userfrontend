import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Linkora Privacy Policy\n\n"
          "We respect your privacy.\n\n"
          "• Your phone number is used only for login.\n"
          "• We do not share user data with third parties.\n"
          "• Paid content is protected.\n\n"
          "More details will be added soon...",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
