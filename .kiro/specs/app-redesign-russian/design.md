# Design Document - App Redesign with Russian Localization

## Overview

This design document outlines the technical architecture and implementation approach for redesigning the taxi dispatch application with Russian localization, username-based authentication, branch management, streamlined navigation, and enhanced delivery workflow.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Onboarding  │  │     Auth     │  │   Dashboard  │      │
│  │   Screens    │  │   Screens    │  │   Screens    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Profile    │  │   History    │  │   Tracking   │      │
│  │   Screens    │  │   Screens    │  │   Screens    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                      State Management                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Riverpod   │  │  Localization│  │  Onboarding  │      │
│  │   Providers  │  │   Provider   │  │   Provider   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                       Domain Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entities   │  │   Services   │  │ Repositories │      │
│  │   (Models)   │  │   (Logic)    │  │ (Interfaces) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                        Data Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Firestore   │  │    Storage   │  │     FCM      │      │
│  │  Datasource  │  │  Datasource  │  │  Datasource  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Flow

```
App Launch
    ↓
Check First Launch
    ↓
[First Time] → Onboarding (3-4 screens) → Role Selection
    ↓
[Returning] → Check Auth Status
    ↓
[Not Authenticated] → Login Screen
    ↓
[Authenticated] → Dashboard (Company or Driver)
    ↓
Bottom Navigation: Home | History | [Transactions] | Profile
```

## Components and Interfaces

### 1. Localization System

**Design Rationale:** Using Flutter's built-in localization system (flutter_localizations) ensures proper date/time formatting, text direction, and locale-specific behavior. ARB files provide a standard format for translations that integrates seamlessly with Flutter's tooling.

**Russian Language Files Structure:**
```
lib/
  l10n/
    app_ru.arb          # Russian translations (primary)
    app_en.arb          # English fallback
  core/
    localization/
      app_localizations.dart        # Generated localization class
      localization_provider.dart    # Riverpod provider for locale management
```

**Key Translation Categories:**
- Authentication (login, register, errors) - _Requirements 1, 3, 7_
- Navigation (home, history, profile, transactions) - _Requirements 1, 5_
- Delivery flow (searching, on the way, delivered) - _Requirements 1, 11, 13_
- Notifications (order received, driver assigned) - _Requirements 1, 10_
- Dialogs (confirmations, errors, status changes) - _Requirements 1, 4, 8_
- Forms (labels, placeholders, validation) - _Requirements 1, 3, 6, 7_
- Onboarding (welcome, features, get started) - _Requirements 1, 2_
- Branch management (add, edit, delete, select) - _Requirements 1, 4_
- Status messages (delivered, cancelled, no driver found) - _Requirements 1, 11, 15_

**Date/Time Formatting:**
```dart
// Use intl package for Russian locale formatting
DateFormat('d MMMM yyyy', 'ru_RU').format(date);  // "15 января 2024"
DateFormat('HH:mm', 'ru_RU').format(time);        // "14:30"
```

**Implementation Notes:**
- All UI text must be loaded from ARB files, no hardcoded strings
- Error messages from Firebase must be mapped to Russian equivalents
- Numeric formatting should follow Russian conventions (space as thousands separator)
- Currency should display as "₽" (ruble symbol)

### 2. Onboarding System

**Design Rationale:** A 3-4 screen onboarding flow introduces the app's value proposition to first-time users without overwhelming them. Using SharedPreferences for persistence ensures the onboarding is shown only once, meeting Requirement 2. The flow ends with role selection, seamlessly transitioning users into the authentication process.

**Onboarding Screens:** _Requirements 2, 14_

**Screen 1: Welcome**
- App logo (from assets/icon/app_icon.png)
- Title: "Добро пожаловать в [App Name]"
- Subtitle: "Быстрая доставка для вашего бизнеса"
- Skip button (top-right)

**Screen 2: For Companies**
- Illustration (delivery truck/office)
- Title: "Для компаний"
- Description: "Заказывайте доставку из любого филиала вашей компании"
- Features:
  - Управление филиалами (Multiple branches)
  - Отслеживание в реальном времени (Real-time tracking)
  - История доставок (Delivery history)

**Screen 3: For Drivers**
- Illustration (driver/car)
- Title: "Для водителей"
- Description: "Принимайте заказы и зарабатывайте"
- Features:
  - Гибкий график (Flexible schedule)
  - Мгновенные уведомления (Instant notifications)
  - Отслеживание заработка (Earnings tracking)

