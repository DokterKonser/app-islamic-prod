import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/logic/prayer_calculator.dart';
import 'package:adhan/adhan.dart';
import '../../tracker/ui/tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    final times = await PrayerCalculator.getCurrentPrayerTimes();
    if (mounted) {
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP ISLAMIC'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrackerScreen()),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prayerTimes == null
              ? const Center(child: Text('Gagal mengambil lokasi / data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: StateAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Jadwal Sholat Hari Ini',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: Center,
                      ),
                      const SizedBox(height: 20),
                      _buildPrayerCard('Subuh', _prayerTimes!.fajr),
                      _buildPrayerCard('Dzuhur', _prayerTimes!.dhuhr),
                      _buildPrayerCard('Ashar', _prayerTimes!.asr),
                      _buildPrayerCard('Maghrib', _prayerTimes!.maghrib),
                      _buildPrayerCard('Isya', _prayerTimes!.isha),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrayerCard(String name, DateTime time) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text(
          DateFormat.Hm().format(time),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
