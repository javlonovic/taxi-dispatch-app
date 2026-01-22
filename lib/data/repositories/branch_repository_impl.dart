import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/firestore_branch_datasource.dart';
import '../models/branch_dto.dart';

/// Implementation of BranchRepository using Firestore
class BranchRepositoryImpl implements BranchRepository {
  final FirestoreBranchDatasource _datasource;

  BranchRepositoryImpl({FirestoreBranchDatasource? datasource})
      : _datasource = datasource ?? FirestoreBranchDatasource();

  @override
  Future<String> createBranch(Branch branch) async {
    final dto = BranchDto.fromEntity(branch);
    return await _datasource.createBranch(dto);
  }

  @override
  Future<Branch> getBranch(String companyId, String branchId) async {
    final dto = await _datasource.getBranch(companyId, branchId);
    return dto.toEntity();
  }

  @override
  Future<List<Branch>> getBranches(String companyId) async {
    final dtos = await _datasource.getBranches(companyId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Stream<List<Branch>> streamBranches(String companyId) {
    return _datasource.streamBranches(companyId).map(
          (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
        );
  }

  @override
  Future<void> updateBranch(Branch branch) async {
    final updates = {
      'name': branch.name,
      'address': branch.address,
      'location': branch.location,
      'isHeadquarters': branch.isHeadquarters,
    };

    await _datasource.updateBranch(
      branch.companyId,
      branch.id,
      updates,
    );
  }

  @override
  Future<void> deleteBranch(String companyId, String branchId) async {
    // Check if this is the last branch
    final canDelete = await canDeleteBranch(companyId, branchId);
    if (!canDelete) {
      throw Exception('Cannot delete the last branch');
    }

    await _datasource.deleteBranch(companyId, branchId);
  }

  @override
  Future<Branch?> getHeadquarters(String companyId) async {
    final dto = await _datasource.getHeadquarters(companyId);
    return dto?.toEntity();
  }

  @override
  Future<int> countBranches(String companyId) async {
    return await _datasource.countBranches(companyId);
  }

  @override
  Future<bool> canDeleteBranch(String companyId, String branchId) async {
    final count = await countBranches(companyId);
    return count > 1;
  }
}