**Screen 4: Get Started**
- CTA buttons: 
  - "Я компания" (I'm a company) → Company Registration
  - "Я водитель" (I'm a driver) → Driver Registration

**Implementation:**
```dart
class OnboardingScreen extends StatefulWidget {
  // PageView with 4 screens
  // Dots indicator for current page
  // Skip button (navigates to role selection)
  // Next/Get Started button
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final List<String> features;
  final String? imagePath;
}

class OnboardingProvider extends StateNotifier<OnboardingState> {
  Future<void> completeOnboarding() async {
    await _prefs.setBool('has_seen_onboarding', true);
    state = state.copyWith(hasSeenOnboarding: true);
  }
  
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }
}
```

**Storage:**
- SharedPreferences: `has_seen_onboarding: bool`
- Check on app launch to determine navigation path

**Navigation Flow:**
```
App Launch
    ↓
Check has_seen_onboarding
    ↓
[false] → Onboarding Screen → Role Selection
    ↓
[true] → Check Auth Status → Login/Dashboard
```

### 3. Authentication System Redesign

**Design Rationale:** Username-based authentication provides a simpler, more memorable login experience compared to email addresses. Since Firebase Auth requires an email, we use an internal email format (`{username}@taxidispatch.internal`) that's hidden from users. This approach maintains Firebase Auth's security features while presenting a username-based interface. _Requirements 3, 7_

**Changes from Email to Username:**

**Old System:**
- Email + Password
- Firebase Auth email/password
- Email visible to users

**New System:**
- Username + Password (user-facing)
- Internal email format: `{username}@taxidispatch.internal`
- Store username in Firestore for display
- Hide internal email from all UI

**Username Validation:**
```dart
class UsernameValidator {
  static const minLength = 3;
  static const maxLength = 20;
  static final validPattern = RegExp(r'^[a-zA-Z0-9_]+$');
  
  static Future<bool> isUnique(String username) async {
    // Query Firestore users collection
    final query = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username.toLowerCase())
      .limit(1)
      .get();
    return query.docs.isEmpty;
  }
}
```

**Data Model:**
```dart
class User {
  String id;
  String username;           // NEW: Display name for login (unique, lowercase)
  String internalEmail;      // Hidden: {username}@taxidispatch.internal
  String phoneNumber;
  String? profileImageUrl;
  UserType type;             // company or driver
  DateTime createdAt;
  
  // Company-specific fields
  String? companyName;
  GeoPoint? headquartersLocation;
  List<Branch> branches;     // NEW: Company branches
  
  // Driver-specific fields
  String? firstName;
  String? lastName;
  int? age;
  String? carModel;
  String? carNumber;
  String? carColor;
  bool? isActive;            // NEW: Driver availability status
  double? rating;
  GeoPoint? currentLocation;
}

class Branch {
  String id;
  String name;
  String address;
  GeoPoint location;
  bool isHeadquarters;
  DateTime createdAt;
}
```

**Company Registration Flow:** _Requirement 3_
```
1. Username (unique check, 3-20 chars, alphanumeric + underscore)
2. Password (min 8 chars, validation)
3. Company Name (required)
4. Phone Number (required, format validation)
5. Profile Image (optional, upload to Firebase Storage)
6. Headquarters Location (map picker, required)
   ↓
Validate all fields
   ↓
Check username uniqueness
   ↓
Create Firebase Auth account: {username}@taxidispatch.internal
   ↓
Store user data in Firestore users/{userId}
   ↓
Create default branch (headquarters) in users/{userId}/branches
   ↓
Navigate to Company Dashboard
```

**Driver Registration Flow:** _Requirement 7_
```
1. Username (unique check)
2. Password (min 8 chars)
3. First Name (required)
4. Last Name (required)
5. Age (required, min 18)
6. Car Model (required)
7. Car Number (required, format validation)
8. Car Color (required)
   ↓
Validate all fields
   ↓
Check username uniqueness
   ↓
Create Firebase Auth account: {username}@taxidispatch.internal
   ↓
Store driver data in Firestore users/{userId}
   ↓
Set isActive = false (driver must manually activate)
   ↓
Navigate to Driver Dashboard
```

**Login Flow:** _Requirements 3, 7_
```
1. Enter username
2. Enter password
   ↓
Convert username to internal email: {username}@taxidispatch.internal
   ↓
Authenticate with Firebase Auth
   ↓
Fetch user data from Firestore
   ↓
Navigate to appropriate dashboard (Company/Driver)
```

**Error Handling:**
- Username already exists: "Имя пользователя уже занято"
- Invalid credentials: "Неверное имя пользователя или пароль"
- Weak password: "Пароль слишком слабый (минимум 8 символов)"
- Network error: "Нет подключения к интернету"

### 4. Branch Management System

**Design Rationale:** Storing branches as a subcollection under each company user provides natural data isolation and efficient querying. The system prevents deletion of the last branch to ensure companies always have at least one location. Branch selection before delivery requests allows companies to accurately specify pickup locations. _Requirement 4_

**Firestore Structure:**
```
users/{userId}/
  branches/{branchId}/
    name: string                    // "Главный офис", "Филиал №2"
    address: string                 // Full address for display
    location: GeoPoint              // Lat/lng for map and distance calculations
    isHeadquarters: boolean         // True for main office
    createdAt: timestamp
```

**UI Components:**
```dart
class BranchListWidget extends StatelessWidget {
  // Displays all branches in profile screen
  // Shows headquarters badge
  // Edit/Delete actions per branch
  // Add branch button
}

class BranchFormDialog extends StatefulWidget {
  // Add/Edit branch form
  // Fields: name, address, map picker
  // Validation and save
}

class BranchSelectorBottomSheet extends StatelessWidget {
  // Shows when company has multiple branches
  // Displays before delivery request form
  // Radio selection with branch names and addresses
  // Confirm button
}

class BranchMapPicker extends StatefulWidget {
  // Google Maps integration
  // Draggable marker for location selection
  // Address search/autocomplete
  // Confirm location button
}
```

**Operations:** _Requirement 4_

**Add Branch:**
```
1. Tap "Добавить филиал" in profile
2. Enter branch name (required)
3. Enter address (required)
4. Select location on map (required)
5. Save
   ↓
Validate fields
   ↓
Create document in users/{userId}/branches
   ↓
Refresh branch list
```

**Edit Branch:**
```
1. Tap edit icon on branch
2. Modify name, address, or location
3. Save
   ↓
Update document in Firestore
   ↓
Refresh branch list
```

**Delete Branch:** _Requirement 4_
```
1. Tap delete icon on branch
2. Check if last remaining branch
   ↓
[Last branch] → Show error: "Нельзя удалить последний филиал"
   ↓
[Not last] → Show confirmation dialog:
   "Вы уверены, что хотите удалить этот филиал?"
   [Отмена] [Удалить]
   ↓
Delete document from Firestore
   ↓
Refresh branch list
```

**Select Branch for Delivery:** _Requirements 4, 6_
```
Company taps "Найти такси"
   ↓
Check number of branches
   ↓
[1 branch] → Use default branch, show delivery form
   ↓
[Multiple branches] → Show BranchSelectorBottomSheet
   ↓
User selects branch
   ↓
Show delivery form with selected branch as pickup location
```

**Branch Provider:**
```dart
final branchesProvider = StreamProvider.family<List<Branch>, String>(
  (ref, userId) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('branches')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Branch.fromFirestore(doc))
          .toList());
  },
);
```

### 5. Simplified Navigation

**Company Navigation (4 items):**
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icons.home,
      label: 'Главная',  // Home
    ),
    BottomNavigationBarItem(
      icon: Icons.history,
      label: 'История',  // History
    ),
    BottomNavigationBarItem(
      icon: Icons.receipt_long,
      label: 'Транзакции',  // Transactions
    ),
    BottomNavigationBarItem(
      icon: Icons.person,
      label: 'Профиль',  // Profile
    ),
  ],
)
```

**Driver Navigation (3 items):**
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icons.home,
      label: 'Главная',  // Home
    ),
    BottomNavigationBarItem(
      icon: Icons.history,
      label: 'История',  // History
    ),
    BottomNavigationBarItem(
      icon: Icons.person,
      label: 'Профиль',  // Profile
    ),
  ],
)
```

### 6. Enhanced Company Dashboard

**Design Rationale:** A first-time user banner provides contextual help without cluttering the interface for experienced users. The prominent "Найти такси" button makes the primary action immediately obvious. Showing recent deliveries gives users quick access to their order history. _Requirement 6_

**First-Time User Banner:**
```dart
class FirstTimeUserBanner extends StatelessWidget {
  // Displays: "Это ваш первый заказ? Мы поможем!"
  // Button: "Как заказать доставку"
  // Shows tutorial/help overlay
  // Dismissible after first completed order
  // Stored in Firestore: users/{userId}/hasCompletedFirstOrder: bool
}
```

