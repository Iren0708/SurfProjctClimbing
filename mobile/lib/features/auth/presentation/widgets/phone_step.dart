import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';
import 'package:vertical_mobile/features/auth/domain/phone_validator.dart';

class PhoneStep extends StatefulWidget {
  const PhoneStep({
    super.key,
    required this.phoneInput,
    required this.fieldError,
    required this.onChanged,
  });

  final String phoneInput;
  final String? fieldError;
  final ValueChanged<String> onChanged;

  static bool isPhoneReady(String phoneInput) {
    return PhoneValidator.toRussianE164(phoneInput) != null;
  }

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<PhoneStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.phoneInput);
  }

  @override
  void didUpdateWidget(covariant PhoneStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneInput != widget.phoneInput &&
        _controller.text != widget.phoneInput) {
      _controller.text = widget.phoneInput;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Войдите, чтобы записаться на тренировку',
            style: textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingXl),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Телефон',
              hintText: '9991234567',
              errorText: widget.fieldError,
              prefixText: '+7 ',
            ),
            onChanged: widget.onChanged,
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            AuthMessages.phoneHint,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
