import 'package:flutter/material.dart';
import 'app_database.dart';

class SubjectSettingsPage extends StatefulWidget {
  const SubjectSettingsPage({super.key});

  @override
  State<SubjectSettingsPage> createState() => _SubjectSettingsPageState();
}

class _SubjectSettingsPageState extends State<SubjectSettingsPage> {
  final db = AppDatabase.instance;
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final database = await db.database;
    final result = await database.query('subjects');
    setState(() => subjects = result);
  }

  Future<void> _toggleSubject(String name, bool active) async {
    final database = await db.database;
    await database.update(
      'subjects',
      {'active': active ? 1 : 0},
      where: 'name = ?',
      whereArgs: [name],
    );
    _loadSubjects();
  }

  Future<void> _deleteSubject(String name) async {
    final database = await db.database;
    await database.delete('subjects', where: 'name = ?', whereArgs: [name]);
    _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("教科設定")),
      body: subjects.isEmpty
          ? const Center(child: Text("まだ教科が登録されていません"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final name = subject['name'] as String;
          final active = subject['active'] == 1;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(name),
              trailing: Switch(
                value: active,
                onChanged: (val) => _toggleSubject(name, val),
              ),
              onLongPress: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("削除しますか？"),
                    content: Text("$name を完全に削除します。"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("キャンセル")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("削除")),
                    ],
                  ),
                );
                if (confirm == true) _deleteSubject(name);
              },
            ),
          );
        },
      ),
    );
  }
}
