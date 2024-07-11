import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'splash_screen.dart';

void main() {
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
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
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
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                children: [
                  _buildAnimatedButton('Previous week', () {
                    setState(() {
                      _focusedDay = DateTime.now().subtract(Duration(days: 7));
                    });
                  }),
                  _buildAnimatedButton('Current week', () {
                    setState(() {
                      _focusedDay = DateTime.now();
                    });
                  }),
                  _buildAnimatedButton('15 Days ago', () {
                    setState(() {
                      _focusedDay = DateTime.now().subtract(Duration(days: 15));
                    });
                  }),
                  _buildAnimatedButton('12 Days ago', () {
                    setState(() {
                      _focusedDay = DateTime.now().subtract(Duration(days: 12));
                    });
                  }),
                  _buildAnimatedButton('10 Days ago', () {
                    setState(() {
                      _focusedDay = DateTime.now().subtract(Duration(days: 10));
                    });
                  }),
                  _buildAnimatedButton('5 Days ago', () {
                    setState(() {
                      _focusedDay = DateTime.now().subtract(Duration(days: 5));
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String text, VoidCallback onPressed) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(text)),
        body: Center(child: Text(text)),
      ),
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      closedColor: Colors.black,
      openColor: Colors.white,
      closedBuilder: (context, openContainer) => ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
