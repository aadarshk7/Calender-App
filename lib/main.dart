import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarHomePage(),
    );
  }
}

class CalendarHomePage extends StatefulWidget {
  @override
  _CalendarHomePageState createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
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
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now().subtract(Duration(days: 7));
                  }),
                  child: Text('Previous week'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now();
                  }),
                  child: Text('Current week'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now().subtract(Duration(days: 15));
                  }),
                  child: Text('15 Days ago'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now().subtract(Duration(days: 12));
                  }),
                  child: Text('12 Days ago'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now().subtract(Duration(days: 10));
                  }),
                  child: Text('10 Days ago'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _focusedDay = DateTime.now().subtract(Duration(days: 5));
                  }),
                  child: Text('5 Days ago'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
