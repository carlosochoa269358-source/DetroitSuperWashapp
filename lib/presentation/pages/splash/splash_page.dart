import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    ref.listen(authStateChangesProvider, (previous, next) => _navigate(context, next));

    // authStateChangesProvider is very likely already resolved by the time this
    // page mounts (app.dart watches it earlier for router redirects), so
    // ref.listen alone would miss that already-delivered value and wait
    // forever for a change that never comes. Navigate on the current value too.
    if (authState.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(context, authState));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_banner.jpg', width: 240),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, AsyncValue<UserEntity?> state) {
    if (!state.hasValue || !context.mounted) return;
    if (state.value != null) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }
}
