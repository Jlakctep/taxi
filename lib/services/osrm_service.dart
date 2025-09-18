import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> polyline;

  const RouteResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polyline,
  });
}

class OsrmService {
  static const String _base = 'https://router.project-osrm.org';
  final http.Client _httpClient;

  OsrmService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<RouteResult?> route(LatLng from, LatLng to) async {
    final coords = '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
    final uri = Uri.parse('$_base/route/v1/driving/$coords').replace(queryParameters: {
      'overview': 'full',
      'geometries': 'geojson',
      'alternatives': 'false',
      'steps': 'false',
    });

    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if ((data['code'] as String?) != 'Ok') return null;

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;
    final route = routes.first as Map<String, dynamic>;
    final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;

    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = (geometry?['coordinates'] as List<dynamic>? ?? [])
        .map((e) => LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble()))
        .toList(growable: false);

    return RouteResult(
      distanceMeters: distance,
      durationSeconds: duration,
      polyline: coordinates,
    );
  }
}


