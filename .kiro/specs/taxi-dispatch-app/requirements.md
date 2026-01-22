# Requirements Document

## Introduction

The Taxi Dispatch App is a mobile application built with Flutter that connects taxi drivers with company owners who need transportation services. The system enables real-time ride requests, GPS tracking, driver management, and automated notifications to facilitate efficient taxi dispatch operations.

## Glossary

- **Mobile App**: The Flutter-based mobile application
- **Driver User**: A registered taxi driver who accepts and fulfills ride requests
- **Company User**: A registered company owner who requests taxi services
- **Ride Request**: A transportation service request created by a Company User
- **Availability Status**: The current state of a Driver User (Available, Busy, or Offline)
- **Proximity Radius**: A 5-kilometer radius used to find available drivers
- **Authentication System**: The system component handling user login and registration
- **Real-Time Tracking System**: The system component providing live GPS location updates
- **Notification System**: The system component managing push notifications
- **Trip Status**: The current state of a ride (Pending, Accepted, En Route, Arrived, Completed)

## Requirements

### Requirement 1: User Authentication

**User Story:** As a new user, I want to register with my role-specific information, so that I can access the appropriate features for my user type

#### Acceptance Criteria

1. WHEN a user opens the Mobile App for the first time, THE Authentication System SHALL display options for Login and Registration
2. WHEN a user selects Registration, THE Authentication System SHALL prompt the user to select between Driver User and Company User roles
3. WHERE the user selects Driver User, THE Authentication System SHALL collect full name, phone number, email address, password, car make and model, license plate number, car color, year of manufacture, profile photo, driver's license number, and driver's license photo
4. WHERE the user selects Company User, THE Authentication System SHALL collect full name, company name, phone number, email address, password, company registration number, business address, and profile photo
5. WHEN all required registration fields are completed and terms are accepted, THE Authentication System SHALL create the user account and grant access to the Mobile App

### Requirement 2: Driver Availability Management

**User Story:** As a Driver User, I want to control my availability status, so that I only receive ride requests when I am ready to work

#### Acceptance Criteria

1. WHEN a Driver User accesses their dashboard, THE Mobile App SHALL display their current Availability Status
2. WHEN a Driver User toggles their Availability Status, THE Mobile App SHALL update the status to Available, Busy, or Offline within 2 seconds
3. WHILE a Driver User has Availability Status set to Available, THE Mobile App SHALL make the driver visible to Company Users within the Proximity Radius
4. WHILE a Driver User has Availability Status set to Offline or Busy, THE Mobile App SHALL exclude the driver from Ride Request matching

### Requirement 3: Ride Request Creation and Matching

**User Story:** As a Company User, I want to request a taxi and see available drivers nearby, so that I can quickly arrange transportation

#### Acceptance Criteria

1. WHEN a Company User creates a Ride Request, THE Mobile App SHALL identify all Driver Users with Availability Status set to Available within the Proximity Radius
2. WHEN eligible Driver Users are identified, THE Notification System SHALL send push notifications to all eligible Driver Users within 5 seconds
3. WHEN a Driver User accepts the Ride Request, THE Mobile App SHALL assign the ride to that Driver User and update the Trip Status to Accepted
4. WHEN a Ride Request is accepted by one Driver User, THE Notification System SHALL cancel pending notifications to all other Driver Users within 3 seconds
5. WHEN a Company User creates a Ride Request, THE Mobile App SHALL display driver details including name, photo, car information, current location, and ratings for all available drivers

### Requirement 4: Real-Time Location Tracking

**User Story:** As a Company User, I want to track my assigned driver's location in real-time, so that I know when they will arrive

#### Acceptance Criteria

1. WHEN a Ride Request is accepted, THE Real-Time Tracking System SHALL display the Driver User's live GPS location on a map view
2. WHILE a ride is in progress, THE Real-Time Tracking System SHALL update the Driver User's location on the map every 10 to 30 seconds
3. WHEN the Driver User's location changes, THE Real-Time Tracking System SHALL recalculate the estimated time of arrival based on current traffic and distance
4. WHILE tracking is active, THE Mobile App SHALL display the driver's current location, pickup point, and route to destination on the map view

### Requirement 5: Trip Status Updates

**User Story:** As a Driver User, I want to notify the company owner of my arrival and trip completion, so that they are informed of the ride progress

#### Acceptance Criteria

1. WHEN a Driver User arrives at the pickup location, THE Mobile App SHALL display an "I Am Here" button
2. WHEN a Driver User presses the "I Am Here" button, THE Notification System SHALL send a notification to the Company User within 3 seconds
3. WHEN a Driver User completes the trip, THE Mobile App SHALL display a "Trip Complete" button
4. WHEN a Driver User presses the "Trip Complete" button, THE Mobile App SHALL update the Trip Status to Completed and mark the ride as finished
5. WHEN Trip Status changes occur, THE Mobile App SHALL automatically update the Driver User's Availability Status from En Route to Arrived to Available

