import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/controllers.dart';
import '../../data/repositories/content_repository.dart';
import 'common.dart';

/// Rebuilds with the shared content bundle and handles loading/error states.
class ContentBuilder extends StatelessWidget {
  const ContentBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ContentBundle data) builder;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).content;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final data = controller.data;
        if (data != null) return builder(context, data);
        if (controller.status == LoadStatus.error) {
          return ErrorView(onRetry: controller.retry);
        }
        if (controller.status == LoadStatus.idle) {
          WidgetsBinding.instance.addPostFrameCallback((_) => controller.load());
        }
        return const LoadingView();
      },
    );
  }
}
