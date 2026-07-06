import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/features/auth/domain/name_validator.dart';

class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.name,
    required this.fieldError,
    required this.onChanged,
  });

  final String name;
  final String? fieldError;
  final ValueChanged<String> onChanged;

  static bool isNameReady(String name) {
    return NameValidator.validate(name) == null;
  }

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant NameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name && _controller.text != widget.name) {
      _controller.text = widget.name;
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
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Имя',
              errorText: widget.fieldError,
            ),
            onChanged: widget.onChanged,
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Так к вам будут обращаться',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
