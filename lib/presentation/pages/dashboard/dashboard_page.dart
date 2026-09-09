import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/dashboard/stat_card_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: DetroitAppBar(
        title: 'Detroit Súper Wash',
        onLogout: () => ref.read(authProvider.notifier).signOut(),
        userName: user?.fullName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDate(DateFormatter.todayBogota()),
                  style: AppTextStyles.heading4,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Text(
                    'Turno: Abierto',
                    style: AppTextStyles.label.copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(AppRoutes.clientes),
                    child: DetroitCard(
                      accentColor: AppColors.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Clientes', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(AppRoutes.vehiculos),
                    child: DetroitCard(
                      accentColor: AppColors.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Buscar placa', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  StatCardWidget(
                    title: 'Nuevas',
                    value: '0',
                    color: AppColors.statusNew,
                    icon: Icons.new_releases,
                  ),
                  StatCardWidget(
                    title: 'Finalizadas',
                    value: '0',
                    color: AppColors.statusFinished,
                    icon: Icons.check_circle,
                  ),
                  StatCardWidget(
                    title: 'Por Cobrar',
                    value: '\$0',
                    color: AppColors.statusReceivable,
                    icon: Icons.payment,
                  ),
                  StatCardWidget(
                    title: 'Ventas del día',
                    value: '\$0',
                    color: AppColors.success,
                    icon: Icons.attach_money,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Operación'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 3:
              context.push(AppRoutes.configuracion);
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Este módulo se activa en una próxima fase')),
              );
          }
        },
      ),
    );
  }
}
