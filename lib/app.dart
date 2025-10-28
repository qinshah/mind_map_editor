import 'package:flutter/material.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/editor/view/editor_view.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final mColor = Colors.teal;
    // final fTheme = FThemes.blue.light;
    // final fDarkTheme = FThemes.blue.dark;
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => EditorNotifier(),
        child: EditorView(),
      ),
      theme: ThemeData(
        primaryColor: mColor,
        colorScheme: ColorScheme.fromSeed(seedColor: mColor),
      ),
      darkTheme: ThemeData(
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
