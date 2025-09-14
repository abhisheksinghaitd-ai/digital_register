import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class AdminuiProvider with ChangeNotifier {
  String? _docId;

  String? get docId => _docId;

  void setDocId(String id) {
    _docId = id;
    developer.log("DEBUG: AdminuiProvider docId set = $docId");
    notifyListeners();
  }
}

