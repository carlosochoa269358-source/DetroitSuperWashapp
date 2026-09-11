import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/cash_register_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';

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
            _TurnoSummaryCard(register: register),
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

class _TurnoSummaryCard extends StatelessWidget {
  final CashRegisterEntity register;

  const _TurnoSummaryCard({required this.register});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DetroitCard(
        accentColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apertura: ${DateFormatter.formatDateTime(register.openedAt)}',
              style: AppTextStyles.body2,
            ),
            Text(
              'Cierre: ${register.closedAt != null ? DateFormatter.formatDateTime(register.closedAt!) : '—'}',
              style: AppTextStyles.body2,
            ),
            if (register.openedByName != null || register.closedByName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Abrió: ${register.openedByName ?? '—'}  ·  Cerró: ${register.closedByName ?? '—'}',
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Caja inicial', style: AppTextStyles.caption),
                Text(CurrencyFormatter.format(register.openingAmount), style: AppTextStyles.body2),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Esperado / Contado', style: AppTextStyles.caption),
                Text(
                  '${CurrencyFormatter.format(register.closingAmountExpected ?? 0)} / ${CurrencyFormatter.format(register.closingAmountCounted ?? 0)}',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
            if (register.closingDifference != null && register.closingDifference != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Diferencia', style: AppTextStyles.caption),
                  Text(
                    CurrencyFormatter.format(register.closingDifference!),
                    style: AppTextStyles.body2.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              if (register.differenceReason != null)
                Text(register.differenceReason!, style: AppTextStyles.caption),
            ],
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
