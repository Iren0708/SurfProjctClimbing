import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    required this.actionLabel,
    required this.actionState,
    required this.onAction,
    this.actionEnabled = true,
    this.appBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final String actionLabel;
  final ActionLoadableState actionState;
  final VoidCallback? onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final padding = context.verticalTokens.screenPadding;

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: true,
      body: body,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          child: ActionLoadableButton(
            label: actionLabel,
            state: actionState,
            onPressed: actionEnabled ? onAction : null,
          ),
        ),
      ),
    );
  }
}
