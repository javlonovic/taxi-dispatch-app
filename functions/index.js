const functions = require("firebase-functions");
const admin = require("firebase-admin");
const geofireCommon = require("geofire-common");
const {logger} = require("firebase-functions");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Send FCM notification to a user
 * @param {string} fcmToken - User's FCM token
 * @param {object} notification - Notification object with title and body
 * @param {object} data - Additional data payload
 * @return {Promise} - Promise resolving to message ID
 */
async function sendNotification(fcmToken, notification, data) {
  const message = {
    notification: notification,
    data: data,
    token: fcmToken,
    android: {
      priority: "high",
      notification: {
        sound: "default",
        channelId: "ride_notifications",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  try {
    const response = await messaging.send(message);
    logger.info("Successfully sent message:", response);
    return response;
  } catch (error) {
    logger.error("Error sending message:", error);
    throw error;
  }
}

/**
 * Find available drivers within radius
 * @param {object} location - GeoPoint with latitude and longitude
 * @param {number} radiusInKm - Search radius in kilometers
 * @return {Promise<Array>} - Array of driver documents
 */
async function findAvailableDrivers(location, radiusInKm) {
  const center = [location.latitude, location.longitude];
  const radiusInM = radiusInKm * 1000;

  // Calculate geohash query bounds
  const bounds = geofireCommon.geohashQueryBounds(center, radiusInM);
  const promises = [];

  for (const b of bounds) {
    const q = db.collection("users")
        .where("type", "==", "driver")
        .where("isActive", "==", true)
        .where("availabilityStatus", "==", "available")
        .where("geohash", ">=", b[0])
        .where("geohash", "<=", b[1]);

    promises.push(q.get());
  }

  // If geohash query returns no results, fallback to querying all active drivers
  // This ensures we don't miss drivers if geohash isn't set
  if (promises.length === 0) {
    const fallbackQuery = db.collection("users")
        .where("type", "==", "driver")
        .where("isActive", "==", true)
        .where("availabilityStatus", "==", "available");
    promises.push(fallbackQuery.get());
  }

  const snapshots = await Promise.all(promises);
  const drivers = [];

  for (const snap of snapshots) {
    for (const doc of snap.docs) {
      const data = doc.data();
      const driverLocation = data.currentLocation;

      if (!driverLocation) continue;

      // Calculate distance
      const distanceInKm = geofireCommon.distanceBetween(
          [driverLocation.latitude, driverLocation.longitude],
          center,
      );

      // If radius is very large (>= 50km), include all active drivers regardless of distance
      if (radiusInKm >= 50 || distanceInKm <= radiusInKm) {
        drivers.push({
          id: doc.id,
          ...data,
          distanceInKm: distanceInKm,
        });
      }
    }
  }

  return drivers;
}

/**
 * Trigger when a new ride is created
 * Notify all available drivers within 5-6km
 */
exports.onRideCreated = functions.firestore
    .document("rides/{rideId}")
    .onCreate(async (snap, context) => {
      const rideData = snap.data();
      const rideId = context.params.rideId;

      logger.info("New ride created:", rideId);

      try {
        // Find available drivers - use large radius (100km) to notify all active drivers
        // The order form screen uses 100km radius to notify all active drivers
        const searchRadius = 100; // Large radius to notify all active drivers
        const drivers = await findAvailableDrivers(rideData.pickupLocation, searchRadius);

        logger.info(`Found ${drivers.length} available drivers within ${searchRadius}km`);

        if (drivers.length === 0) {
          logger.warn("No available drivers found - drivers may not be active or have no FCM tokens");
          return null;
        }

        // Get company user details
        const companyDoc = await db.collection("users").doc(rideData.companyUserId).get();
        const companyData = companyDoc.data();

        // Send notification to all eligible drivers
        let successCount = 0;
        let failCount = 0;

        const notificationPromises = drivers.map(async (driver) => {
          if (!driver.fcmToken) {
            logger.warn(`Driver ${driver.id} has no FCM token`);
            failCount++;
            return null;
          }

          try {
            const notification = {
              title: "🚚 Новый заказ!",
              body: `Забрать: ${rideData.pickupAddress || "Адрес отправления"}\nДоставить: ${rideData.destinationAddress || "Адрес доставки"}`,
            };

            const data = {
              type: "ride_request",
              rideId: rideId,
              companyName: rideData.companyName || companyData?.companyName || companyData?.fullName || "Компания",
              companyPhone: rideData.companyPhone || companyData?.phoneNumber || "",
              pickupAddress: rideData.pickupAddress || "",
              destinationAddress: rideData.destinationAddress || "",
              recipientName: rideData.recipientName || "",
              recipientPhone: rideData.recipientPhone || "",
              distance: driver.distanceInKm ? driver.distanceInKm.toFixed(1) : "0",
              readyInMinutes: (rideData.readyInMinutes || 0).toString(),
              scheduledPickupTime: rideData.scheduledPickupTime ?
                rideData.scheduledPickupTime.toDate().toISOString() :
                rideData.requestedAt.toDate().toISOString(),
            };

            await sendNotification(driver.fcmToken, notification, data);
            successCount++;
            return true;
          } catch (error) {
            logger.error(`Failed to send notification to driver ${driver.id}:`, error);
            failCount++;
            return null;
          }
        });

        await Promise.all(notificationPromises);
        logger.info(`Notifications sent: ${successCount} successful, ${failCount} failed out of ${drivers.length} drivers`);

        return null;
      } catch (error) {
        logger.error("Error in onRideCreated:", error);
        return null;
      }
    });

/**
 * Trigger when a ride is accepted
 * Notify company user
 * Note: Other drivers will see the order is no longer available when they try to accept
 * (status check in OrderDetailsDialog prevents double-acceptance)
 */
exports.onRideAccepted = functions.firestore
    .document("rides/{rideId}")
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const rideId = context.params.rideId;

      // Check if status changed to accepted
      if (beforeData.status !== "accepted" && afterData.status === "accepted") {
        logger.info("Ride accepted:", rideId);

        try {
          // Get driver details
          const driverDoc = await db.collection("users").doc(afterData.driverUserId).get();
          const driverData = driverDoc.data();

          // Get company user details
          const companyDoc = await db.collection("users").doc(afterData.companyUserId).get();
          const companyData = companyDoc.data();

          // Notify company user in Russian
          if (companyData.fcmToken) {
            const notification = {
              title: "Водитель принял заказ",
              body: `${driverData.firstName || driverData.fullName || "Водитель"} ${driverData.lastName || ""} принял ваш заказ`,
            };

            const data = {
              type: "rideAccepted",
              rideId: rideId,
              driverId: afterData.driverUserId,
              driverName: `${driverData.firstName || driverData.fullName || ""} ${driverData.lastName || ""}`.trim(),
              carModel: driverData.carModel || "",
              carColor: driverData.carColor || "",
              carNumber: driverData.carNumber || "",
              rating: (driverData.rating || 5.0).toString(),
            };

            await sendNotification(companyData.fcmToken, notification, data);
            logger.info("Notification sent to company user");
          }

          // Orders are automatically removed from other drivers' view because:
          // 1. Status changes from 'pending' to 'accepted'
          // 2. OrderDetailsDialog checks status before allowing acceptance
          // 3. If another driver tries to accept, they'll see "already accepted" error

          return null;
        } catch (error) {
          logger.error("Error in onRideAccepted:", error);
          return null;
        }
      }

      return null;
    });

/**
 * Trigger when driver arrives at pickup
 * Notify company user
 */
exports.onDriverArrived = functions.firestore
    .document("rides/{rideId}")
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const rideId = context.params.rideId;

      // Check if status changed to arrived
      if (beforeData.status !== "arrived" && afterData.status === "arrived") {
        logger.info("Driver arrived:", rideId);

        try {
          // Get driver details
          const driverDoc = await db.collection("users").doc(afterData.driverUserId).get();
          const driverData = driverDoc.data();

          // Get company user details
          const companyDoc = await db.collection("users").doc(afterData.companyUserId).get();
          const companyData = companyDoc.data();

          // Notify company user
          if (companyData.fcmToken) {
            const notification = {
              title: "Driver Arrived",
              body: `${driverData.fullName} has arrived at the pickup location`,
            };

            const data = {
              type: "driverArrived",
              rideId: rideId,
              driverId: afterData.driverUserId,
              driverName: driverData.fullName || "",
            };

            await sendNotification(companyData.fcmToken, notification, data);
            logger.info("Notification sent to company user");
          }

          return null;
        } catch (error) {
          logger.error("Error in onDriverArrived:", error);
          return null;
        }
      }

      return null;
    });

