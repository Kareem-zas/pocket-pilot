import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pockect_pilot/services/forecast_service.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _historical = [];
  List<dynamic> _predicted = [];
  String _activeFilter = 'BALANCE'; // BALANCE, INCOME, EXPENSES, SAVINGS

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ForecastService.getForecast();
      setState(() {
        _historical = data['historical'] ?? [];
        _predicted = data['predicted'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  double _getValue(dynamic item, String filter) {
    final val = item[filter.toLowerCase()];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Beautiful Sleek Dark Theme
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent))
            : _error != null
                ? _buildErrorWidget()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 25),
                        _buildFilterChips(),
                        const SizedBox(height: 25),
                        _buildChartCard(),
                        const SizedBox(height: 25),
                        _buildOverviewCard(),
                        const SizedBox(height: 25),
                        _buildForecastingFeed(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 70, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              "Forecasting Unavailable",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? "Please ensure your server is active and online.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _loadForecast,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("Retry Connection",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI TIME-TRAVEL FORECAST",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueAccent.shade100,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                "6-Month Projection",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip("Balance", "BALANCE", Colors.greenAccent),
        _chip("Income", "INCOME", Colors.blueAccent),
        _chip("Expenses", "EXPENSES", Colors.orangeAccent),
        _chip("Net Save", "SAVINGS", Colors.purpleAccent),
      ],
    );
  }

  Widget _chip(String label, String filter, Color activeColor) {
    final bool active = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.15) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: active ? activeColor : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? activeColor : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    if (_historical.isEmpty && _predicted.isEmpty) {
      return const SizedBox.shrink();
    }

    // Combine historical and predicted points
    List<FlSpot> histSpots = [];
    List<FlSpot> predSpots = [];

    // Map month names
    List<String> labels = [];

    for (int i = 0; i < _historical.length; i++) {
      final val = _getValue(_historical[i], _activeFilter);
      histSpots.add(FlSpot(i.toDouble(), val));
      labels.add(_historical[i]['month'].toString().substring(5)); // e.g. "05"
    }

    // The first prediction point must connect to the last historical point
    if (_historical.isNotEmpty && _predicted.isNotEmpty) {
      final lastHistVal = _getValue(_historical.last, _activeFilter);
      predSpots.add(FlSpot((_historical.length - 1).toDouble(), lastHistVal));
    }

    for (int i = 0; i < _predicted.length; i++) {
      final val = _getValue(_predicted[i], _activeFilter);
      predSpots.add(FlSpot((_historical.length + i).toDouble(), val));
      labels.add(_predicted[i]['month'].toString().substring(5));
    }

    // Determine max value for Y bounds
    double maxVal = 10.0;
    for (var spot in histSpots) {
      if (spot.y > maxVal) maxVal = spot.y;
    }
    for (var spot in predSpots) {
      if (spot.y > maxVal) maxVal = spot.y;
    }
    maxVal = maxVal * 1.2;

    Color lineColor = Colors.greenAccent;
    if (_activeFilter == 'INCOME') lineColor = Colors.blueAccent;
    if (_activeFilter == 'EXPENSES') lineColor = Colors.orangeAccent;
    if (_activeFilter == 'SAVINGS') lineColor = Colors.purpleAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_activeFilter[0]}${_activeFilter.substring(1).toLowerCase()} Trajectory",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  const Text("Solid: History • Dashed: Projection",
                      style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology,
                    color: Colors.blueAccent, size: 20),
              )
            ],
          ),
          const SizedBox(height: 35),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final int idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          final bool isPredicted = idx >= _historical.length;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[idx],
                              style: TextStyle(
                                color: isPredicted ? Colors.blueAccent : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (labels.length - 1).toDouble(),
                minY: 0,
                maxY: maxVal,
                lineBarsData: [
                  // Historical Solid Line
                  LineChartBarData(
                    spots: histSpots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.1),
                    ),
                  ),
                  // Predicted Dashed Line
                  LineChartBarData(
                    spots: predSpots,
                    isCurved: true,
                    color: lineColor.withValues(alpha: 0.8),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dashArray: [5, 5],
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    double initialBalance = 0.0;
    double projectedEndBalance = 0.0;
    double netSavingsSum = 0.0;

    if (_historical.isNotEmpty) {
      initialBalance = _getValue(_historical.last, 'BALANCE');
    }
    if (_predicted.isNotEmpty) {
      projectedEndBalance = _getValue(_predicted.last, 'BALANCE');
      netSavingsSum = _predicted.map((h) => _getValue(h, 'SAVINGS')).reduce((sum, val) => sum + val);
    }

    final balanceGrowth = projectedEndBalance - initialBalance;
    final growthPercent = initialBalance > 0 ? (balanceGrowth / initialBalance) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI Financial Analysis",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric("Projected Balance Growth", "\$${balanceGrowth.toStringAsFixed(0)}",
                  "+${growthPercent.toStringAsFixed(1)}%", Colors.greenAccent),
              _metric("Total Projected Savings", "\$${netSavingsSum.toStringAsFixed(0)}",
                  "6 Months", Colors.purpleAccent),
            ],
          ),
          const Divider(color: Colors.white12, height: 30),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  netSavingsSum >= 0
                      ? "AI projects that maintaining your velocity will increase your wallet balance by ${growthPercent.toStringAsFixed(0)}% in 6 months."
                      : "Warning: High forecasted variable spending is eroding savings. Consider cutting dynamic expenses.",
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String badge, Color badgeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(badge,
                  style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            )
          ],
        )
      ],
    );
  }

  Widget _buildForecastingFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detailed Forecast Schedule",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 15),
        ..._predicted.map((item) {
          final String month = item['month'];
          final double inc = _getValue(item, 'INCOME');
          final double exp = _getValue(item, 'EXPENSES');
          final double bal = _getValue(item, 'BALANCE');
          final double sav = _getValue(item, 'SAVINGS');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(month,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      "In: +\$${inc.toStringAsFixed(0)} | Out: -\$${exp.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$${bal.toStringAsFixed(0)}",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      sav >= 0 ? "Saved: +\$${sav.toStringAsFixed(0)}" : "Loss: -\$${sav.abs().toStringAsFixed(0)}",
                      style: TextStyle(
                          color: sav >= 0 ? Colors.purpleAccent : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}