**Main Dashboard:** _Requirement 6_
```dart
class CompanyDashboardScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final recentDeliveries = ref.watch(recentDeliveriesProvider(5));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        actions: [
          NotificationBadge(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First-time user banner
            if (!user.hasCompletedFirstOrder) 
              FirstTimeUserBanner(),
            
            SizedBox(height: 24),
            
            // Primary action button - large and prominent
            ElevatedButton.icon(
              icon: Icon(Icons.local_taxi, size: 28),
              label: Text(
                'Найти такси',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _initiateDeliveryRequest(context, ref),
            ),
            
            SizedBox(height: 32),
            
            // Recent deliveries section
            Text(
              'Недавние заказы',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            recentDeliveries.when(
              data: (deliveries) => deliveries.isEmpty
                ? EmptyStateWidget(
                    message: 'У вас пока нет заказов',
                    icon: Icons.history,
                  )
                : RecentDeliveriesWidget(deliveries: deliveries),
              loading: () => ShimmerLoading(),
              error: (error, stack) => ErrorWidget(error: error),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CompanyBottomNav(currentIndex: 0),
    );
  }
}
```

**Delivery Request Flow:** _Requirements 4, 6, 9_
```
1. User taps "Найти такси"
   ↓
2. Check number of branches
   ↓
   [1 branch] → Use default branch
   ↓
   [Multiple branches] → Show BranchSelectorBottomSheet
   ↓
3. Show Delivery Request Form:
   - Recipient Name (text field, required)
   - Recipient Phone (phone input, required, format validation)
   - Delivery Address (map picker, required)
   - Ready Time selector:
     * Сейчас (Now - 0 min)
     * 15 минут
     * 30 минут
     * 45 минут
     * 60 минут
   ↓
4. Validate all fields
   ↓
5. Show confirmation dialog with summary
   ↓
6. Create delivery request in Firestore
   ↓
7. Search for active drivers within 5-6km radius
   ↓
8. Send FCM notifications to matched drivers
   ↓
9. Show searching animation screen
   ↓
10. Wait for driver acceptance or timeout
```

**Recent Deliveries Widget:**
```dart
class RecentDeliveriesWidget extends StatelessWidget {
  final List<DeliveryRequest> deliveries;
  
  Widget build(BuildContext context) {
    return Column(
      children: deliveries.map((delivery) => 
        DeliveryCard(
          delivery: delivery,
          onTap: () => _navigateToDetails(delivery),
        )
      ).toList(),
    );
  }
}

class DeliveryCard extends StatelessWidget {
  // Shows: status badge, date/time, addresses
  // Color-coded by status
  // Tap to view full details
}
```

### 7. Driver Status Management

**Design Rationale:** Requiring confirmation for status changes prevents accidental toggling that could affect a driver's income. The confirmation dialog clearly explains the consequences of the status change. Only active drivers are included in delivery searches, ensuring companies only see available drivers. _Requirement 8_

**Status Toggle in Profile:** _Requirement 8_
```dart
class DriverStatusToggle extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentUserProvider);
    final isActive = driver.isActive ?? false;
    
    return Card(
      child: SwitchListTile(
        title: Text(
          'Статус работы',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isActive 
            ? 'Активен - вы получаете заказы' 
            : 'Неактивен - вы не получаете заказы'
        ),
        value: isActive,
        activeColor: Colors.green,
        onChanged: (value) => _showConfirmationDialog(context, ref, value),
      ),
    );
  }
  
  void _showConfirmationDialog(
    BuildContext context, 
    WidgetRef ref, 
    bool newStatus
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить статус?'),
        content: Text(
          newStatus 
            ? 'Вы начнете получать уведомления о новых заказах в радиусе 5-6 км'
            : 'Вы перестанете получать заказы. Вы сможете включить статус в любое время.'
        ),
        actions: [
          TextButton(
            child: Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Подтвердить'),
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(ref, newStatus);
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateStatus(WidgetRef ref, bool newStatus) async {
    final userId = ref.read(currentUserProvider).id;
    
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
        'isActive': newStatus,
        'lastStatusChange': FieldValue.serverTimestamp(),
      });
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus 
            ? 'Статус изменен на Активен' 
            : 'Статус изменен на Неактивен'
        ),
      ),
    );
  }
}
```

**Firestore Structure:**
```
users/{driverId}/
  isActive: boolean              // Driver availability status
  lastStatusChange: timestamp    // Track when status was last changed
  currentLocation: GeoPoint      // Updated while active
```

**Driver Search Query:** _Requirements 8, 9_
```dart
// When company requests delivery, search for active drivers
Future<List<Driver>> findNearbyDrivers(
  GeoPoint pickupLocation,
  double radiusKm,
) async {
  // Use geohashing or GeoFlutterFire for radius query
  final drivers = await FirebaseFirestore.instance
    .collection('users')
    .where('type', isEqualTo: 'driver')
    .where('isActive', isEqualTo: true)  // Only active drivers
    .get();
  
  // Filter by distance (5-6 km radius)
  return drivers.docs
    .map((doc) => Driver.fromFirestore(doc))
    .where((driver) {
      final distance = _calculateDistance(
        pickupLocation,
        driver.currentLocation,
      );
      return distance <= radiusKm;
    })
    .toList();
}
```

**Status Indicator in Driver Dashboard:**
```dart
class DriverDashboardScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentUserProvider);
    final isActive = driver.isActive ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        actions: [
          // Status indicator badge
          Chip(
            avatar: Icon(
              Icons.circle,
              size: 12,
              color: isActive ? Colors.green : Colors.grey,
            ),
            label: Text(isActive ? 'Активен' : 'Неактивен'),
            backgroundColor: isActive 
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          ),
          SizedBox(width: 8),
        ],
      ),
      // ... rest of dashboard
    );
  }
}
```

### 8. Delivery Request with Scheduled Time

**Design Rationale:** Allowing companies to specify when they'll be ready for pickup improves coordination and reduces driver wait time. Using discrete time intervals (15, 30, 45, 60 minutes) simplifies the UI while covering common use cases. Drivers see the scheduled time in notifications, allowing them to plan their route. _Requirement 9_

**Time Selector:** _Requirement 9_
```dart
class ReadyTimeSelector extends StatelessWidget {
  final List<int> options = [0, 15, 30, 45, 60]; // minutes
  final int selectedMinutes;
  final ValueChanged<int> onSelected;
  
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Когда готов к отправке?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((minutes) => 
            ChoiceChip(
              label: Text(
                minutes == 0 ? 'Сейчас' : '$minutes мин',
                style: TextStyle(
                  fontWeight: selectedMinutes == minutes 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                ),
              ),
              selected: selectedMinutes == minutes,
              onSelected: (selected) {
                if (selected) onSelected(minutes);
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: selectedMinutes == minutes 
                  ? Colors.white 
                  : Colors.black87,
              ),
            )
          ).toList(),
        ),
        if (selectedMinutes > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Водитель будет уведомлен о времени готовности',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
```

