import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/service_order_item_entity.dart';
import '../../providers/accounts_receivable_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_order_item_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'pago_modal.dart';
import 'service_picker_field.dart';

class OrdenDetallePage extends HookConsumerWidget {
  final String orderId;
  final String vehicleTypeId;

  const OrdenDetallePage({super.key, required this.orderId, required this.vehicleTypeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(serviceOrderByIdProvider(orderId));
    final itemsAsync = ref.watch(serviceOrderItemsProvider(orderId));
    final showAddService = useState(false);
    final newSelection = useState<ServiceSelection?>(null);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> agregarServicio() async {
      if (newSelection.value == null) return;
      isSaving.value = true;
      final result = await ref.read(serviceOrderItemRepositoryProvider).create(
            serviceOrderId: orderId,
            serviceId: newSelection.value!.service.id,
            basePrice: newSelection.value!.basePrice,
            discountAmount: newSelection.value!.discountAmount,
            commissionPct: newSelection.value!.service.commissionPct,
          );
      isSaving.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          showAddService.value = false;
          newSelection.value = null;
          ref.invalidate(serviceOrderItemsProvider(orderId));
          ref.invalidate(serviceOrderByIdProvider(orderId));
          ref.invalidate(serviceOrdersByStatusProvider('new'));
        },
      );
    }

    Future<void> editarPrecio(ServiceOrderItemEntity item) async {
      final priceController = TextEditingController(text: item.finalPrice.toStringAsFixed(0));
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Editar precio — ${item.serviceName ?? ''}'),
          content: DetroitTextField(
            controller: priceController,
            label: 'Precio a cobrar',
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final newPrice = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (newPrice == null || newPrice <= 0) {
        errorMessage.value = 'El precio debe ser mayor a cero.';
        return;
      }

      final result = await ref.read(serviceOrderItemRepositoryProvider).updatePrice(
            itemId: item.id,
            basePrice: item.basePrice,
            commissionPct: item.commissionPct,
            newFinalPrice: newPrice,
          );
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          ref.invalidate(serviceOrderItemsProvider(orderId));
          ref.invalidate(serviceOrderByIdProvider(orderId));
          ref.invalidate(serviceOrdersByStatusProvider('new'));
        },
      );
    }

    Future<void> quitarServicio(String itemId) async {
      final result = await ref.read(serviceOrderItemRepositoryProvider).delete(itemId);
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          ref.invalidate(serviceOrderItemsProvider(orderId));
          ref.invalidate(serviceOrderByIdProvider(orderId));
          ref.invalidate(serviceOrdersByStatusProvider('new'));
        },
      );
    }

    Future<void> anularOrden() async {
      final reasonController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Anular orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta orden no se borra, queda registrada como anulada.',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: reasonController,
                label: 'Motivo de la anulación',
                validator: Validators.validateRequired,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('ANULAR', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final user = ref.read(authProvider).value;
      if (user == null) return;
      final result = await ref.read(serviceOrderRepositoryProvider).cancel(
            orderId: orderId,
            cancelledBy: user.id,
            reason: reasonController.text.trim(),
          );
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          ref.invalidate(serviceOrdersByStatusProvider('new'));
          ref.invalidate(serviceOrdersByStatusProvider('finished'));
          ref.invalidate(serviceOrdersByStatusProvider('paid'));
          ref.invalidate(openAccountsReceivableProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      appBar: const DetroitAppBar(title: 'Detalle de la orden'),
      body: orderAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: AppColors.error))),
        data: (order) {
          final isEditable = order.status == 'new';
          final user = ref.watch(authProvider).value;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage.value != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(errorMessage.value!, style: const TextStyle(color: AppColors.error)),
                  ),
                  const SizedBox(height: 16),
                ],
                DetroitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.vehiclePlate ?? '—', style: AppTextStyles.heading3),
                          if (!isEditable) Text(_statusLabel(order.status), style: AppTextStyles.caption),
                        ],
                      ),
                      Text(order.customerName ?? '—', style: AppTextStyles.body2),
                      if (order.workerName != null)
                        Text('Lavador: ${order.workerName}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Servicios', style: AppTextStyles.heading4),
                const SizedBox(height: 8),
                itemsAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                  data: (items) => Column(
                    children: items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: DetroitCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.serviceName ?? '—', style: AppTextStyles.body1),
                                    ),
                                    Text(CurrencyFormatter.format(item.finalPrice), style: AppTextStyles.body1),
                                    if (isEditable) ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
                                        tooltip: 'Editar precio',
                                        onPressed: () => editarPrecio(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () => quitarServicio(item.id),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(height: 8),
                  if (!showAddService.value)
                    TextButton.icon(
                      onPressed: () => showAddService.value = true,
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text('Agregar servicio', style: TextStyle(color: AppColors.primary)),
                    )
                  else
                    DetroitCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ServicePickerField(
                            vehicleTypeId: vehicleTypeId,
                            onChanged: (value) => newSelection.value = value,
                          ),
                          const SizedBox(height: 16),
                          DetroitButton(
                            text: 'AGREGAR',
                            fullWidth: false,
                            isLoading: isSaving.value,
                            onPressed: newSelection.value == null ? null : agregarServicio,
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.heading4),
                      Text(
                        CurrencyFormatter.format(order.finalPrice),
                        style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(height: 24),
                  DetroitButton(
                    text: 'FINALIZAR SERVICIO',
                    onPressed: () async {
                      await ref.read(serviceOrderRepositoryProvider).finalize(order.id);
                      ref.invalidate(serviceOrdersByStatusProvider('new'));
                      ref.invalidate(serviceOrdersByStatusProvider('finished'));
                      ref.invalidate(serviceOrderByIdProvider(orderId));
                      if (context.mounted) showPagoModal(context, ref, order);
                    },
                  ),
                ],
                if (order.status != 'cancelled' && (user?.isAdminGeneral ?? false)) ...[
                  const SizedBox(height: 12),
                  DetroitButton(
                    text: 'ANULAR ORDEN',
                    type: DetroitButtonType.danger,
                    onPressed: anularOrden,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
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
}