### Requirement 6: Driver Discovery and Selection

**User Story:** As a Company User, I want to view all available drivers within 5 km and see their details, so that I can make an informed decision about which driver to request

#### Acceptance Criteria

1. WHEN a Company User accesses the driver request feature, THE Mobile App SHALL display all Driver Users with Availability Status set to Available within 5 kilometers
2. WHEN displaying available drivers, THE Mobile App SHALL show driver name, profile photo, car model, car color, license plate number, current GPS location, and average rating
3. WHEN a Company User selects a driver, THE Mobile App SHALL display the driver's location on an interactive map
4. WHEN a Company User sends a Ride Request to nearby drivers, THE Notification System SHALL deliver the request to all eligible Driver Users within the Proximity Radius

### Requirement 7: User Profile Management

**User Story:** As a registered user, I want to update my profile and preferences, so that my information remains current and accurate

#### Acceptance Criteria

1. WHERE the user is a Driver User, THE Mobile App SHALL allow updates to profile information, vehicle information, availability radius, notification preferences, payment details, language preferences, and privacy settings
2. WHERE the user is a Company User, THE Mobile App SHALL allow updates to company information, payment methods, default pickup locations, notification preferences, language preferences, privacy settings, and billing information
3. WHEN a user updates their profile information, THE Mobile App SHALL save the changes and reflect them across the system within 5 seconds

### Requirement 8: Security and Verification

**User Story:** As a system administrator, I want users to verify their identity and credentials, so that the platform maintains security and trust

#### Acceptance Criteria

1. WHEN a user registers with a phone number, THE Authentication System SHALL send a one-time password for verification
2. WHEN a user registers with an email address, THE Authentication System SHALL send a verification link to confirm the email
3. WHERE the user is a Driver User, THE Mobile App SHALL require upload and verification of driver's license photo and driver's license number
4. WHEN verification documents are uploaded, THE Authentication System SHALL store them securely in cloud storage with encrypted access

### Requirement 9: Communication Features

**User Story:** As a Driver User or Company User, I want to communicate with the other party during a ride, so that I can coordinate pickup details or address issues

#### Acceptance Criteria

1. WHEN a Ride Request is accepted, THE Mobile App SHALL enable in-app chat between the Driver User and Company User
2. WHEN either user sends a message, THE Notification System SHALL deliver the message to the recipient within 2 seconds
3. THE Mobile App SHALL provide an emergency contact button accessible during active rides
4. THE Mobile App SHALL provide access to a support and help center for both user types

### Requirement 10: Ratings and Reviews

**User Story:** As a user, I want to rate my experience after each ride, so that the platform maintains quality standards

#### Acceptance Criteria

1. WHEN a trip is marked as Completed, THE Mobile App SHALL prompt both the Driver User and Company User to provide a rating
2. WHEN a user submits a rating, THE Mobile App SHALL accept ratings from 1 to 5 and optional text feedback
3. WHEN ratings are submitted, THE Mobile App SHALL calculate and update the average rating for the rated user
4. WHEN viewing driver or company profiles, THE Mobile App SHALL display the average rating based on all historical ratings

### Requirement 11: Payment and Billing

**User Story:** As a Company User, I want to pay for rides through the app, so that transactions are convenient and trackable

#### Acceptance Criteria

1. WHEN a trip is completed, THE Mobile App SHALL calculate the fare automatically based on distance and time
2. THE Mobile App SHALL support multiple payment methods including credit card, debit card, and digital wallets
3. WHEN payment is processed, THE Mobile App SHALL generate a digital receipt and store it in transaction history
4. WHEN a Driver User completes rides, THE Mobile App SHALL update their earnings summary with payout details

### Requirement 12: Ride History and Management

**User Story:** As a user, I want to view my past rides, so that I can track my usage and review previous trips

#### Acceptance Criteria

1. WHERE the user is a Driver User, THE Mobile App SHALL display a history of all completed rides with date, pickup location, destination, earnings, and rating
2. WHERE the user is a Company User, THE Mobile App SHALL display a history of all requested rides with date, driver name, pickup location, destination, fare, and rating
3. WHEN a user accesses ride history, THE Mobile App SHALL load and display records within 3 seconds
4. THE Mobile App SHALL allow users to filter ride history by date range and status

### Requirement 13: Push Notifications

**User Story:** As a user, I want to receive timely notifications about ride events, so that I stay informed of important updates

#### Acceptance Criteria

1. WHEN a new Ride Request is created, THE Notification System SHALL send push notifications to all eligible Driver Users
2. WHEN a Driver User accepts a Ride Request, THE Notification System SHALL send a notification to the requesting Company User
3. WHEN a Driver User presses "I Am Here", THE Notification System SHALL send an arrival notification to the Company User
4. WHEN a trip is completed, THE Notification System SHALL send a completion notification to both users
5. WHEN payment is confirmed, THE Notification System SHALL send a payment confirmation notification to both users
