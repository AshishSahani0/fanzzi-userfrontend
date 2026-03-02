import 'package:flutter/material.dart';
import 'package:frontenduser/profile/user_api.dart';
import 'package:frontenduser/channel/createpage/create_channel_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  String phone = "";
  String username = "";
  String dob = "";

  bool loading = true;
  bool saving = false; // ⭐ NEW

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final user = await UserApi.getMe();

    setState(() {
      firstNameCtrl.text = user["firstName"] ?? "";
      lastNameCtrl.text = user["lastName"] ?? "";
      bioCtrl.text = user["bio"] ?? "";

      phone = user["phone"] ?? "";
      username = user["userName"] ?? "";
      dob = user["dateOfBirth"] ?? "";

      loading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => saving = true);

    try {
      await UserApi.updateProfile({
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "bio": bioCtrl.text.trim(),
        "userName": username,
        "dateOfBirth": dob,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));

      Navigator.pop(context); // optional
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Colors.white,
        elevation: 0,

        /// ⭐ SAVE BUTTON IN NAVBAR
        actions: [
          saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: "Save",
                  onPressed: _saveProfile,
                ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          /// 🔹 YOUR INFO
          _section([
            _title("Your Info"),

            _tile(
              icon: Icons.phone_outlined,
              title: phone.isEmpty ? "Add phone" : phone,
              subtitle: "Tap to change phone",
              onTap: _changePhone,
            ),

            _divider(),

            _tile(
              icon: Icons.alternate_email,
              title: username.isEmpty ? "Set username" : "@$username",
              subtitle: "Username",
              onTap: _editUsername,
            ),

            _divider(),

            _actionTile(
              icon: Icons.cake_outlined,
              title: dob.isEmpty ? "Add Birthday" : dob,
              onTap: _pickBirthday,
            ),
          ]),

          const SizedBox(height: 16),

          /// 🔹 NAME
          _section([
            _title("Your name"),
            _nameField(firstNameCtrl, "First name"),
            _divider(),
            _nameField(lastNameCtrl, "Last name"),
          ]),

          const SizedBox(height: 16),

          /// 🔹 BIO
          _section([
            _title("Your bio"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: bioCtrl,
                maxLength: 70,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Write about yourself...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          /// 🔹 ACTIONS
          _section([
            _title("Actions"),

            _actionTile(
              icon: Icons.campaign_outlined,
              title: "Add Personal Channel",
              onTap: _addPersonalChannel,
            ),

            _divider(),

            _actionTile(
              icon: Icons.logout,
              title: "Log Out",
              color: Colors.red,
              onTap: _logout,
            ),
          ]),
        ],
      ),
    );
  }

  // ================= FUNCTIONS =================

  Future<void> _editUsername() async {
    final ctrl = TextEditingController(text: username);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => username = result);
    }
  }

  Future<void> _changePhone() async {
    // Implement OTP flow here
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dob =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addPersonalChannel() async {
  final created = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CreateChannelPage(),
    ),
  );

  /// Optional: show success message after channel created
  if (created == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Channel created successfully")),
    );
  }
}

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  // ================= UI HELPERS =================

  Widget _section(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(children: children),
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    onTap: onTap,
  );

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(title, style: TextStyle(color: color)),
    onTap: onTap,
  );

  Widget _nameField(TextEditingController ctrl, String hint) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none),
    ),
  );

  Widget _divider() => const Divider(height: 1);
}
