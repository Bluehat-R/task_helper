import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Helper',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      // 🌏 日本語ローカライズ設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      routes: appRoutes,
    );
  }
}
