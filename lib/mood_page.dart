import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_repository.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  List<String> _registeredMedicines = [];
  Map<String, bool> _checked = {};
  int _selectedMood = 3;
  double _sleepHours = 7;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('medicines') ?? [];
    setState(() {
      _registeredMedicines = list;
      for (var m in list) {
        _checked[m] = false;
      }
    });
  }

  Future<void> _saveMood() async {
    final selectedMeds =
    _checked.entries.where((e) => e.value).map((e) => e.key).toList();

    final entry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood,
      sleepHours: _sleepHours,
      medicines: selectedMeds,
      note: _noteController.text,
    );

    await MoodRepository.instance.saveMood(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メンタル記録を保存しました！')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("メンタル記録")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("今日の気分 (1〜5)"),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              label: _selectedMood.toString(),
              value: _selectedMood.toDouble(),
              onChanged: (v) => setState(() => _selectedMood = v.toInt()),
            ),
            const SizedBox(height: 16),
            const Text("睡眠時間（時間）"),
            Slider(
              min: 0,
              max: 12,
              divisions: 24,
              label: "${_sleepHours.toStringAsFixed(1)}h",
              value: _sleepHours,
              onChanged: (v) => setState(() => _sleepHours = v),
            ),
            const SizedBox(height: 16),
            const Text("服薬チェック"),
            Expanded(
              child: ListView(
                children: _registeredMedicines.map((name) {
                  return CheckboxListTile(
                    title: Text(name),
                    value: _checked[name] ?? false,
                    onChanged: (v) {
                      setState(() {
                        _checked[name] = v ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "メモ",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: _saveMood,
                child: const Text("記録する"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
