# Implementation Plan

## Overview
This implementation plan breaks down the app redesign into manageable tasks, focusing on Russian localization, username authentication, branch management, simplified navigation, onboarding, and enhanced delivery workflow.

- [x] 1. Setup Russian Localization Infrastructure








- [x] 1.1 Add flutter_localizations and intl packages to pubspec.yaml

- [x] 1.2 Create l10n directory with app_ru.arb and app_en.arb files


- [x] 1.3 Configure localization in main.dart with Russian as default locale


- [x] 1.4 Create LocalizationProvider for runtime language switching


  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Translate All UI Text to Russian





- [x] 2.1 Create comprehensive Russian translation file (app_ru.arb) with all UI strings


- [x] 2.2 Update authentication screens with Russian text


- [x] 2.3 Update navigation labels to Russian


- [x] 2.4 Update all error messages to Russian


- [x] 2.5 Update notification text to Russian


  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 3. Implement Onboarding Flow



- [x] 3.1 Create OnboardingScreen with PageView for 4 screens


- [x] 3.2 Design Welcome screen with app logo and introduction




- [x] 3.3 Design "For Companies" screen with features

- [x] 3.4 Design "For Drivers" screen with features


- [x] 3.5 Design "Get Started" screen with role selection buttons

- [x] 3.6 Create OnboardingProvider to track completion status





- [x] 3.7 Store onboarding completion in SharedPreferences

- [x] 3.8 Update app router to show onboarding on first launch

  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Redesign Authentication System





- [x] 4.1 Update User entity to include username field


- [x] 4.2 Update UserDTO to handle username and internal email


- [x] 4.3 Modify registration to accept username instead of email


- [x] 4.4 Implement username uniqueness validation


- [x] 4.5 Generate internal email format: {username}@taxidispatch.internal

- [x] 4.6 Update login screen to use username field


- [x] 4.7 Update Firebase Auth calls to use internal email

- [x] 4.8 Update company registration to include company name, phone, profile image


- [x] 4.9 Add headquarters location picker to company registration


- [x] 4.10 Update driver registration with firstName, lastName, age, car details


  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 7.1, 7.2, 7.3, 7.4, 7.5_


- [x] 5. Implement Branch Management System





- [x] 5.1 Create Branch entity and DTO models


- [x] 5.2 Create Firestore datasource for branch CRUD operations


- [x] 5.3 Create branch repository implementation


- [x] 5.4 Create BranchProvider for state management


- [x] 5.5 Build BranchListWidget to display all branches


- [x] 5.6 Build BranchFormDialog for add/edit operations


- [x] 5.7 Build BranchMapPicker for location selection


- [x] 5.8 Add branch management section to company profile screen


- [x] 5.9 Implement branch deletion with confirmation dialog

- [x] 5.10 Create BranchSelectorBottomSheet for delivery requests


  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 6. Simplify Navigation Bar





- [x] 6.1 Update CompanyBottomNav to 4 items: Home, History, Transactions, Profile


- [x] 6.2 Update DriverBottomNav to 3 items: Home, History, Profile


- [x] 6.3 Remove Settings tab from bottom navigation

- [x] 6.4 Update navigation icons with Russian labels

- [x] 6.5 Update router to handle simplified navigation structure


  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 7. Enhance Company Dashboard





- [x] 7.1 Create FirstTimeUserBanner widget with guidance


- [x] 7.2 Add banner dismissal logic after first delivery


- [x] 7.3 Create prominent "Найти такси" (Search for Taxi) button


- [x] 7.4 Build RecentDeliveriesWidget for dashboard summary


- [x] 7.5 Update CompanyDashboardScreen layout with new components


  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Implement Enhanced Delivery Request Flow





- [x] 8.1 Create ReadyTimeSelector widget for scheduled pickups


- [x] 8.2 Update DeliveryRequest model with readyInMinutes and scheduledPickupTime


- [x] 8.3 Build delivery request form with recipient details


- [x] 8.4 Add branch selection step if company has multiple branches


- [x] 8.5 Implement map picker for delivery address


- [x] 8.6 Add form validation for all required fields


- [x] 8.7 Update delivery creation to include scheduled time


  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 9. Implement Driver Status Management





- [x] 9.1 Add isActive field to Driver entity and DTO

