import 'package:flutter/material.dart';

class MindMapState {
  Map<String, bool> expandeds = {};

  String? focusedId;

  String? editingId;
  String? selectionId;

  TextSelection selection= TextSelection.collapsed(offset: 0);
}
