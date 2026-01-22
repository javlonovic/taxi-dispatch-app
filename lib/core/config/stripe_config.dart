/// Stripe configuration
class StripeConfig {
  // TODO: Replace with your actual Stripe publishable key
  // For development, use test keys from https://dashboard.stripe.com/test/apikeys
  static const String publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
  
  // Merchant display name
  static const String merchantDisplayName = 'Taxi Dispatch App';
  
  // Currency
  static const String currency = 'usd';
  
  // Note: Secret key should NEVER be stored in the app
  // It should only be used in backend/Cloud Functions
}
