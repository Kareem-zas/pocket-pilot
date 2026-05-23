import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockect_pilot/services/theme_service.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/services/userprofile_service.dart';
import 'package:pockect_pilot/view/geo_reminders_settings_page.dart';
import 'package:pockect_pilot/services/biometric_service.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
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

      final bioEnabled = await BiometricService.isBiometricsEnabled();
      setState(() {
        name = extractedName;
        biometric = bioEnabled;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black)),
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
    final themeService = Provider.of<ThemeService>(context);

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
              value: themeService.isDarkMode,
              onChanged: (val) {
                themeService.toggleTheme(val);
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
              onChanged: (val) async {
                if (val) {
                  final capable = await BiometricService.isDeviceCapable();
                  if (!capable) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Biometric login is not supported or configured on this device.")),
                      );
                    }
                    return;
                  }
                }
                await BiometricService.setBiometricsEnabled(val);
                setState(() => biometric = val);
              },
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeoRemindersSettingsPage()),
              );
            },
            child: _settingTile(
              icon: Icons.location_on,
              title: "Geo-Spatial Reminders",
              subtitle: "Manage location alerts & dwell logs",
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF7F1D1D)
                    : const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red[200]
                        : Colors.red,
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