- [x] 9.2 Create DriverStatusToggle widget in profile screen


- [x] 9.3 Build status change confirmation dialog


- [x] 9.4 Update Firestore when driver changes status


- [x] 9.5 Filter active drivers in delivery search queries


  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 10. Enhance Driver Notification System




- [x] 10.1 Update FCM notification payload with delivery details
- [x] 10.2 Create OrderDetailsCard widget for notification tap


- [x] 10.3 Display company info, addresses, and recipient details

- [x] 10.4 Add Accept and Skip buttons to order card

- [x] 10.5 Implement driver acceptance logic


- [x] 10.6 Remove order from other drivers when accepted


- [x] 10.7 Send notification to company when driver accepts

  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 11. Implement Delivery Status Tracking





- [x] 11.1 Update DeliveryStatus enum with all states


- [x] 11.2 Create DeliveryStatusWidget with status-specific UI


- [x] 11.3 Build searching animation with loading indicator


- [x] 11.4 Add timeout logic for "no driver found" status


- [x] 11.5 Create DriverTrackingCard for assigned deliveries


- [x] 11.6 Build SuccessCard for completed deliveries


- [x] 11.7 Build ErrorCard for failed deliveries


- [x] 11.8 Update delivery status in Firestore on state changes


  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 12. Implement Real-time Driver Tracking





- [x] 12.1 Create driverLocationStreamProvider for real-time updates


- [x] 12.2 Build DriverTrackingCard with driver info and map


- [x] 12.3 Display driver name, car model, color, number, and rating

- [x] 12.4 Show driver location marker on map

- [x] 12.5 Calculate and display ETA to pickup/delivery

- [x] 12.6 Update driver location every 10 seconds


- [x] 12.7 Draw route polyline from driver to destination

  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 13. Implement Waiting Animation





- [x] 13.1 Create SearchingAnimation widget with loading indicator


- [x] 13.2 Display "Ищем водителя..." text during search

- [x] 13.3 Show "Все еще ищем" after 30 seconds

- [x] 13.4 Add cancel button after 60 seconds

- [x] 13.5 Implement search cancellation logic


  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [x] 14. Integrate App Icon and Branding





- [x] 14.1 Add provided logo to assets/icon/ directory


- [x] 14.2 Configure flutter_launcher_icons in pubspec.yaml


- [x] 14.3 Generate app launcher icons for Android and iOS


- [x] 14.4 Update splash screen with logo


- [x] 14.5 Add logo to onboarding screens


- [x] 14.6 Use logo in notification icons


- [x] 14.7 Display logo in about section


  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [x] 15. Enhance Delivery History














- [x] 15.1 Update history screen to show all delivery statuses





- [x] 15.2 Display status badges (Delivered, Cancelled, No Driver Found)





- [x] 15.3 Show date, time, and addresses in history list





- [x] 15.4 Implement history item detail view




- [x] 15.5 Sort history by most recent first





- [x] 15.6 Add filtering by status




  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 16. Update Driver Search Radius





- [x] 16.1 Change search radius from current value to 5-6 km


- [x] 16.2 Update Firestore geoqueries to use new radius


- [x] 16.3 Display search radius to users


- [x] 16.4 Optimize query performance for radius search


  - _Requirements: 9.5, 10.1_

- [x] 17. Testing and Quality Assurance





- [x] 17.1 Test onboarding flow on first launch



- [x] 17.2 Test username registration and login


- [x] 17.3 Test branch management (add, edit, delete)


- [x] 17.4 Test delivery request with branch selection


- [x] 17.5 Test driver status toggle with confirmation

- [x] 17.6 Test scheduled delivery times


- [x] 17.7 Test driver notifications and acceptance





- [x] 17.8 Test real-time tracking and ETA

- [x] 17.9 Test all delivery status transitions



- [x] 17.10 Verify all text is in Russian

- [x] 17.11 Test app icon on device





- [x] 17.12 Test delivery history with various statuses





  - _Requirements: All_

- [x] 18. Documentation and Deployment






- [x] 18.1 Update README with new features


- [x] 18.2 Document username authentication system


- [x] 18.3 Document branch management workflow


- [x] 18.4 Create user guide for onboarding


- [x] 18.5 Document delivery request flow


