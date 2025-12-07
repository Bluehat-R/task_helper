import 'package:flutter/material.dart';
import 'log_page.dart';
import 'mood_log_page.dart';
import 'task_log_page.dart';
import 'mood_chart_page.dart';

class LogRootPage extends StatefulWidget {
  const LogRootPage({super.key});

  @override
  State<LogRootPage> createState() => _LogRootPageState();
}

class _LogRootPageState extends State<LogRootPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログ管理"),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "行動ログ"),
            Tab(text: "メンタル"),
            Tab(text: "タスク"),
            Tab(text: "グラフ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LogPage(),
          MoodLogPage(),
          TaskLogPage(),
          MoodChartPage(), // ← これがグラフタブ！
        ],
      ),
    );
  }
}
