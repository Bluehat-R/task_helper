import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'log_repository.dart';
import 'log_model.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  bool _loading = true;
  List<LogEntry> _logs = [];

  final _formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await LogRepository.instance.getAllLogs();
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行動ログ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('まだログがありません'))
          : RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  _iconForType(log.type),
                  color: _colorForType(log.type),
                ),
                title: Text(log.type),
                subtitle: Text(_formatter.format(log.timestamp)),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pc_start':
        return Icons.computer;
      case 'task_finish':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'pc_start':
        return Colors.green;
      case 'task_finish':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
