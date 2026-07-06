import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.length,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final int length;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OtpCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final digits = widget.value.padRight(widget.length).split('');

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < widget.length; index++) ...[
              if (index > 0) SizedBox(width: tokens.spacingSm),
              _OtpCell(
                digit: index < widget.value.length ? digits[index] : '',
                radius: tokens.cardRadius,
                minSize: tokens.minTouchTarget,
              ),
            ],
          ],
        ),
        Opacity(
          opacity: 0.01,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: widget.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              final trimmed = value.replaceAll(RegExp(r'\D'), '');
              final limited = trimmed.length > widget.length
                  ? trimmed.substring(0, widget.length)
                  : trimmed;
              widget.onChanged(limited);
            },
          ),
        ),
      ],
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.digit,
    required this.radius,
    required this.minSize,
  });

  final String digit;
  final double radius;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: minSize,
      height: minSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colorScheme.outline),
        color: colorScheme.surface,
      ),
      child: Text(
        digit.trim(),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
