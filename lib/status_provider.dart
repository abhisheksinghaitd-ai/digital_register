import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatusProvider extends ChangeNotifier {
  final Box status = Hive.box('status');

  String _stat = '';
  String get currentStatus => _stat;

  /// Load the saved status from Hive
  void loadStatus() {
    _stat = status.get('requestStatus', defaultValue: '');
    
    notifyListeners();
  }

  /// Update status and save to Hive
  void changeStatus(String newStatus) {
    _stat = newStatus;
    status.put('requestStatus', newStatus);
    notifyListeners();
  }
 
  String _reason = '';
  String get currentreason => _reason;

  void loadReason(){
    _reason = status.get('currentReason',defaultValue: '');
    notifyListeners();
  }

  void changeReason(String newReason){
    _reason = newReason;
    status.put('currentReason',newReason);
    notifyListeners();
  }
}
