import 'package:flutter/foundation.dart';

import '../models/ride.dart';

class HistoryProvider extends ChangeNotifier {
  final List<Ride> _rides = <Ride>[];

  List<Ride> get rides => List.unmodifiable(_rides);

  void addRide(Ride ride) {
    _rides.insert(0, ride);
    notifyListeners();
  }
}


