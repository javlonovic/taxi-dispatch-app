# Design Document - Balance & Cancellation System

## Overview

This document describes the technical design for implementing a balance-based payment system with commission management and enhanced order cancellation functionality.

## Architecture

### System Components

1. **Balance Management Module**
   - Company balance tracking
   - Transaction recording
   - Balance validation

2. **Commission Module**
   - Commission calculation
   - Revenue tracking
   - Financial reporting

3. **Cancellation Module**
   - Driver cancellation flow
   - Reason tracking
   - Company notification

4. **Admin Module**
   - Balance top-up interface
   - Commission dashboard
   - Transaction monitoring

## Data Models

### Company Balance Model

```dart
class CompanyBalance {
  final String companyId;
  final double balance;           // Current balance in sums
  final double reservedBalance;   // Amount reserved for pending orders
  final DateTime lastUpdated;
  final DateTime createdAt;
}
```

### Transaction Model

```dart
enum TransactionType {
  topUp,
  deduction,
  refund,
  commission,
}

class Transaction {
  final String id;
  final String companyId;
  final TransactionType type;
  final double amount;
  final double balanceAfter;
  final String? orderId;
  final String? adminId;
  final String? description;
  final DateTime createdAt;
}
```

### Commission Record Model

```dart
class CommissionRecord {
  final String id;
  final String orderId;
  final String companyId;
  final String driverId;
  final double deliveryCost;      // 25,000
  final double commissionAmount;  // 2,500
  final double driverEarnings;    // 22,500
  final DateTime createdAt;
}
```

### Cancellation Record Model

```dart
enum CancellationReason {
  traffic,
  emergency,
  vehicleIssue,
  other,
}

class CancellationRecord {
  final String id;
  final String orderId;
  final String driverId;
  final CancellationReason reason;
  final String? customReason;
  final DateTime cancelledAt;
}
```

## Firestore Structure

```
companies/{companyId}/
  balance: number (current balance)
  reservedBalance: number (reserved for pending orders)
  
transactions/{transactionId}/
  companyId: string
  type: string (topUp, deduction, refund)
  amount: number
  balanceAfter: number
  orderId: string (optional)
  adminId: string (optional)
  createdAt: timestamp
  
commissions/{commissionId}/
  orderId: string
  companyId: string
  driverId: string
  deliveryCost: number (25000)
  commissionAmount: number (2500)
  driverEarnings: number (22500)
  createdAt: timestamp
  
cancellations/{cancellationId}/
  orderId: string
  driverId: string
  reason: string
  customReason: string (optional)
  cancelledAt: timestamp
  
orders/{orderId}/
  status: string
  cancelledBy: string (optional)
  cancellationReason: string (optional)
```

## Component Design

### 1. Balance Service

```dart
class BalanceService {
  Future<double> getBalance(String companyId);
  Future<bool> hasInsufficientBalance(String companyId, double amount);
  Future<void> reserveBalance(String companyId, double amount);
  Future<void> releaseReservedBalance(String companyId, double amount);
  Future<void> deductBalance(String companyId, double amount, String orderId);
  Future<void> addBalance(String companyId, double amount, String adminId);
}
```

### 2. Commission Service

```dart
class CommissionService {
  static const double DELIVERY_COST = 25000.0;
  static const double COMMISSION_RATE = 0.10;
  
  double calculateCommission(double deliveryCost);
  double calculateDriverEarnings(double deliveryCost);
  Future<void> recordCommission(String orderId, String companyId, String driverId);
  Future<double> getTotalCommission(DateTime startDate, DateTime endDate);
}
```

### 3. Cancellation Service

```dart
class CancellationService {
  Future<void> cancelOrder(String orderId, String driverId, CancellationReason reason, String? customReason);
  Future<void> notifyCompanyOfCancellation(String companyId, String orderId);
  Future<void> refundCompany(String companyId, String orderId);
}
```

## User Interface Design

### Company Dashboard - Balance Display

```
┌─────────────────────────────────┐
│  Баланс: 150,000 сум           │
│  [Пополнить баланс]            │
└─────────────────────────────────┘
```

