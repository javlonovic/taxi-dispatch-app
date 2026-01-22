import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch_dto.dart';
import '../../core/exceptions/app_exception.dart';

/// Firestore datasource for branch CRUD operations
class FirestoreBranchDatasource {
  final FirebaseFirestore _firestore;

  FirestoreBranchDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get reference to branches subcollection for a company
  CollectionReference _getBranchesCollection(String companyId) {
    return _firestore.collection('users').doc(companyId).collection('branches');
  }

  /// Create a new branch
  Future<String> createBranch(BranchDto branch) async {
    try {
      final docRef = await _getBranchesCollection(branch.companyId).add(
        branch.toMap(),
      );
      return docRef.id;
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to create branch: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error creating branch: $e',
      );
    }
  }

  /// Get a single branch by ID
  Future<BranchDto> getBranch(String companyId, String branchId) async {
    try {
      final doc = await _getBranchesCollection(companyId).doc(branchId).get();

      if (!doc.exists) {
        throw GeneralException(
          'Branch not found',
          'branch-not-found',
        );
      }

      return BranchDto.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to get branch: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw GeneralException(
        'Unexpected error getting branch: $e',
      );
    }
  }

  /// Get all branches for a company
  Future<List<BranchDto>> getBranches(String companyId) async {
    try {
      final querySnapshot = await _getBranchesCollection(companyId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => BranchDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to get branches: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error getting branches: $e',
      );
    }
  }

  /// Stream all branches for a company
  Stream<List<BranchDto>> streamBranches(String companyId) {
    try {
      return _getBranchesCollection(companyId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BranchDto.fromFirestore(doc))
              .toList());
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to stream branches: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error streaming branches: $e',
      );
    }
  }

  /// Update an existing branch
  Future<void> updateBranch(
    String companyId,
    String branchId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updatedAt timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _getBranchesCollection(companyId).doc(branchId).update(updates);
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to update branch: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error updating branch: $e',
      );
    }
  }

  /// Delete a branch
  Future<void> deleteBranch(String companyId, String branchId) async {
    try {
      await _getBranchesCollection(companyId).doc(branchId).delete();
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to delete branch: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error deleting branch: $e',
      );
    }
  }

  /// Get the headquarters branch for a company
  Future<BranchDto?> getHeadquarters(String companyId) async {
    try {
      final querySnapshot = await _getBranchesCollection(companyId)
          .where('isHeadquarters', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return BranchDto.fromFirestore(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to get headquarters: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error getting headquarters: $e',
      );
    }
  }

  /// Count total branches for a company
  Future<int> countBranches(String companyId) async {
    try {
      final querySnapshot = await _getBranchesCollection(companyId).get();
      return querySnapshot.docs.length;
    } on FirebaseException catch (e) {
      throw GeneralException(
        'Failed to count branches: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw GeneralException(
        'Unexpected error counting branches: $e',
      );
    }
  }
}
