// lib/services/classroom_service.dart
import 'package:googleapis/classroom/v1.dart';
import 'auth_service.dart';

class ClassroomService {
  static Future<List<Map<String, dynamic>>> fetchAssignments() async {
    final client = await GoogleAuthService.getAuthenticatedClient();
    if (client == null) return [];

    final api = ClassroomApi(client);
    final courses = await api.courses.list();
    final allTasks = <Map<String, dynamic>>[];

    if (courses.courses == null) return [];

    for (final course in courses.courses!) {
      final courseWork = await api.courses.courseWork.list(course.id!);
      for (final work in courseWork.courseWork ?? []) {
        allTasks.add({
          "title": work.title,
          "due": work.dueDate == null
              ? "期限未設定"
              : "${work.dueDate!.year}/${work.dueDate!.month}/${work.dueDate!.day}",
          "subject": course.name,
          "done": false,
          "subtasks": [],
        });
      }
    }
    return allTasks;
  }
}
