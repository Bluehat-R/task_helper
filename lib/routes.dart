import 'package:flutter/material.dart';

// 各ページのimport
import 'features/home/home_page.dart';
import 'pc_check_page.dart';
import 'log_root_page.dart';
import 'log_page.dart';
import 'mood_page.dart';
import 'mood_chart_page.dart';
import 'mood_log_page.dart';
import 'task_page.dart';
import 'task_add_page.dart';
import 'task_detail_page.dart';
import 'task_log_page.dart';
import 'setting_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const HomePage(),
  '/pc-check': (_) => const PcCheckPage(),
  '/logs': (_) => const LogRootPage(),
  '/logs/behavior': (_) => const LogPage(),
  '/logs/mood': (_) => const MoodLogPage(),
  '/logs/task': (_) => const TaskLogPage(),
  '/mood': (_) => const MoodPage(),
  '/mood/chart': (_) => const MoodChartPage(),
  '/tasks': (_) => const TaskPage(),
  '/tasks/add': (_) => const TaskAddPage(),
  '/tasks/detail': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return TaskDetailPage(task: args);
  },
  '/settings': (_) => const SettingPage(),
};
