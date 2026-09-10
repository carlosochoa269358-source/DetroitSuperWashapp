import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../caja/caja_tab.dart';
import '../operacion/operacion_page.dart';

class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState(0);
    final user = ref.watch(authProvider).value;
    final registerAsync = ref.watch(openCashRegisterTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppConstants.appName, style: AppTextStyles.heading4.copyWith(color: AppColors.primary)),
            registerAsync.when(
              data: (register) => Text(
                register != null
                    ? 'Caja #${register.id.substring(0, 5)} · ${user?.fullName ?? ''}'
                    : '',
                style: AppTextStyles.caption,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 120),
                    const SizedBox(height: 12),
                    Text(user?.fullName ?? '', style: AppTextStyles.heading4),
                    Text(DateFormatter.formatDate(DateFormatter.todayBogota()), style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider),
              ListTile(
                leading: const Icon(Icons.people, color: AppColors.primary),
                title: const Text('Clientes'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.clientes);
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car, color: AppColors.primary),
                title: const Text('Buscar por placa'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.vehiculos);
                },
              ),
              const Spacer(),
              const Divider(color: AppColors.divider),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Cerrar sesión'),
                onTap: () => ref.read(authProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: tabIndex.value,
        children: const [
          OperacionPage(),
          CajaTab(),
          _ReportesPlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex.value,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
        onTap: (index) {
          if (index == 3) {
            context.push(AppRoutes.configuracion);
            return;
          }
          tabIndex.value = index;
        },
      ),
      floatingActionButton: tabIndex.value == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.nuevoServicio),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              icon: const Icon(Icons.add_circle),
              label: const Text('Registrar servicio'),
            )
          : null,
    );
  }
}

class _ReportesPlaceholder extends StatelessWidget {
  const _ReportesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Próximamente', style: AppTextStyles.body1));
  }
}
