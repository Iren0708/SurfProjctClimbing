import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/features/auth/domain/phone_validator.dart';
import 'package:vertical_mobile/features/auth/presentation/widgets/otp_code_field.dart';

class OtpStep extends StatelessWidget {
  const OtpStep({
    super.key,
    required this.phone,
    required this.otpCode,
    required this.otpLength,
    required this.resendSecondsLeft,
    required this.enabled,
    required this.onChanged,
    required this.onResend,
  });

  final String phone;
  final String otpCode;
  final int otpLength;
  final int resendSecondsLeft;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final textTheme = Theme.of(context).textTheme;
    final displayPhone = PhoneValidator.formatForDisplay(phone);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Мы отправили код на $displayPhone',
            style: textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingXl),
          Text('Код из SMS', style: textTheme.labelLarge),
          SizedBox(height: tokens.spacingMd),
          OtpCodeField(
            length: otpLength,
            value: otpCode,
            enabled: enabled,
            onChanged: onChanged,
          ),
          SizedBox(height: tokens.spacingLg),
          if (resendSecondsLeft > 0)
            Text(
              'Отправить код повторно (${_formatTimer(resendSecondsLeft)})',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            )
          else
            TextButton(
              onPressed: onResend,
              child: const Text('Отправить код повторно'),
            ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
