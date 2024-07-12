import 'package:flutter/material.dart';

enum CalendarType { Gregorian, Nepali }

class CalendarTypeProvider extends ChangeNotifier {
  CalendarType _calendarType = CalendarType.Gregorian;

  CalendarType get calendarType => _calendarType;

  void toggleCalendarType() {
    _calendarType = _calendarType == CalendarType.Gregorian
        ? CalendarType.Nepali
        : CalendarType.Gregorian;
    notifyListeners();
  }
}
