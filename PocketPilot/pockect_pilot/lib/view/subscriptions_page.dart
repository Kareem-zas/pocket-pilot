import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/subscription_service.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    try {
      final subs = await SubscriptionService.getSubscriptions();
      setState(() {
        _subscriptions = subs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _triggerRescan() async {
    setState(() => _isLoading = true);
    try {
      await SubscriptionService.triggerRescan();
      await _loadSubscriptions(); // Refresh list after rescan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rescan complete. Found latest subscriptions.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _cancelSubscription(String id) async {
    // Optimistic UI update
    final tempSubs = List.from(_subscriptions);
    setState(() {
      _subscriptions.removeWhere((sub) => sub['_id'] == id);
    });

    try {
      await SubscriptionService.cancelSubscription(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription tracking stopped.')),
        );
      }
    } catch (e) {
      // Revert if failed
      setState(() {
        _subscriptions = tempSubs;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showCancelDialog(String id, String vendor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262C49),
        title: const Text("Stop Tracking", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to stop tracking $vendor? Note: This only removes it from your Pocket Pilot dashboard, it does not cancel your actual bank or merchant subscription.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelSubscription(id);
            },
            child: const Text("Stop Tracking", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F35), // Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Subscription Radar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: _triggerRescan,
            tooltip: 'Rescan Transactions',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _subscriptions.isEmpty
                ? _buildEmptyState()
                : _buildList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text(
            "No Subscriptions Detected",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "We scan your transactions to find recurring monthly charges automatically. Tap the refresh icon to scan now.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _triggerRescan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5BD8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text("Scan Transactions", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final sub = _subscriptions[index];
        final vendorName = sub['vendor']?.toString().toUpperCase() ?? 'UNKNOWN';
        final amount = sub['amount']?.toString() ?? '0.00';
        final nextDateStr = sub['nextExpectedDate'];
        
        String formattedDate = '';
        if (nextDateStr != null) {
          final d = DateTime.tryParse(nextDateStr);
          if (d != null) {
            formattedDate = "${d.day}/${d.month}/${d.year}";
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF262C49),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.autorenew, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Next: $formattedDate",
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "\$$amount",
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showCancelDialog(sub['_id'], vendorName),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                  ),
                  child: const Text("Stop Tracking", style: TextStyle(color: Colors.redAccent)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
