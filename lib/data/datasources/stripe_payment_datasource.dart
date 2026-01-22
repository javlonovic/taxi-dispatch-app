import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/config/stripe_config.dart';
import '../../core/exceptions/app_exception.dart';

/// Stripe payment data source
class StripePaymentDataSource {
  /// Initialize Stripe
  Future<void> initialize() async {
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      Stripe.merchantIdentifier = StripeConfig.merchantDisplayName;
      await Stripe.instance.applySettings();
    } catch (e) {
      throw PaymentException('Failed to initialize Stripe: ${e.toString()}');
    }
  }

  /// Create payment method
  Future<PaymentMethod> createPaymentMethod() async {
    try {
      // Present card form to user
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      return paymentMethod;
    } on StripeException catch (e) {
      throw PaymentException(
        'Failed to create payment method: ${e.error.message}',
        e.error.code.name,
      );
    } catch (e) {
      throw PaymentException('Failed to create payment method: ${e.toString()}');
    }
  }

  /// Present card form
  Future<PaymentMethod?> presentCardForm() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return null;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return null; // User canceled
      }
      throw PaymentException(
        'Payment failed: ${e.error.message}',
        e.error.code.name,
      );
    } catch (e) {
      throw PaymentException('Payment failed: ${e.toString()}');
    }
  }

  /// Initialize payment sheet
  Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String customerId,
    required String ephemeralKeySecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: StripeConfig.merchantDisplayName,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: false,
        ),
      );
    } on StripeException catch (e) {
      throw PaymentException(
        'Failed to initialize payment sheet: ${e.error.message}',
        e.error.code.name,
      );
    } catch (e) {
      throw PaymentException('Failed to initialize payment sheet: ${e.toString()}');
    }
  }

  /// Confirm payment
  Future<void> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );
    } on StripeException catch (e) {
      throw PaymentException(
        'Payment confirmation failed: ${e.error.message}',
        e.error.code.name,
      );
    } catch (e) {
      throw PaymentException('Payment confirmation failed: ${e.toString()}');
    }
  }
}
