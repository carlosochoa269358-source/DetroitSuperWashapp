import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/debounce_hook.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';

class ClientesListPage extends HookConsumerWidget {
  const ClientesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState<String?>(null);

    useDebouncedTextListener(searchController, (text) {
      query.value = text.trim().isEmpty ? null : text.trim();
    });

    final customersAsync = ref.watch(customerSearchProvider(query.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, teléfono o placa',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: customersAsync.when(
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(
                child: Text('Error: $error', style: AppTextStyles.body2.copyWith(color: AppColors.error)),
              ),
              data: (customers) {
                if (customers.isEmpty) {
                  return Center(
                    child: Text('No se encontraron clientes', style: AppTextStyles.body2),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push(AppRoutes.clienteDetalleFor(customer.id)),
                      child: DetroitCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer.fullName, style: AppTextStyles.heading4),
                                  const SizedBox(height: 4),
                                  Text(customer.phone, style: AppTextStyles.body2),
                                ],
                              ),
                            ),
                            if (customer.visitCount > 0)
                              Text('${customer.visitCount} visitas', style: AppTextStyles.caption),
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.clienteNuevo),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cliente'),
      ),
    );
  }
}
