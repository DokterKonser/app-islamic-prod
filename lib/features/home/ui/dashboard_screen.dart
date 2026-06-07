import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../core/logic/prayer_calculator.dart';
import '../../tracker/ui/tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        title: const Text('APP ISLAMIC Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigationGrid(context),
            const SizedBox(height: 32),
            const Text(
              'Jadwal Sholat Hari Ini',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildPrayerTimesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.2,
      children: [
        _buildDashboardItem(
          context,
          title: 'Ibadah Tracker',
          icon: Icons.track_changes,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrackerScreen()),
          ),
        ),
        _buildDashboardItem(
          context,
          title: 'AI Chatbot',
          icon: Icons.chat,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI Chatbot integration coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrayerTimesSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_prayerTimes == null) {
      return const Center(child: Text('Gagal mengambil lokasi / data'));
    }
    return Column(
      children: [
        _buildPrayerCard('Subuh', _prayerTimes!.fajr),
        _buildPrayerCard('Dzuhur', _prayerTimes!.dhuhr),
        _buildPrayerCard('Ashar', _prayerTimes!.asr),
        _buildPrayerCard('Maghrib', _prayerTimes!.maghrib),
        _buildPrayerCard('Isya', _prayerTimes!.isha),
      ],
    );
  }

  Widget _buildPrayerCard(String name, DateTime time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(name),
        trailing: Text(
          DateFormat.Hm().format(time),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.teal),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