- [x] 18.6 Update Firebase security rules for branches



- [x] 18.7 Prepare release notes in Russian


- [x] 18.8 Build and test release APK

  - _Requirements: All_



## Implementation Status Summary

All 18 core tasks for the app redesign with Russian localization have been completed. The implementation includes:

### Completed Features
1. **Russian Localization** - Full app translation with proper date/time formatting
2. **Onboarding Flow** - 4-screen introduction for first-time users
3. **Username Authentication** - Simplified login with username/password instead of email
4. **Branch Management** - Companies can manage multiple office locations
5. **Simplified Navigation** - Streamlined bottom nav (4 items for companies, 3 for drivers)
6. **Enhanced Dashboard** - First-time user guidance and prominent "Search for Taxi" button
7. **Driver Status Management** - Active/inactive toggle with confirmation
8. **Scheduled Deliveries** - Ready time selector (0, 15, 30, 45, 60 minutes)
9. **Enhanced Notifications** - Rich order details for drivers
10. **Status Tracking** - Complete delivery lifecycle with searching animation
11. **Real-time Tracking** - Driver location updates every 10 seconds with ETA
12. **Delivery History** - Comprehensive history with all statuses
13. **5-6km Search Radius** - Optimized driver search distance
14. **App Branding** - Logo integration across all touchpoints
15. **Testing & QA** - Comprehensive testing of all flows
16. **Documentation** - Complete user guides and technical documentation

### Architecture Highlights
- Clean architecture with domain/data/presentation layers
- Riverpod for state management
- Firebase backend (Auth, Firestore, FCM, Storage)
- Google Maps integration for location services
- Proper error handling with Russian error messages
- Responsive UI with Material Design 3

### Next Steps
The app is ready for production deployment. All requirements from the design document have been implemented and tested. Future enhancements can be added as new specs based on user feedback.


## New Feature Tasks

- [x] 19. Implement Driver Order Cancellation Flow




- [x] 19.1 Add "Cancel Order" button to driver active ride screen (visible only when status is "driverAssigned" or "onTheWay")




- [x] 19.2 Create cancellation confirmation dialog with reason input field




- [x] 19.3 Add cancellation reasons dropdown (e.g., "Не могу найти адрес", "Проблемы с автомобилем", "Личные обстоятельства", "Другое")


- [x] 19.4 Implement cancellation logic to update ride status to "cancelled" with reason

- [x] 19.5 Remove "Cancel Order" button after driver accepts order (when status changes from "driverAssigned")


- [x] 19.6 Notify company when driver cancels with cancellation reason


- [x] 19.7 Show cancellation notification to company with option to request new driver




- [x] 19.8 Update company tracking screen to show "Заказ отменен водителем" message




- [x] 19.9 Add "Найти нового водителя" button on cancellation screen for company


- [x] 19.10 Reset delivery request flow to allow company to request again from start

  - _Requirements: Driver cancellation, company notification, retry flow_

- [x] 20. Implement Order Completion Flow






- [x] 20.1 Add "Complete Order" button to driver active ride screen (visible when status is "onTheWay")



- [x] 20.2 Create completion confirmation dialog



- [x] 20.3 Update ride status to "completed" when driver confirms completion



- [x] 20.4 Show success message to driver: "Заказ успешно завершен!"


- [x] 20.5 Notify company that order is completed



- [x] 20.6 Show completion notification to company: "Заказ доставлен успешно!"


- [x] 20.7 Update ride history with completion timestamp


- [x] 20.8 Trigger balance deduction and commission calculation on completion


  - _Requirements: Order completion, notifications, balance integration_

- [x] 21. Implement Company Balance System






- [x] 21.1 Add balance and reservedBalance fields to Company entity



- [x] 21.2 Update CompanyDto to include balance fields



- [x] 21.3 Create BalanceService for balance operations (check, reserve, deduct, add)



- [x] 21.4 Display current balance prominently in company dashboard header



- [x] 21.5 Display current balance in company profile screen



- [x] 21.6 Create low balance warning banner (shows when balance < 50,000 сум)



- [x] 21.7 Create insufficient balance error dialog with call center contact info



- [x] 21.8 Add call center phone number display: "+998 XX XXX XX XX"



- [x] 21.9 Implement balance check before allowing delivery request creation



