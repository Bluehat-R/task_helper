import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_database.dart';

class TaskLogPage extends StatefulWidget {
  const TaskLogPage({super.key});

  @override
  State<TaskLogPage> createState() => _TaskLogPageState();
}

class _TaskLogPageState extends State<TaskLogPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _logs = [];

  final _formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final db = await AppDatabase.instance.database;
    // ✅ ここで task_log テーブルを読むように変更
    final rows = await db.query(
      'task_log',
      orderBy: 'timestamp DESC',
    );
    setState(() {
      _logs = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("タスク行動ログ")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text("まだ行動ログがありません"))
          : RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            final action = log['action'] ?? '不明';
            final subject = log['subject'] ?? '不明な教科';
            final subtask = log['subtask_title'];
            final date = _formatDate(log['timestamp']);

            return Card(
              child: ListTile(
                leading: Icon(
                  action == "完了"
                      ? Icons.check_circle
                      : Icons.undo,
                  color: action == "完了"
                      ? Colors.green
                      : Colors.orange,
                  size: 40,
                ),
                title: Text(
                  log['task_title'] ?? '不明なタスク',
                  style:
                  const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "教科: $subject\n"
                      "${subtask != null ? "サブタスク: $subtask\n" : ""}"
                      "状態: $action\n"
                      "日時: $date",
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(dynamic val) {
    if (val == null) return '不明';
    try {
      return _formatter.format(DateTime.parse(val));
    } catch (_) {
      return val.toString();
    }
  }
}
