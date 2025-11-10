import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/widget/editor_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final mColor = Colors.teal;
    // final fTheme = FThemes.blue.light;
    // final fDarkTheme = FThemes.blue.dark;
    return MaterialApp(
      home: EditorView(),
      builder: (context, child) {
        return Scaffold(appBar: AppBar(toolbarHeight: 0), body: child);
      },
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Color(0xffEEF0F2)),
        primaryColor: mColor,
        colorScheme: ColorScheme.fromSeed(seedColor: mColor),
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade800),
        brightness: Brightness.dark,
        primaryColor: mColor,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: mColor,
        ),
      ),
      // darkTheme: fDarkTheme.toApproximateMaterialTheme(),
    );
  }
}
