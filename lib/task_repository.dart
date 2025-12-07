import 'app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:googleapis/classroom/v1.dart' as classroom;

class TaskEntry {
  final int? id;
  final String title;
  final DateTime dueDate;
  final String? note;
  final bool completed;

  TaskEntry({
    this.id,
    required this.title,
    required this.dueDate,
    this.note,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'due_date': dueDate.toIso8601String(),
    'note': note,
    'completed': completed ? 1 : 0,
  };

  static TaskEntry fromMap(Map<String, dynamic> map) => TaskEntry(
    id: map['id'] as int?,
    title: map['title'] as String,
    dueDate: DateTime.parse(map['due_date']),
    note: map['note'] as String?,
    completed: (map['completed'] as int) == 1,
  );
}

class AssignmentStatus {
  final String title;
  final String status;
  final DateTime? dueDate;

  AssignmentStatus({
    required this.title,
    required this.status,
    this.dueDate,
  });
}

class ClassroomRepository {
  final classroom.ClassroomApi api;

  ClassroomRepository(this.api);

  Future<List<AssignmentStatus>> fetchAssignmentsWithStatus() async {
    final coursesResponse = await api.courses.list();
    final List<AssignmentStatus> assignments = [];

    if (coursesResponse.courses != null) {
      for (var course in coursesResponse.courses!) {
        final courseworkResponse = await api.courses.courseWork.list(
            course.id!);

        if (courseworkResponse.courseWork != null) {
          int count = 0; // 👈 リクエスト数カウンター

          for (var work in courseworkResponse.courseWork!) {
            // ここで5件ごとに待機
            if (count % 5 == 0 && count > 0) {
              await Future.delayed(const Duration(seconds: 3));
            }
            count++;

            String status = "未提出";
            try {
              final submissions = await api.courses.courseWork
                  .studentSubmissions.list(
                course.id!,
                work.id!,
              );

              if (submissions.studentSubmissions != null &&
                  submissions.studentSubmissions!.isNotEmpty) {
                final sub = submissions.studentSubmissions!.first;
                switch (sub.state) {
                  case "TURNED_IN":
                    status = "提出済み";
                    break;
                  case "RETURNED":
                    status = "採点済み";
                    break;
                }
              }
            } catch (e) {
              print("⚠️ 提出状況取得エラー: $e");
              // → 失敗しても他を続行
            }

            DateTime? dueDate;
            if (work.dueDate != null) {
              dueDate = DateTime(
                work.dueDate!.year!,
                work.dueDate!.month!,
                work.dueDate!.day!,
                work.dueTime?.hours ?? 0,
                work.dueTime?.minutes ?? 0,
              );
            }

            assignments.add(AssignmentStatus(
              title: work.title ?? "タイトルなし",
              status: status,
              dueDate: dueDate,
            ));
          }
        }
      }
    }

    return assignments;
  }
}

  class TaskRepository {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  Future<void> addTask(TaskEntry entry) async {
    final db = await AppDatabase.instance.database;
    await db.insert('task', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TaskEntry>> getAllTasks() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('task', orderBy: 'due_date ASC');
    return rows.map((e) => TaskEntry.fromMap(e)).toList();
  }

  Future<void> updateTaskCompletion(int id, bool completed) async {
    final db = await AppDatabase.instance.database;
    await db.update('task', {'completed': completed ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('task', where: 'id = ?', whereArgs: [id]);
  }
}
