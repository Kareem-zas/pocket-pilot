import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockect_pilot/services/geo_reminder_service.dart';
import 'package:pockect_pilot/utils/db_helper.dart';
import 'package:geolocator/geolocator.dart';

class GeoRemindersSettingsPage extends StatefulWidget {
  const GeoRemindersSettingsPage({super.key});

  @override
  State<GeoRemindersSettingsPage> createState() => _GeoRemindersSettingsPageState();
}

class _GeoRemindersSettingsPageState extends State<GeoRemindersSettingsPage> {
  bool _isTrackingEnabled = false;
  bool _isDemoModeEnabled = false;
  String _apiKey = '';
  List<Map<String, dynamic>> _dwellLogs = [];
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDwellLogs();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTrackingEnabled = prefs.getBool('geo_reminders_enabled') ?? false;
      _isDemoModeEnabled = prefs.getBool('geo_demo_mode') ?? false;
      _apiKey = prefs.getString('google_places_api_key') ?? '';
    });
  }

  Future<void> _loadDwellLogs() async {
    setState(() {
      _isLoadingLogs = true;
    });
    final logs = await DbHelper.getDwells();
    setState(() {
      _dwellLogs = logs;
      _isLoadingLogs = false;
    });
  }

  Future<void> _toggleTracking(bool value) async {
    if (value) {
      // Check location permissions first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionErrorDialog("GPS permission was denied. Please grant permissions to enable location reminders.");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showPermissionErrorDialog("GPS permission is permanently denied. Please enable it in device settings.");
        return;
      }

      await GeoReminderService.startTracking();
    } else {
      await GeoReminderService.stopTracking();
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTrackingEnabled = prefs.getBool('geo_reminders_enabled') ?? false;
    });
    _loadDwellLogs();
  }

  Future<void> _toggleDemoMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geo_demo_mode', value);
    setState(() {
      _isDemoModeEnabled = value;
    });

    // If already tracking, restart tracking to apply the new interval
    if (_isTrackingEnabled) {
      await GeoReminderService.stopTracking();
      await GeoReminderService.startTracking();
    }
  }

  Future<void> _saveApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_places_api_key', value);
    setState(() {
      _apiKey = value;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Key saved successfully!')),
    );
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to delete all dwell history logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DbHelper.clearDwells();
      _loadDwellLogs();
    }
  }

  void _showPermissionErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Needed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: _apiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Places API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optional: Enter your Google Places API Key. If empty, the app will fallback to simulated commercial zones around your location for demo stability.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'AIzaSy...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveApiKey(controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.blue[300] : const Color(0xFF0055D4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Geo-Spatial Reminders",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureIntroCard(),
              const SizedBox(height: 25),
              const Text(
                "SETTINGS",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingsTiles(),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "RECENT DWELL HISTORY",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_dwellLogs.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearLogs,
                      icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                      label: const Text(
                        "Clear History",
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0055D4), Color(0xFF1E5BD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Geofenced Alerts",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  "Pocket Pilot monitors when you dwell in commercial spots and gently prompts you to log expenses.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTiles() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _isTrackingEnabled,
            onChanged: _toggleTracking,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEFF7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.gps_fixed, color: isDark ? Colors.blue[300] : const Color(0xFF0055D4)),
            ),
            title: const Text("Location Reminders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("Monitor nearby shops & notify when dwelling", style: TextStyle(fontSize: 11)),
            activeColor: isDark ? Colors.blue[300] : const Color(0xFF0055D4),
          ),
          const Divider(height: 1, indent: 60),
          SwitchListTile(
            value: _isDemoModeEnabled,
            onChanged: _toggleDemoMode,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flash_on, color: Colors.orange),
            ),
            title: const Text("Demo Mode (10s Dwell)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("Reduces check interval to 5s & dwell to 10s", style: TextStyle(fontSize: 11)),
            activeColor: Colors.orange,
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEFF7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.api, color: isDark ? Colors.blue[300] : const Color(0xFF0055D4)),
            ),
            title: const Text("Google Places API Key", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              _apiKey.isEmpty ? "Simulated fallbacks active" : "Using custom Places key",
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: _showApiKeyDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_isLoadingLogs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dwellLogs.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off, size: 48, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No dwell logs recorded yet.",
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Start walking near simulated Starbucks, Target, or McDonald's to trigger logs.",
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 11),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dwellLogs.length,
      itemBuilder: (context, index) {
        final log = _dwellLogs[index];
        final entryTime = DateTime.tryParse(log['entryTime'] ?? '') ?? DateTime.now();
        final duration = log['durationMinutes'] ?? 0;
        final timeString = "${entryTime.hour.toString().padLeft(2, '0')}:${entryTime.minute.toString().padLeft(2, '0')} - ${entryTime.day}/${entryTime.month}/${entryTime.year}";

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green.withValues(alpha: 0.15) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store, color: Colors.green),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['placeName'] ?? 'Commercial Store',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isDemoModeEnabled ? "$duration sec" : "$duration min",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text("Dwell Duration", style: TextStyle(color: Colors.grey, fontSize: 9)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
