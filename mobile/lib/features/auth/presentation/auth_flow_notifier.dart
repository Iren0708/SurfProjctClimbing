import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/auth/data/auth_repository_provider.dart';
import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';
import 'package:vertical_mobile/features/auth/domain/name_validator.dart';
import 'package:vertical_mobile/features/auth/domain/otp_validator.dart';
import 'package:vertical_mobile/features/auth/domain/phone_validator.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_state.dart';

class AuthFlowNotifier extends Notifier<AuthFlowState> {
  Timer? _resendTimer;

  @override
  AuthFlowState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    return const AuthFlowState();
  }

  void updatePhoneInput(String value) {
    state = state.copyWith(
      phoneInput: value,
      clearPhoneError: true,
    );
  }

  void updateOtpCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(otpCode: digits);
  }

  void updateName(String value) {
    state = state.copyWith(
      name: value,
      clearNameError: true,
    );
  }

  void goBack() {
    switch (state.step) {
      case AuthStep.phone:
        return;
      case AuthStep.otp:
        _resendTimer?.cancel();
        state = state.copyWith(
          step: AuthStep.phone,
          otpCode: '',
          resendSecondsLeft: 0,
        );
      case AuthStep.name:
        state = state.copyWith(step: AuthStep.otp);
    }
  }

  Future<String?> requestCode() async {
    final e164 = PhoneValidator.toRussianE164(state.phoneInput);
    final validationError = e164 == null
        ? PhoneValidator.validateE164(state.phoneInput)
        : null;

    if (e164 == null) {
      state = state.copyWith(
        phoneFieldError: validationError ?? AuthMessages.phoneInvalid,
      );
      return null;
    }

    state = state.copyWith(
      phoneAction: const ActionLoadableState.submitting(),
      clearPhoneError: true,
    );

    try {
      final response =
          await ref.read(authRepositoryProvider).requestCode(e164);
      _startResendTimer(response.resendAfterSeconds);
      state = state.copyWith(
        step: AuthStep.otp,
        e164Phone: e164,
        ttlSeconds: response.ttlSeconds,
        resendAfterSeconds: response.resendAfterSeconds,
        otpCode: '',
        phoneAction: const ActionLoadableState.idle(),
      );
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(phoneAction: const ActionLoadableState.idle());
      return _mapRequestCodeError(error);
    } catch (_) {
      state = state.copyWith(phoneAction: const ActionLoadableState.idle());
      return AuthMessages.networkLoadError;
    }
  }

  Future<String?> resendCode() async {
    final phone = state.e164Phone;
    if (phone == null || !state.canResendCode) {
      return null;
    }

    try {
      final response =
          await ref.read(authRepositoryProvider).requestCode(phone);
      _startResendTimer(response.resendAfterSeconds);
      state = state.copyWith(
        otpCode: '',
        ttlSeconds: response.ttlSeconds,
        resendAfterSeconds: response.resendAfterSeconds,
      );
      return null;
    } on ApiException catch (error) {
      return _mapRequestCodeError(error);
    } catch (_) {
      return AuthMessages.networkLoadError;
    }
  }

  Future<String?> verifyCode() async {
    final phone = state.e164Phone;
    if (phone == null) {
      return AuthMessages.loginFailed;
    }

    if (!OtpValidator.isComplete(state.otpCode)) {
      return AuthMessages.codeInvalid;
    }

    state = state.copyWith(otpAction: const ActionLoadableState.submitting());

    try {
      final response = await ref.read(authRepositoryProvider).verifyCode(
            phone: phone,
            code: state.otpCode,
          );

      await ref.read(authSessionProvider.notifier).saveSession(
            response.tokens,
            requiresProfile: response.isNew,
          );

      if (response.isNew) {
        state = state.copyWith(
          step: AuthStep.name,
          otpAction: const ActionLoadableState.idle(),
        );
        return null;
      }

      state = state.copyWith(otpAction: const ActionLoadableState.idle());
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(otpAction: const ActionLoadableState.idle());
      return _mapVerifyError(error);
    } catch (_) {
      state = state.copyWith(otpAction: const ActionLoadableState.idle());
      return AuthMessages.networkLoadError;
    }
  }

  Future<String?> submitName() async {
    final validationError = NameValidator.validate(state.name);
    if (validationError != null) {
      state = state.copyWith(nameFieldError: validationError);
      return null;
    }

    state = state.copyWith(nameAction: const ActionLoadableState.submitting());

    try {
      await ref.read(authRepositoryProvider).updateProfile(state.name);
      await ref.read(authSessionProvider.notifier).completeProfile();
      state = state.copyWith(nameAction: const ActionLoadableState.idle());
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(nameAction: const ActionLoadableState.idle());
      if (error.statusCode == 400) {
        state = state.copyWith(nameFieldError: AuthMessages.nameInvalid);
        return null;
      }
      return _mapActionError(error);
    } catch (_) {
      state = state.copyWith(nameAction: const ActionLoadableState.idle());
      return AuthMessages.networkLoadError;
    }
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    state = state.copyWith(resendSecondsLeft: seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.resendSecondsLeft;
      if (left <= 1) {
        timer.cancel();
        state = state.copyWith(resendSecondsLeft: 0);
      } else {
        state = state.copyWith(resendSecondsLeft: left - 1);
      }
    });
  }

  String _mapRequestCodeError(ApiException error) {
    if (error.statusCode == 429) {
      final retryAfter = state.resendAfterSeconds ?? 60;
      _startResendTimer(retryAfter);
      return AuthMessages.tooManyAttempts;
    }
    if (error.statusCode != null && error.statusCode! >= 500) {
      return AuthMessages.serverError;
    }
    return AuthMessages.loginFailed;
  }

  String _mapVerifyError(ApiException error) {
    if (error.statusCode == 429) {
      final retryAfter = state.resendAfterSeconds ?? 60;
      _startResendTimer(retryAfter);
      return AuthMessages.tooManyAttempts;
    }
    if (error.error.code == 'invalid_code' || error.statusCode == 400) {
      return AuthMessages.codeInvalid;
    }
    if (error.statusCode != null && error.statusCode! >= 500) {
      return AuthMessages.serverError;
    }
    return AuthMessages.loginFailed;
  }

  String _mapActionError(ApiException error) {
    if (error.statusCode != null && error.statusCode! >= 500) {
      return AuthMessages.serverError;
    }
    return AuthMessages.actionError;
  }
}

final authFlowProvider =
    NotifierProvider<AuthFlowNotifier, AuthFlowState>(AuthFlowNotifier.new);