/**
 * Trigger when trip is completed
 * Notify both driver and company user
 */
exports.onTripCompleted = functions.firestore
    .document("rides/{rideId}")
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const rideId = context.params.rideId;

      // Check if status changed to completed
      if (beforeData.status !== "completed" && afterData.status === "completed") {
        logger.info("Trip completed:", rideId);

        try {
          // Get driver details
          const driverDoc = await db.collection("users").doc(afterData.driverUserId).get();
          const driverData = driverDoc.data();

          // Get company user details
          const companyDoc = await db.collection("users").doc(afterData.companyUserId).get();
          const companyData = companyDoc.data();

          const notificationPromises = [];

          // Notify company user
          if (companyData.fcmToken) {
            const companyNotification = {
              title: "Trip Completed",
              body: `Your trip with ${driverData.fullName} has been completed`,
            };

            const companyData = {
              type: "tripCompleted",
              rideId: rideId,
              driverId: afterData.driverUserId,
              fare: afterData.fare?.toString() || "0",
            };

            notificationPromises.push(
                sendNotification(companyData.fcmToken, companyNotification, companyData),
            );
          }

          // Notify driver
          if (driverData.fcmToken) {
            const driverNotification = {
              title: "Trip Completed",
              body: `Trip with ${companyData.fullName} has been completed`,
            };

            const driverDataPayload = {
              type: "tripCompleted",
              rideId: rideId,
              companyId: afterData.companyUserId,
              fare: afterData.fare?.toString() || "0",
            };

            notificationPromises.push(
                sendNotification(driverData.fcmToken, driverNotification, driverDataPayload),
            );
          }

          await Promise.all(notificationPromises);
          logger.info("Notifications sent to both users");

          return null;
        } catch (error) {
          logger.error("Error in onTripCompleted:", error);
          return null;
        }
      }

      return null;
    });

/**
 * Cloud Function to process notifications from app
 * This processes notifications stored in the 'notifications' collection
 */
exports.processNotifications = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
      const notificationData = snap.data();
      const notificationId = context.params.notificationId;

      logger.info("Processing notification:", notificationId);

      try {
        const {fcmToken, title, body, data} = notificationData;

        if (!fcmToken) {
          logger.warn(`Notification ${notificationId} has no FCM token`);
          await snap.ref.update({sent: false, error: "No FCM token"});
          return null;
        }

        const notification = {
          title: title || "Уведомление",
          body: body || "",
        };

        await sendNotification(fcmToken, notification, data || {});

        // Mark as sent
        await snap.ref.update({sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp()});
        logger.info(`Notification ${notificationId} sent successfully`);

        return null;
      } catch (error) {
        logger.error(`Error processing notification ${notificationId}:`, error);
        await snap.ref.update({
          sent: false,
          error: error.message,
          errorAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }
    });
