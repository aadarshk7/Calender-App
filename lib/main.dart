import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'dart:convert';
import 'splash_screen.dart';

void main() {
  NepaliUtils().language = Language.nepali;
  runApp(CalendarApp());
}

class CalendarApp extends StatefulWidget {
  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
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
          isDarkMode: isDarkMode,
        ),
      },
    );
  }
}

class CalendarHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  CalendarHomePage({required this.toggleTheme, required this.isDarkMode});

  @override
  _CalendarHomePageState createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  late CalendarFormat _calendarFormat;
  late NepaliDateTime _focusedDay;
  late NepaliDateTime _selectedDay;
  late Map<String, List<String>> _notes;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = NepaliDateTime.now();
    _selectedDay = NepaliDateTime.now();
    _notes = {};
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = Map<String, List<String>>.from(
          json.decode(prefs.getString('notes') ?? '{}'));
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
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar(
                calendarFormat: _calendarFormat,
                firstDay: NepaliDateTime(2000),
                lastDay: NepaliDateTime(2099),
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
                  return isSameDay(_selectedDay, day);
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
                  _focusedDay = focusedDay;
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
          'Notes for ${_selectedDay.format('MMMM d, yyyy')}',
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
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteNoteForSelectedDay(index);
                  },
                ),
                onTap: () {
                  _noteController.text = notes[index];
                },
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
