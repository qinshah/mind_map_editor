import 'package:flutter/material.dart';
// import 'package:forui/theme.dart';
import 'package:mind_map_editor/editor/view/editor_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final fTheme = FThemes.blue.light;
    // final fDarkTheme = FThemes.blue.dark;
    return MaterialApp(
      home: EditorView(),
      // theme: fTheme.toApproximateMaterialTheme(),
      // darkTheme: fDarkTheme.toApproximateMaterialTheme(),
    );
  }
}
