import 'package:flutter/material.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';

class LoadableSkeleton extends StatelessWidget {
  const LoadableSkeleton({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 88,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) {
        return Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: placeholder,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class LoadableErrorView extends StatelessWidget {
  const LoadableErrorView({
    super.key,
    this.message = LoadableMessages.loadError,
    required this.onRetry,
    this.retryLabel = LoadableMessages.retryAction,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadableEmptyView extends StatelessWidget {
  const LoadableEmptyView({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
