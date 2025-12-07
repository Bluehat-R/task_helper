import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';
import 'package:sqflite/sqflite.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _medicineController = TextEditingController();
  List<Map<String, dynamic>> subjects = [];
  List<String> medicines = [];
  final db = AppDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final database = await db.database;
    final prefs = await SharedPreferences.getInstance();
    final subjResult = await database.query('subjects');
    setState(() {
      subjects = subjResult;
      medicines = prefs.getStringList('medicines') ?? [];
    });
  }

  Future<void> _toggleSubject(String name, bool active) async {
    final database = await db.database;
    await database.update(
      'subjects',
      {'active': active ? 1 : 0},
      where: 'name = ?',
      whereArgs: [name],
    );
    _loadAll();
  }

  Future<void> _addMedicine() async {
    final name = _medicineController.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      medicines.add(name);
      _medicineController.clear();
    });
    await prefs.setStringList('medicines', medicines);
  }

  Future<void> _deleteMedicine(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => medicines.removeAt(index));
    await prefs.setStringList('medicines', medicines);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // === 教科設定 ===
            const Text(
              "📚 教科設定",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            subjects.isEmpty
                ? const Text("まだ教科が登録されていません（Classroom同期後に表示）")
                : Column(
              children: subjects.map((sub) {
                final name = sub['name'] as String;
                final active = sub['active'] == 1;
                return Card(
                  child: ListTile(
                    title: Text(name),
                    trailing: Switch(
                      value: active,
                      onChanged: (v) => _toggleSubject(name, v),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 40),

            // === 薬設定 ===
            const Text(
              "💊 薬の設定",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _medicineController,
                    decoration: const InputDecoration(
                      hintText: "薬名を入力 (例: トリンテリックス)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _addMedicine, child: const Text("追加")),
              ],
            ),
            const SizedBox(height: 12),
            ...medicines.map((med) => Card(
              child: ListTile(
                title: Text(med),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _deleteMedicine(medicines.indexOf(med)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
