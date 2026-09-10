import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/accounts_receivable_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../providers/accounts_receivable_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'pago_modal.dart';

/// Cuerpo de la pestaña "Servicios" del shell principal. No trae su propio
/// Scaffold/AppBar/FAB — esos los provee DashboardPage para tener una sola
/// barra superior y un solo botón flotante en toda la app.
class OperacionPage extends StatelessWidget {
  const OperacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: AppColors.background,
            child: const TabBar(
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: [
                Tab(text: 'Nuevas'),
                Tab(text: 'Finalizadas'),
                Tab(text: 'Pagadas'),
                Tab(text: 'Por Cobrar'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _OrdersTab(status: 'new'),
                _OrdersTab(status: 'finished'),
                _OrdersTab(status: 'paid'),
                _ReceivableTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  final String status;

  const _OrdersTab({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(serviceOrdersByStatusProvider(status));

    return ordersAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Text(_emptyMessage(status), style: AppTextStyles.body2, textAlign: TextAlign.center),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _OrderCard(order: orders[index]),
        );
      },
    );
  }

  String _emptyMessage(String status) {
    switch (status) {
      case 'new':
        return 'No hay servicios nuevos.\nUsa "Registrar servicio" para crear uno.';
      case 'finished':
        return 'No hay servicios finalizados pendientes de cobro.';
      case 'paid':
        return 'Todavía no hay servicios pagados.';
      default:
        return 'Sin resultados.';
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final ServiceOrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetroitCard(
      accentColor: _statusColor(order.status),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(order.vehiclePlate ?? '—', style: AppTextStyles.heading4),
                    const SizedBox(width: 8),
                    Text(DateFormatter.formatTime(order.createdAt), style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Text(order.customerName ?? '—', style: AppTextStyles.body2),
                Text(
                  order.serviceNames.isNotEmpty ? order.serviceNames.join(' + ') : 'Sin servicios agregados',
                  style: AppTextStyles.body2.copyWith(
                    color: order.serviceNames.isNotEmpty ? AppColors.onBackground : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (order.status == 'new') ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textMuted),
              onPressed: order.vehicleTypeId == null
                  ? null
                  : () => context.push(
                        AppRoutes.ordenDetalleFor(order.id),
                        extra: order.vehicleTypeId,
                      ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(serviceOrderRepositoryProvider).finalize(order.id);
                ref.invalidate(serviceOrdersByStatusProvider('new'));
                ref.invalidate(serviceOrdersByStatusProvider('finished'));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
              child: const Text('Finalizar'),
            ),
          ] else if (order.status == 'finished')
            ElevatedButton(
              onPressed: () => showPagoModal(context, ref, order),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              child: const Text('Cobrar'),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return AppColors.statusNew;
      case 'finished':
        return AppColors.statusFinished;
      case 'paid':
        return AppColors.statusPaid;
      default:
        return AppColors.textMuted;
    }
  }
}

class _ReceivableTab extends ConsumerWidget {
  const _ReceivableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivablesAsync = ref.watch(openAccountsReceivableProvider);

    return receivablesAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
      data: (receivables) {
        if (receivables.isEmpty) {
          return Center(
            child: Text('No hay cuentas por cobrar pendientes.', style: AppTextStyles.body2),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: receivables.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _ReceivableCard(receivable: receivables[index]),
        );
      },
    );
  }
}

class _ReceivableCard extends ConsumerWidget {
  final AccountsReceivableEntity receivable;

  const _ReceivableCard({required this.receivable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetroitCard(
      accentColor: AppColors.statusReceivable,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(receivable.vehiclePlate ?? '—', style: AppTextStyles.heading4),
                    const SizedBox(width: 8),
                    Text(receivable.orderNumber ?? '', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Text(receivable.customerName ?? '—', style: AppTextStyles.body2),
                Text(
                  'Debe ${CurrencyFormatter.format(receivable.pendingAmount)}',
                  style: AppTextStyles.body2.copyWith(color: AppColors.statusReceivable),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showAbonoModal(context, ref, receivable),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
            child: const Text('Abonar'),
          ),
        ],
      ),
    );
  }
}