**Delivery Request Model:** _Requirements 9, 11_
```dart
class DeliveryRequest {
  final String id;
  final String companyId;
  final String? branchId;
  final String companyName;
  final String companyPhone;
  final String recipientName;
  final String recipientPhone;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint deliveryLocation;
  final String deliveryAddress;
  final DateTime requestedAt;
  final int readyInMinutes;             // 0, 15, 30, 45, 60
  final DateTime? scheduledPickupTime;  // Calculated: requestedAt + readyInMinutes
  final DeliveryStatus status;
  final String? assignedDriverId;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  DeliveryRequest({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.companyName,
    required this.companyPhone,
    required this.recipientName,
    required this.recipientPhone,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.requestedAt,
    this.readyInMinutes = 0,
    this.scheduledPickupTime,
    required this.status,
    this.assignedDriverId,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });
  
  // Calculate scheduled pickup time
  DateTime get effectivePickupTime {
    return requestedAt.add(Duration(minutes: readyInMinutes));
  }
  
  // Check if pickup is immediate
  bool get isImmediatePickup => readyInMinutes == 0;
}

enum DeliveryStatus {
  searching,      // Ищем водителя
  driverAssigned, // Водитель назначен
  onTheWay,       // В пути
  delivered,      // Доставлено
  cancelled,      // Отменено
  noDriverFound,  // Водитель не найден
}
```

**Firestore Document Structure:**
```
deliveryRequests/{requestId}/
  companyId: string
  branchId: string (optional)
  companyName: string
  companyPhone: string
  recipientName: string
  recipientPhone: string
  pickupLocation: GeoPoint
  pickupAddress: string
  deliveryLocation: GeoPoint
  deliveryAddress: string
  requestedAt: timestamp
  readyInMinutes: number (0, 15, 30, 45, 60)
  scheduledPickupTime: timestamp (calculated)
  status: string (searching, driverAssigned, onTheWay, delivered, cancelled, noDriverFound)
  assignedDriverId: string (optional)
  acceptedAt: timestamp (optional)
  pickedUpAt: timestamp (optional)
  deliveredAt: timestamp (optional)
  cancelledAt: timestamp (optional)
  cancellationReason: string (optional)
```

**Creating Delivery Request:**
```dart
Future<String> createDeliveryRequest({
  required String companyId,
  required String? branchId,
  required String recipientName,
  required String recipientPhone,
  required GeoPoint deliveryLocation,
  required String deliveryAddress,
  required int readyInMinutes,
}) async {
  final company = await _getCompanyData(companyId);
  final branch = branchId != null 
    ? await _getBranchData(companyId, branchId)
    : await _getHeadquarters(companyId);
  
  final requestedAt = DateTime.now();
  final scheduledPickupTime = requestedAt.add(
    Duration(minutes: readyInMinutes)
  );
  
  final docRef = await FirebaseFirestore.instance
    .collection('deliveryRequests')
    .add({
      'companyId': companyId,
      'branchId': branchId,
      'companyName': company.companyName,
      'companyPhone': company.phoneNumber,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'pickupLocation': branch.location,
      'pickupAddress': branch.address,
      'deliveryLocation': deliveryLocation,
      'deliveryAddress': deliveryAddress,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'readyInMinutes': readyInMinutes,
      'scheduledPickupTime': Timestamp.fromDate(scheduledPickupTime),
      'status': 'searching',
    });
  
  return docRef.id;
}
```

### 9. Driver Notification System

**Design Rationale:** FCM notifications ensure drivers receive order requests in real-time, even when the app is in the background. Including key details in the notification payload allows drivers to quickly assess the order. The order details card provides all necessary information for drivers to make an informed decision. _Requirement 10_

**FCM Notification Payload:** _Requirements 9, 10_
```json
{
  "notification": {
    "title": "Новый заказ рядом!",
    "body": "Доставка на 2.3 км от вашего местоположения"
  },
  "data": {
    "type": "delivery_request",
    "deliveryId": "abc123",
    "companyName": "ООО Компания",
    "companyPhone": "+7 (999) 123-45-67",
    "pickupAddress": "ул. Ленина, 10",
    "deliveryAddress": "ул. Пушкина, 25",
    "recipientName": "Иван Петров",
    "recipientPhone": "+7 (999) 987-65-43",
    "distance": "2.3",
    "readyInMinutes": "15",
    "scheduledPickupTime": "2024-01-15T14:30:00Z"
  }
}
```

**Sending Notifications (Cloud Function):**
```javascript
// functions/index.js
exports.notifyNearbyDrivers = functions.firestore
  .document('deliveryRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();
    const pickupLocation = request.pickupLocation;
    
    // Find active drivers within 5-6 km
    const driversSnapshot = await admin.firestore()
      .collection('users')
      .where('type', '==', 'driver')
      .where('isActive', '==', true)
      .get();
    
    const nearbyDrivers = driversSnapshot.docs.filter(doc => {
      const driver = doc.data();
      const distance = calculateDistance(
        pickupLocation,
        driver.currentLocation
      );
      return distance <= 6; // 6 km radius
    });
    
    // Send notification to each nearby driver
    const tokens = nearbyDrivers
      .map(doc => doc.data().fcmToken)
      .filter(token => token);
    
    if (tokens.length > 0) {
      const distance = calculateDistance(
        pickupLocation,
        nearbyDrivers[0].data().currentLocation
      ).toFixed(1);
      
      await admin.messaging().sendMulticast({
        tokens: tokens,
        notification: {
          title: 'Новый заказ рядом!',
          body: `Доставка на ${distance} км от вашего местоположения`,
        },
        data: {
          type: 'delivery_request',
          deliveryId: context.params.requestId,
          companyName: request.companyName,
          companyPhone: request.companyPhone,
          pickupAddress: request.pickupAddress,
          deliveryAddress: request.deliveryAddress,
          recipientName: request.recipientName,
          recipientPhone: request.recipientPhone,
          distance: distance,
          readyInMinutes: request.readyInMinutes.toString(),
          scheduledPickupTime: request.scheduledPickupTime.toISOString(),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'delivery_requests',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
    }
  });
```

**Order Details Card:** _Requirement 10_
```dart
class OrderDetailsCard extends StatelessWidget {
  final DeliveryRequest order;
  final VoidCallback onSkip;
  final VoidCallback onAccept;
  
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.local_shipping, size: 32, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Новый заказ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Company info
            _buildInfoRow(
              context,
              icon: Icons.business,
              label: 'Компания',
              value: order.companyName,
            ),
            _buildInfoRow(
              context,
              icon: Icons.phone,
              label: 'Телефон компании',
              value: order.companyPhone,
              isCallable: true,
            ),
            
            SizedBox(height: 16),
            
            // Pickup info
            _buildInfoRow(
              context,
              icon: Icons.location_on,
              label: 'Откуда',
              value: order.pickupAddress,
            ),
            
            // Delivery info
            _buildInfoRow(
              context,
              icon: Icons.flag,
              label: 'Куда',
              value: order.deliveryAddress,
            ),
            
            SizedBox(height: 16),
            
            // Recipient info
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'Получатель',
              value: order.recipientName,
            ),
            _buildInfoRow(
              context,
              icon: Icons.phone,
              label: 'Телефон получателя',
              value: order.recipientPhone,
              isCallable: true,
            ),
            
            // Scheduled time (if not immediate)
            if (order.readyInMinutes > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Готов через ${order.readyInMinutes} мин',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: Text('Пропустить'),
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    child: Text('Принять заказ'),
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCallable = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCallable)
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () => _makeCall(value),
            ),
        ],
      ),
    );
  }
  
  void _makeCall(String phoneNumber) {
    // Launch phone dialer
    // launch('tel:$phoneNumber');
  }
}
```

