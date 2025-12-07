import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskAddPage extends StatefulWidget {
  final Map<String, dynamic>? initialTask;
  const TaskAddPage({super.key, this.initialTask});

  @override
  State<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  final _titleController = TextEditingController();
  final _dueController = TextEditingController();
  final _subtaskController = TextEditingController();
  List<String> subjects = [];
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadSubjects();

    // 🟡 引数から編集データ受け取り
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _titleController.text = args["title"] ?? "";
        _dueController.text = args["due"] ?? "";
        selectedSubject = args["subject"];
      }
    });
  }

  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subjects = prefs.getStringList('subjects') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "課題を編集" : "課題を追加")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "課題タイトル",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              items: subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => selectedSubject = v),
              decoration: const InputDecoration(
                labelText: "教科を選択",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dueController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "期限を選択",
                border: OutlineInputBorder(),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtaskController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "サブタスク（1行ごとに1つ）",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? "更新して戻る" : "保存"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() {
        _dueController.text = "${picked.year}/${picked.month}/${picked.day}";
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    // 改行で区切ってサブタスクリスト化
    final subtasks = _subtaskController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final task = {
      "title": _titleController.text.trim(),
      "due": _dueController.text.trim(),
      "subject": selectedSubject ?? "未設定",
      "done": widget.initialTask?["done"] ?? false,
      "subtasks": subtasks,
    };

    Navigator.pop(context, task);
  }
}
