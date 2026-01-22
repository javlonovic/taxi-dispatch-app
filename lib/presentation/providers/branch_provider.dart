import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../data/repositories/branch_repository_impl.dart';
import '../../data/datasources/firestore_branch_datasource.dart';
import 'auth_provider.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

/// Firestore Branch Data Source Provider
final firestoreBranchDataSourceProvider = Provider<FirestoreBranchDatasource>((ref) {
  return FirestoreBranchDatasource();
});

// ============================================================================
// Repository Provider
// ============================================================================

/// Branch Repository Provider
final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepositoryImpl(
    datasource: ref.watch(firestoreBranchDataSourceProvider),
  );
});

// ============================================================================
// Stream Providers
// ============================================================================

/// Stream provider for all branches of the current company
final branchesStreamProvider = StreamProvider.autoDispose<List<Branch>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      final repository = ref.watch(branchRepositoryProvider);
      return repository.streamBranches(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Stream provider for branches of a specific company
final companyBranchesStreamProvider = StreamProvider.autoDispose.family<List<Branch>, String>(
  (ref, companyId) {
    final repository = ref.watch(branchRepositoryProvider);
    return repository.streamBranches(companyId);
  },
);

// ============================================================================
// Future Providers
// ============================================================================

/// Future provider to get a specific branch
final branchProvider = FutureProvider.autoDispose.family<Branch, BranchParams>(
  (ref, params) async {
    final repository = ref.watch(branchRepositoryProvider);
    return await repository.getBranch(params.companyId, params.branchId);
  },
);

/// Future provider to get headquarters branch
final headquartersProvider = FutureProvider.autoDispose.family<Branch?, String>(
  (ref, companyId) async {
    final repository = ref.watch(branchRepositoryProvider);
    return await repository.getHeadquarters(companyId);
  },
);

/// Future provider to count branches
final branchCountProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, companyId) async {
    final repository = ref.watch(branchRepositoryProvider);
    return await repository.countBranches(companyId);
  },
);

/// Future provider to check if a branch can be deleted
final canDeleteBranchProvider = FutureProvider.autoDispose.family<bool, BranchParams>(
  (ref, params) async {
    final repository = ref.watch(branchRepositoryProvider);
    return await repository.canDeleteBranch(params.companyId, params.branchId);
  },
);

// ============================================================================
// State Notifier Provider
// ============================================================================

/// State notifier for branch operations
final branchNotifierProvider = StateNotifierProvider<BranchNotifier, AsyncValue<void>>(
  (ref) => BranchNotifier(ref.watch(branchRepositoryProvider)),
);

/// Branch notifier for managing branch operations
class BranchNotifier extends StateNotifier<AsyncValue<void>> {
  final BranchRepository _repository;

  BranchNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Create a new branch
  Future<String> createBranch(Branch branch) async {
    state = const AsyncValue.loading();
    try {
      final branchId = await _repository.createBranch(branch);
      state = const AsyncValue.data(null);
      return branchId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update an existing branch
  Future<void> updateBranch(Branch branch) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBranch(branch);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete a branch
  Future<void> deleteBranch(String companyId, String branchId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBranch(companyId, branchId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

/// Parameters for branch-related providers
class BranchParams {
  final String companyId;
  final String branchId;

  const BranchParams({
    required this.companyId,
    required this.branchId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchParams &&
        other.companyId == companyId &&
        other.branchId == branchId;
  }

  @override
  int get hashCode => companyId.hashCode ^ branchId.hashCode;
}
