import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../app_database.dart';
import '../../mood_repository.dart';

class MoodChartPage extends StatefulWidget {
  const MoodChartPage({super.key});

  @override
  State<MoodChartPage> createState() => _MoodChartPageState();
}

class _MoodChartPageState extends State<MoodChartPage> {
  bool _loading = true;
  List<MoodEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('mood', orderBy: 'date ASC');
    setState(() {
      _entries = rows.map((e) => MoodEntry.fromMap(e)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンタル推移グラフ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? const Center(child: Text('データがありません'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "気分レベルの推移",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildMoodChart()),
            const SizedBox(height: 24),
            const Text(
              "睡眠時間の推移",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildSleepChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    final spots = <FlSpot>[];
    final dateLabels = <int, String>{};
    final formatter = DateFormat('MM/dd');

    for (int i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _entries[i].mood.toDouble()));
      dateLabels[i] = formatter.format(_entries[i].date);
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                return Text(
                  dateLabels[v.toInt()] ?? "",
                  style: const TextStyle(fontSize: 10),
                );
              },
              interval: 1,
            ),
          ),
        ),
        minY: 1,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.pinkAccent,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart() {
    final spots = <FlSpot>[];
    final dateLabels = <int, String>{};
    final formatter = DateFormat('MM/dd');

    for (int i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _entries[i].sleepHours));
      dateLabels[i] = formatter.format(_entries[i].date);
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                return Text(
                  dateLabels[v.toInt()] ?? "",
                  style: const TextStyle(fontSize: 10),
                );
              },
              interval: 1,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
