import 'package:vertical_mobile/core/widgets/loadable_state.dart';

enum AuthStep {
  phone,
  otp,
  name,
}

class AuthFlowState {
  const AuthFlowState({
    this.step = AuthStep.phone,
    this.phoneInput = '',
    this.e164Phone,
    this.otpCode = '',
    this.name = '',
    this.ttlSeconds,
    this.resendAfterSeconds,
    this.resendSecondsLeft = 0,
    this.phoneFieldError,
    this.nameFieldError,
    this.phoneAction = const ActionLoadableState.idle(),
    this.otpAction = const ActionLoadableState.idle(),
    this.nameAction = const ActionLoadableState.idle(),
  });

  final AuthStep step;
  final String phoneInput;
  final String? e164Phone;
  final String otpCode;
  final String name;
  final int? ttlSeconds;
  final int? resendAfterSeconds;
  final int resendSecondsLeft;
  final String? phoneFieldError;
  final String? nameFieldError;
  final ActionLoadableState phoneAction;
  final ActionLoadableState otpAction;
  final ActionLoadableState nameAction;

  bool get canResendCode => resendSecondsLeft <= 0;

  AuthFlowState copyWith({
    AuthStep? step,
    String? phoneInput,
    String? e164Phone,
    String? otpCode,
    String? name,
    int? ttlSeconds,
    int? resendAfterSeconds,
    int? resendSecondsLeft,
    String? phoneFieldError,
    String? nameFieldError,
    ActionLoadableState? phoneAction,
    ActionLoadableState? otpAction,
    ActionLoadableState? nameAction,
    bool clearPhoneError = false,
    bool clearNameError = false,
    bool clearE164Phone = false,
  }) {
    return AuthFlowState(
      step: step ?? this.step,
      phoneInput: phoneInput ?? this.phoneInput,
      e164Phone: clearE164Phone ? null : (e164Phone ?? this.e164Phone),
      otpCode: otpCode ?? this.otpCode,
      name: name ?? this.name,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      resendAfterSeconds: resendAfterSeconds ?? this.resendAfterSeconds,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
      phoneFieldError:
          clearPhoneError ? null : (phoneFieldError ?? this.phoneFieldError),
      nameFieldError:
          clearNameError ? null : (nameFieldError ?? this.nameFieldError),
      phoneAction: phoneAction ?? this.phoneAction,
      otpAction: otpAction ?? this.otpAction,
      nameAction: nameAction ?? this.nameAction,
    );
  }
}
