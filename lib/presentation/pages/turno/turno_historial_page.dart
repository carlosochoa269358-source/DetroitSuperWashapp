import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/cash_register_entity.dart';
import '../../providers/cash_register_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';

class TurnoHistorialPage extends ConsumerWidget {
  const TurnoHistorialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(closedCashRegistersProvider);

    return Scaffold(
      appBar: const DetroitAppBar(title: 'Historial de turnos'),
      body: historyAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
        ),
        data: (registers) {
          if (registers.isEmpty) {
            return Center(
              child: Text('Todavía no hay turnos cerrados.', style: AppTextStyles.body2),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: registers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _TurnoCard(register: registers[index]),
          );
        },
      ),
    );
  }
}

class _TurnoCard extends StatelessWidget {
  final CashRegisterEntity register;

  const _TurnoCard({required this.register});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(AppRoutes.turnoHistorialDetalleFor(register.id), extra: register),
      child: DetroitCard(
        accentColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Turno #${register.id.substring(0, 5)}', style: AppTextStyles.heading4),
                if (register.closingDifference != null && register.closingDifference != 0)
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              ],
            ),
            const SizedBox(height: 4),
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
                Text('Caja esperada / contada', style: AppTextStyles.caption),
                Text(
                  '${CurrencyFormatter.format(register.closingAmountExpected ?? 0)} / ${CurrencyFormatter.format(register.closingAmountCounted ?? 0)}',
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
