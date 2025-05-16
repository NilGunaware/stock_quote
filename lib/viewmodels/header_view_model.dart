import 'package:flutter/foundation.dart';
import '../services/date_service.dart';

class HeaderViewModel extends ChangeNotifier {
  final DateService _dateService;
  DateTime _currentDate = DateTime.now();

  HeaderViewModel(this._dateService);

  String get formattedDate => _dateService.getFormattedDate(_currentDate);
  
  void updateDate() {
    _currentDate = DateTime.now();
    notifyListeners();
  }
} 