import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/place_suggestion.dart';

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  final http.Client _httpClient;

  NominatimService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<List<PlaceSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'limit': '8',
      'addressdetails': '0',
    });

    final response = await _httpClient.get(
      uri,
      headers: {
        'User-Agent': 'TaxiFlutterApp/1.0 (contact: example@example.com)',
      },
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      final lat = double.tryParse(map['lat'] as String? ?? '') ?? 0;
      final lon = double.tryParse(map['lon'] as String? ?? '') ?? 0;
      return PlaceSuggestion(
        displayName: (map['display_name'] as String?)?.trim() ?? 'Unknown',
        coordinates: LatLng(lat, lon),
      );
    }).toList(growable: false);
  }
}


