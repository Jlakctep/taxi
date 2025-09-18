import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../services/osrm_service.dart';

enum TripStatus { idle, searchingDriver, driverAssigned, onTrip, completed }

class TripProvider extends ChangeNotifier {
  LatLng? pickup;
  LatLng? destination;
  RouteResult? route;
  TripStatus status = TripStatus.idle;

  double baseFare = 80; // базовая подача
  double perKm = 25; // цена за км
  double perMin = 4; // цена за минуту

  Future<void> setPoints({LatLng? from, LatLng? to, required OsrmService osrm}) async {
    pickup = from ?? pickup;
    destination = to ?? destination;
    route = null;
    if (pickup != null && destination != null) {
      route = await osrm.route(pickup!, destination!);
    }
    notifyListeners();
  }

  double? get estimatedPrice {
    if (route == null) return null;
    final km = route!.distanceMeters / 1000.0;
    final minutes = route!.durationSeconds / 60.0;
    final price = baseFare + km * perKm + minutes * perMin;
    return double.parse(price.toStringAsFixed(2));
  }

  void startSearchingDriver() {
    status = TripStatus.searchingDriver;
    notifyListeners();
  }

  void assignDriver() {
    status = TripStatus.driverAssigned;
    notifyListeners();
  }

  void startTrip() {
    status = TripStatus.onTrip;
    notifyListeners();
  }

  void completeTrip() {
    status = TripStatus.completed;
    notifyListeners();
  }

  void reset() {
    pickup = null;
    destination = null;
    route = null;
    status = TripStatus.idle;
    notifyListeners();
  }
}


