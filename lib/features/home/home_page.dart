import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _buildTile(
        context,
        title: '📚 課題一覧',
        color: Colors.deepPurple,
        onTap: () => Navigator.pushNamed(context, '/tasks'),
      ),
      _buildTile(
        context,
        title: '💻 PCチェック',
        color: Colors.blue,
        onTap: () => Navigator.pushNamed(context, '/pc-check'),
      ),
      _buildTile(
        context,
        title: '💭 メンタル記録',
        color: Colors.pink,
        onTap: () => Navigator.pushNamed(context, '/mood'),
      ),
      _buildTile(
        context,
        title: '📋 ログ管理',
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/logs'),
      ),
      _buildTile(
        context,
        title: '⚙️ 設定',
        color: Colors.grey,
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Task Helper')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: tiles,
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (color is MaterialColor) ? color.shade700 : color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
