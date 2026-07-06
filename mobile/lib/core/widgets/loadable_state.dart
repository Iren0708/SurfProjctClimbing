enum LoadableStatus {
  loading,
  content,
  empty,
  error,
}

/// Состояние экрана с данными API (LOGIC-008).
class LoadableState<T> {
  const LoadableState._({
    required this.status,
    this.data,
    this.isRefreshing = false,
    this.errorMessage,
  });

  factory LoadableState.loading() {
    return LoadableState<T>._(status: LoadableStatus.loading);
  }

  factory LoadableState.content(
    T data, {
    bool isRefreshing = false,
  }) {
    return LoadableState<T>._(
      status: LoadableStatus.content,
      data: data,
      isRefreshing: isRefreshing,
    );
  }

  factory LoadableState.empty({
    bool isRefreshing = false,
  }) {
    return LoadableState<T>._(
      status: LoadableStatus.empty,
      isRefreshing: isRefreshing,
    );
  }

  factory LoadableState.error({
    String? message,
  }) {
    return LoadableState<T>._(
      status: LoadableStatus.error,
      errorMessage: message,
    );
  }

  final LoadableStatus status;
  final T? data;
  final bool isRefreshing;
  final String? errorMessage;

  bool get isLoading => status == LoadableStatus.loading;

  bool get hasContent => status == LoadableStatus.content && data != null;

  LoadableState<T> copyWith({
    LoadableStatus? status,
    T? data,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return LoadableState<T>._(
      status: status ?? this.status,
      data: data ?? this.data,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Успешный ответ: пустая коллекция → Empty, иначе Content.
  static LoadableState<List<E>> fromList<E>(List<E> items) {
    if (items.isEmpty) {
      return LoadableState<List<E>>.empty();
    }
    return LoadableState<List<E>>.content(items);
  }
}

enum ActionLoadableStatus {
  idle,
  submitting,
}

class ActionLoadableState {
  const ActionLoadableState._(this.status);

  const ActionLoadableState.idle() : this._(ActionLoadableStatus.idle);

  const ActionLoadableState.submitting() : this._(ActionLoadableStatus.submitting);

  final ActionLoadableStatus status;

  bool get isSubmitting => status == ActionLoadableStatus.submitting;
}
