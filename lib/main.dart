import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'calendar_home_page.dart';
import 'splash_screen.dart';
import 'theme_notifier.dart'; // Import the theme notifier

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Provide the ThemeNotifier
      child: CalendarApp(),
    ),
  );
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Calendar App',
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            textTheme: GoogleFonts.latoTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            textTheme: GoogleFonts.latoTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(),
          routes: {
            '/calendar': (context) => CalendarHomePage(),
          },
        );
      },
    );
  }
}
