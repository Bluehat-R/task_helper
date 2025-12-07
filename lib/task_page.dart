import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/classroom/v1.dart' as classroom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'task_repository.dart';
import 'sub_task_page.dart';
import 'app_database.dart';
import 'subject_settings_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _googleSignIn = GoogleSignIn(
    clientId:
    "<CLASSROOM_TOKEN>",
    scopes: [
      "https://www.googleapis.com/auth/classroom.courses.readonly",
      "https://www.googleapis.com/auth/classroom.coursework.me.readonly",
    ],
  );

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> _assignments = [];
  http.Client? client;
  bool _loading = false;

  /// 🧹 削除
  Future<void> _deleteTask(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final deleted = prefs.getStringList("deletedTasks") ?? [];
    if (!deleted.contains(title)) {
      deleted.add(title);
      await prefs.setStringList("deletedTasks", deleted);
    }
    setState(() {
      tasks.removeWhere((t) => t["title"] == title);
    });
  }

  /// 📦 DBから読み込み
  Future<void> _loadTasksFromDb() async {
    final dbClient = await AppDatabase.instance.database;
    final result = await dbClient.query(
        'tasks',
        orderBy: "date(substr(due, 1, 10)) DESC"  // ← dueを日付扱いで降順
    );
    setState(() {
      tasks = result
          .map((e) => {
        "title": e["title"],
        "subject": e["subject"],
        "due": e["due"],
        "done": e["done"] == 1,
        "status": e["status"],
        "subtasks": [],
      })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasksFromDb();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksFromDb();
    });
  }

  /// 🔁 Classroom 同期
  Future<void> _syncFromClassroom() async {
    final db = AppDatabase.instance;
    final prefs = await SharedPreferences.getInstance();
    final deletedTasks = prefs.getStringList("deletedTasks") ?? [];

    setState(() => _loading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }

      final authHeaders = await account.authHeaders;
      client = _GoogleAuthClient(authHeaders);
      final classroomApi = classroom.ClassroomApi(client!);
      final dbClient = await db.database;

      final existing = await dbClient.query('tasks');
      final existingIds = existing.map((e) => e['unique_id'] as String).toSet();

      final courses = await classroomApi.courses.list();
      final activeSubjects = await db.getActiveSubjects();
      final allTasks = <Map<String, dynamic>>[];
      final currentIds = <String>{};

      for (final c in courses.courses ?? []) {
        final courseName = c.name ?? "不明なクラス";
        final courseId = c.id;
        if (courseId == null) continue;

        if (activeSubjects.isNotEmpty && !activeSubjects.contains(courseName)) {
          continue;
        }

        await db.insertOrActivateSubject(courseName);

        final coursework = await classroomApi.courses.courseWork.list(courseId);
        for (final work in coursework.courseWork ?? []) {
          if (deletedTasks.contains(work.title)) continue;

          final uid = "${courseName}_${work.title}";
          currentIds.add(uid);
          if (existingIds.contains(uid)) continue;

          allTasks.add({
            "title": work.title ?? "無題の課題",
            "due": _formatDueDate(work.dueDate, work.dueTime),
            "subject": courseName,
            "done": false,
            "status": "未提出",
            "subtasks": [],
          });
        }
      }

      // 🧩 追加
      for (final t in allTasks) {
        await dbClient.insert(
          'tasks',
          {
            'title': t["title"],
            'subject': t["subject"],
            'due': t["due"],
            'status': t["status"],
            'done': t["done"] ? 1 : 0,
            'unique_id': "${t["subject"]}_${t["title"]}",
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 🗑️ 不要削除
      for (final id in existingIds) {
        if (!currentIds.contains(id)) {
          await dbClient.delete('tasks', where: 'unique_id = ?', whereArgs: [id]);
        }
      }

      final updatedList = await dbClient.query('tasks', orderBy: 'updated_at DESC');
      setState(() {
        tasks = updatedList
            .map((e) => {
          "title": e["title"],
          "subject": e["subject"],
          "due": e["due"],
          "done": e["done"] == 1,
          "status": e["status"],
          "subtasks": [],
        })
            .toList();
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Classroom と同期しました！")),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("同期エラー: $e");
    }
  }

  bool _isOverdue(String? due) {
    if (due == null || due == "期限なし") return false;
    try {
      final date = DateTime.parse(due.replaceAll("/", "-"));
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _formatDueDate(classroom.Date? date, classroom.TimeOfDay? time) {
    if (date == null) return "期限なし";
    final y = date.year;
    final m = date.month?.toString().padLeft(2, '0');
    final d = date.day?.toString().padLeft(2, '0');
    String formatted = "$y/$m/$d";
    if (time != null) {
      formatted +=
      " ${time.hours?.toString().padLeft(2, '0')}:${time.minutes?.toString().padLeft(2, '0')}";
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("課題一覧"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "教科設定",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubjectSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: "Classroom同期",
            onPressed: _syncFromClassroom,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount:
        _assignments.isNotEmpty ? _assignments.length : tasks.length,
        itemBuilder: (context, index) {
          final task = _assignments.isNotEmpty
              ? _assignments[index]
              : tasks[index];

          // 🎨 色設定
          Color tileColor = Colors.white;
          switch (task["status"]) {
            case "提出済み":
              tileColor = Colors.blue.shade100;
              break;
            case "採点済み":
              tileColor = Colors.green.shade100;
              break;
            default:
              if (_isOverdue(task["due"])) {
                tileColor = Colors.red.shade100;
              }
          }

          return Card(
            color: tileColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(task["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "教科: ${task["subject"] ?? "不明"}\n期限: ${task["due"] ?? "なし"}",
              ),
              trailing: Checkbox(
                value: task["done"] ?? false,
                onChanged: (v) async {
                  final newValue = v ?? false;
                  setState(() {
                    task["done"] = newValue;
                  });
                  final dbClient = await AppDatabase.instance.database;
                  await dbClient.update(
                    'tasks',
                    {
                      'done': newValue ? 1 : 0,
                      'updated_at': DateTime.now().toIso8601String(),
                    },
                    where: 'title = ? AND subject = ?',
                    whereArgs: [task["title"], task["subject"]],
                  );
                },
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubTaskPage(task: task),
                  ),
                );
              },
              onLongPress: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("削除しますか？"),
                    content: Text("${task["title"]} を削除します。"),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("キャンセル")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("削除")),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _deleteTask(task["title"]);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (client == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("先にClassroom同期を行ってください。")),
            );
            return;
          }

          final dbClient = await AppDatabase.instance.database;
          final repository =
          ClassroomRepository(classroom.ClassroomApi(client!));
          final assignments = await repository.fetchAssignmentsWithStatus();

          if (!mounted) return;
          setState(() {
            _assignments = assignments
                .map((a) => {
              "title": a.title,
              "due": a.dueDate?.toString() ?? "期限未設定",
              "status": a.status,
              "done":
              a.status == "提出済み" || a.status == "採点済み",
            })
                .toList();
          });

          // 🧠 DBへ提出状況保存
          for (final a in assignments) {
            await dbClient.update(
              'tasks',
              {
                'status': a.status,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'title = ?',
              whereArgs: [a.title],
            );
          }
        },
        icon: const Icon(Icons.assignment_turned_in),
        label: const Text("提出状況取得"),
      ),
    );
  }
}

/// 🔐 Google Sign-InのトークンでAPIを叩くHTTPクライアント
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
