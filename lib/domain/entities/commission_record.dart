/// Commission record entity
/// Represents a commission transaction for a completed delivery
class CommissionRecord {
  final String id;
  final String rideId;
  final String companyId;
  final String driverId;
  final double amount; // Total delivery fee (25,000 сум)
  final double commission; // Platform commission (5,000 сум - 20%)
  final double driverEarnings; // Driver earnings (20,000 сум - 80%)
  final DateTime timestamp;

  CommissionRecord({
    required this.id,
    required this.rideId,
    required this.companyId,
    required this.driverId,
    required this.amount,
    required this.commission,
    required this.driverEarnings,
    required this.timestamp,
  });

  /// Verify that commission calculation is correct
  bool get isValid {
    return (commission + driverEarnings) == amount;
  }

  /// Get commission rate as percentage
  double get commissionRate {
    return (commission / amount) * 100;
  }

  /// Get driver earnings rate as percentage
  double get driverEarningsRate {
    return (driverEarnings / amount) * 100;
  }
}
