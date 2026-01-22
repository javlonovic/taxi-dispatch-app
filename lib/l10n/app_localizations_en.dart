// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Taxi Dispatch';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get usernameHint => 'Enter username';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get phoneHint => 'Enter phone number';

  @override
  String get invalidUsername => 'Invalid username';

  @override
  String get invalidPassword => 'Password must be at least 8 characters';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get usernameAlreadyExists => 'Username already exists';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get weakPassword => 'Password is too weak (minimum 8 characters)';

  @override
  String get networkError => 'No internet connection';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get transactions => 'Transactions';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get companyRole => 'I\'m a Company';

  @override
  String get driverRole => 'I\'m a Driver';

  @override
  String get companyName => 'Company Name';

  @override
  String get companyNameHint => 'Enter company name';

  @override
  String get companyNameRequired => 'Company name is required';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get age => 'Age';

  @override
  String get carModel => 'Car Model';

  @override
  String get carNumber => 'Car Number';

  @override
  String get carColor => 'Car Color';

  @override
  String get firstNameHint => 'Enter first name';

  @override
  String get lastNameHint => 'Enter last name';

  @override
  String get ageHint => 'Enter age';

  @override
  String get carModelHint => 'Enter car model';

  @override
  String get carNumberHint => 'Enter car number';

  @override
  String get carColorHint => 'Enter car color';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get ageRequired => 'Age is required';

  @override
  String get carModelRequired => 'Car model is required';

  @override
  String get carNumberRequired => 'Car number is required';

  @override
  String get carColorRequired => 'Car color is required';

  @override
  String get headquartersLocation => 'Headquarters Location';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get selectLocationOnMap => 'Select location on map';

  @override
  String get branches => 'Branches';

  @override
  String get addBranch => 'Add Branch';

  @override
  String get editBranch => 'Edit Branch';

  @override
  String get deleteBranch => 'Delete Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchNameHint => 'Enter branch name';

  @override
  String get branchNameRequired => 'Branch name is required';

  @override
  String get cannotDeleteLastBranch => 'Cannot delete the last branch';

  @override
  String get confirmDeleteBranch =>
      'Are you sure you want to delete this branch?';

  @override
  String get searchForTaxi => 'Search for Taxi';

  @override
  String get recipientName => 'Recipient Name';

  @override
  String get recipientPhone => 'Recipient Phone';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get recipientNameHint => 'Enter recipient name';

  @override
  String get recipientPhoneHint => 'Enter recipient phone';

  @override
  String get deliveryAddressHint => 'Enter delivery address';

  @override
  String get recipientNameRequired => 'Recipient name is required';

  @override
  String get recipientPhoneRequired => 'Recipient phone is required';

  @override
  String get deliveryAddressRequired => 'Delivery address is required';

  @override
  String get readyTime => 'When ready for pickup?';

  @override
  String get readyNow => 'Now';

  @override
  String get readyIn15 => '15 min';

  @override
  String get readyIn30 => '30 min';

  @override
  String get readyIn45 => '45 min';

  @override
  String get readyIn60 => '60 min';

  @override
  String get driverWillBeNotified => 'Driver will be notified of ready time';

  @override
  String get selectBranch => 'Select Branch';

  @override
  String get selectBranchForDelivery => 'Select which branch needs delivery';

  @override
  String get driverStatus => 'Driver Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get activeDescription => 'Active - you receive orders';

  @override
  String get inactiveDescription => 'Inactive - you don\'t receive orders';

  @override
  String get changeStatus => 'Change Status?';

  @override
  String get confirmActivateStatus =>
      'You will start receiving notifications about new orders within 5-6 km radius';

  @override
  String get confirmDeactivateStatus =>
      'You will stop receiving orders. You can activate status anytime.';

  @override
  String get statusChangedToActive => 'Status changed to Active';

  @override
  String get statusChangedToInactive => 'Status changed to Inactive';

  @override
  String get searching => 'Searching';

  @override
  String get searchingForDriver => 'Searching for available drivers nearby';

  @override
  String get stillSearching => 'Still searching, please wait';

  @override
  String get driverOnTheWay => 'Driver on the way';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get noDriverFound => 'No taxi found, try later';

  @override
  String get driverInfo => 'Driver Information';

  @override
  String get driverName => 'Driver Name';

  @override
  String get carInfo => 'Car Information';

  @override
  String get rating => 'Rating';

  @override
  String get eta => 'ETA';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get acceptOrder => 'Accept';

  @override
  String get skipOrder => 'Skip';

  @override
  String get orderAccepted => 'Order Accepted';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get firstTimeUserBanner => 'This is your first order? We\'ll help!';

  @override
  String get howToOrder => 'How to order delivery';

  @override
  String get deliveryHistory => 'Delivery History';

  @override
  String get noHistory => 'No history';

  @override
  String get viewDetails => 'View Details';

  @override
  String get profileImage => 'Profile Image';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Taxi Dispatch';

  @override
  String get onboardingWelcomeSubtitle => 'Fast delivery for your business';

  @override
  String get onboardingCompanyTitle => 'For Companies';

  @override
  String get onboardingCompanyDescription =>
      'Order delivery from any branch of your company';

  @override
  String get onboardingCompanyFeature1 => 'Multiple branches';

  @override
  String get onboardingCompanyFeature2 => 'Real-time tracking';

  @override
  String get onboardingCompanyFeature3 => 'Delivery history';

  @override
  String get onboardingDriverTitle => 'For Drivers';

  @override
  String get onboardingDriverDescription => 'Accept orders and earn';

  @override
  String get onboardingDriverFeature1 => 'Flexible schedule';

  @override
  String get onboardingDriverFeature2 => 'Instant notifications';

  @override
  String get onboardingDriverFeature3 => 'Earnings tracking';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get submit => 'Submit';

  @override
  String get continueButton => 'Continue';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get phoneVerification => 'Phone Verification';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verify => 'Verify';

  @override
  String get companyRegistration => 'Company Registration';

  @override
  String get driverRegistration => 'Driver Registration';

  @override
  String get selectRole => 'Select Role';

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get minAge => 'Minimum age is 18';

  @override
  String get invalidAge => 'Invalid age';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get companyDashboard => 'Company Dashboard';

  @override
  String get driverDashboard => 'Driver Dashboard';

  @override
  String get headquarters => 'Headquarters';

  @override
  String get isHeadquarters => 'Headquarters';

  @override
  String get branchAddress => 'Branch Address';

  @override
  String get branchLocation => 'Branch Location';

  @override
  String get createDelivery => 'Create Delivery';

  @override
  String get requestDelivery => 'Request Delivery';

  @override
  String get deliveryRequest => 'Delivery Request';

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get deliveryStatus => 'Delivery Status';

  @override
  String get requestedAt => 'Requested At';

  @override
  String get acceptedAt => 'Accepted At';

  @override
  String get completedAt => 'Completed At';

  @override
  String get cancelledAt => 'Cancelled At';

  @override
  String get cancellationReason => 'Cancellation Reason';

  @override
  String get pickupTime => 'Pickup Time';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get route => 'Route';

  @override
  String get driverAssigned => 'Driver Assigned';

  @override
  String get waitingForDriver => 'Waiting for Driver';

  @override
  String get driverArriving => 'Driver Arriving';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get enroute => 'En Route';

  @override
  String get arrived => 'Arrived';

  @override
  String get acceptedOrders => 'Accepted Orders';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get completedOrders => 'Completed Orders';

  @override
  String get cancelledOrders => 'Cancelled Orders';

  @override
  String get newOrder => 'New Order';

  @override
  String get newOrderAvailable => 'New Order Available';

  @override
  String get orderReceived => 'Order Received';

  @override
  String get orderCancelled => 'Order Cancelled';

  @override
  String get orderCompleted => 'Order Completed';

  @override
  String get notificationTitle => 'Notification';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get disableNotifications => 'Disable Notifications';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get notificationPermissionRequired =>
      'Notification permission required';

  @override
  String get location => 'Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get locationPermission => 'Location Permission';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get locationServices => 'Location Services';

  @override
  String get locationNotAvailable => 'Location not available';

  @override
  String get map => 'Map';

  @override
  String get showOnMap => 'Show on Map';

  @override
  String get openMap => 'Open Map';

  @override
  String get selectOnMap => 'Select on Map';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get amount => 'Amount';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get payNow => 'Pay Now';

  @override
  String get earnings => 'Earnings';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get todayEarnings => 'Today\'s Earnings';

  @override
  String get weekEarnings => 'Week\'s Earnings';

  @override
  String get monthEarnings => 'Month\'s Earnings';

  @override
  String get transaction => 'Transaction';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get transactionDate => 'Transaction Date';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactions => 'No Transactions';

  @override
  String get chat => 'Chat';

  @override
  String get messages => 'Messages';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get typeMessage => 'Type a message';

  @override
  String get noMessages => 'No Messages';

  @override
  String get chatWith => 'Chat with';

  @override
  String get rateDriver => 'Rate Driver';

  @override
  String get rateCompany => 'Rate Company';

  @override
  String get rateExperience => 'Rate Your Experience';

  @override
  String get howWasDriver => 'How was your driver?';

  @override
  String get howWasService => 'How was the service?';

  @override
  String get leaveReview => 'Leave a Review';

  @override
  String get review => 'Review';

  @override
  String get reviews => 'Reviews';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get ratingSubmitted => 'Rating Submitted';

  @override
  String get ratingSubmittedSuccessfully => 'Rating submitted successfully';

  @override
  String get failedToSubmitRating => 'Failed to submit rating';

  @override
  String get driverVerification => 'Driver Verification';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get verified => 'Verified';

  @override
  String get rejected => 'Rejected';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get approveDriver => 'Approve Driver';

  @override
  String get rejectDriver => 'Reject Driver';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get noPendingVerifications => 'No pending verifications';

  @override
  String get driverApproved => 'Driver Approved';

  @override
  String get driverRejected => 'Driver Rejected';

  @override
  String get driverApprovedSuccessfully => 'Driver approved successfully';

  @override
  String get driverRejectedSuccessfully => 'Driver rejected successfully';

  @override
  String get failedToUpdateVerification => 'Failed to update verification';

  @override
  String get rejectionReason => 'Rejection Reason';

  @override
  String get enterRejectionReason => 'Enter rejection reason';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get driverLicense => 'Driver License';

  @override
  String get licenseNumber => 'License Number';

  @override
  String get licensePhoto => 'License Photo';

  @override
  String get viewLicense => 'View License';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get faq => 'FAQ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete your account?';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Update Later';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkInternetConnection => 'Check your internet connection';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String get reconnecting => 'Reconnecting...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get requiredField => 'Required field';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get fieldRequired => 'Field is required';

  @override
  String get fieldTooShort => 'Field is too short';

  @override
  String get fieldTooLong => 'Field is too long';

  @override
  String get searchRadius => 'Search Radius';

  @override
  String searchRadiusKm(Object radius) {
    return 'Search radius: $radius km';
  }

  @override
  String get nearbyDrivers => 'Nearby Drivers';

  @override
  String get noDriversNearby => 'No drivers nearby';

  @override
  String driversFound(Object count) {
    return 'Drivers found: $count';
  }

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get confirmCancelOrder =>
      'Are you sure you want to cancel this order?';

  @override
  String get orderCancelledSuccessfully => 'Order cancelled successfully';

  @override
  String get cannotCancelOrder => 'Cannot cancel order';

  @override
  String get startRide => 'Start Ride';

  @override
  String get endRide => 'End Ride';

  @override
  String get arrivedAtPickup => 'Arrived at Pickup';

  @override
  String get arrivedAtDestination => 'Arrived at Destination';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get dropoffLocation => 'Dropoff Location';

  @override
  String get destination => 'Destination';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get filter => 'Filter';

  @override
  String get filterBy => 'Filter by';

  @override
  String get sortBy => 'Sort by';

  @override
  String get all => 'All';

  @override
  String get dateRange => 'Date Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get noRidesFound => 'No rides found';

  @override
  String get rideHistoryEmpty => 'Ride history is empty';

  @override
  String get yourRideHistoryWillAppearHere =>
      'Your ride history will appear here';

  @override
  String get errorLoadingRideHistory => 'Error loading ride history';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get pleaseLogInToViewHistory => 'Please log in to view ride history';

  @override
  String get loginRequired => 'Login required';

  @override
  String get youllSeeNotificationsHere =>
      'You\'ll see notifications here when you receive them';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get cameraPermission => 'Camera Permission';

  @override
  String get cameraPermissionRequired => 'Camera permission required';

  @override
  String get storagePermission => 'Storage Permission';

  @override
  String get storagePermissionRequired => 'Storage permission required';

  @override
  String get updating => 'Updating...';

  @override
  String get saving => 'Saving...';

  @override
  String get deleting => 'Deleting...';

  @override
  String get uploading => 'Uploading...';

  @override
  String get downloading => 'Downloading...';

  @override
  String get processing => 'Processing...';

  @override
  String get updatedSuccessfully => 'Updated successfully';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get uploadedSuccessfully => 'Uploaded successfully';

  @override
  String get failedToUpdate => 'Failed to update';

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get failedToUpload => 'Failed to upload';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone';

  @override
  String get proceedWithCaution => 'Proceed with caution';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get week => 'week';

  @override
  String get weeks => 'weeks';

  @override
  String get month => 'month';

  @override
  String get months => 'months';

  @override
  String get ago => 'ago';

  @override
  String get justNow => 'just now';

  @override
  String get now => 'now';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get away => 'Away';

  @override
  String get busy => 'Busy';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get onDuty => 'On Duty';

  @override
  String get offDuty => 'Off Duty';
}
