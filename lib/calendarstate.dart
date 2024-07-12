import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'dart:convert';

enum CalendarType { Gregorian, Nepali }

class CalendarState extends ChangeNotifier {
  late CalendarFormat calendarFormat;
  late dynamic focusedDay;
  late dynamic selectedDay;
  late Map<String, List<String>> notes;
  CalendarType calendarType;

  CalendarState({
    required this.calendarType,
  }) {
    calendarFormat = CalendarFormat.month;
    focusedDay = _getInitialDay();
    selectedDay = _getInitialDay();
    notes = {};
    _loadNotes();
  }

  dynamic _getInitialDay() {
    if (calendarType == CalendarType.Nepali) {
      return NepaliDateTime.now();
    } else {
      return DateTime.now();
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    notes = Map<String, List<String>>.from(
      json.decode(prefs.getString('notes') ?? '{}'),
    );
    notifyListeners();
  }

  Future<void> saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(notes));
    notifyListeners();
  }

  void addOrUpdateNoteForSelectedDay(String note) {
    if (notes[selectedDay.toString()] == null) {
      notes[selectedDay.toString()] = [];
    }
    notes[selectedDay.toString()]!.add(note);
    saveNote();
  }

  void deleteNoteForSelectedDay(int index) {
    notes[selectedDay.toString()]!.removeAt(index);
    if (notes[selectedDay.toString()]!.isEmpty) {
      notes.remove(selectedDay.toString());
    }
    saveNote();
  }

  void setFocusedDay(dynamic day) {
    focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(dynamic day) {
    selectedDay = day;
    notifyListeners();
  }

  void toggleCalendarType() {
    calendarType = calendarType == CalendarType.Gregorian
        ? CalendarType.Nepali
        : CalendarType.Gregorian;
    focusedDay = _getInitialDay();
    selectedDay = _getInitialDay();
    notes.clear();
    _loadNotes();
    notifyListeners();
  }
}
