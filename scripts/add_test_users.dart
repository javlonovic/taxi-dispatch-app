import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to add test users to Firebase
/// Run with: dart run scripts/add_test_users.dart
void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  print('Adding test users...\n');

  // Add test driver
  await addTestDriver(auth, firestore);

  // Add test company
  await addTestCompany(auth, firestore);

  print('\n✅ Test users added successfully!');
  print('You can now login with these credentials in the app.');
}

Future<void> addTestDriver(FirebaseAuth auth, FirebaseFirestore firestore) async {
  const email = 'driver.test@example.com';
  const password = 'TestDriver123!';

  try {
    // Create auth user
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // Add to Firestore
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': 'Test Driver',
      'phoneNumber': '+1234567890',
      'type': 'driver',
      'availabilityStatus': 'offline',
      'vehicleInfo': {
        'make': 'Toyota',
        'model': 'Camry',
        'color': 'Blue',
        'licensePlate': 'TEST-001',
        'year': 2020,
      },
      'licenseNumber': 'DL-TEST-001',
      'rating': 5.0,
      'totalRides': 0,
      'isVerified': true,
      'emailVerified': true,
      'phoneVerified': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Driver added:');
    print('   Email: $email');
    print('   Password: $password');
    print('   UID: $uid');
  } catch (e) {
    print('❌ Error adding driver: $e');
  }
}

Future<void> addTestCompany(FirebaseAuth auth, FirebaseFirestore firestore) async {
  const email = 'company.test@example.com';
  const password = 'TestCompany123!';

  try {
    // Create auth user
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // Add to Firestore
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': 'Test Manager',
      'phoneNumber': '+1234567891',
      'type': 'company',
      'companyName': 'Test Transport Inc',
      'companyRegistrationNumber': 'REG-TEST-001',
      'businessAddress': '123 Test Street, Test City, TC 12345',
      'rating': 5.0,
      'totalRides': 0,
      'isVerified': true,
      'emailVerified': true,
      'phoneVerified': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('\n✅ Company added:');
    print('   Email: $email');
    print('   Password: $password');
    print('   UID: $uid');
  } catch (e) {
    print('❌ Error adding company: $e');
  }
}
