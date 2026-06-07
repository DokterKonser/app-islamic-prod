import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/database_helper.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  final List<String> _prayers = ['Subuh', 'Dhuhur', 'Ashar', 'Maghrib', 'Isya'];
  Map<String, bool> _trackerStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrackerData();
  }

  Future<void> _loadTrackerData() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logs = await DatabaseHelper.instance.getLogsByDate(today);
    
    final Map<String, bool> status = {};
    for (var prayer in _prayers) {
      status[prayer] = logs.any((log) => log['name'] == prayer && log['status'] == 'Completed');
    }

    if (mounted) {
      setState(() {
        _trackerStatus = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePrayer(String prayer, bool? value) async {
    if (value == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final now = DateTime.now().toIso8601String();

    if (value) {
      await DatabaseHelper.instance.insertLog({
        'type': 'Salah',
        'name': prayer,
        'status': 'Completed',
        'performed_at': now,
        'intensity': 1,
        'metadata': '{}',
      });
    } else {
      await DatabaseHelper.instance.deleteLog(prayer, today);
    }

    if (mounted) {
      setState(() {
        _trackerStatus[prayer] = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibadah Tracker'),
        centerTitle: true,
        backgroundColor: Colors.emerald,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Prayers - ${DateTime.now().toIso8601String().split('T')[0]}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _prayers.length,
                      itemBuilder: (context, index) {
                        final prayer = _prayers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: CheckboxListTile(
                            title: Text(
                              prayer,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text('Mark as completed'),
                            value: _trackerStatus[prayer] ?? false,
                            onChanged: (bool? value) => _togglePrayer(prayer, value),
                            secondary: const Icon(Icons.mosque_outlined, color: Colors.emerald),
                            activeColor: Colors.emerald,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
