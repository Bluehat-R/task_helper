import 'package:flutter/material.dart';
import 'mood_repository.dart';

class MoodLogPage extends StatefulWidget {
  const MoodLogPage({super.key});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  List<MoodEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await MoodRepository.instance.getAllMoods();
    setState(() => _entries = data);
  }

  IconData _iconForMood(int level) {
    if (level >= 4) return Icons.sentiment_satisfied;
    if (level == 3) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  Color _colorForMood(int level) {
    if (level >= 4) return Colors.green;
    if (level == 3) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンタル記録ログ')),
      body: _entries.isEmpty
          ? const Center(child: Text('まだ記録がありません'))
          : ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                _iconForMood(entry.mood),
                color: _colorForMood(entry.mood),
                size: 32,
              ),
              title: Text(
                "日付: ${entry.date.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("気分: ${entry.mood} / 睡眠: ${entry.sleepHours}h"),
                  Text("服薬: ${entry.medicines.isEmpty ? 'なし' : entry.medicines.join(', ')}"),
                  if (entry.note != null && entry.note!.isNotEmpty)
                    Text("メモ: ${entry.note}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
