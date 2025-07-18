import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/family_service.dart';
import 'auth_provider.dart';

// Family service provider
final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});

// Family state
class FamilyState {
  final String? familyId;
  final String? familyName;
  final List<UserModel> members;
  final String? inviteCode;
  final bool isLoading;
  final String? error;

  const FamilyState({
    this.familyId,
    this.familyName,
    this.members = const [],
    this.inviteCode,
    this.isLoading = false,
    this.error,
  });

  bool get hasFamily => familyId != null;

  FamilyState copyWith({
    String? familyId,
    String? familyName,
    List<UserModel>? members,
    String? inviteCode,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FamilyState(
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Family notifier
class FamilyNotifier extends StateNotifier<FamilyState> {
  final FamilyService _familyService;
  final Ref _ref;

  FamilyNotifier(this._familyService, this._ref) : super(const FamilyState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _ref.read(currentUserProvider);
    if (user == null || user.familyId == null) return;

    await loadFamily();
  }

  Future<void> loadFamily() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = _ref.read(currentUserProvider);
      if (user?.familyId == null) {
        state = const FamilyState();
        return;
      }

      final familyData = await _familyService.getFamily(user!.familyId!);
      final members = await _familyService.getFamilyMembers(user.familyId!);

      state = FamilyState(
        familyId: familyData['id'],
        familyName: familyData['name'],
        members: members,
        inviteCode: familyData['inviteCode'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createFamily(String familyName) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final familyData = await _familyService.createFamily(familyName);
      
      state = FamilyState(
        familyId: familyData['id'],
        familyName: familyData['name'],
        inviteCode: familyData['inviteCode'],
        members: [_ref.read(currentUserProvider)!],
      );

      // Refresh auth to update user's familyId
      await _ref.read(authProvider.notifier).refreshUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> joinFamily(String inviteCode) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final familyData = await _familyService.joinFamily(inviteCode);
      
      await loadFamily();
      
      // Refresh auth to update user's familyId
      await _ref.read(authProvider.notifier).refreshUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> leaveFamily() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _familyService.leaveFamily();
      
      state = const FamilyState();
      
      // Refresh auth to update user's familyId
      await _ref.read(authProvider.notifier).refreshUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> removeMember(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _familyService.removeFamilyMember(memberId);
      
      // Reload family to get updated members
      await loadFamily();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<String> generateNewInviteCode() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newCode = await _familyService.generateNewInviteCode();
      
      state = state.copyWith(
        inviteCode: newCode,
        isLoading: false,
      );
      
      return newCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateFamilyName(String newName) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _familyService.updateFamilyName(newName);
      
      state = state.copyWith(
        familyName: newName,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Main family provider
final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  final familyService = ref.watch(familyServiceProvider);
  return FamilyNotifier(familyService, ref);
});

// Convenient providers
final familyIdProvider = Provider<String?>((ref) {
  return ref.watch(familyProvider).familyId;
});

final familyMembersProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(familyProvider).members;
});

final familyInviteCodeProvider = Provider<String?>((ref) {
  return ref.watch(familyProvider).inviteCode;
});

final hasFamilyProvider = Provider<bool>((ref) {
  return ref.watch(familyProvider).hasFamily;
});

final isFamilyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(familyProvider).isLoading;
});