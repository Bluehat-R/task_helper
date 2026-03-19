# Task Helper

Task Helper は、学校の課題管理とメンタルログを一体化した Flutter アプリです。
Google Classroom と連携して課題を取得し、提出状況の確認や日々の記録をまとめて行えます。

## 主な機能
- Google Classroom から課題を取得
- 提出状況の確認（未提出 / 提出済み / 採点済み）
- サブタスクによる進捗管理
- 教科ごとの表示切り替え
- タスク行動ログの記録
- 気分・睡眠時間・服薬・メモの記録
- PC起動チェック機能
- SQLite によるローカル保存

## 技術スタック
- Flutter
- Dart
- SQLite (sqflite)
- Google Sign-In
- Google Classroom API

## 工夫したポイント
- オフラインでも使えるようにローカルDBを採用
- 課題、サブタスク、ログ、メンタル記録を分けて管理
- Classroom API の利用時にリクエスト負荷を意識した実装
- 日常的に使いやすいUIを意識して設計

## 想定ユーザー
- 学校課題をまとめて管理したい学生
- 課題だけでなく体調や気分も一緒に記録したい人
- Google Classroom を使っている人

## セットアップ
```bash
flutter pub get
flutter run