**Notification Handler:**
```dart
class NotificationHandler {
  static Future<void> handleNotification(RemoteMessage message) async {
    if (message.data['type'] == 'delivery_request') {
      final deliveryId = message.data['deliveryId'];
      
      // Show order details dialog
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => OrderDetailsDialog(deliveryId: deliveryId),
      );
    }
  }
}
```

### 10. Delivery Status Tracking

**Design Rationale:** Clear status progression helps companies understand where their delivery is in the process. The searching state includes progressive messaging to manage expectations during longer wait times. All deliveries are saved to history regardless of outcome, providing a complete audit trail. _Requirements 11, 13, 15_

**Status Flow:** _Requirement 11_
```
searching → driverAssigned → onTheWay → delivered
    ↓              ↓
cancelled    noDriverFound (after 2-3 min timeout)
```

**Status Display:** _Requirements 11, 13_
```dart
class DeliveryStatusWidget extends StatelessWidget {
  final DeliveryRequest delivery;
  final VoidCallback? onCancel;
  
  Widget build(BuildContext context) {
    final searchDuration = DateTime.now().difference(delivery.requestedAt).inSeconds;
    
    switch (delivery.status) {
      case DeliveryStatus.searching:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            PulseAnimation(
              child: Icon(
                Icons.local_taxi,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            
            Text(
              'Ищем водителя...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Поиск доступных водителей поблизости',
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24),
            
            // Progress messages based on duration
            if (searchDuration > 30)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Все еще ищем, пожалуйста подождите...',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
            
            if (searchDuration > 60)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  icon: Icon(Icons.cancel),
                  label: Text('Отменить поиск'),
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
          ],
        );
      
      case DeliveryStatus.driverAssigned:
      case DeliveryStatus.onTheWay:
        return DriverTrackingCard(delivery: delivery);
      
      case DeliveryStatus.delivered:
        return SuccessCard(
          icon: Icons.check_circle,
          title: 'Доставлено!',
          message: 'Заказ успешно доставлен',
          timestamp: delivery.deliveredAt,
        );
      
      case DeliveryStatus.noDriverFound:
        return ErrorCard(
          icon: Icons.error_outline,
          title: 'Водитель не найден',
          message: 'К сожалению, сейчас нет доступных водителей',
          subtitle: 'Попробуйте повторить заказ через несколько минут',
          actionLabel: 'Попробовать снова',
          onAction: () => _retryDeliveryRequest(context),
        );
      
      case DeliveryStatus.cancelled:
        return ErrorCard(
          icon: Icons.cancel,
          title: 'Заказ отменен',
          message: delivery.cancellationReason ?? 'Заказ был отменен',
          timestamp: delivery.cancelledAt,
        );
    }
  }
}

// Animated pulse for searching state
class PulseAnimation extends StatefulWidget {
  final Widget child;
  
  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
```

**Status Update Logic:**
```dart
// Timeout handler for no driver found
Future<void> startDeliverySearch(String deliveryId) async {
  // Set timeout for 2-3 minutes
  Timer(Duration(minutes: 2), () async {
    final delivery = await _getDelivery(deliveryId);
    
    // If still searching after timeout, mark as no driver found
    if (delivery.status == DeliveryStatus.searching) {
      await FirebaseFirestore.instance
        .collection('deliveryRequests')
        .doc(deliveryId)
        .update({
          'status': 'noDriverFound',
          'updatedAt': FieldValue.serverTimestamp(),
        });
    }
  });
}

// Driver accepts order
Future<void> acceptDelivery(String deliveryId, String driverId) async {
  await FirebaseFirestore.instance
    .collection('deliveryRequests')
    .doc(deliveryId)
    .update({
      'status': 'driverAssigned',
      'assignedDriverId': driverId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  
  // Notify company
  await _notifyCompany(deliveryId, 'Водитель принял заказ');
}

// Driver marks as on the way
Future<void> startDelivery(String deliveryId) async {
  await FirebaseFirestore.instance
    .collection('deliveryRequests')
    .doc(deliveryId)
    .update({
      'status': 'onTheWay',
      'pickedUpAt': FieldValue.serverTimestamp(),
    });
}

// Driver completes delivery
Future<void> completeDelivery(String deliveryId) async {
  await FirebaseFirestore.instance
    .collection('deliveryRequests')
    .doc(deliveryId)
    .update({
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });
  
  // Mark company's first order as complete
  final delivery = await _getDelivery(deliveryId);
  await FirebaseFirestore.instance
    .collection('users')
    .doc(delivery.companyId)
    .update({
      'hasCompletedFirstOrder': true,
    });
}
```

### 11. Real-time Driver Tracking

**Design Rationale:** Real-time location updates give companies visibility into delivery progress and accurate ETAs. Updating every 10 seconds balances accuracy with battery/data usage. Displaying driver details (name, car info, rating) builds trust and helps companies identify the driver. _Requirement 12_

