import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';

void main() async {
  // 🧩 Flutterのバインディングを最初に初期化
  WidgetsFlutterBinding.ensureInitialized();

  // 🧹 一度だけDB削除したい場合（再生成用）
  // final path = join(await getDatabasesPath(), 'task_helper.db');
  // await deleteDatabase(path);
  // print("🧹 Database deleted for reset.");

  // 💻 デスクトップ(Windows/Linux/macOS)用の初期化
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const ProviderScope(child: MyApp()));
}
