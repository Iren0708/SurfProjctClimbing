import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/app/router/app_router.dart';
import 'package:vertical_mobile/app/theme/vertical_theme.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';

class VerticalApp extends ConsumerStatefulWidget {
  const VerticalApp({super.key});

  @override
  ConsumerState<VerticalApp> createState() => _VerticalAppState();
}

class _VerticalAppState extends ConsumerState<VerticalApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(authSessionProvider.notifier).bootstrap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Вертикаль',
      theme: VerticalTheme.light(),
      routerConfig: router,
    );
  }
}
