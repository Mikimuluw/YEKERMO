import 'package:flutter/material.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class ScreenStateMapper {
  static ScreenState<T> fromSnapshot<T>(
    AsyncSnapshot<Result<T>> snapshot, {
    bool Function(T data)? isEmpty,
    String? emptyMessage,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
      return ScreenState.loading();
    }

    if (snapshot.hasError) {
      return ScreenState.error(
        Failure(snapshot.error.toString()),
      );
    }

    if (!snapshot.hasData) {
      return ScreenState.initial();
    }

    final Result<T> result = snapshot.data as Result<T>;
    switch (result) {
      case Success<T>(:final data):
        if (isEmpty?.call(data) ?? false) {
          return ScreenState.empty(emptyMessage);
        }
        return ScreenState.success(data);
      case FailureResult<T>(:final failure):
        return ScreenState.error(failure);
    }
  }
}
