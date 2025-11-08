import 'package:flutter/material.dart';
import 'package:mind_map_editor/app.dart';
import 'package:mind_map_editor/function/file_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FM.init();
  runApp(const App());
}