# Requirements Document - Balance & Cancellation System

## Introduction

This document outlines the requirements for implementing a balance-based payment system with commission management and enhanced order cancellation functionality for the taxi dispatch application.

## Glossary

- **System**: The taxi dispatch mobile application
- **Company**: Business user who requests deliveries
- **Driver**: User who accepts and completes deliveries
- **Admin**: System administrator who manages balances and commissions
- **Balance**: Company's prepaid account balance in sums
- **Commission**: Platform fee deducted from each delivery (10%)
- **Delivery Cost**: Fixed price per delivery (25,000 sums)
- **Call Center**: Support team that processes balance top-up requests

## Requirements

### Requirement 1: Driver Order Cancellation

**User Story:** As a driver, I want to cancel an active order if something unexpected happens, so that I can manage my availability properly.

#### Acceptance Criteria

1. WHEN the driver is on the way to pickup or delivery, THE System SHALL display a "Cancel Order" button
2. WHEN the driver taps the "Cancel Order" button, THE System SHALL display a confirmation dialog with reason input
3. IF the driver confirms cancellation, THEN THE System SHALL update the order status to "cancelled_by_driver"
4. WHEN an order is cancelled by driver, THE System SHALL notify the company immediately
5. AFTER driver cancels an order, THE System SHALL allow the company to request a new driver

### Requirement 2: Cancel Button Visibility Control

**User Story:** As a driver, I should not see the cancel button after I confirm order acceptance, so that I commit to completing accepted orders.

#### Acceptance Criteria

1. WHEN the driver views a new order notification, THE System SHALL display both "Accept" and "Skip" buttons
2. WHEN the driver taps "I got the order" (acceptance), THE System SHALL remove the cancel button
3. WHILE the driver is en route to pickup, THE System SHALL display the cancel button
4. WHILE the driver is en route to delivery destination, THE System SHALL display the cancel button
5. WHEN the driver arrives at pickup location, THE System SHALL hide the cancel button

### Requirement 3: Order Completion Notification

**User Story:** As a driver, I want to see a success message when I complete an order, so that I know the delivery was recorded successfully.

#### Acceptance Criteria

1. WHEN the driver marks an order as delivered, THE System SHALL display a success notification
2. THE success notification SHALL include delivery completion confirmation
3. THE System SHALL update the driver's earnings immediately
4. THE System SHALL save the completed delivery to history
5. AFTER showing success message, THE System SHALL return driver to dashboard

### Requirement 4: Company Balance Management

**User Story:** As a company, I need to maintain a balance to pay for deliveries, so that I can request taxi services.

#### Acceptance Criteria

1. THE System SHALL store each company's balance in sums
2. WHEN a company registers, THE System SHALL initialize balance to 0 sums
3. THE System SHALL display current balance in company profile
4. THE System SHALL display balance in company dashboard
5. WHEN balance is low, THE System SHALL display a warning message

### Requirement 5: Balance Requirement for Delivery Requests

**User Story:** As a company, I should only be able to request deliveries if I have sufficient balance, so that the platform ensures payment.

#### Acceptance Criteria

1. WHEN a company attempts to request a delivery, THE System SHALL check if balance >= 25,000 sums
2. IF balance is insufficient, THEN THE System SHALL display an error message with top-up instructions
3. IF balance is sufficient, THEN THE System SHALL allow the delivery request to proceed
4. THE System SHALL reserve 25,000 sums when a delivery request is created
5. THE reserved amount SHALL be deducted only when delivery is completed

### Requirement 6: Automatic Balance Deduction

**User Story:** As the system, I need to automatically deduct delivery costs from company balance when orders are completed, so that payments are processed correctly.

#### Acceptance Criteria

1. WHEN a delivery is marked as completed, THE System SHALL deduct 25,000 sums from company balance
2. THE System SHALL calculate commission as 10% of delivery cost (2,500 sums)
3. THE System SHALL transfer 22,500 sums to driver's earnings
4. THE System SHALL record 2,500 sums as platform commission
5. IF balance deduction fails, THE System SHALL log an error and notify admin

### Requirement 7: Manual Balance Top-Up by Admin

**User Story:** As an admin, I need to manually add balance to company accounts when they request top-ups, so that companies can continue using the service.

#### Acceptance Criteria

1. THE System SHALL provide an admin interface for balance management
2. WHEN admin adds balance, THE System SHALL require company ID and amount
3. THE System SHALL validate that amount is positive and reasonable
4. WHEN balance is added, THE System SHALL update company balance immediately
5. THE System SHALL record all balance top-ups with timestamp and admin ID

### Requirement 8: Balance Top-Up Process

