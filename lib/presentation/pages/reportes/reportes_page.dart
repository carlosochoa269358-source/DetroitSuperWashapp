import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../operacion/pago_modal.dart' show paymentMethodLabels;

/// Cuerpo de la pestaña "Reportes". No trae su propio Scaffold/AppBar — lo
/// provee DashboardPage. Solo admin general (información financiera sensible).
class ReportesTab extends HookConsumerWidget {
  const ReportesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    if (user == null || !user.isAdminGeneral) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Solo el Administrador General puede ver los reportes.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
        ),
      );
    }

    final selectedPeriod = useState<String>('hoy');
    final customRange = useState<DateTimeRange?>(null);
    final today = DateFormatter.todayBogota();

    late final DateTime fromDate;
    late final DateTime toDate;
    switch (selectedPeriod.value) {
      case 'semana':
        fromDate = today.subtract(Duration(days: today.weekday - 1));
        toDate = today;
      case 'mes':
        fromDate = DateTime(today.year, today.month, 1);
        toDate = today;
      case 'personalizado':
        fromDate = customRange.value?.start ?? today;
        toDate = customRange.value?.end ?? today;
      default:
        fromDate = today;
        toDate = today;
    }

    final reportAsync = ref.watch(profitReportProvider(fromDate, toDate));

    Future<void> pickCustomRange() async {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(today.year - 2),
        lastDate: today,
        initialDateRange: customRange.value ?? DateTimeRange(start: today, end: today),
      );
      if (range != null) {
        customRange.value = range;
        selectedPeriod.value = 'personalizado';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Hoy'),
                selected: selectedPeriod.value == 'hoy',
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => selectedPeriod.value = 'hoy',
              ),
              ChoiceChip(
                label: const Text('Esta semana'),
                selected: selectedPeriod.value == 'semana',
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => selectedPeriod.value = 'semana',
              ),
              ChoiceChip(
                label: const Text('Este mes'),
                selected: selectedPeriod.value == 'mes',
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => selectedPeriod.value = 'mes',
              ),
              ChoiceChip(
                label: const Text('Personalizado'),
                selected: selectedPeriod.value == 'personalizado',
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => pickCustomRange(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormatter.formatDate(fromDate)} — ${DateFormatter.formatDate(toDate)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          reportAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (report) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen del período', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      _ReportRow(label: 'Ventas totales', value: CurrencyFormatter.format(report.totalSales)),
                      _ReportRow(
                        label: 'Comisiones pagadas',
                        value: '-${CurrencyFormatter.format(report.totalCommissions)}',
                        isNegative: true,
                      ),
                      _ReportRow(
                        label: 'Gastos',
                        value: '-${CurrencyFormatter.format(report.totalExpenses)}',
                        isNegative: true,
                      ),
                      const Divider(color: AppColors.divider),
                      _ReportRow(
                        label: 'Utilidad neta',
                        value: CurrencyFormatter.format(report.netProfit),
                        isTotal: true,
                        isNegative: report.netProfit < 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ventas por método de pago', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      if (report.salesByMethod.isEmpty)
                        Text('Sin ventas en este período.', style: AppTextStyles.body2)
                      else
                        for (final entry in report.salesByMethod)
                          _ReportRow(
                            label: '${paymentMethodLabels[entry.method] ?? entry.method} (${entry.count})',
                            value: CurrencyFormatter.format(entry.total),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gastos por categoría', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      if (report.expensesByCategory.isEmpty)
                        Text('Sin gastos en este período.', style: AppTextStyles.body2)
                      else
                        for (final entry in report.expensesByCategory)
                          _ReportRow(label: entry.categoryName, value: CurrencyFormatter.format(entry.amount)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isNegative;

  const _ReportRow({required this.label, required this.value, this.isTotal = false, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    final color = isNegative ? AppColors.error : (isTotal ? AppColors.primary : null);
    final style = isTotal
        ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700, color: color)
        : AppTextStyles.body2.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
