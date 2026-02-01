import 'package:yekermo/domain/failure.dart';

sealed class ScreenState<T> {
  const ScreenState();

  factory ScreenState.initial() = InitialState<T>;
  factory ScreenState.loading() = LoadingState<T>;
  factory ScreenState.success(T data) = SuccessState<T>;
  factory ScreenState.empty([String? message]) = EmptyState<T>;
  factory ScreenState.error(Failure failure) = ErrorState<T>;
}

final class InitialState<T> extends ScreenState<T> {
  const InitialState();
}

final class LoadingState<T> extends ScreenState<T> {
  const LoadingState();
}

final class SuccessState<T> extends ScreenState<T> {
  const SuccessState(this.data);
  final T data;
}

final class EmptyState<T> extends ScreenState<T> {
  const EmptyState([this.message]);
  final String? message;
}

final class ErrorState<T> extends ScreenState<T> {
  const ErrorState(this.failure);
  final Failure failure;
}
