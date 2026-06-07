import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/ui/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppIslamic(),
    ),
  );
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
      home: const HomeScreen(),
    );
  }
}
