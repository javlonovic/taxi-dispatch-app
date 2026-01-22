import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

/// Firebase Storage service for file uploads
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    final compressedFile = await _compressImage(filePath);
    final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
    final ref = _storage.ref().child('profile_photos/$fileName');
    
    await ref.putFile(compressedFile);
    final downloadUrl = await ref.getDownloadURL();
    
    // Clean up compressed file
    await compressedFile.delete();
    
    return downloadUrl;
  }

  /// Upload driver license photo
  Future<String> uploadDriverLicensePhoto(String userId, String filePath) async {
    final compressedFile = await _compressImage(filePath);
    final fileName = 'license_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
    final ref = _storage.ref().child('driver_licenses/$fileName');
    
    await ref.putFile(compressedFile);
    final downloadUrl = await ref.getDownloadURL();
    
    // Clean up compressed file
    await compressedFile.delete();
    
    return downloadUrl;
  }

  /// Delete file by URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist, ignore error
    }
  }

  /// Compress image to reduce file size
  Future<File> _compressImage(String filePath) async {
    final file = File(filePath);
    final fileExtension = path.extension(filePath).toLowerCase();
    
    // Skip compression for non-image files
    if (!['.jpg', '.jpeg', '.png'].contains(fileExtension)) {
      return file;
    }

    final targetPath = path.join(
      path.dirname(filePath),
      'compressed_${path.basename(filePath)}',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 85,
      minWidth: 1024,
      minHeight: 1024,
    );

    return compressedFile != null ? File(compressedFile.path) : file;
  }
}
