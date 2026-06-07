import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../../../core/logic/prayer_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? _prayerTimes;
  String _locationStatus = 'Determining location...';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationStatus = 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationStatus = 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationStatus = 'Location permissions are permanently denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final prayerTimes = PrayerCalculator.getPrayerTimes(position.latitude, position.longitude);
      
      setState(() {
        _prayerTimes = prayerTimes;
        _locationStatus = 'Location: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() => _locationStatus = 'Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
      ),
      body: Center(
        child: _prayerTimes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_locationStatus),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_locationStatus, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 32),
                    _buildPrayerTimeCard('Fajr', _prayerTimes!.fajr),
                    _buildPrayerTimeCard('Dhuhr', _prayerTimes!.dhuhr),
                    _buildPrayerTimeCard('Asr', _prayerTimes!.asr),
                    _buildPrayerTimeCard('Maghrib', _prayerTimes!.maghrib),
                    _buildPrayerTimeCard('Isha', _prayerTimes!.isha),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(String label, DateTime time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text(
              DateFormat.jm().format(time.toLocal()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
