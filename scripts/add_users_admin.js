/**
 * Script to add users using Firebase Admin SDK
 * 
 * Setup:
 * 1. npm install firebase-admin
 * 2. Download service account key from Firebase Console
 * 3. Save as serviceAccountKey.json in this directory
 * 4. Run: node scripts/add_users_admin.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

async function addDriver(email, password, userData) {
  try {
    // Create user in Authentication
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      emailVerified: true,
    });

    console.log('✅ Driver created in Auth:', userRecord.uid);

    // Add user data to Firestore
    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: email,
      type: 'driver',
      availabilityStatus: 'offline',
      rating: 5.0,
      totalRides: 0,
      isVerified: true,
      emailVerified: true,
      phoneVerified: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      ...userData,
    });

    console.log('✅ Driver data added to Firestore');
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   UID: ${userRecord.uid}\n`);

    return userRecord.uid;
  } catch (error) {
    console.error('❌ Error adding driver:', error.message);
    throw error;
  }
}

async function addCompany(email, password, userData) {
  try {
    // Create user in Authentication
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      emailVerified: true,
    });

    console.log('✅ Company created in Auth:', userRecord.uid);

    // Add user data to Firestore
    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: email,
      type: 'company',
      rating: 5.0,
      totalRides: 0,
      isVerified: true,
      emailVerified: true,
      phoneVerified: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      ...userData,
    });

    console.log('✅ Company data added to Firestore');
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   UID: ${userRecord.uid}\n`);

    return userRecord.uid;
  } catch (error) {
    console.error('❌ Error adding company:', error.message);
    throw error;
  }
}

async function main() {
  console.log('Adding test users...\n');

  try {
    // Add test drivers
    await addDriver('driver1@test.com', 'Driver123!', {
      fullName: 'John Driver',
      phoneNumber: '+1234567890',
      vehicleInfo: {
        make: 'Toyota',
        model: 'Camry',
        color: 'Blue',
        licensePlate: 'ABC-1234',
        year: 2020,
      },
      licenseNumber: 'DL123456',
    });

    await addDriver('driver2@test.com', 'Driver123!', {
      fullName: 'Jane Driver',
      phoneNumber: '+1234567891',
      vehicleInfo: {
        make: 'Honda',
        model: 'Accord',
        color: 'Black',
        licensePlate: 'XYZ-5678',
        year: 2021,
      },
      licenseNumber: 'DL789012',
    });

    // Add test companies
    await addCompany('company1@test.com', 'Company123!', {
      fullName: 'Bob Manager',
      phoneNumber: '+1234567892',
      companyName: 'ABC Transport',
      companyRegistrationNumber: 'REG123456',
      businessAddress: '123 Business St, City, State 12345',
    });

    await addCompany('company2@test.com', 'Company123!', {
      fullName: 'Alice Manager',
      phoneNumber: '+1234567893',
      companyName: 'XYZ Logistics',
      companyRegistrationNumber: 'REG789012',
      businessAddress: '456 Commerce Ave, City, State 67890',
    });

    console.log('\n✅ All test users added successfully!');
    console.log('You can now login with these credentials in the app.');
  } catch (error) {
    console.error('\n❌ Failed to add users:', error);
  } finally {
    process.exit(0);
  }
}

main();
