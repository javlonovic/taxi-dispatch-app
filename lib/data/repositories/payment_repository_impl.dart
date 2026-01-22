import '../../domain/repositories/payment_repository.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/config/stripe_config.dart';
import '../datasources/stripe_payment_datasource.dart';
import '../datasources/firestore_payment_datasource.dart';
import '../models/payment_dto.dart';

/// Payment repository implementation
class PaymentRepositoryImpl implements PaymentRepository {
  final StripePaymentDataSource _stripeDataSource;
  final FirestorePaymentDataSource _firestoreDataSource;

  PaymentRepositoryImpl({
    StripePaymentDataSource? stripeDataSource,
    FirestorePaymentDataSource? firestoreDataSource,
  })  : _stripeDataSource = stripeDataSource ?? StripePaymentDataSource(),
        _firestoreDataSource = firestoreDataSource ?? FirestorePaymentDataSource();

  /// Initialize payment system
  Future<void> initialize() async {
    await _stripeDataSource.initialize();
  }

  @override
  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      // In a real implementation, you would:
      // 1. Create payment method via Stripe
      // 2. Attach it to customer
      // 3. Save reference in Firestore
      
      // Note: userId should be passed as parameter in real implementation
      // For now, this is a placeholder
      throw UnimplementedError('User ID required - should be passed as parameter');
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to add payment method: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      final methods = await _firestoreDataSource.getPaymentMethods(userId);
      return methods.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to get payment methods: ${e.toString()}');
    }
  }

  @override
  Future<Payment> processPayment(String rideId, double amount) async {
    try {
      // Calculate fare (in real implementation, this would be more complex)
      final fare = calculateFare(amount);
      
      // Create payment intent via Cloud Function
      // In production, this should call a Cloud Function to create payment intent
      // For now, we'll create a payment record
      
      final paymentDto = PaymentDto(
        id: '', // Will be set by Firestore
        rideId: rideId,
        userId: '', // Should be passed as parameter
        amount: fare,
        currency: StripeConfig.currency,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      final paymentId = await _firestoreDataSource.createPayment(paymentDto);
      
      // In real implementation:
      // 1. Call Cloud Function to create Stripe payment intent
      // 2. Initialize payment sheet with client secret
      // 3. Present payment sheet to user
      // 4. Confirm payment
      // 5. Update payment status
      
      return Payment(
        id: paymentId,
        rideId: rideId,
        amount: fare,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to process payment: ${e.toString()}');
    }
  }

  @override
  Future<Receipt> generateReceipt(String paymentId) async {
    try {
      // Get payment details
      final payment = await _firestoreDataSource.getPayment(paymentId);
      if (payment == null) {
        throw PaymentException('Payment not found');
      }

      // Create receipt
      final receiptDto = ReceiptDto(
        id: '', // Will be set by Firestore
        paymentId: paymentId,
        rideId: payment.rideId,
        amount: payment.amount,
        currency: payment.currency,
        timestamp: payment.timestamp,
      );

      final receiptId = await _firestoreDataSource.createReceipt(receiptDto);

      return Receipt(
        id: receiptId,
        paymentId: paymentId,
        amount: payment.amount,
        timestamp: payment.timestamp,
      );
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to generate receipt: ${e.toString()}');
    }
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String userId) async {
    try {
      final transactions = await _firestoreDataSource.getTransactionHistory(userId);
      return transactions.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to get transaction history: ${e.toString()}');
    }
  }

  /// Calculate fare based on distance and time
  /// Requirements: 11.1, 11.4
  double calculateFare(double distance, {int? durationMinutes}) {
    // Base fare
    const double baseFare = 2.50;
    
    // Per kilometer rate
    const double perKmRate = 1.50;
    
    // Per minute rate
    const double perMinuteRate = 0.25;
    
    // Calculate distance fare
    final distanceFare = distance * perKmRate;
    
    // Calculate time fare
    final timeFare = durationMinutes != null ? durationMinutes * perMinuteRate : 0.0;
    
    // Total fare
    final totalFare = baseFare + distanceFare + timeFare;
    
    // Minimum fare
    const double minimumFare = 5.00;
    
    return totalFare < minimumFare ? minimumFare : totalFare;
  }

  /// Get driver earnings
  Future<double> getDriverEarnings(String driverId) async {
    try {
      return await _firestoreDataSource.getDriverEarnings(driverId);
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to get driver earnings: ${e.toString()}');
    }
  }

  /// Record driver earning
  Future<void> recordDriverEarning({
    required String driverId,
    required String rideId,
    required double amount,
  }) async {
    try {
      final transaction = TransactionDto(
        id: '', // Will be set by Firestore
        userId: driverId,
        amount: amount,
        timestamp: DateTime.now(),
        type: 'earning',
        rideId: rideId,
        description: 'Ride earnings',
      );

      await _firestoreDataSource.createTransaction(transaction);
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to record driver earning: ${e.toString()}');
    }
  }

  /// Record company payment
  Future<void> recordCompanyPayment({
    required String companyId,
    required String rideId,
    required double amount,
  }) async {
    try {
      final transaction = TransactionDto(
        id: '', // Will be set by Firestore
        userId: companyId,
        amount: -amount, // Negative for payment
        timestamp: DateTime.now(),
        type: 'payment',
        rideId: rideId,
        description: 'Ride payment',
      );

      await _firestoreDataSource.createTransaction(transaction);
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Failed to record company payment: ${e.toString()}');
    }
  }
}
