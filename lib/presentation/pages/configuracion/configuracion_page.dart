import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/service_category_entity.dart';
import '../../../domain/entities/service_entity.dart';
import '../../../domain/entities/vehicle_type_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class ConfiguracionPage extends ConsumerWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    if (user == null || !user.isAdminGeneral) {
      return Scaffold(
        appBar: const DetroitAppBar(title: 'Configuración'),
        body: Center(
          child: Text(
            'Solo el Administrador General puede acceder a la configuración.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Categorías'),
              Tab(text: 'Servicios'),
              Tab(text: 'Tipos de vehículo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ServiceCategoriesTab(),
            _ServicesTab(),
            _VehicleTypesTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORÍAS DE SERVICIO
// ============================================================

class _ServiceCategoriesTab extends ConsumerWidget {
  const _ServiceCategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (categories) => categories.isEmpty
            ? Center(child: Text('No hay categorías creadas', style: AppTextStyles.body2))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return DetroitCard(
                    accentColor: category.isActive ? AppColors.success : AppColors.textDisabled,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.name, style: AppTextStyles.heading4),
                              if (category.description != null)
                                Text(category.description!, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.textMuted),
                          onPressed: () => _showCategoryDialog(context, ref, category: category),
                        ),
                        Switch(
                          value: category.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) async {
                            await ref
                                .read(serviceCategoryRepositoryProvider)
                                .toggleActive(id: category.id, isActive: value);
                            ref.invalidate(serviceCategoriesProvider);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría'),
      ),
    );
  }
}

void _showCategoryDialog(BuildContext context, WidgetRef ref, {ServiceCategoryEntity? category}) {
  showDialog(
    context: context,
    builder: (context) => _CategoryFormDialog(category: category),
  );
}

class _CategoryFormDialog extends HookConsumerWidget {
  final ServiceCategoryEntity? category;

