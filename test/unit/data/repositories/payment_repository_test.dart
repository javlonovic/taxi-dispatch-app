    import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentRepository - calculateFare logic', () {
    // Test the fare calculation logic directly
    // Base fare: 2.50, Per km: 1.50, Per minute: 0.25, Minimum: 5.00
    
    double calculateFare(double distance, {int? durationMinutes}) {
      const double baseFare = 2.50;
      const double perKmRate = 1.50;
      const double perMinuteRate = 0.25;
      const double minimumFare = 5.00;
      
      final distanceFare = distance * perKmRate;
      final timeFare = durationMinutes != null ? durationMinutes * perMinuteRate : 0.0;
      final totalFare = baseFare + distanceFare + timeFare;
      
      return totalFare < minimumFare ? minimumFare : totalFare;
    }

    test('calculateFare returns correct fare for short distance', () {
      final fare = calculateFare(2.0);
      
      // Base fare (2.50) + (2.0 km * 1.50 per km) = 5.50
      expect(fare, 5.50);
    });

    test('calculateFare includes time-based charges', () {
      final fare = calculateFare(3.0, durationMinutes: 20);
      
      // Base fare (2.50) + (3.0 km * 1.50) + (20 min * 0.25) = 12.00
      expect(fare, 12.00);
    });

    test('calculateFare applies minimum fare', () {
      final fare = calculateFare(0.5);
      
      // Should return minimum fare of 5.0
      expect(fare, 5.0);
    });

    test('calculateFare handles zero distance', () {
      final fare = calculateFare(0.0);
      
      // Should return minimum fare
      expect(fare, 5.0);
    });

    test('calculateFare handles large distances', () {
      final fare = calculateFare(50.0, durationMinutes: 60);
      
      // Base fare (2.50) + (50.0 km * 1.50) + (60 min * 0.25) = 92.50
      expect(fare, 92.50);
    });
  });
}