**User Story:** As a company, I want to request balance top-ups through call center, so that I can add funds to my account.

#### Acceptance Criteria

1. THE System SHALL display call center contact information in company profile
2. WHEN balance is low, THE System SHALL show a "Top Up Balance" button
3. THE button SHALL display call center phone number
4. THE System SHALL provide instructions for top-up process
5. AFTER calling, THE admin SHALL manually add balance in Firebase

### Requirement 9: Commission Tracking

**User Story:** As an admin, I need to track all commissions collected from deliveries, so that I can monitor platform revenue.

#### Acceptance Criteria

1. THE System SHALL record commission amount for each completed delivery
2. THE System SHALL store commission in a separate collection
3. THE System SHALL calculate total commission per day, week, and month
4. THE System SHALL display commission statistics in admin dashboard
5. THE System SHALL include commission in financial reports

### Requirement 10: Cancellation Reason Tracking

**User Story:** As an admin, I need to know why drivers cancel orders, so that I can identify and address issues.

#### Acceptance Criteria

1. WHEN driver cancels an order, THE System SHALL require a cancellation reason
2. THE System SHALL provide predefined reason options (traffic, emergency, vehicle issue, other)
3. IF driver selects "other", THE System SHALL allow free text input
4. THE System SHALL store cancellation reason with order record
5. THE System SHALL display cancellation statistics in admin dashboard

### Requirement 11: Company Notification on Cancellation

**User Story:** As a company, I want to be notified immediately when a driver cancels my order, so that I can request another driver quickly.

#### Acceptance Criteria

1. WHEN driver cancels an order, THE System SHALL send push notification to company
2. THE notification SHALL include cancellation reason
3. THE notification SHALL include a "Request New Driver" action button
4. WHEN company taps the action button, THE System SHALL restart the delivery request process
5. THE System SHALL use the same delivery details from cancelled order

### Requirement 12: Balance History and Transactions

**User Story:** As a company, I want to view my balance history and all transactions, so that I can track my spending.

#### Acceptance Criteria

1. THE System SHALL maintain a transaction history for each company
2. THE System SHALL record all balance additions (top-ups)
3. THE System SHALL record all balance deductions (completed deliveries)
4. THE System SHALL display transaction date, type, amount, and balance after transaction
5. THE System SHALL allow filtering transactions by date range

### Requirement 13: Low Balance Warning

**User Story:** As a company, I want to be warned when my balance is low, so that I can top up before running out of funds.

#### Acceptance Criteria

1. WHEN company balance falls below 50,000 sums (2 deliveries), THE System SHALL display a warning
2. THE warning SHALL appear on dashboard and in profile
3. WHEN company balance reaches 0, THE System SHALL display a critical alert
4. THE alert SHALL include call center contact information
5. THE System SHALL prevent new delivery requests when balance is 0

### Requirement 14: Driver Earnings Calculation

**User Story:** As a driver, I want to see my earnings after each delivery, so that I know how much I've earned.

#### Acceptance Criteria

1. WHEN a delivery is completed, THE System SHALL add 22,500 sums to driver earnings
2. THE System SHALL display updated earnings immediately
3. THE System SHALL show earnings breakdown (delivery count × 22,500)
4. THE System SHALL maintain earnings history
5. THE System SHALL display total earnings in driver profile

### Requirement 15: Refund on Cancellation

**User Story:** As a company, I should not be charged if a driver cancels my order, so that I only pay for completed deliveries.

#### Acceptance Criteria

1. WHEN driver cancels an order, THE System SHALL release the reserved 25,000 sums
2. THE System SHALL return the amount to company's available balance
3. THE System SHALL not charge any cancellation fee to company
4. THE System SHALL record the cancellation in transaction history
5. THE System SHALL show "Refunded" status in transaction list

## Non-Functional Requirements

### Performance
- Balance checks must complete within 500ms
- Balance deductions must be atomic (all-or-nothing)
- Transaction history must load within 2 seconds

### Security
- Only admins can modify company balances
- All balance transactions must be logged
- Balance operations must use Firestore transactions to prevent race conditions

### Reliability
- System must handle concurrent balance operations correctly
- Failed balance deductions must be retried automatically
- All financial transactions must be auditable

### Usability
- Balance display must be prominent and easy to find
- Top-up instructions must be clear and accessible
- Cancellation dialog must be simple and quick to use

## Constraints

1. Delivery cost is fixed at 25,000 sums
2. Commission rate is fixed at 10% (2,500 sums)
3. Driver receives 90% of delivery cost (22,500 sums)
4. Balance top-ups are manual (via admin)
5. No automated payment gateway integration
6. All amounts are in Uzbek sums (UZS)
