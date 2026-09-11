import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/debounce_hook.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';

class BuscarPlacaPage extends HookConsumerWidget {
  const BuscarPlacaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState<String?>(null);

    useDebouncedTextListener(searchController, (text) {
      query.value = text.trim().isEmpty ? null : text.trim();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar por placa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Escribe cualquier parte de la placa',
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
            child: query.value == null
                ? Center(
                    child: Text('Escribe para buscar', style: AppTextStyles.body2),
                  )
                : _SearchResults(query: query.value!),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleSearchByPlateProvider(query));

    return vehiclesAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return Center(
            child: Text('No se encontró ningún vehículo con "$query"', style: AppTextStyles.body2),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vehicles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _VehicleResultCard(vehicle: vehicles[index]),
        );
      },
    );
  }
}

class _VehicleResultCard extends StatelessWidget {
  final VehicleEntity vehicle;

  const _VehicleResultCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(AppRoutes.clienteDetalleFor(vehicle.customerId)),
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
    );
  }
}
