import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'splash_screen.dart';

void main() {
  NepaliUtils().language = Language.nepali;
  runApp(CalendarApp());
}

enum CalendarType { Gregorian, Nepali }

class CalendarApp extends StatefulWidget {
  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  bool isDarkMode = false;
  CalendarType _calendarType = CalendarType.Gregorian;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendar App',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: isDarkMode ? Colors.white : Colors.black,
            displayColor: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/calendar': (context) => CalendarHomePage(
          toggleTheme: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
          toggleCalendar: () {
            setState(() {
              _calendarType = _calendarType == CalendarType.Gregorian
                  ? CalendarType.Nepali
                  : CalendarType.Gregorian;
            });
          },
          isDarkMode: isDarkMode,
          calendarType: _calendarType,
        ),
      },
    );
  }
}

class CalendarHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleCalendar;
  final bool isDarkMode;
  final CalendarType calendarType;

  CalendarHomePage({
    required this.toggleTheme,
    required this.toggleCalendar,
    required this.isDarkMode,
    required this.calendarType,
  });

  @override
  _CalendarHomePageState createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  late CalendarFormat _calendarFormat;
  late dynamic _focusedDay;
  late dynamic _selectedDay;
  late Map<String, List<String>> _notes;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = _getInitialDay();
    _selectedDay = _getInitialDay();
    _notes = {};
    _loadNotes();
  }

  dynamic _getInitialDay() {
    if (widget.calendarType == CalendarType.Nepali) {
      return NepaliDateTime.now();
    } else {
      return DateTime.now();
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = Map<String, List<String>>.from(
        json.decode(prefs.getString('notes') ?? '{}'),
      );
    });
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(_notes));
  }

  void _addOrUpdateNoteForSelectedDay(String note) {
    setState(() {
      if (_notes[_selectedDay.toString()] == null) {
        _notes[_selectedDay.toString()] = [];
      }
      _notes[_selectedDay.toString()]!.add(note);
    });
    _saveNote();
  }

  void _deleteNoteForSelectedDay(int index) {
    setState(() {
      _notes[_selectedDay.toString()]!.removeAt(index);
      if (_notes[_selectedDay.toString()]!.isEmpty) {
        _notes.remove(_selectedDay.toString());
      }
    });
    _saveNote();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes[_selectedDay.toString()] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar App'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(widget.calendarType == CalendarType.Gregorian
                ? Icons.language
                : Icons.calendar_today),
            onPressed: widget.toggleCalendar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar<dynamic>(
                calendarFormat: _calendarFormat,
                firstDay: widget.calendarType == CalendarType.Nepali
                    ? NepaliDateTime(2000, 1, 1)
                    : DateTime(2000, 1, 1),
                lastDay: widget.calendarType == CalendarType.Nepali
                    ? NepaliDateTime(2099, 12, 31)
                    : DateTime(2099, 12, 31),
                focusedDay: _focusedDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  defaultTextStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  weekendTextStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  outsideTextStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.lato(
                    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  formatButtonTextStyle: GoogleFonts.lato(
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  weekendStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                selectedDayPredicate: (day) {
                  if (widget.calendarType == CalendarType.Nepali) {
                    return isSameDay(_selectedDay, day);
                  } else {
                    return isSameDay(_selectedDay, NepaliDateTime.fromDateTime(day));
                  }
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildNotesSection(notes),
              _buildAddNoteSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(List<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes for ${widget.calendarType == CalendarType.Nepali ? NepaliDateTime.fromDateTime(_selectedDay).format('MMMM d, yyyy') : DateFormat.yMMMMd().format(_selectedDay)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        notes.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
              child: ListTile(
                title: Text(
                  notes[index],
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _noteController.text = notes[index];
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteNoteForSelectedDay(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : Text('No notes for this day', style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAddNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add or edit a note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Note',
          ),
          maxLines: 4,
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            if (_noteController.text.isNotEmpty) {
              _addOrUpdateNoteForSelectedDay(_noteController.text);
              _noteController.clear();
            }
          },
          child: Text('Save Note'),
        ),
      ],
    );
  }
}
