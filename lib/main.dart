import 'package:flutter/material.dart';
import 'features/tracker/ui/tracker_screen.dart';

void main() {
  runApp(const AppIslamic());
}

class AppIslamic extends StatelessWidget {
  const AppIslamic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP ISLAMIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TrackerScreen(),
    );
  }
}