- [x] 21.10 Show "Недостаточно средств" error if balance < 25,000 сум



  - _Requirements: Balance display, validation, warnings_

- [x] 22. Implement Balance Deduction and Commission System








- [x] 22.1 Create CommissionService with fixed rates (25,000 сум per delivery, 20% commission = 5,000 сум)



- [x] 22.2 Reserve 25,000 сум from company balance when delivery request is created



- [x] 22.3 Update company balance: balance -= 25,000, reservedBalance += 25,000


- [x] 22.4 Deduct from reservedBalance on delivery completion: reservedBalance -= 25,000



- [x] 22.5 Calculate commission: 5,000 сум (20% of 25,000)


- [x] 22.6 Add driver earnings: 20,000 сум (80% of 25,000)


- [x] 22.7 Create CommissionRecord model with fields: rideId, companyId, driverId, amount, commission, driverEarnings, timestamp



- [x] 22.8 Store commission records in Firestore "commissionRecords" collection


- [x] 22.9 Implement atomic Firestore transaction for balance deduction


- [x] 22.10 Handle balance deduction failures with retry logic and error notifications









- [x] 22.11 Update company transaction history with deduction record




- [x] 22.12 Update driver transaction history with earnings record





- [x] 22.13 Refund reserved balance if order is cancelled (reservedBalance -= 25,000, balance += 25,000)




  - _Requirements: Commission calculation, balance transactions, atomic operations_

- [x] 23. Implement Admin Balance Top-Up Interface






- [x] 23.1 Create admin role and authentication system



- [x] 23.2 Create admin dashboard screen accessible only to admin users



- [x] 23.3 Build company search/selection interface for admin



- [x] 23.4 Create balance top-up form with company ID and amount input


- [x] 23.5 Add amount validation (minimum 10,000 сум, maximum 10,000,000 сум)


- [x] 23.6 Display current balance before top-up


- [x] 23.7 Implement addBalance function in BalanceService


- [x] 23.8 Create top-up confirmation dialog showing old and new balance


- [x] 23.9 Record top-up transaction in company transaction history


- [x] 23.10 Create TopUpRecord model with fields: companyId, adminId, amount, timestamp, notes



- [x] 23.11 Store top-up records in Firestore "topUpRecords" collection


- [x] 23.12 Send notification to company when balance is topped up


- [x] 23.13 Add admin activity log for all balance operations


- [x] 23.14 Implement admin authentication guard for balance top-up routes



  - _Requirements: Admin interface, balance top-up, transaction logging_

- [x] 24. Update UI for Balance Integration






- [x] 24.1 Add balance display widget to company dashboard (large, prominent)



- [x] 24.2 Show balance with currency: "Баланс: 150,000 сум"


- [x] 24.3 Add balance indicator color coding (green > 100k, yellow 50k-100k, red < 50k)


- [x] 24.4 Create balance history screen showing all transactions (top-ups, deductions, refunds)



- [x] 24.5 Add "История баланса" navigation item to company profile



- [x] 24.6 Update ride request screen to show cost: "Стоимость: 25,000 сум"



- [x] 24.7 Show remaining balance after deduction preview


- [x] 24.8 Add balance refresh button to manually update balance display



- [x] 24.9 Implement real-time balance updates using Firestore listeners



- [x] 24.10 Create balance transaction card widget for history display


  - _Requirements: Balance UI, transaction history, real-time updates_

- [x] 25. Testing and Validation






- [x] 25.1 Test driver cancellation flow with all cancellation reasons



- [x] 25.2 Test order completion flow and success notifications


- [x] 25.3 Test balance reservation on delivery request

- [x] 25.4 Test balance deduction on order completion


- [x] 25.5 Test commission calculation (verify 5,000 сум commission, 20,000 сум driver earnings)


- [x] 25.6 Test insufficient balance error handling


- [x] 25.7 Test balance refund on order cancellation


- [x] 25.8 Test admin balance top-up functionality


- [x] 25.9 Test concurrent balance operations (race conditions)


- [x] 25.10 Test balance display updates in real-time


- [x] 25.11 Verify all balance transactions are recorded correctly


- [x] 25.12 Test edge cases (negative balance, very large amounts, network failures)


  - _Requirements: All new features_
