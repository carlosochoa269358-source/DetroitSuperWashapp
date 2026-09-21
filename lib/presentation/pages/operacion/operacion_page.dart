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
import '../../providers/cash_register_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'pago_modal.dart';

/// Cuerpo de la pestaña "Servicios" del shell principal. No trae su propio
/// Scaffold/AppBar/FAB — esos los provee DashboardPage para tener una sola
/// barra superior y un solo botón flotante en toda la app.
class OperacionPage extends ConsumerWidget {
  const OperacionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerAsync = ref.watch(anyOpenCashRegisterProvider);

    return registerAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
      data: (register) {
        if (register == null) return const _SinTurnoAbierto();

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
      },
    );
  }
}

/// Se muestra en vez de la lista de órdenes cuando no hay turno abierto —
/// deja entrar a admin_general/admin_punto a revisar el resto de la app sin
/// obligarlos a abrir caja, pero registrar servicios sigue requiriendo uno.
class _SinTurnoAbierto extends StatelessWidget {
  const _SinTurnoAbierto();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.point_of_sale_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No hay un turno abierto', style: AppTextStyles.heading4, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Para registrar servicios primero hay que abrir el turno.',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.turno),
              icon: const Icon(Icons.lock_open),
              label: const Text('Abrir turno'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
            ),
          ],
        ),
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
        final total = orders.fold<double>(0, (sum, o) => sum + o.finalPrice);
        return Column(
          children: [
            _TotalHeader(total: total),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _OrderCard(order: orders[index]),
              ),
            ),
          ],
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
                if (order.serviceNames.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(order.finalPrice),
                    style: AppTextStyles.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
                if (order.status == 'paid' && order.paymentMethods.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.paymentMethods.map((m) => paymentMethodLabels[m] ?? m).join(' + '),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (order.status != 'cancelled')
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textMuted),
              tooltip: order.status == 'new' ? 'Editar servicios' : 'Corregir / anular orden',
              onPressed: order.vehicleTypeId == null
                  ? null
                  : () => context.push(
                        AppRoutes.ordenDetalleFor(order.id),
                        extra: order.vehicleTypeId,
                      ),
            ),
          if (order.status == 'new')
            ElevatedButton(
              onPressed: () async {
                await ref.read(serviceOrderRepositoryProvider).finalize(order.id);
                ref.invalidate(serviceOrdersByStatusProvider('new'));
                ref.invalidate(serviceOrdersByStatusProvider('finished'));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
              child: const Text('Finalizar'),
            )
          else if (order.status == 'finished')
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
        final total = receivables.fold<double>(0, (sum, r) => sum + r.pendingAmount);
        return Column(
          children: [
            _TotalHeader(total: total),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: receivables.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _ReceivableCard(receivable: receivables[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Total en dinero de la pestaña actual, alineado arriba a la derecha.
class _TotalHeader extends StatelessWidget {
  final double total;

  const _TotalHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Total: ${CurrencyFormatter.format(total)}',
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
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
