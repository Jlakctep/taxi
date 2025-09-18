import 'package:latlong2/latlong.dart';

class Ride {
  final LatLng pickup;
  final LatLng destination;
  final double price;
  final double distanceMeters;
  final double durationSeconds;
  final DateTime date;

  const Ride({
    required this.pickup,
    required this.destination,
    required this.price,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.date,
  });
}