**Driver Location Updates:** _Requirement 12_
```dart
class DriverTrackingCard extends ConsumerWidget {
  final DeliveryRequest delivery;
  
  Widget build(BuildContext context, WidgetRef ref) {
    final driverAsync = ref.watch(driverProvider(delivery.assignedDriverId!));
    final driverLocation = ref.watch(
      driverLocationStreamProvider(delivery.assignedDriverId!)
    );
    
    return driverAsync.when(
      data: (driver) => Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            // Driver info header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: driver.profileImageUrl != null
                        ? NetworkImage(driver.profileImageUrl!)
                        : null,
                      child: driver.profileImageUrl == null
                        ? Icon(Icons.person, size: 30)
                        : null,
                    ),
                    title: Text(
                      '${driver.firstName} ${driver.lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${driver.carModel} • ${driver.carColor}',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '${driver.rating?.toStringAsFixed(1) ?? "5.0"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Car number chip
                  Chip(
                    avatar: Icon(Icons.directions_car, size: 18),
                    label: Text(
                      driver.carNumber ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Map showing driver location
            driverLocation.when(
              data: (location) => SizedBox(
                height: 250,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    zoom: 14,
                  ),
                  markers: {
                    // Driver marker (blue)
                    Marker(
                      markerId: MarkerId('driver'),
                      position: LatLng(
                        location.latitude,
                        location.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Водитель',
                        snippet: '${driver.firstName} ${driver.lastName}',
                      ),
                    ),
                    // Pickup marker (green)
                    Marker(
                      markerId: MarkerId('pickup'),
                      position: LatLng(
                        delivery.pickupLocation.latitude,
                        delivery.pickupLocation.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Откуда',
                        snippet: delivery.pickupAddress,
                      ),
                    ),
                    // Delivery marker (red)
                    Marker(
                      markerId: MarkerId('delivery'),
                      position: LatLng(
                        delivery.deliveryLocation.latitude,
                        delivery.deliveryLocation.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Куда',
                        snippet: delivery.deliveryAddress,
                      ),
                    ),
                  },
                  polylines: {
                    // Route line
                    Polyline(
                      polylineId: PolylineId('route'),
                      points: [
                        LatLng(location.latitude, location.longitude),
                        LatLng(
                          delivery.deliveryLocation.latitude,
                          delivery.deliveryLocation.longitude,
                        ),
                      ],
                      color: Colors.blue,
                      width: 3,
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              loading: () => Container(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 250,
                child: Center(child: Text('Ошибка загрузки карты')),
              ),
            ),
            
            Divider(height: 1),
            
            // ETA and status
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Статус:',
                        style: TextStyle(fontSize: 16),
                      ),
                      StatusBadge(status: delivery.status),
                    ],
                  ),
                  SizedBox(height: 12),
                  driverLocation.when(
                    data: (location) {
                      final eta = _calculateETA(
                        location,
                        delivery.deliveryLocation,
                      );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прибытие через:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '$eta мин',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => CircularProgressIndicator(),
                    error: (_, __) => Text('—'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
  
  int _calculateETA(GeoPoint from, GeoPoint to) {
    // Calculate distance in km
    final distance = _calculateDistance(from, to);
    // Assume average speed of 30 km/h in city
    final hours = distance / 30;
    return (hours * 60).ceil(); // Convert to minutes
  }
}
```

**Location Update Stream:** _Requirement 12_
```dart
// Stream driver location updates every 10 seconds
final driverLocationStreamProvider = StreamProvider.family<GeoPoint, String>(
  (ref, driverId) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(driverId)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        return data?['currentLocation'] as GeoPoint? ?? 
          GeoPoint(0, 0); // Fallback
      });
  },
);

// Driver provider for full driver details
final driverProvider = FutureProvider.family<Driver, String>(
  (ref, driverId) async {
    final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(driverId)
      .get();
    return Driver.fromFirestore(doc);
  },
);
```

**Driver Location Update Service:**
```dart
// Driver app updates location every 10 seconds while on active delivery
class LocationUpdateService {
  Timer? _locationTimer;
  
  void startLocationUpdates(String driverId) {
    _locationTimer?.cancel();
    
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final position = await Geolocator.getCurrentPosition();
      
      await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .update({
          'currentLocation': GeoPoint(
            position.latitude,
            position.longitude,
          ),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
    });
  }
  
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }
}
```

### 12. Delivery History

**Design Rationale:** Comprehensive delivery history provides transparency and accountability. Showing all deliveries regardless of outcome (delivered, cancelled, no driver found) gives companies a complete record. Sorting by most recent first ensures easy access to current orders. _Requirement 15_

