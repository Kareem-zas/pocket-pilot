import 'package:flutter/material.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/services/userprofile_service.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool darkMode = false;
  bool notifications = true;
  bool biometric = false;

  String name = "User";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await UserService.getProfile();

      if (!mounted) return;

      String extractedName = "User";

      if (data['user'] != null) {
        extractedName =
            data['user']['fullName'] ??
            data['user']['name'] ??
            data['user']['username'] ??
            extractedName;
      } else if (data['data'] != null) {
        if (data['data']['user'] != null) {
          extractedName =
              data['data']['user']['fullName'] ??
              data['data']['user']['name'] ??
              data['data']['user']['username'] ??
              extractedName;
        } else {
          extractedName =
              data['data']['fullName'] ??
              data['data']['name'] ??
              data['data']['username'] ??
              extractedName;
        }
      }

      setState(() {
        name = extractedName;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains("token")) {
        await TokenService.clearToken();
        _goLogin();
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  void _goLogin() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> _logout() async {
    await TokenService.clearToken();
    _goLogin();
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, color: Colors.blue),
              Text("Pocket Pilot",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue)),
              CircleAvatar(radius: 18)
            ],
          ),

          const SizedBox(height: 30),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.person,
                    size: 60, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit,
                    size: 16, color: Colors.white),
              )
            ],
          ),

          const SizedBox(height: 20),

          Text(
            name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "PREMIUM PILOT MEMBER",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          Container(
            height: 45,
            width: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E5BD8), Color(0xFF3A7BFF)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                "Edit Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Account Settings",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 15),

          _settingTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            subtitle: "Switch between light and dark themes",
            trailing: Switch(
              value: darkMode,
              onChanged: (val) {
                setState(() => darkMode = val);
              },
            ),
          ),

          _settingTile(
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Real-time alerts for your spending",
            trailing: Switch(
              value: notifications,
              onChanged: (val) {
                setState(() => notifications = val);
              },
            ),
          ),

          _settingTile(
            icon: Icons.fingerprint,
            title: "Biometric Login",
            subtitle: "Face ID or fingerprint unlock",
            trailing: Switch(
              value: biometric,
              onChanged: (val) {
                setState(() => biometric = val);
              },
            ),
          ),

          _settingTile(
            icon: Icons.security,
            title: "Privacy & Security",
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          _settingTile(
            icon: Icons.help_outline,
            title: "Help Center",
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: _logout,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "POCKET PILOT V2.4.0",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}