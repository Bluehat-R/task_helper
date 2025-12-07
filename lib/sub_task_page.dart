import 'package:flutter/material.dart';
import 'app_database.dart';

class SubTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const SubTaskPage({super.key, required this.task});

  @override
  State<SubTaskPage> createState() => _SubTaskPageState();
}

class _SubTaskPageState extends State<SubTaskPage> {
  List<Map<String, dynamic>> subtasks = [];
  int? parentId;

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final db = await AppDatabase.instance.database;
    // 親タスクのIDを取得
    final parent = await db.query(
      'tasks',
      where: 'title = ? AND subject = ?',
      whereArgs: [widget.task["title"], widget.task["subject"]],
      limit: 1,
    );

    if (parent.isEmpty) return;
    parentId = parent.first["id"] as int;

    final result = await db.query(
      'subtasks',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );

    setState(() {
      subtasks = result
          .map((e) => {
        "id": e["id"],
        "title": e["title"],
        "done": e["done"] == 1,
      })
          .toList();
    });
  }

  Future<void> _addSubtask() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("サブタスクを追加"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "サブタスク名を入力"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("キャンセル")),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("追加")),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && parentId != null) {
      final db = await AppDatabase.instance.database;
      final id = await db.insert('subtasks', {
        'parent_id': parentId,
        'title': result.trim(),
        'done': 0,
      });

      setState(() {
        subtasks.add({"id": id, "title": result.trim(), "done": false});
      });
    }
  }

  Future<void> _toggleSubtask(int id, bool value) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'subtasks',
      {'done': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    setState(() {
      final index = subtasks.indexWhere((e) => e["id"] == id);
      if (index != -1) {
        subtasks[index]["done"] = value;
      }
    });
  }

  Future<void> _deleteSubtask(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);

    setState(() {
      subtasks.removeWhere((e) => e["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task["title"] ?? "サブタスク")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subtasks.length,
        itemBuilder: (context, index) {
          final sub = subtasks[index];
          return Dismissible(
            key: ValueKey(sub["id"]),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteSubtask(sub["id"]),
            child: CheckboxListTile(
              title: Text(sub["title"]),
              value: sub["done"],
              onChanged: (v) => _toggleSubtask(sub["id"], v ?? false),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubtask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
