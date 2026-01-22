# Requirements Document - App Redesign with Russian Localization

## Introduction

This specification outlines a comprehensive redesign of the taxi dispatch application with Russian localization, improved authentication flow, enhanced company branch management, streamlined navigation, onboarding experience, and refined delivery workflow.

## Glossary

- **System**: The taxi dispatch mobile application
- **Company User**: Business entity requesting delivery/taxi services
- **Driver**: Individual providing taxi/delivery services
- **Branch**: Physical location of a company (headquarters or subsidiary)
- **Delivery Request**: Order for taxi service to transport goods/documents
- **Active Status**: Driver availability state for accepting orders
- **Onboarding**: First-time user introduction flow
- **Localization**: Translation and adaptation to Russian language

## Requirements

### Requirement 1: Russian Localization

**User Story:** As a user, I want the entire application in Russian language, so that I can understand and use it naturally.

#### Acceptance Criteria

1. WHEN the System launches, THE System SHALL display all UI text in Russian language
2. WHEN a user navigates through screens, THE System SHALL display all labels, buttons, and messages in Russian
3. WHEN the System displays error messages, THE System SHALL present them in Russian language
4. WHEN the System shows notifications, THE System SHALL format them in Russian language
5. WHEN the System displays dates and times, THE System SHALL format them according to Russian locale standards

### Requirement 2: Onboarding Experience

**User Story:** As a first-time user, I want to see an introduction to the app, so that I understand its purpose and features.

#### Acceptance Criteria

1. WHEN a user opens the System for the first time, THE System SHALL display an onboarding flow
2. WHEN displaying onboarding, THE System SHALL show the app's purpose and target audience
3. WHEN displaying onboarding, THE System SHALL explain key features for companies and drivers
4. WHEN a user completes onboarding, THE System SHALL mark the user as onboarded and not show it again
5. WHEN a user skips onboarding, THE System SHALL proceed to role selection screen

### Requirement 3: Username/Password Authentication

**User Story:** As a company user, I want to log in with username and password instead of email, so that I have a simpler login experience.

#### Acceptance Criteria

1. WHEN a company user registers, THE System SHALL require username, password, company name, phone number, and profile image
2. WHEN a company user registers, THE System SHALL require company headquarters location selected from map
3. WHEN a company user logs in, THE System SHALL accept username and password credentials
4. WHEN authentication succeeds, THE System SHALL grant access to company dashboard
5. WHEN authentication fails, THE System SHALL display error message in Russian

### Requirement 4: Company Branch Management

**User Story:** As a company user, I want to manage multiple branch locations, so that I can request deliveries from different offices.

#### Acceptance Criteria

1. WHEN a company user accesses profile, THE System SHALL display list of all company branches
2. WHEN a company user adds a branch, THE System SHALL require branch name, address, and location from map
3. WHEN a company user removes a branch, THE System SHALL display confirmation dialog in Russian
4. WHEN requesting delivery, THE System SHALL prompt user to select which branch needs the service
5. WHERE a company has multiple branches, THE System SHALL allow selection before showing delivery form

### Requirement 5: Simplified Navigation Bar

**User Story:** As a user, I want a streamlined navigation bar, so that I can access main features quickly.

#### Acceptance Criteria

1. WHEN a company user views the app, THE System SHALL display navigation bar with: Home, History, Transactions, Profile
2. WHEN a driver views the app, THE System SHALL display navigation bar with: Home, History, Profile
3. WHEN a user taps navigation items, THE System SHALL navigate to corresponding screen
4. THE System SHALL display active tab indicator on navigation bar
5. THE System SHALL use consistent icons across navigation bar

### Requirement 6: Enhanced Company Dashboard

**User Story:** As a company user, I want an informative home screen, so that I can easily request deliveries and see guidance.

#### Acceptance Criteria

1. WHEN a first-time company user views dashboard, THE System SHALL display banner explaining how to order first delivery
2. WHEN an experienced company user views dashboard, THE System SHALL display prominent "Search for Taxi" button
3. WHEN a user taps search button, THE System SHALL display delivery request form
4. WHEN displaying form, THE System SHALL request recipient name, phone number, delivery address, and estimated arrival time
5. WHERE company has branches, WHEN displaying form, THE System SHALL first ask which branch is requesting delivery

### Requirement 7: Driver Registration Enhancement

**User Story:** As a driver, I want to register with essential information, so that I can start accepting orders.

#### Acceptance Criteria

1. WHEN a driver registers, THE System SHALL require first name, last name, age, car model, car number, and car color
2. WHEN a driver registers, THE System SHALL NOT require driver license photo
3. WHEN registration completes, THE System SHALL create driver profile with provided information
4. WHEN a driver logs in, THE System SHALL accept username and password credentials
5. THE System SHALL validate all required fields before allowing registration