### Low Balance Warning

```
┌─────────────────────────────────┐
│  ⚠️ Низкий баланс!             │
│  Осталось: 25,000 сум          │
│  Пополните баланс для          │
│  продолжения работы            │
│  [Позвонить в call-центр]      │
└─────────────────────────────────┘
```

### Driver Cancellation Dialog

```
┌─────────────────────────────────┐
│  Отменить заказ?               │
│                                 │
│  Что случилось?                │
│  ○ Пробка                      │
│  ○ Экстренная ситуация         │
│  ○ Проблема с машиной          │
│  ○ Другое: [________]          │
│                                 │
│  [Назад]  [Отменить заказ]     │
└─────────────────────────────────┘
```

### Order Completion Success

```
┌─────────────────────────────────┐
│  ✅ Заказ выполнен!            │
│                                 │
│  Вы заработали: 22,500 сум     │
│                                 │
│  [Вернуться на главную]        │
└─────────────────────────────────┘
```

### Admin Balance Top-Up Interface

```
┌─────────────────────────────────┐
│  Пополнение баланса            │
│                                 │
│  ID компании: [________]       │
│  Сумма: [________] сум         │
│                                 │
│  Текущий баланс: 50,000 сум    │
│  После пополнения: 150,000 сум │
│                                 │
│  [Отмена]  [Пополнить]         │
└─────────────────────────────────┘
```

## Implementation Details

### Balance Check Before Order Creation

```dart
Future<void> createDeliveryRequest() async {
  final balance = await balanceService.getBalance(companyId);
  
  if (balance < 25000) {
    showInsufficientBalanceDialog();
    return;
  }
  
  // Reserve balance
  await balanceService.reserveBalance(companyId, 25000);
  
  // Create order
  final orderId = await createOrder();
}
```

### Balance Deduction on Completion

```dart
Future<void> completeDelivery(String orderId) async {
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    // Deduct from company
    await balanceService.deductBalance(companyId, 25000, orderId);
    
    // Add to driver earnings
    await driverService.addEarnings(driverId, 22500);
    
    // Record commission
    await commissionService.recordCommission(orderId, companyId, driverId);
    
    // Update order status
    await orderService.updateStatus(orderId, 'completed');
  });
}
```

### Driver Cancellation Flow

```dart
Future<void> handleDriverCancellation() async {
  // Show cancellation dialog
  final result = await showCancellationDialog();
  
  if (result.confirmed) {
    // Cancel order
    await cancellationService.cancelOrder(
      orderId,
      driverId,
      result.reason,
      result.customReason,
    );
    
    // Refund company
    await cancellationService.refundCompany(companyId, orderId);
    
    // Notify company
    await cancellationService.notifyCompanyOfCancellation(companyId, orderId);
    
    // Show success message
    showSnackBar('Заказ отменен');
  }
}
```

## Security Rules

```javascript
// Balance can only be modified by system or admin
match /companies/{companyId} {
  allow read: if request.auth.uid == companyId;
  allow update: if request.auth.uid == companyId && 
    !request.resource.data.diff(resource.data).affectedKeys().hasAny(['balance', 'reservedBalance']);
}

// Transactions are read-only for users
match /transactions/{transactionId} {
  allow read: if request.auth != null;
  allow write: if false; // Only via Cloud Functions
}

// Commissions are admin-only
match /commissions/{commissionId} {
  allow read: if isAdmin();
  allow write: if false; // Only via Cloud Functions
}
```

## Error Handling

1. **Insufficient Balance**: Show dialog with top-up instructions
2. **Balance Deduction Failure**: Retry with exponential backoff
3. **Concurrent Balance Operations**: Use Firestore transactions
4. **Network Errors**: Queue operations for retry

## Testing Strategy

1. **Unit Tests**: Balance calculations, commission calculations
2. **Integration Tests**: Balance deduction flow, cancellation flow
3. **E2E Tests**: Complete order with balance deduction
4. **Load Tests**: Concurrent balance operations

