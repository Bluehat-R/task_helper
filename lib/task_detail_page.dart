import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late List<Map<String, dynamic>> subtasks;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    subtasks = List<Map<String, dynamic>>.from(widget.task["subtasks"] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task["title"] ?? "課題詳細"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "保存して戻る",
            onPressed: () {
              Navigator.pop(context, {
                ...widget.task,
                "subtasks": subtasks,
                "done": subtasks.isNotEmpty && subtasks.every((s) => s["done"] == true),
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: subtasks.isEmpty
                  ? const Center(child: Text("サブタスクがまだありません"))
                  : ListView.builder(
                itemCount: subtasks.length,
                itemBuilder: (context, index) {
                  final sub = subtasks[index];
                  return CheckboxListTile(
                    value: sub["done"] ?? false,
                    title: Text(
                      sub["title"] ?? "",
                      style: TextStyle(
                        decoration: (sub["done"] ?? false)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        sub["done"] = v ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "サブタスクを追加",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubtask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addSubtask() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      subtasks.add({
        "title": _controller.text.trim(),
        "done": false,
      });
      _controller.clear();
    });
  }
}