**History Screen:** _Requirement 15_
```dart
class DeliveryHistoryScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider).id;
    final historyAsync = ref.watch(deliveryHistoryProvider(userId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('История'),
      ),
      body: historyAsync.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history,
              message: 'У вас пока нет заказов',
              subtitle: 'История ваших доставок появится здесь',
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              return DeliveryHistoryCard(
                delivery: delivery,
                onTap: () => _navigateToDetails(context, delivery),
              );
            },
          );
        },
        loading: () => ShimmerLoading(),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

**History Card:** _Requirement 15_
```dart
class DeliveryHistoryCard extends StatelessWidget {
  final DeliveryRequest delivery;
  final VoidCallback onTap;
  
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(delivery.requestedAt),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  StatusBadge(status: delivery.status),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Pickup address
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.pickupAddress,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Delivery address
              Row(
                children: [
                  Icon(Icons.flag, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.deliveryAddress,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Recipient
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    delivery.recipientName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    // Format: "15 января, 14:30"
    return DateFormat('d MMMM, HH:mm', 'ru_RU').format(date);
  }
}

// Status badge widget
class StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  _StatusConfig _getStatusConfig(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.searching:
        return _StatusConfig('Поиск', Colors.blue);
      case DeliveryStatus.driverAssigned:
        return _StatusConfig('Назначен', Colors.orange);
      case DeliveryStatus.onTheWay:
        return _StatusConfig('В пути', Colors.purple);
      case DeliveryStatus.delivered:
        return _StatusConfig('Доставлено', Colors.green);
      case DeliveryStatus.cancelled:
        return _StatusConfig('Отменено', Colors.grey);
      case DeliveryStatus.noDriverFound:
        return _StatusConfig('Не найден', Colors.red);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  _StatusConfig(this.label, this.color);
}
```

**History Provider:**
```dart
// Stream all deliveries for a user, sorted by most recent first
final deliveryHistoryProvider = StreamProvider.family<List<DeliveryRequest>, String>(
  (ref, userId) {
    return FirebaseFirestore.instance
      .collection('deliveryRequests')
      .where('companyId', isEqualTo: userId)
      .orderBy('requestedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DeliveryRequest.fromFirestore(doc))
          .toList());
  },
);
```

**Delivery Details Screen:**
```dart
class DeliveryDetailsScreen extends StatelessWidget {
  final DeliveryRequest delivery;
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали заказа'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and date
            StatusBadge(status: delivery.status),
            SizedBox(height: 8),
            Text(
              _formatFullDate(delivery.requestedAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24),
            
            // Addresses
            _buildSection(
              context,
              title: 'Маршрут',
              children: [
                _buildAddressRow('Откуда', delivery.pickupAddress, Icons.location_on),
                SizedBox(height: 12),
                _buildAddressRow('Куда', delivery.deliveryAddress, Icons.flag),
              ],
            ),
            
            // Recipient
            _buildSection(
              context,
              title: 'Получатель',
              children: [
                _buildInfoRow('Имя', delivery.recipientName),
                _buildInfoRow('Телефон', delivery.recipientPhone),
              ],
            ),
            
            // Driver info (if assigned)
            if (delivery.assignedDriverId != null)
              _buildSection(
                context,
                title: 'Водитель',
                children: [
                  DriverInfoWidget(driverId: delivery.assignedDriverId!),
                ],
              ),
            
            // Timestamps
            _buildSection(
              context,
              title: 'Временная шкала',
              children: [
                if (delivery.requestedAt != null)
                  _buildTimestamp('Заказ создан', delivery.requestedAt!),
                if (delivery.acceptedAt != null)
                  _buildTimestamp('Принят водителем', delivery.acceptedAt!),
                if (delivery.pickedUpAt != null)
                  _buildTimestamp('Забран', delivery.pickedUpAt!),
                if (delivery.deliveredAt != null)
                  _buildTimestamp('Доставлен', delivery.deliveredAt!),
                if (delivery.cancelledAt != null)
                  _buildTimestamp('Отменен', delivery.cancelledAt!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 13. App Icon Integration

**Design Rationale:** Consistent branding across all touchpoints (launcher, splash, onboarding, notifications) creates a cohesive user experience and improves brand recognition. Using flutter_launcher_icons automates icon generation for all required sizes and formats. _Requirement 14_

**Icon Setup:** _Requirement 14_
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # Your logo (1024x1024 recommended)
  adaptive_icon_background: "#00BCD4"     # Cyan from logo
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  
  # iOS specific
  ios_app_icon_size: 1024
  
  # Android specific
  adaptive_icon_foreground_inset: 16
  
  # Generate command: flutter pub run flutter_launcher_icons
```

**Usage Locations:** _Requirement 14_
- App launcher icon (Android & iOS)
- Splash screen logo
- Onboarding welcome screen
- About/Settings screen
- Notification icon (Android - small monochrome version)
- Loading screens
- Empty state illustrations

**Splash Screen Configuration:**
```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/icon/app_icon.png
  android: true
  ios: true
  android_12:
    image: assets/icon/app_icon.png
    color: "#FFFFFF"
```

**Notification Icon (Android):**
```xml
<!-- android/app/src/main/res/drawable/ic_notification.xml -->
<!-- Monochrome version of logo for status bar -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
  <path
      android:fillColor="#FFFFFF"
      android:pathData="[Your logo path data]"/>
</vector>
```

## Data Models

### Updated User Model

```dart
class User {
  final String id;
  final String username;
  final String internalEmail;
  final String phoneNumber;
  final String? profileImageUrl;
  final UserType type;
  final DateTime createdAt;
  
  // Company-specific
  final String? companyName;
  final GeoPoint? headquartersLocation;
  final List<Branch> branches;
  
  // Driver-specific
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? carModel;
  final String? carNumber;
  final String? carColor;
  final bool? isActive;
  final double? rating;
  final GeoPoint? currentLocation;
}
```

### Branch Model

```dart
class Branch {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final bool isHeadquarters;
  final DateTime createdAt;
  
  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.isHeadquarters = false,
    required this.createdAt,
  });
  
  factory Branch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Branch(
      id: doc.id,
      name: data['name'],
      address: data['address'],
      location: data['location'],
      isHeadquarters: data['isHeadquarters'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'location': location,
      'isHeadquarters': isHeadquarters,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
```

### Enhanced Delivery Request Model

```dart
class DeliveryRequest {
  final String id;
  final String companyId;
  final String? branchId;
  final String companyName;
  final String companyPhone;
  final String recipientName;
  final String recipientPhone;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint deliveryLocation;
  final String deliveryAddress;
  final DateTime requestedAt;
  final int readyInMinutes;
  final DateTime? scheduledPickupTime;
  final DeliveryStatus status;
  final String? assignedDriverId;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  DeliveryRequest({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.companyName,
    required this.companyPhone,
    required this.recipientName,
    required this.recipientPhone,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.requestedAt,
    this.readyInMinutes = 0,
    this.scheduledPickupTime,
    required this.status,
    this.assignedDriverId,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });
}

enum DeliveryStatus {
  searching,
  driverAssigned,
  onTheWay,
  delivered,
  cancelled,
  noDriverFound,
}
```

## Error Handling

**Design Rationale:** All error messages must be in Russian to maintain consistency with the localized interface. Mapping Firebase error codes to user-friendly Russian messages improves user experience. _Requirement 1_

### Russian Error Messages

```dart
class ErrorMessages {
  static const Map<String, String> messages = {
    // Authentication errors
    'auth/user-not-found': 'Пользователь не найден',
    'auth/wrong-password': 'Неверный пароль',
    'auth/invalid-credential': 'Неверное имя пользователя или пароль',
    'auth/username-already-exists': 'Имя пользователя уже занято',
    'auth/weak-password': 'Пароль слишком слабый (минимум 8 символов)',
    'auth/invalid-email': 'Неверный формат email',
    'auth/email-already-in-use': 'Этот email уже используется',
    'auth/too-many-requests': 'Слишком много попыток. Попробуйте позже',
    
    // Delivery errors
    'delivery/no-drivers-available': 'Нет доступных водителей',
    'delivery/timeout': 'Время ожидания истекло',
    'delivery/already-assigned': 'Заказ уже принят другим водителем',
    'delivery/invalid-location': 'Неверное местоположение',
    
    // Branch errors
    'branch/cannot-delete-last': 'Нельзя удалить последний филиал',
    'branch/not-found': 'Филиал не найден',
    'branch/invalid-location': 'Неверное местоположение филиала',
    
    // Location errors
    'location/permission-denied': 'Доступ к местоположению запрещен',
    'location/service-disabled': 'Службы геолокации отключены',
    'location/timeout': 'Не удалось определить местоположение',
    
    // Network errors
    'network/no-connection': 'Нет подключения к интернету',
    'network/timeout': 'Превышено время ожидания',
    'network/server-error': 'Ошибка сервера. Попробуйте позже',
    
    // Validation errors
    'validation/required-field': 'Это поле обязательно',
    'validation/invalid-phone': 'Неверный формат телефона',
    'validation/invalid-username': 'Имя пользователя может содержать только буквы, цифры и подчеркивание',
    'validation/username-too-short': 'Имя пользователя должно быть не менее 3 символов',
    'validation/username-too-long': 'Имя пользователя должно быть не более 20 символов',
    'validation/password-too-short': 'Пароль должен быть не менее 8 символов',
    'validation/age-too-young': 'Минимальный возраст: 18 лет',
    
    // Storage errors
    'storage/upload-failed': 'Не удалось загрузить файл',
    'storage/file-too-large': 'Файл слишком большой',
    
    // Permission errors
    'permission/camera-denied': 'Доступ к камере запрещен',
    'permission/storage-denied': 'Доступ к хранилищу запрещен',
  };
  
  static String get(String code) {
    return messages[code] ?? 'Произошла ошибка. Попробуйте еще раз';
  }
  
  // Map Firebase error codes to our error codes
  static String fromFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      return get('auth/${error.code}');
    } else if (error is FirebaseException) {
      return get('${error.plugin}/${error.code}');
    } else {
      return get('unknown');
    }
  }
}
```

### Error Display Components

```dart
// Error dialog for critical errors
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('Ошибка'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

// Error snackbar for non-critical errors
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 4),
    ),
  );
}

// Inline error widget for forms
class InlineErrorWidget extends StatelessWidget {
  final String message;
  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Testing Strategy

### Unit Tests
- Username validation
- Branch CRUD operations
- Delivery status transitions
- ETA calculations
- Russian text formatting

### Widget Tests
- Onboarding flow
- Login/registration forms
- Branch selector
- Delivery request form
- Status display widgets

### Integration Tests
- Complete delivery flow
- Driver acceptance flow
- Real-time location updates
- Notification handling

## Performance Considerations

1. **Localization**: Load Russian strings at app start
2. **Images**: Compress logo for different sizes
3. **Maps**: Cache map tiles
4. **Real-time Updates**: Throttle location updates to 10s intervals
5. **Search**: Index drivers by location for fast radius queries
6. **Notifications**: Batch notifications to nearby drivers

## Security Considerations

1. **Username Uniqueness**: Check before registration
2. **Internal Email**: Never expose to users
3. **Branch Access**: Verify company ownership
4. **Driver Status**: Only driver can change own status
5. **Delivery Assignment**: Prevent double-assignment
6. **Location Privacy**: Only share during active delivery

## Migration Strategy

**Design Rationale:** A phased migration approach minimizes risk and allows for testing at each stage. Starting with localization ensures all subsequent features are built with Russian language support from the start.

### Phase 1: Localization Foundation
- Set up flutter_localizations and intl packages
- Create app_ru.arb with all Russian translations
- Create app_en.arb as fallback
- Update MaterialApp to support Russian locale
- Test date/time formatting with Russian locale
- **Validates:** Requirements 1

### Phase 2: Onboarding Experience
- Create onboarding screen components
- Implement SharedPreferences for first-launch detection
- Design and integrate app icon across all screens
- Create onboarding illustrations
- Test skip and complete flows
- **Validates:** Requirements 2, 14

### Phase 3: Authentication Redesign
- Implement username validation logic
- Create username-based registration forms (company & driver)
- Update login screen for username input
- Implement internal email conversion ({username}@taxidispatch.internal)
- Add username uniqueness check
- Remove driver license photo requirement
- Test authentication flows
- **Validates:** Requirements 3, 7

### Phase 4: Branch Management System
- Create branches subcollection structure
- Implement branch CRUD operations
- Create branch management UI in profile
- Implement branch selector for delivery requests
- Migrate existing headquarters to first branch
- Test branch operations and constraints
- **Validates:** Requirement 4

### Phase 5: Simplified Navigation
- Update company bottom navigation (4 items: Home, History, Transactions, Profile)
- Update driver bottom navigation (3 items: Home, History, Profile)
- Remove unnecessary navigation items
- Update routing configuration
- Test navigation flows
- **Validates:** Requirement 5

### Phase 6: Enhanced Company Dashboard
- Implement first-time user banner
- Create prominent "Найти такси" button
- Add recent deliveries widget
- Integrate branch selection into delivery flow
- Implement ready time selector (0, 15, 30, 45, 60 minutes)
- Test delivery request flow
- **Validates:** Requirements 6, 9

### Phase 7: Driver Status Management
- Add isActive field to driver profiles
- Implement status toggle with confirmation dialog
- Update driver search to filter by isActive
- Add status indicator to driver dashboard
- Test status change flows
- **Validates:** Requirement 8

### Phase 8: Enhanced Notification System
- Update FCM notification payload with all required fields
- Implement order details card for drivers
- Add scheduled pickup time display
- Update Cloud Functions for 5-6km radius search
- Test notification delivery and display
- **Validates:** Requirements 9, 10

### Phase 9: Delivery Status Tracking
- Implement status progression logic
- Create searching animation with progressive messages
- Add timeout handler for no driver found
- Implement cancel search functionality
- Create status-specific UI components
- Test all status transitions
- **Validates:** Requirements 11, 13

### Phase 10: Real-time Driver Tracking
- Implement driver location update service (10-second intervals)
- Create driver tracking card with map
- Add ETA calculation
- Display driver details (name, car, rating)
- Add route polyline on map
- Test real-time updates
- **Validates:** Requirement 12

### Phase 11: Delivery History
- Create delivery history screen
- Implement history provider with sorting
- Create delivery history cards with status badges
- Implement delivery details screen
- Ensure all deliveries are saved regardless of status
- Test history display and filtering
- **Validates:** Requirement 15

### Phase 12: Testing and Polish
- Conduct end-to-end testing of all flows
- Test with Russian locale exclusively
- Verify all error messages are in Russian
- Performance testing (location updates, notifications)
- UI/UX polish and refinements
- **Validates:** All requirements

## Implementation Notes

### Key Dependencies
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  flutter_riverpod: ^2.4.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_messaging: ^14.7.0
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  shared_preferences: ^2.2.0
  
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.0
```

### Firestore Security Rules Updates
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      
      // Branches subcollection
      match /branches/{branchId} {
        allow read: if request.auth != null;
        allow write: if request.auth.uid == userId;
      }
    }
    
    // Delivery requests
    match /deliveryRequests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.companyId == request.auth.uid ||
        resource.data.assignedDriverId == request.auth.uid
      );
    }
  }
}
```

### Performance Optimizations
1. **Location Updates:** Throttle to 10-second intervals to balance accuracy with battery/data usage
2. **Driver Search:** Use geohashing (GeoFlutterFire) for efficient radius queries
3. **Image Loading:** Compress profile images to max 500KB
4. **Map Rendering:** Cache map tiles for offline viewing
5. **Notification Batching:** Send to max 500 drivers per batch (FCM limit)
6. **History Pagination:** Load 20 deliveries at a time with infinite scroll

### Accessibility Considerations
- All interactive elements have minimum 48x48 touch targets
- Color contrast ratios meet WCAG AA standards
- Screen reader support for all text elements
- Semantic labels for icons and buttons
- Focus indicators for keyboard navigation

## Summary

This design document provides a comprehensive technical architecture for redesigning the taxi dispatch application with Russian localization, username-based authentication, branch management, streamlined navigation, onboarding experience, and enhanced delivery workflow. The design addresses all 15 requirements specified in the requirements document, with clear rationales for design decisions and detailed implementation guidance.

**Key Design Decisions:**
1. **Russian-First Approach:** All UI, errors, and notifications in Russian using flutter_localizations
2. **Username Authentication:** Internal email format hidden from users for simpler UX
3. **Branch Subcollections:** Natural data isolation and efficient querying
4. **Status Confirmation:** Prevents accidental driver status changes
5. **Progressive Search Feedback:** Manages user expectations during driver search
6. **10-Second Location Updates:** Balances accuracy with resource usage
7. **Comprehensive History:** All deliveries saved regardless of outcome

The phased migration strategy ensures systematic implementation with validation at each stage.
