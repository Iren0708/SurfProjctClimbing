import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_action_error_mapper.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository_provider.dart';
import 'package:vertical_mobile/features/profile/domain/profile_messages.dart';
import 'package:vertical_mobile/features/profile/presentation/profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future<void>.microtask(loadProfile);
    return ProfileState.initial();
  }

  Future<void> loadProfile() async {
    state = ProfileState.initial();
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      state = ProfileState(
        profile: LoadableState.content(profile),
        draftName: profile.name ?? '',
      );
    } on ApiException catch (_) {
      state = ProfileState(
        profile: LoadableState<ClientDto>.error(),
      );
    } catch (_) {
      state = ProfileState(
        profile: LoadableState<ClientDto>.error(),
      );
    }
  }

  void startEditing() {
    final profile = state.profile.data;
    if (profile == null) {
      return;
    }
    state = state.copyWith(
      editMode: ProfileEditMode.edit,
      draftName: profile.name ?? '',
    );
  }

  void cancelEditing() {
    final profile = state.profile.data;
    state = state.copyWith(
      editMode: ProfileEditMode.view,
      draftName: profile?.name ?? '',
    );
  }

  void updateDraftName(String value) {
    state = state.copyWith(draftName: value);
  }

  String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return ProfileMessages.nameRequired;
    }
    if (trimmed.length > 100) {
      return ProfileMessages.nameTooLong;
    }
    return null;
  }

  Future<bool> saveProfile() async {
    final validationError = validateName(state.draftName);
    if (validationError != null) {
      state = state.copyWith(actionSnack: validationError);
      return false;
    }

    state = state.copyWith(
      saveState: const ActionLoadableState.submitting(),
      clearSnack: true,
    );

    try {
      final profile = await ref.read(profileRepositoryProvider).updateProfile(
            state.draftName,
          );
      state = ProfileState(
        profile: LoadableState.content(profile),
        draftName: profile.name ?? '',
        actionSnack: ProfileMessages.updatedSnack,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        saveState: const ActionLoadableState.idle(),
        actionSnack: ApiActionErrorMapper.map(
          error,
          fallback: ProfileMessages.saveError,
        ),
      );
    } catch (_) {
      state = state.copyWith(
        saveState: const ActionLoadableState.idle(),
        actionSnack: ProfileMessages.saveError,
      );
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await ref.read(profileRepositoryProvider).logout();
    } catch (_) {
      // Локально завершаем сессию даже при ошибке сети (SCR-007).
    }
    await ref.read(authSessionProvider.notifier).logout();
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(
      saveState: const ActionLoadableState.submitting(),
      clearSnack: true,
    );
    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      await ref.read(authSessionProvider.notifier).logout();
      state = state.copyWith(
        saveState: const ActionLoadableState.idle(),
        actionSnack: ProfileMessages.deletedSnack,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        saveState: const ActionLoadableState.idle(),
        actionSnack: ApiActionErrorMapper.map(
          error,
          fallback: ProfileMessages.deleteError,
        ),
      );
    } catch (_) {
      state = state.copyWith(
        saveState: const ActionLoadableState.idle(),
        actionSnack: ProfileMessages.deleteError,
      );
    }
    return false;
  }

  void clearSnack() {
    if (state.actionSnack != null) {
      state = state.copyWith(clearSnack: true);
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
