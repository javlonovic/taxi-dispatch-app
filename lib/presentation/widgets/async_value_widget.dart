import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'loading_widget.dart';
import 'error_widget.dart';

/// A widget that handles AsyncValue states (loading, error, data)
/// This is a reusable widget for displaying Riverpod AsyncValue states
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget? loading;

  const AsyncValueWidget({
    Key? key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const LoadingWidget(),
      error: (err, stack) =>
          error?.call(err, stack) ??
          ErrorDisplayWidget(
            message: err.toString(),
          ),
    );
  }
}

/// A widget builder that handles AsyncValue with custom loading and error widgets
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error, StackTrace stack)? errorBuilder;

  const AsyncValueBuilder({
    Key? key,
    required this.value,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () => loadingBuilder?.call(context) ?? const LoadingWidget(),
      error: (error, stack) =>
          errorBuilder?.call(context, error, stack) ??
          ErrorDisplayWidget(message: error.toString()),
    );
  }
}

/// A sliver version of AsyncValueWidget for use in CustomScrollView
class SliverAsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget? loading;

  const SliverAsyncValueWidget({
    Key? key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SliverFillRemaining(
        child: loading ?? const LoadingWidget(),
      ),
      error: (err, stack) => SliverFillRemaining(
        child: error?.call(err, stack) ??
            ErrorDisplayWidget(
              message: err.toString(),
            ),
      ),
    );
  }
}