### Requirement 8: Driver Active Status Management

**User Story:** As a driver, I want to control my availability status, so that I only receive orders when ready.

#### Acceptance Criteria

1. WHEN a driver accesses profile, THE System SHALL display Active/Inactive status toggle
2. WHEN a driver changes status, THE System SHALL display confirmation dialog asking "Do you really want to change status?"
3. WHEN a driver confirms status change to Active, THE System SHALL make driver visible to nearby delivery requests
4. WHEN a driver confirms status change to Inactive, THE System SHALL stop sending delivery notifications
5. WHEN a driver is Inactive, THE System SHALL NOT include driver in search radius for companies

### Requirement 9: Delivery Request with Scheduled Time

**User Story:** As a company user, I want to specify when delivery should arrive, so that I can coordinate with my schedule.

#### Acceptance Criteria

1. WHEN creating delivery request, THE System SHALL allow company to specify "ready in X minutes" option
2. WHEN company selects delayed pickup, THE System SHALL display time options (15, 30, 45, 60 minutes)
3. WHEN company confirms delayed request, THE System SHALL notify drivers with scheduled pickup time
4. WHEN a driver accepts delayed request, THE System SHALL display scheduled pickup time
5. THE System SHALL search for drivers within 5-6 km radius of pickup location

### Requirement 10: Driver Notification and Acceptance

**User Story:** As an active driver, I want to receive nearby delivery requests, so that I can accept orders.

#### Acceptance Criteria

1. WHEN a company requests delivery within 5-6 km, THE System SHALL send notification to all active drivers in radius
2. WHEN a driver taps notification, THE System SHALL display order details card
3. WHEN displaying order, THE System SHALL show company name, phone, pickup address, delivery address, and recipient phone
4. WHEN a driver views order, THE System SHALL provide Accept and Skip buttons
5. WHEN a driver accepts order, THE System SHALL notify company and remove order from other drivers

### Requirement 11: Delivery Status Tracking

**User Story:** As a company user, I want to track delivery status, so that I know the current state of my order.

#### Acceptance Criteria

1. WHEN searching for driver, THE System SHALL display "Searching for driver" status with loading animation
2. WHEN driver accepts, THE System SHALL change status to "Driver on the way"
3. WHEN delivery completes, THE System SHALL change status to "Delivered"
4. WHEN no driver found after timeout, THE System SHALL display "No taxi found, try later" message
5. THE System SHALL save all delivery requests to history regardless of completion status

### Requirement 12: Real-time Driver Tracking

**User Story:** As a company user, I want to see driver location and ETA, so that I can prepare for delivery.

#### Acceptance Criteria

1. WHEN a driver accepts order, THE System SHALL display driver information card to company
2. WHEN displaying driver card, THE System SHALL show driver name, car model, car color, car number, and rating
3. WHEN driver is en route, THE System SHALL display driver's real-time location on map
4. WHEN driver is en route, THE System SHALL calculate and display estimated time of arrival
5. THE System SHALL update driver location every 10 seconds while order is active

### Requirement 13: Waiting Animation

**User Story:** As a company user, I want visual feedback while searching, so that I know the system is working.

#### Acceptance Criteria

1. WHEN searching for drivers, THE System SHALL display animated loading indicator
2. WHEN searching for drivers, THE System SHALL display text "Searching for available drivers nearby"
3. WHEN search exceeds 30 seconds, THE System SHALL display "Still searching, please wait"
4. WHEN search exceeds 60 seconds, THE System SHALL display option to cancel search
5. THE System SHALL allow user to cancel search at any time

### Requirement 14: App Icon Integration

**User Story:** As a user, I want to see consistent branding, so that I recognize the app easily.

#### Acceptance Criteria

1. THE System SHALL use provided logo as app launcher icon
2. THE System SHALL display logo on splash screen
3. THE System SHALL display logo in onboarding screens
4. THE System SHALL use logo in notification icons
5. THE System SHALL maintain logo aspect ratio across all sizes

### Requirement 15: Delivery History Enhancement

**User Story:** As a user, I want to view past deliveries with status, so that I can track my service history.

#### Acceptance Criteria

1. WHEN a user views history, THE System SHALL display all past delivery requests
2. WHEN displaying history, THE System SHALL show delivery status (Delivered, Cancelled, No Driver Found)
3. WHEN displaying history, THE System SHALL show date, time, pickup and delivery addresses
4. WHEN a user taps history item, THE System SHALL display full delivery details
5. THE System SHALL sort history by most recent first

## Constraints

- All text must be in Russian language
- Authentication must use username/password, not email
- Navigation bar must have maximum 4 items
- Driver search radius must be 5-6 km
- Onboarding must be shown only once per installation
- Branch management must be accessible from profile section
- Driver status changes must require confirmation
- All delivery requests must be saved to history
