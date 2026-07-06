import 'package:flutter/material.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

typedef LoadableContentBuilder<T> = Widget Function(BuildContext context, T data);

/// Переиспользуемый контейнер состояний экрана (LOGIC-008, `StateContainer`).
class StateContainer<T> extends StatelessWidget {
  const StateContainer({
    super.key,
    required this.state,
    required this.contentBuilder,
    required this.onRetry,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onRefresh,
    this.refreshable = false,
  });

  final LoadableState<T> state;
  final LoadableContentBuilder<T> contentBuilder;
  final VoidCallback onRetry;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, VoidCallback onRetry)? errorBuilder;
  final Future<void> Function()? onRefresh;
  final bool refreshable;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case LoadableStatus.loading:
        return loadingBuilder?.call(context) ?? const LoadableSkeleton();
      case LoadableStatus.error:
        return errorBuilder?.call(context, onRetry) ??
            LoadableErrorView(onRetry: onRetry);
      case LoadableStatus.empty:
        final empty = emptyBuilder?.call(context) ??
            const LoadableEmptyView(title: 'Нет данных');
        return _maybeRefreshable(child: empty);
      case LoadableStatus.content:
        final data = state.data;
        if (data == null) {
          return LoadableErrorView(onRetry: onRetry);
        }
        final content = Stack(
          children: [
            contentBuilder(context, data),
            if (state.isRefreshing)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
        return _maybeRefreshable(child: content);
    }
  }

  Widget _maybeRefreshable({required Widget child}) {
    if (!refreshable || onRefresh == null) {
      return child;
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Обёртка pull-to-refresh для списков в состоянии Content/Empty.
class LoadableRefreshable extends StatelessWidget {
  const LoadableRefreshable({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// CTA с блокировкой повторного нажатия при submitting (LOGIC-008 §4).
class ActionLoadableButton extends StatelessWidget {
  const ActionLoadableButton({
    super.key,
    required this.label,
    required this.state,
    required this.onPressed,
  });

  final String label;
  final ActionLoadableState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: state.isSubmitting ? null : onPressed,
      child: state.isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

/// Показывает снек ошибки PTR, не меняя контент (LOGIC-008 §3).
void showRefreshErrorSnackBar(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    const SnackBar(
      content: Text(LoadableMessages.refreshError),
    ),
  );
}
