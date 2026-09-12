import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../../domain/entities/service_category_entity.dart';
import '../../../domain/entities/service_entity.dart';
import '../../../domain/entities/vehicle_type_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/user_management_provider.dart';
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

    if (user == null || !(user.isAdminGeneral || user.isAdminPunto)) {
      return Scaffold(
        appBar: const DetroitAppBar(title: 'Configuración'),
        body: Center(
          child: Text(
            'Solo un administrador puede acceder a la configuración.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
        ),
      );
    }

    final tabs = [
      const Tab(text: 'Categorías'),
      const Tab(text: 'Servicios'),
      const Tab(text: 'Tipos de vehículo'),
      const Tab(text: 'Trabajadores'),
      if (user.isAdminGeneral) const Tab(text: 'Usuarios'),
    ];
    final tabViews = [
      const _ServiceCategoriesTab(),
      const _ServicesTab(),
      const _VehicleTypesTab(),
      const _EmployeesTab(),
      if (user.isAdminGeneral) const _UsersTab(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: tabViews,
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
              uppercase: true,
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
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return Scaffold(
      body: servicesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (services) {
          final categories = categoriesAsync.value ?? [];
          final vehicleTypes = vehicleTypesAsync.value ?? [];
          String categoryName(String? id) {
            final matches = categories.where((c) => c.id == id);
            return matches.isEmpty ? 'Sin categoría' : matches.first.name;
          }

          String priceSummary(ServiceEntity service) {
            if (service.pricesByVehicleType.isEmpty) return 'Sin precios configurados';
            return service.pricesByVehicleType.entries.map((entry) {
              final typeMatches = vehicleTypes.where((t) => t.id == entry.key);
              final typeName = typeMatches.isEmpty ? '?' : typeMatches.first.name;
              return '$typeName ${CurrencyFormatter.format(entry.value)}';
            }).join(' · ');
          }

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
                            '${priceSummary(service)} · Comisión ${service.commissionPct.toStringAsFixed(0)}%',
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
    final durationController = useTextEditingController(
      text: service?.estimatedDurationMin?.toString(),
    );
    final commissionController = useTextEditingController(
      text: (service?.commissionPct ?? 40.0).toStringAsFixed(0),
    );
    final selectedCategoryId = useState<String?>(service?.categoryId);
    final selectedVehicleTypeIds = useState<Set<String>>(service?.pricesByVehicleType.keys.toSet() ?? {});
    // Un controller de precio por cada tipo de vehículo, creado sobre la marcha.
    final priceControllers = useRef<Map<String, TextEditingController>>({});
    final isSaving = useState(false);

    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    TextEditingController priceControllerFor(String vehicleTypeId) {
      return priceControllers.value.putIfAbsent(
        vehicleTypeId,
        () => TextEditingController(
          text: service?.pricesByVehicleType[vehicleTypeId]?.toStringAsFixed(0),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(service == null ? 'Nuevo servicio' : 'Editar servicio'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DetroitTextField(
                  controller: nameController,
                  label: 'Nombre',
              uppercase: true,
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
                  child: Text(
                    'Selecciona los tipos de vehículo y su precio',
                    style: AppTextStyles.body2,
                  ),
                ),
                const SizedBox(height: 8),
                vehicleTypesAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (types) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
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
                      if (selectedVehicleTypeIds.value.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...selectedVehicleTypeIds.value.map((typeId) {
                          final type = types.firstWhere((t) => t.id == typeId);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DetroitTextField(
                              controller: priceControllerFor(typeId),
                              label: 'Precio para ${type.name}',
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  Validators.validateRequired(v) ?? Validators.validateAmount(v),
                            ),
                          );
                        }),
                      ],
                    ],
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
            if (selectedVehicleTypeIds.value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona al menos un tipo de vehículo')),
              );
              return;
            }
            if (!formKey.currentState!.validate()) return;
            isSaving.value = true;
            final repo = ref.read(serviceRepositoryProvider);
            final commissionPct = double.tryParse(commissionController.text.trim()) ?? 40.0;
            final durationMin = durationController.text.trim().isEmpty
                ? null
                : int.tryParse(durationController.text.trim());
            final prices = <String, double>{
              for (final typeId in selectedVehicleTypeIds.value)
                typeId: double.parse(
                  priceControllerFor(typeId).text.replaceAll(RegExp(r'[^0-9]'), ''),
                ),
            };

            final result = service == null
                ? await repo.create(
                    companyId: ref.read(authProvider).value!.companyId,
                    categoryId: selectedCategoryId.value,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    estimatedDurationMin: durationMin,
                    commissionPct: commissionPct,
                    pricesByVehicleType: prices,
                  )
                : await repo.update(
                    id: service!.id,
                    categoryId: selectedCategoryId.value,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    estimatedDurationMin: durationMin,
                    commissionPct: commissionPct,
                    pricesByVehicleType: prices,
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
              uppercase: true,
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

// ============================================================
// TRABAJADORES
// ============================================================

class _EmployeesTab extends ConsumerWidget {
  const _EmployeesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      body: employeesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (employees) => employees.isEmpty
            ? Center(child: Text('No hay trabajadores creados', style: AppTextStyles.body2))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: employees.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return DetroitCard(
                    accentColor: employee.isActive ? AppColors.success : AppColors.textDisabled,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.fullName, style: AppTextStyles.heading4),
                              if (employee.phone != null) Text(employee.phone!, style: AppTextStyles.body2),
                              Text(
                                'Comisión ${employee.commissionPct.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.textMuted),
                          onPressed: () => _showEmployeeDialog(context, ref, employee: employee),
                        ),
                        Switch(
                          value: employee.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) async {
                            await ref.read(employeeRepositoryProvider).toggleActive(id: employee.id, isActive: value);
                            ref.invalidate(employeesProvider);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo trabajador'),
      ),
    );
  }
}

void _showEmployeeDialog(BuildContext context, WidgetRef ref, {EmployeeEntity? employee}) {
  showDialog(
    context: context,
    builder: (context) => _EmployeeFormDialog(employee: employee),
  );
}

class _EmployeeFormDialog extends HookConsumerWidget {
  final EmployeeEntity? employee;

  const _EmployeeFormDialog({this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: employee?.fullName);
    final phoneController = useTextEditingController(text: employee?.phone);
    final commissionController = useTextEditingController(
      text: (employee?.commissionPct ?? 40.0).toStringAsFixed(0),
    );
    final isSaving = useState(false);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(employee == null ? 'Nuevo trabajador' : 'Editar trabajador'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DetroitTextField(
              controller: nameController,
              label: 'Nombre completo',
              uppercase: true,
              validator: Validators.validateRequired,
            ),
            const SizedBox(height: 16),
            DetroitTextField(
              controller: phoneController,
              label: 'Teléfono (opcional)',
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
            DetroitTextField(
              controller: commissionController,
              label: '% Comisión',
              keyboardType: TextInputType.number,
              validator: Validators.validateRequired,
            ),
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
            final repo = ref.read(employeeRepositoryProvider);
            final commissionPct = double.tryParse(commissionController.text.trim()) ?? 40.0;
            final result = employee == null
                ? await repo.create(
                    companyId: ref.read(authProvider).value!.companyId,
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    commissionPct: commissionPct,
                  )
                : await repo.update(
                    id: employee!.id,
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    commissionPct: commissionPct,
                  );
            isSaving.value = false;
            result.fold(
              (failure) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(failure.message))),
              (_) {
                ref.invalidate(employeesProvider);
                if (context.mounted) Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(companyUsersProvider);
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (users) => users.isEmpty
            ? Center(child: Text('No hay usuarios creados', style: AppTextStyles.body2))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isSelf = user.id == currentUser?.id;
                  return DetroitCard(
                    accentColor: user.isActive ? AppColors.success : AppColors.textDisabled,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.fullName, style: AppTextStyles.heading4),
                              if (user.email != null) Text(user.email!, style: AppTextStyles.body2),
                              Text(_roleLabel(user.roleName), style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Switch(
                          value: user.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: isSelf
                              ? null
                              : (value) async {
                                  await ref
                                      .read(userManagementRepositoryProvider)
                                      .toggleActive(id: user.id, isActive: value);
                                  ref.invalidate(companyUsersProvider);
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo usuario'),
      ),
    );
  }

  String _roleLabel(String roleName) {
    switch (roleName) {
      case 'admin_general':
        return 'Admin general';
      case 'admin_punto':
        return 'Admin de punto';
      case 'operador':
        return 'Operador';
      default:
        return roleName;
    }
  }
}

void _showCreateUserDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const _CreateUserDialog(),
  );
}

class _CreateUserDialog extends HookConsumerWidget {
  const _CreateUserDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final selectedRoleId = useState<String?>(null);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);
    final rolesAsync = ref.watch(availableRolesProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Nuevo usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              DetroitTextField(
                controller: nameController,
                label: 'Nombre completo',
                uppercase: true,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: emailController,
                label: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: phoneController,
                label: 'Teléfono (opcional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: passwordController,
                label: 'Contraseña inicial',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              rolesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error'),
                data: (roles) => DropdownButtonFormField<String>(
                  initialValue: selectedRoleId.value,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  dropdownColor: AppColors.surface2,
                  items: roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.label))).toList(),
                  onChanged: (value) => selectedRoleId.value = value,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        DetroitButton(
          text: 'CREAR',
          fullWidth: false,
          isLoading: isSaving.value,
          onPressed: () async {
            errorMessage.value = null;
            if (!formKey.currentState!.validate()) return;
            if (selectedRoleId.value == null) {
              errorMessage.value = 'Selecciona un rol.';
              return;
            }

            isSaving.value = true;
            final result = await ref.read(userManagementRepositoryProvider).createUser(
                  companyId: ref.read(authProvider).value!.companyId,
                  roleId: selectedRoleId.value!,
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                );
            isSaving.value = false;
            result.fold(
              (failure) => errorMessage.value = failure.message,
              (_) {
                ref.invalidate(companyUsersProvider);
                if (context.mounted) Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}
