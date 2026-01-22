import '../entities/branch.dart';

/// Repository interface for branch operations
abstract class BranchRepository {
  /// Create a new branch
  Future<String> createBranch(Branch branch);

  /// Get a single branch by ID
  Future<Branch> getBranch(String companyId, String branchId);

  /// Get all branches for a company
  Future<List<Branch>> getBranches(String companyId);

  /// Stream all branches for a company
  Stream<List<Branch>> streamBranches(String companyId);

  /// Update an existing branch
  Future<void> updateBranch(Branch branch);

  /// Delete a branch
  Future<void> deleteBranch(String companyId, String branchId);

  /// Get the headquarters branch for a company
  Future<Branch?> getHeadquarters(String companyId);

  /// Count total branches for a company
  Future<int> countBranches(String companyId);

  /// Check if a branch can be deleted (not the last branch)
  Future<bool> canDeleteBranch(String companyId, String branchId);
}
