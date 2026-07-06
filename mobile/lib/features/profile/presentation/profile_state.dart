import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

enum ProfileEditMode {
  view,
  edit,
}

class ProfileState {
  const ProfileState({
    required this.profile,
    this.editMode = ProfileEditMode.view,
    this.draftName = '',
    this.saveState = const ActionLoadableState.idle(),
    this.actionSnack,
  });

  final LoadableState<ClientDto> profile;
  final ProfileEditMode editMode;
  final String draftName;
  final ActionLoadableState saveState;
  final String? actionSnack;

  factory ProfileState.initial() {
    return ProfileState(
      profile: LoadableState<ClientDto>.loading(),
    );
  }

  ProfileState copyWith({
    LoadableState<ClientDto>? profile,
    ProfileEditMode? editMode,
    String? draftName,
    ActionLoadableState? saveState,
    String? actionSnack,
    bool clearSnack = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      editMode: editMode ?? this.editMode,
      draftName: draftName ?? this.draftName,
      saveState: saveState ?? this.saveState,
      actionSnack: clearSnack ? null : (actionSnack ?? this.actionSnack),
    );
  }
}
