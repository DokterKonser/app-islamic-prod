import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerCalculator {
  static Future<PrayerTimes?> getCurrentPrayerTimes() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    // Get current position
    Position position = await Geolocator.getCurrentPosition();

    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.shafii.getParameters();
    params.madhab = Madhab.shafii;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    return prayerTimes;
  }
}
