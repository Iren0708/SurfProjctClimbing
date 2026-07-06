import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';
import 'package:vertical_mobile/features/auth/domain/otp_validator.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_notifier.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_state.dart';
import 'package:vertical_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:vertical_mobile/features/auth/presentation/widgets/name_step.dart';
import 'package:vertical_mobile/features/auth/presentation/widgets/otp_step.dart';
import 'package:vertical_mobile/features/auth/presentation/widgets/phone_step.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(authFlowProvider);
    final notifier = ref.read(authFlowProvider.notifier);

    Future<void> showMessage(String? message) async {
      if (message == null || !context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return AuthScaffold(
      appBar: _buildAppBar(flow, notifier),
      body: _buildBody(
        flow: flow,
        notifier: notifier,
        onResend: () async {
          await showMessage(await notifier.resendCode());
        },
      ),
      actionLabel: _actionLabel(flow.step),
      actionState: _actionState(flow),
      actionEnabled: _isActionEnabled(flow),
      onAction: () async {
        final message = switch (flow.step) {
          AuthStep.phone => await notifier.requestCode(),
          AuthStep.otp => await notifier.verifyCode(),
          AuthStep.name => await notifier.submitName(),
        };
        await showMessage(message);
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    AuthFlowState flow,
    AuthFlowNotifier notifier,
  ) {
    return switch (flow.step) {
      AuthStep.phone => AppBar(title: const Text('Вертикаль')),
      AuthStep.otp => AppBar(
          leading: BackButton(onPressed: notifier.goBack),
          title: const Text('Подтверждение'),
        ),
      AuthStep.name => AppBar(
          leading: BackButton(onPressed: notifier.goBack),
          title: const Text('Как вас зовут?'),
        ),
    };
  }

  Widget _buildBody({
    required AuthFlowState flow,
    required AuthFlowNotifier notifier,
    required Future<void> Function() onResend,
  }) {
    return switch (flow.step) {
      AuthStep.phone => PhoneStep(
          phoneInput: flow.phoneInput,
          fieldError: flow.phoneFieldError,
          onChanged: notifier.updatePhoneInput,
        ),
      AuthStep.otp => OtpStep(
          phone: flow.e164Phone ?? '',
          otpCode: flow.otpCode,
          otpLength: AuthConfig.otpLength,
          resendSecondsLeft: flow.resendSecondsLeft,
          enabled: !flow.otpAction.isSubmitting,
          onChanged: notifier.updateOtpCode,
          onResend: flow.canResendCode ? () => onResend() : null,
        ),
      AuthStep.name => NameStep(
          name: flow.name,
          fieldError: flow.nameFieldError,
          onChanged: notifier.updateName,
        ),
    };
  }

  String _actionLabel(AuthStep step) {
    return switch (step) {
      AuthStep.phone => 'Получить код',
      AuthStep.otp => 'Подтвердить',
      AuthStep.name => 'Продолжить',
    };
  }

  ActionLoadableState _actionState(AuthFlowState flow) {
    return switch (flow.step) {
      AuthStep.phone => flow.phoneAction,
      AuthStep.otp => flow.otpAction,
      AuthStep.name => flow.nameAction,
    };
  }

  bool _isActionEnabled(AuthFlowState flow) {
    return switch (flow.step) {
      AuthStep.phone => PhoneStep.isPhoneReady(flow.phoneInput),
      AuthStep.otp => OtpValidator.isComplete(
          flow.otpCode,
          length: AuthConfig.otpLength,
        ),
      AuthStep.name => NameStep.isNameReady(flow.name),
    };
  }
}
