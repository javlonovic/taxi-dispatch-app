import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';

/// Сервис для работы с геокодированием адресов
class GeocodingService {
  /// Получить адрес по координатам (обратное геокодирование)
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    String localeIdentifier = 'ru_RU',
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: localeIdentifier,
      );

      if (placemarks.isEmpty) {
        return 'Координаты: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      }

      final placemark = placemarks.first;
      final addressParts = <String>[];

      // Собираем адрес из доступных частей
      if (placemark.street?.isNotEmpty == true) {
        String street = placemark.street!;
        if (placemark.subThoroughfare?.isNotEmpty == true) {
          street += ', ${placemark.subThoroughfare!}';
        }
        addressParts.add(street);
      }

      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      } else if (placemark.subAdministrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.subAdministrativeArea!);
      }

      if (placemark.administrativeArea?.isNotEmpty == true &&
          placemark.administrativeArea != placemark.locality) {
        addressParts.add(placemark.administrativeArea!);
      }

      if (placemark.country?.isNotEmpty == true &&
          placemark.country != 'Uzbekistan' &&
          placemark.country != 'Узбекистан') {
        addressParts.add(placemark.country!);
      }

      return addressParts.isNotEmpty
          ? addressParts.join(', ')
          : 'Координаты: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      // В случае ошибки возвращаем координаты
      return 'Координаты: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Получить координаты по адресу (прямое геокодирование)
  Future<List<LocationResult>> getCoordinatesFromAddress(
    String address, {
    String localeIdentifier = 'ru_RU',
    int maxResults = 5,
  }) async {
    try {
      if (address.trim().isEmpty) {
        throw ValidationException('Адрес не может быть пустым');
      }

      final locations = await locationFromAddress(
        address,
        localeIdentifier: localeIdentifier,
      );

      if (locations.isEmpty) {
        throw ValidationException('Адрес не найден');
      }

      final results = <LocationResult>[];
      
      for (int i = 0; i < locations.length && i < maxResults; i++) {
        final location = locations[i];
        
        // Получаем читаемый адрес для каждой найденной точки
        final readableAddress = await getAddressFromCoordinates(
          location.latitude,
          location.longitude,
          localeIdentifier: localeIdentifier,
        );

        results.add(LocationResult(
          geoPoint: GeoPoint(location.latitude, location.longitude),
          address: readableAddress,
          originalQuery: address,
        ));
      }

      return results;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Ошибка поиска адреса: $e');
    }
  }

  /// Проверить, находится ли адрес в пределах Ташкента
  bool isLocationInTashkent(double latitude, double longitude) {
    // Примерные границы Ташкента
    const double minLat = 41.1;
    const double maxLat = 41.4;
    const double minLng = 69.1;
    const double maxLng = 69.4;

    return latitude >= minLat &&
           latitude <= maxLat &&
           longitude >= minLng &&
           longitude <= maxLng;
  }

  /// Получить предложения адресов для автодополнения
  Future<List<String>> getAddressSuggestions(String query) async {
    try {
      if (query.trim().length < 3) {
        return [];
      }

      // Добавляем "Ташкент" к запросу для более точных результатов
      final searchQuery = query.contains('Ташкент') || query.contains('Tashkent')
          ? query
          : '$query, Ташкент';

      final locations = await locationFromAddress(
        searchQuery,
        localeIdentifier: 'ru_RU',
      );

      final suggestions = <String>[];
      
      for (final location in locations.take(5)) {
        final address = await getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
        
        if (!suggestions.contains(address)) {
          suggestions.add(address);
        }
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }
}

/// Результат поиска местоположения
class LocationResult {
  final GeoPoint geoPoint;
  final String address;
  final String originalQuery;

  const LocationResult({
    required this.geoPoint,
    required this.address,
    required this.originalQuery,
  });

  @override
  String toString() {
    return 'LocationResult(address: $address, coordinates: ${geoPoint.latitude}, ${geoPoint.longitude})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationResult &&
           other.geoPoint.latitude == geoPoint.latitude &&
           other.geoPoint.longitude == geoPoint.longitude &&
           other.address == address;
  }

  @override
  int get hashCode {
    return geoPoint.latitude.hashCode ^
           geoPoint.longitude.hashCode ^
           address.hashCode;
  }
}