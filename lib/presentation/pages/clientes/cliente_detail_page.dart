import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/customer_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';

class ClienteDetailPage extends ConsumerWidget {
  final String customerId;

  const ClienteDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final vehiclesAsync = ref.watch(vehiclesByCustomerProvider(customerId));

    return Scaffold(
      appBar: DetroitAppBar(title: 'Cliente'),
      body: customerAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
        ),
        data: (customer) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(customer.fullName, style: AppTextStyles.heading3),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () => context.push(
                              AppRoutes.clienteEditarFor(customer.id),
                              extra: customer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(customer.phone, style: AppTextStyles.body2),
                      if (customer.email != null) Text(customer.email!, style: AppTextStyles.body2),
                      if (customer.notes != null) ...[
                        const SizedBox(height: 8),
                        Text(customer.notes!, style: AppTextStyles.caption),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Stat(label: 'Visitas', value: '${customer.visitCount}'),
                          _Stat(label: 'Total histórico', value: CurrencyFormatter.format(customer.totalSpent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vehículos', style: AppTextStyles.heading4),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.vehiculoNuevo, extra: customer.id),
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text('Agregar vehículo', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                vehiclesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LoadingWidget(),
                  ),
                  error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return Text('Este cliente aún no tiene vehículos registrados', style: AppTextStyles.body2);
                    }
                    return Column(
                      children: vehicles
                          .map((vehicle) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => context.push(
                                    AppRoutes.vehiculoEditarFor(vehicle.id),
                                    extra: vehicle,
                                  ),
                                  child: DetroitCard(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(vehicle.plate, style: AppTextStyles.heading4),
                                              const SizedBox(height: 4),
                                              Text(
                                                [vehicle.brand, vehicle.model, vehicle.color]
                                                    .where((e) => e != null && e.isNotEmpty)
                                                    .join(' · '),
                                                style: AppTextStyles.body2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: AppColors.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.heading4),
      ],
    );
  }
}
