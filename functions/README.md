# Cloud Functions for Taxi Dispatch App

This directory contains Firebase Cloud Functions for handling server-side operations and notifications.

## Functions

### 1. onRideCreated
Triggered when a new ride is created in Firestore.
- Finds all available drivers within 5km radius
- Sends push notifications to eligible drivers
- Uses geohashing for efficient proximity queries

### 2. onRideAccepted
Triggered when a ride status changes to "accepted".
- Notifies the company user that their ride was accepted
- Includes driver details in the notification

### 3. onDriverArrived
Triggered when a ride status changes to "arrived".
- Notifies the company user that the driver has arrived at pickup location

### 4. onTripCompleted
Triggered when a ride status changes to "completed".
- Notifies both the driver and company user
- Includes fare information in the notification

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Deploy functions:
```bash
firebase deploy --only functions
```

3. Test locally with emulators:
```bash
npm run serve
```

## Requirements

- Node.js 18 or higher
- Firebase CLI installed globally
- Firebase project configured

## Dependencies

- `firebase-admin`: Firebase Admin SDK for server-side operations
- `firebase-functions`: Cloud Functions SDK
- `geofire-common`: Geohashing utilities for proximity queries

## Environment Variables

No additional environment variables required. Functions use Firebase Admin SDK with default credentials.

## Notes

- All functions use Firestore triggers
- FCM tokens must be stored in user documents under `fcmToken` field
- Driver locations must include `geohash` field for proximity queries
- Notifications are sent with high priority for immediate delivery
