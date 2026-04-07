# task_helper

## 📱 概要
Google Classroomの課題を管理するためのアプリです。  
課題の提出状況や期限を一覧で確認でき、タスクの見逃しを防ぐことを目的に開発しました。

---

## 🎯 開発背景
Google Classroomは課題管理がしづらく、提出漏れが発生しやすいと感じたため、  
課題を見やすく整理・可視化できるアプリを作成しました。

---

## ✨ 主な機能
- 課題の一覧表示
- 提出状況の管理（未提出/提出済み）
- 課題の期限表示
- 状態の可視化（わかりやすいUI）

---

## 🛠 使用技術
- Flutter / Dart
- SQLite
- Google Classroom API

---

## 💡 工夫した点
- 課題の状態を一目で把握できるUI設計
- 実際の利用を想定したシンプルで使いやすい画面構成
- APIから取得したデータをローカルDBに保存し、動作を軽量化

---

## 🧠 このプロジェクトで学んだこと
- APIを利用したデータ取得と管理
- モバイルアプリにおけるUI設計
- データの永続化（SQLite）
- 実際に使うことを想定したアプリ設計

---

## ▶️ 実行方法

```bash
git clone https://github.com/Bluehat-R/task_helper.git
cd task_helper
flutter pub get
flutter run