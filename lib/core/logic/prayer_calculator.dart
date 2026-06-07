import 'package:adhan/adhan.dart';

class PrayerCalculator {
  static PrayerTimes getPrayerTimes(double latitude, double longitude) {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final date = DateComponents.from(DateTime.now());
    return PrayerTimes(myCoordinates, date, params);
  }
}
