import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_text_field.dart';

class ClienteFormPage extends HookConsumerWidget {
  final CustomerEntity? customer;

  const ClienteFormPage({super.key, this.customer});

  bool get isEditing => customer != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: customer?.fullName);
    final phoneController = useTextEditingController(text: customer?.phone);
    final emailController = useTextEditingController(text: customer?.email);
    final notesController = useTextEditingController(text: customer?.notes);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    final currentUser = ref.watch(authProvider).value;
    final canDelete = isEditing && (currentUser?.isAdminGeneral ?? false);

    Future<void> deleteCustomer() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('¿Eliminar cliente?'),
          content: Text(
            'Se eliminará a ${customer!.fullName} y dejará de aparecer en la lista de clientes. Si tiene vehículos o historial de servicios, en vez de borrarse se ocultará por completo.',
          ),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      isSaving.value = true;
      final result = await ref.read(customerRepositoryProvider).delete(customer!.id);
      isSaving.value = false;
      if (!context.mounted) return;

      ref.invalidate(customerSearchProvider);
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (hardDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hardDeleted
                    ? 'Cliente eliminado'
                    : 'Este cliente tiene historial: se ocultó en lugar de borrarse',
              ),
            ),
          );
          // Cierra este formulario Y la ficha del cliente (ya eliminado), en
          // vez de context.go() — eso reemplazaba toda la pila de navegación
          // y dejaba a la lista de Clientes sin flecha para volver atrás.
          Navigator.of(context)
            ..pop()
            ..pop();
        },
      );
    }

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      isSaving.value = true;
      errorMessage.value = null;

      final repo = ref.read(customerRepositoryProvider);
      final result = isEditing
          ? await repo.update(
              id: customer!.id,
              fullName: nameController.text.trim(),
              phone: phoneController.text.trim(),
              email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            )
          : await repo.create(
              companyId: ref.read(authProvider).value!.companyId,
              fullName: nameController.text.trim(),
              phone: phoneController.text.trim(),
              email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            );

      isSaving.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (savedCustomer) {
          ref.invalidate(customerSearchProvider);
          if (isEditing) ref.invalidate(customerByIdProvider(customer!.id));
          if (context.mounted) context.pop(savedCustomer);
        },
      );
    }

    return Scaffold(
      appBar: DetroitAppBar(title: isEditing ? 'Editar cliente' : 'Nuevo cliente'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
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
              DetroitTextField(
                controller: nameController,
                label: 'Nombre completo',
                uppercase: true,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: phoneController,
                label: 'Teléfono',
                hint: '3001234567',
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.validateRequired(v) ?? Validators.validatePhone(v),
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: emailController,
                label: 'Correo electrónico (opcional)',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: notesController,
                label: 'Observaciones (opcional)',
              ),
              const SizedBox(height: 32),
              DetroitButton(
                text: isEditing ? 'GUARDAR CAMBIOS' : 'CREAR CLIENTE',
                isLoading: isSaving.value,
                onPressed: save,
              ),
              if (canDelete) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: isSaving.value ? null : deleteCustomer,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  label: const Text('Eliminar cliente', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
