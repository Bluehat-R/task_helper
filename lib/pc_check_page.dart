import 'package:flutter/material.dart';
import 'log_repository.dart';

class PcCheckPage extends StatefulWidget {
  const PcCheckPage({super.key});

  @override
  State<PcCheckPage> createState() => _PcCheckPageState();
}

class _PcCheckPageState extends State<PcCheckPage> {
  bool step1 = false; // PCを手元に持ってくる
  bool step2 = false; // フタを開ける
  bool step3 = false; // 画面がつく

  int streakDays = 0;

  int get completedCount => [step1, step2, step3].where((x) => x).length;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final value = await LogRepository.instance.getPcStartStreak();
    if (!mounted) return;
    setState(() {
      streakDays = value;
    });
  }

  Widget build(BuildContext context) {
    final allDone = completedCount == 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PC起動チェック'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PCを起動するための最小ステップ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // チェックリスト
            _buildCheckItem(
              label: 'PCを手元に持ってくる',
              value: step1,
              onChanged: (v) => setState(() => step1 = v ?? false),
            ),
            _buildCheckItem(
              label: 'フタを開ける',
              value: step2,
              onChanged: (v) => setState(() => step2 = v ?? false),
            ),
            _buildCheckItem(
              label: '画面がついた',
              value: step3,
              onChanged: (v) => setState(() => step3 = v ?? false),
            ),

            const SizedBox(height: 24),

            // 進捗表示（本当は連続日数だけど、まずはシンプルに）
            Center(
              child: Column(
                children: [
                  Text('$completedCount / 3 完了'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completedCount / 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '連続PC起動日数: $streakDays日',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const Spacer(),

            FilledButton(
              onPressed: allDone
                  ? () async {
                await LogRepository.instance.addPcStartLog();
                await _loadStreak(); // ★ ここで最新ストリークに更新

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PC起動チェック完了！ログに記録した')),
                  );
                  Navigator.of(context).pop();
                }
              }
                  : null,
              child: const Text('完了'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
