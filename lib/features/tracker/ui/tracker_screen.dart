import 'package:flutter/material.dart';
import '../../../core/logic/database_helper.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<String> _prayers = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  final Map<String, bool> _status = {};

  @override
  void initState() {
    super.initState();
    for (var prayer in _prayers) {
      _status[prayer] = false;
    }
  }

  Future<void> _togglePrayer(String name, bool? value) async {
    setState(() {
      _status[name] = value ?? false;
    });

    if (_status[name] == true) {
      await DatabaseHelper.instance.database.then((db) {
        db.insert('ibadah_logs', {
          'type': 'Salah',
          'name': name,
          'status': 'Completed',
          'performed_at': DateTime.now().toIso8601String(),
          'metadata': '{}',
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alhamdulillah, $name selesai!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibadah Tracker'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: _prayers.length,
        itemBuilder: (context, index) {
          final prayer = _prayers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CheckboxListTile(
              title: Text(prayer, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Sudahkah Anda sholat?'),
              value: _status[prayer],
              activeColor: Colors.teal,
              onChanged: (val) => _togglePrayer(prayer, val),
            ),
          );
        },
      ),
    );
  }
}