  const _CategoryFormDialog({this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: category?.name);
    final descController = useTextEditingController(text: category?.description);
    final isSaving = useState(false);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(category == null ? 'Nueva categoría' : 'Editar categoría'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DetroitTextField(
              controller: nameController,
              label: 'Nombre',
              validator: Validators.validateRequired,
            ),
            const SizedBox(height: 16),
            DetroitTextField(controller: descController, label: 'Descripción (opcional)'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        DetroitButton(
          text: 'GUARDAR',
          fullWidth: false,
          isLoading: isSaving.value,
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            isSaving.value = true;
            final repo = ref.read(serviceCategoryRepositoryProvider);
            final result = category == null
                ? await repo.create(
                    companyId: ref.read(authProvider).value!.companyId,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  )
                : await repo.update(
                    id: category!.id,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    colorHex: category!.colorHex,
                    sortOrder: category!.sortOrder,
                  );
            isSaving.value = false;
            result.fold(
              (failure) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(failure.message))),
              (_) {
                ref.invalidate(serviceCategoriesProvider);
                if (context.mounted) Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// SERVICIOS
// ============================================================

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      body: servicesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (services) {
          final categories = categoriesAsync.value ?? [];
          String categoryName(String? id) =>
              categories.firstWhere((c) => c.id == id, orElse: () => ServiceCategoryEntity(
                    id: '',
                    companyId: '',
                    name: 'Sin categoría',
                    sortOrder: 0,
                    isActive: true,
                  )).name;

          if (services.isEmpty) {
            return Center(child: Text('No hay servicios creados', style: AppTextStyles.body2));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final service = services[index];
              return DetroitCard(
                accentColor: service.isActive ? AppColors.success : AppColors.textDisabled,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.name, style: AppTextStyles.heading4),
                          Text(categoryName(service.categoryId), style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.format(service.basePrice)} · Comisión ${service.commissionPct.toStringAsFixed(0)}%',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.textMuted),
                      onPressed: () => _showServiceDialog(context, ref, service: service),
                    ),
                    Switch(
                      value: service.isActive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) async {
                        await ref.read(serviceRepositoryProvider).toggleActive(id: service.id, isActive: value);
                        ref.invalidate(servicesProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo servicio'),
      ),
    );
  }
}

void _showServiceDialog(BuildContext context, WidgetRef ref, {ServiceEntity? service}) {
  showDialog(
    context: context,
    builder: (context) => _ServiceFormDialog(service: service),
  );
}

class _ServiceFormDialog extends HookConsumerWidget {
  final ServiceEntity? service;

  const _ServiceFormDialog({this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: service?.name);
    final descController = useTextEditingController(text: service?.description);
    final priceController = useTextEditingController(
      text: service?.basePrice.toStringAsFixed(0),
    );
    final durationController = useTextEditingController(
      text: service?.estimatedDurationMin?.toString(),
    );
    final commissionController = useTextEditingController(
      text: (service?.commissionPct ?? 40.0).toStringAsFixed(0),
    );
    final selectedCategoryId = useState<String?>(service?.categoryId);
    final selectedVehicleTypeIds = useState<Set<String>>(service?.applicableVehicleTypeIds.toSet() ?? {});
    final isSaving = useState(false);

    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(service == null ? 'Nuevo servicio' : 'Editar servicio'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DetroitTextField(
                  controller: nameController,
                  label: 'Nombre',
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),
                DetroitTextField(controller: descController, label: 'Descripción (opcional)'),
                const SizedBox(height: 16),
                categoriesAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (categories) => DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId.value,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: AppColors.surface2,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) => selectedCategoryId.value = value,
                  ),
                ),
                const SizedBox(height: 16),
                DetroitTextField(
                  controller: priceController,
                  label: 'Precio base',
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.validateRequired(v) ?? Validators.validateAmount(v),
                ),
                const SizedBox(height: 16),
                DetroitTextField(
                  controller: commissionController,
                  label: '% Comisión trabajador',
                  keyboardType: TextInputType.number,
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),
                DetroitTextField(
                  controller: durationController,
                  label: 'Duración estimada en minutos (opcional)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Tipos de vehículo aplicables', style: AppTextStyles.body2),
                ),
                const SizedBox(height: 8),
                vehicleTypesAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (types) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: types.map((type) {
                      final selected = selectedVehicleTypeIds.value.contains(type.id);
                      return FilterChip(
                        label: Text(type.name),
                        selected: selected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.3),
                        onSelected: (value) {
                          final updated = Set<String>.from(selectedVehicleTypeIds.value);
                          if (value) {
                            updated.add(type.id);
                          } else {
                            updated.remove(type.id);
                          }
                          selectedVehicleTypeIds.value = updated;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        DetroitButton(
          text: 'GUARDAR',
          fullWidth: false,
          isLoading: isSaving.value,
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            isSaving.value = true;
            final repo = ref.read(serviceRepositoryProvider);
            final basePrice = Validators.validateAmount(priceController.text) == null
                ? double.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''))
                : 0.0;
            final commissionPct = double.tryParse(commissionController.text.trim()) ?? 40.0;
            final durationMin = durationController.text.trim().isEmpty
                ? null
                : int.tryParse(durationController.text.trim());

            final result = service == null
                ? await repo.create(
                    companyId: ref.read(authProvider).value!.companyId,
                    categoryId: selectedCategoryId.value,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    basePrice: basePrice,
                    estimatedDurationMin: durationMin,
                    commissionPct: commissionPct,
                    applicableVehicleTypeIds: selectedVehicleTypeIds.value.toList(),
                  )
                : await repo.update(
                    id: service!.id,
                    categoryId: selectedCategoryId.value,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    basePrice: basePrice,
                    estimatedDurationMin: durationMin,
                    commissionPct: commissionPct,
                    applicableVehicleTypeIds: selectedVehicleTypeIds.value.toList(),
                  );
            isSaving.value = false;
            result.fold(
              (failure) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(failure.message))),
              (_) {
                ref.invalidate(servicesProvider);
                if (context.mounted) Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// TIPOS DE VEHÍCULO
// ============================================================

class _VehicleTypesTab extends ConsumerWidget {
  const _VehicleTypesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(vehicleTypesProvider);

    return Scaffold(
      body: typesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (types) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: types.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final type = types[index];
            return DetroitCard(
              accentColor: type.isActive ? AppColors.success : AppColors.textDisabled,
              child: Row(
                children: [
                  Expanded(child: Text(type.name, style: AppTextStyles.heading4)),
                  if (type.companyId == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('Global', style: AppTextStyles.caption),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.textMuted),
                    onPressed: () => _showVehicleTypeDialog(context, ref, vehicleType: type),
                  ),
                  Switch(
                    value: type.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) async {
                      await ref.read(vehicleTypeRepositoryProvider).toggleActive(id: type.id, isActive: value);
                      ref.invalidate(vehicleTypesProvider);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVehicleTypeDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tipo'),
      ),
    );
  }
}

void _showVehicleTypeDialog(BuildContext context, WidgetRef ref, {VehicleTypeEntity? vehicleType}) {
  showDialog(
    context: context,
    builder: (context) => _VehicleTypeFormDialog(vehicleType: vehicleType),
  );
}

class _VehicleTypeFormDialog extends HookConsumerWidget {
  final VehicleTypeEntity? vehicleType;

  const _VehicleTypeFormDialog({this.vehicleType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: vehicleType?.name);
    final isSaving = useState(false);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(vehicleType == null ? 'Nuevo tipo de vehículo' : 'Editar tipo de vehículo'),
      content: Form(
        key: formKey,
        child: DetroitTextField(
          controller: nameController,
          label: 'Nombre',
          validator: Validators.validateRequired,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        DetroitButton(
          text: 'GUARDAR',
          fullWidth: false,
          isLoading: isSaving.value,
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            isSaving.value = true;
            final repo = ref.read(vehicleTypeRepositoryProvider);
            final result = vehicleType == null
                ? await repo.create(
                    companyId: ref.read(authProvider).value!.companyId,
                    name: nameController.text.trim(),
                  )
                : await repo.update(
                    id: vehicleType!.id,
                    name: nameController.text.trim(),
                    sortOrder: vehicleType!.sortOrder,
                  );
            isSaving.value = false;
            result.fold(
              (failure) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(failure.message))),
              (_) {
                ref.invalidate(vehicleTypesProvider);
                if (context.mounted) Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}
