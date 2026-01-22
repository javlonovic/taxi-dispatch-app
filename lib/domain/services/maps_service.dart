import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../core/exceptions/app_exception.dart';

/// Service for Google Maps API integration
class MapsService {
  final String _apiKey;

  MapsService({required String apiKey}) : _apiKey = apiKey;

  /// Calculate distance and duration using Google Maps Directions API
  Future<Map<String, dynamic>> getDirections(
    GeoPoint origin,
    GeoPoint destination,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&departure_time=now'
        '&traffic_model=best_guess'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw NetworkException(
          'Failed to get directions: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw NetworkException(
          'Directions API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}',
        );
      }

      if (data['routes'] == null || (data['routes'] as List).isEmpty) {
        throw NetworkException('No routes found');
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      return {
        'distance': leg['distance']['value'], // in meters
        'duration': leg['duration']['value'], // in seconds
        'durationInTraffic': leg['duration_in_traffic']?['value'] ?? leg['duration']['value'], // in seconds
        'polyline': route['overview_polyline']['points'],
        'startAddress': leg['start_address'],
        'endAddress': leg['end_address'],
      };
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Failed to get directions: $e');
    }
  }

  /// Decode polyline string to list of LatLng points
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Calculate straight-line distance between two points (Haversine formula)
  double calculateStraightLineDistance(
    GeoPoint start,
    GeoPoint end,
  ) {
    const double earthRadius = 6371000; // meters

    final lat1 = start.latitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final dLat = (end.latitude - start.latitude) * (math.pi / 180);
    final dLon = (end.longitude - start.longitude) * (math.pi / 180);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }
}
