import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/cash_register_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/employee_settlement_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../operacion/pago_modal.dart' show paymentMethodLabels;

class TurnoHistorialDetallePage extends ConsumerWidget {
  final CashRegisterEntity register;

  const TurnoHistorialDetallePage({super.key, required this.register});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdAsync = ref.watch(ordersCreatedInRegisterProvider(register.id));
    final paidAsync = ref.watch(ordersPaidInRegisterProvider(register.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: DetroitAppBar(title: 'Turno #${register.id.substring(0, 5)}'),
        body: Column(
          children: [
            _TurnoStatsGrid(register: register),
            const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: [
                Tab(text: 'Atendidas'),
                Tab(text: 'Cobradas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OrdersList(
                    ordersAsync: createdAsync,
                    emptyMessage: 'No se atendió ningún vehículo en este turno.',
                  ),
                  _OrdersList(
                    ordersAsync: paidAsync,
                    emptyMessage: 'No se cobró nada durante este turno.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Encabezado compacto (apertura/cierre/quién) + cuadrícula de tarjeticas
/// pequeñas (estilo widget de iPhone) con los totales del turno — antes eran
/// 4 tarjetas completas apiladas que en el celular dejaban casi sin espacio
/// la lista de órdenes de abajo.
class _TurnoStatsGrid extends ConsumerWidget {
  final CashRegisterEntity register;

  const _TurnoStatsGrid({required this.register});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviciosAsync = ref.watch(servicesSummaryProvider(register.id));
    final settledAsync = ref.watch(turnoSettlementsProvider(register.id));
    final metodosAsync = ref.watch(paymentMethodTotalsProvider(register.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apertura: ${DateFormatter.formatDateTime(register.openedAt)}   ·   '
            'Cierre: ${register.closedAt != null ? DateFormatter.formatDateTime(register.closedAt!) : '—'}',
            style: AppTextStyles.caption,
          ),
          if (register.openedByName != null || register.closedByName != null)
            Text(
              'Abrió: ${register.openedByName ?? '—'}   ·   Cerró: ${register.closedByName ?? '—'}',
              style: AppTextStyles.caption,
            ),
          if (register.closingDifference != null &&
              register.closingDifference != 0 &&
              register.differenceReason != null)
            Text(register.differenceReason!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final tileWidth = (constraints.maxWidth - spacing) / 2;

              final tiles = <Widget>[
                _StatTile(
                  width: tileWidth,
                  label: 'Caja inicial',
                  value: CurrencyFormatter.format(register.openingAmount),
                ),
                _StatTile(
                  width: tileWidth,
                  label: 'Esperado',
                  value: CurrencyFormatter.format(register.closingAmountExpected ?? 0),
                ),
                _StatTile(
                  width: tileWidth,
                  label: 'Contado',
                  value: CurrencyFormatter.format(register.closingAmountCounted ?? 0),
                ),
                if (register.closingDifference != null && register.closingDifference != 0)
                  _StatTile(
                    width: tileWidth,
                    label: 'Diferencia',
                    value: CurrencyFormatter.format(register.closingDifference!),
                    valueColor: AppColors.error,
                  ),
                serviciosAsync.when(
                  loading: () => _StatTile.loading(width: tileWidth, label: 'Servicios'),
                  error: (error, stack) => _StatTile.error(width: tileWidth, label: 'Servicios'),
                  data: (summary) => _StatTile(
                    width: tileWidth,
                    label: '${summary.count} servicio(s)',
                    value: CurrencyFormatter.format(summary.total),
                  ),
                ),
                settledAsync.when(
                  loading: () => _StatTile.loading(width: tileWidth, label: 'Comisión'),
                  error: (error, stack) => _StatTile.error(width: tileWidth, label: 'Comisión'),
                  data: (settlements) {
                    final total = settlements.fold<double>(0, (sum, s) => sum + s.commissionPaid);
                    return _StatTile(
                      width: tileWidth,
                      label: 'Comisión liquidada',
                      value: CurrencyFormatter.format(total),
                    );
                  },
                ),
                ...metodosAsync.when(
                  loading: () => [_StatTile.loading(width: tileWidth, label: 'Métodos de pago')],
                  error: (error, stack) => [_StatTile.error(width: tileWidth, label: 'Métodos de pago')],
                  data: (totals) {
                    if (totals.isEmpty) {
                      return [_StatTile(width: tileWidth, label: 'Métodos de pago', value: 'Nada cobrado')];
                    }
                    final byMethod = {for (final t in totals) t.method: t};
                    double grandTotal = 0;
                    final methodTiles = <Widget>[];
                    for (final entry in paymentMethodLabels.entries) {
                      final totalForMethod = byMethod[entry.key];
                      if (totalForMethod == null) continue;
                      grandTotal += totalForMethod.total;
                      methodTiles.add(_StatTile(
                        width: tileWidth,
                        label: '${entry.value} (${totalForMethod.count})',
                        value: CurrencyFormatter.format(totalForMethod.total),
                      ));
                    }
                    methodTiles.add(_StatTile(
                      width: tileWidth,
                      label: 'Total cobrado',
                      value: CurrencyFormatter.format(grandTotal),
                      valueColor: AppColors.primary,
                    ));
                    return methodTiles;
                  },
                ),
              ];

              return Wrap(spacing: spacing, runSpacing: spacing, children: tiles);
            },
          ),
        ],
      ),
    );
  }
}

/// Tarjetica pequeña estilo widget (etiqueta arriba, valor grande abajo).
class _StatTile extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({required this.width, required this.label, required this.value, this.valueColor});

  factory _StatTile.loading({required double width, required String label}) =>
      _StatTile(width: width, label: label, value: '…');

  factory _StatTile.error({required double width, required String label}) =>
      _StatTile(width: width, label: label, value: 'Error', valueColor: AppColors.error);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DetroitCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700, color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final AsyncValue<List<ServiceOrderEntity>> ordersAsync;
  final String emptyMessage;

  const _OrdersList({required this.ordersAsync, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return ordersAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(child: Text(emptyMessage, style: AppTextStyles.body2, textAlign: TextAlign.center));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _HistorialOrderCard(order: orders[index]),
        );
      },
    );
  }
}

class _HistorialOrderCard extends StatelessWidget {
  final ServiceOrderEntity order;

  const _HistorialOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return DetroitCard(
      accentColor: _statusColor(order.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.vehiclePlate ?? '—', style: AppTextStyles.heading4),
              const SizedBox(width: 8),
              Text(DateFormatter.formatTime(order.createdAt), style: AppTextStyles.caption),
              const Spacer(),
              Text(_statusLabel(order.status), style: AppTextStyles.caption.copyWith(color: _statusColor(order.status))),
            ],
          ),
          Text(order.customerName ?? '—', style: AppTextStyles.body2),
          if (order.serviceNames.isNotEmpty)
            Text(order.serviceNames.join(' + '), style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(order.finalPrice),
            style: AppTextStyles.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          if (order.status == 'paid' && order.paymentMethods.isNotEmpty)
            Text(
              order.paymentMethods.map((m) => paymentMethodLabels[m] ?? m).join(' + '),
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return 'Nueva';
      case 'finished':
        return 'Finalizada';
      case 'paid':
        return 'Pagada';
      case 'receivable':
        return 'Por cobrar';
      case 'cancelled':
        return 'Anulada';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return AppColors.statusNew;
      case 'finished':
        return AppColors.statusFinished;
      case 'paid':
        return AppColors.statusPaid;
      case 'receivable':
        return AppColors.statusReceivable;
      default:
        return AppColors.textMuted;
    }
  }
}
