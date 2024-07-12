import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_state.dart';
import 'splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CalendarState(calendarType: CalendarType.Gregorian),
      child: CalendarApp(),
    ),
  );
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendar App',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue, // Set primaryColor instead of primarySwatch
        textTheme: GoogleFonts.latoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue, // Set primaryColor instead of primarySwatch
        textTheme: GoogleFonts.latoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
      routes: {
        '/calendar': (context) => CalendarHomePage(),
      },
    );
  }
}
class CalendarHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final calendarState = Provider.of<CalendarState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar App'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              var toggleTheme = Provider.of<CalendarState>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(calendarState.calendarType == CalendarType.Gregorian
                ? Icons.language
                : Icons.calendar_today),
            onPressed: () {
              Provider.of<CalendarState>(context, listen: false).toggleCalendarType();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar<dynamic>(
                calendarFormat: calendarState.calendarFormat,
                firstDay: calendarState.calendarType == CalendarType.Nepali
                    ? NepaliDateTime(2000, 1, 1)
                    : DateTime(2000, 1, 1),
                lastDay: calendarState.calendarType == CalendarType.Nepali
                    ? NepaliDateTime(2099, 12, 31)
                    : DateTime(2099, 12, 31),
                focusedDay: calendarState.focusedDay,
                selectedDayPredicate: (day) =>
                    calendarState.selectedDay.isSameDay(day),
                onDaySelected: (selectedDay, focusedDay) {
                  calendarState.setSelectedDay(selectedDay);
                  calendarState.setFocusedDay(focusedDay);
                },
                onPageChanged: (focusedDay) {
                  calendarState.setFocusedDay(focusedDay);
                },
                onFormatChanged: (format) {
                  calendarState.calendarFormat = format;
                },
              ),
              SizedBox(height: 20),
              _buildNotesSection(context),
              _buildAddNoteSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final calendarState = Provider.of<CalendarState>(context);
    final notes = calendarState.notes[calendarState.selectedDay.toString()] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes for ${calendarState.calendarType == CalendarType.Nepali ? NepaliDateTime.fromDateTime(calendarState.selectedDay).format('MMMM d, yyyy') : DateFormat.yMMMMd().format(calendarState.selectedDay)}',
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
              child: ListTile(
                title: Text(
                  notes[index],
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Implement edit functionality if needed
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        calendarState.deleteNoteForSelectedDay(index);
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

  Widget _buildAddNoteSection(BuildContext context) {
    final calendarState = Provider.of<CalendarState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add or edit a note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Note',
          ),
          maxLines: 4,
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            calendarState.addOrUpdateNoteForSelectedDay('Sample note');
          },
          child: Text('Save Note'),
        ),
      ],
    );
  }
}
