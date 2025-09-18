import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/place_suggestion.dart';
import '../providers/trip_provider.dart';
import '../providers/history_provider.dart';
import '../models/ride.dart';
import '../services/location_service.dart';
import '../services/nominatim_service.dart';
import '../services/osrm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final NominatimService _nominatim = NominatimService();
  final OsrmService _osrm = OsrmService();
  final LocationService _location = LocationService();

  LatLng _camera = const LatLng(50.4501, 30.5234); // Киев по умолчанию

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await _location.getCurrentPosition();
    if (mounted && pos != null) {
      setState(() => _camera = pos);
      _mapController.move(pos, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Faster Taxi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _buildFromField(trip)),
                const SizedBox(width: 8),
                Expanded(child: _buildToField(trip)),
              ],
            ),
          ),
          if (trip.estimatedPrice != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Оценка: ~${trip.estimatedPrice} ₴'),
                  Text('Время: ~${(trip.route!.durationSeconds / 60).toStringAsFixed(0)} мин'),
                ],
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _camera,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.taxi',
                ),
                if (trip.pickup != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: trip.pickup!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.radio_button_checked, color: Colors.green, size: 28),
                    )
                  ]),
                if (trip.destination != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: trip.destination!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.place, color: Colors.red, size: 28),
                    )
                  ]),
                if (trip.route != null)
                  PolylineLayer(polylines: [
                    Polyline(points: trip.route!.polyline, strokeWidth: 4, color: Colors.blue),
                  ]),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (trip.pickup != null && trip.destination != null)
                      ? () async {
                          final history = context.read<HistoryProvider>();
                          trip.startSearchingDriver();
                          await Future.delayed(const Duration(seconds: 2));
                          trip.assignDriver();
                          await Future.delayed(const Duration(seconds: 2));
                          trip.startTrip();
                          await Future.delayed(const Duration(seconds: 2));
                          trip.completeTrip();
                          if (trip.route != null && trip.estimatedPrice != null && trip.pickup != null && trip.destination != null) {
                            history.addRide(Ride(
                              pickup: trip.pickup!,
                              destination: trip.destination!,
                              price: trip.estimatedPrice!,
                              distanceMeters: trip.route!.distanceMeters,
                              durationSeconds: trip.route!.durationSeconds,
                              date: DateTime.now(),
                            ));
                          }
                        }
                      : null,
                  child: Text(_ctaText(trip)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ctaText(TripProvider trip) {
    switch (trip.status) {
      case TripStatus.idle:
        return 'Заказать';
      case TripStatus.searchingDriver:
        return 'Поиск водителя...';
      case TripStatus.driverAssigned:
        return 'Водитель назначен';
      case TripStatus.onTrip:
        return 'В пути';
      case TripStatus.completed:
        return 'Завершено';
    }
  }

  Widget _buildFromField(TripProvider trip) {
    return TypeAheadField<PlaceSuggestion>(
      controller: _fromController,
      suggestionsCallback: (pattern) => _nominatim.search(pattern),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: 'Откуда',
            border: OutlineInputBorder(),
          ),
        );
      },
      itemBuilder: (context, item) => ListTile(title: Text(item.displayName)),
      onSelected: (item) async {
        await trip.setPoints(from: item.coordinates, osrm: _osrm);
        _mapController.move(item.coordinates, 14);
      },
      emptyBuilder: (context) => const ListTile(title: Text('Ничего не найдено')),
    );
  }

  Widget _buildToField(TripProvider trip) {
    return TypeAheadField<PlaceSuggestion>(
      controller: _toController,
      suggestionsCallback: (pattern) => _nominatim.search(pattern),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: 'Куда',
            border: OutlineInputBorder(),
          ),
        );
      },
      itemBuilder: (context, item) => ListTile(title: Text(item.displayName)),
      onSelected: (item) async {
        await trip.setPoints(to: item.coordinates, osrm: _osrm);
        _mapController.move(item.coordinates, 14);
      },
      emptyBuilder: (context) => const ListTile(title: Text('Ничего не найдено')),
    );
  }
}


