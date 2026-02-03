import 'package:flutter/material.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_error_view.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final ScreenState<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, String message)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case InitialState<T>():
        return loadingBuilder?.call(context) ?? const AppLoading();
      case LoadingState<T>():
        return loadingBuilder?.call(context) ?? const AppLoading();
      case StaleLoadingState<T>():
        return loadingBuilder?.call(context) ?? const _StaleLoadingView();
      case EmptyState<T>(:final message):
        return emptyBuilder?.call(context) ??
            _DefaultEmptyView(message: message);
      case ErrorState<T>(:final failure):
        return errorBuilder?.call(context, failure.message) ??
            AppErrorView(message: failure.message);
      case SuccessState<T>(:final data):
        return dataBuilder(context, data);
    }
  }
}

class _StaleLoadingView extends StatelessWidget {
  const _StaleLoadingView();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle? bodySmall = Theme.of(context).textTheme.bodySmall;
    final Color subdued = scheme.onSurface.withValues(alpha: 0.7);
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We're checking on this.",
              style: bodySmall?.copyWith(color: subdued),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSm,
            Text(
              'No action needed right now.',
              style: bodySmall?.copyWith(color: subdued),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultEmptyView extends StatelessWidget {
  const _DefaultEmptyView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        message ?? 'Nothing here yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
