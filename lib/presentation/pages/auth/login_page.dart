import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_text_field.dart';

const _rememberedEmailKey = 'remembered_email';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final rememberMe = useState(false);

    useEffect(() {
      SharedPreferences.getInstance().then((prefs) {
        final saved = prefs.getString(_rememberedEmailKey);
        if (saved != null && saved.isNotEmpty) {
          emailController.text = saved;
          rememberMe.value = true;
        }
      });
      return null;
    }, const []);

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_background.jpg', fit: BoxFit.cover),
          // Oscurece el tercio inferior (donde va la tarjeta) para que el
          // formulario se lea bien sin importar qué haya detrás en la foto.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent, Color(0xE6000000)],
                stops: [0.0, 0.38, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/logo.png', width: 190),
                        const SizedBox(height: 8),
                        Text(
                          'Tu vehículo, nuestra pasión',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _LoginGlassCard(
                          formKey: formKey,
                          emailController: emailController,
                          passwordController: passwordController,
                          rememberMe: rememberMe,
                          authState: authState,
                          onSubmit: () async {
                            if (formKey.currentState!.validate()) {
                              final prefs = await SharedPreferences.getInstance();
                              if (rememberMe.value) {
                                await prefs.setString(_rememberedEmailKey, emailController.text.trim());
                              } else {
                                await prefs.remove(_rememberedEmailKey);
                              }
                              if (context.mounted) {
                                ref.read(authProvider.notifier).signIn(
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        const _FeatureRow(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginGlassCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> rememberMe;
  final AsyncValue<dynamic> authState;
  final VoidCallback onSubmit;

  const _LoginGlassCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.authState,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authState.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      authState.error.toString(),
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                DetroitTextField(
                  controller: emailController,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                DetroitTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  isPassword: true,
                  validator: Validators.validateRequired,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe.value,
                      activeColor: AppColors.primary,
                      onChanged: (value) => rememberMe.value = value ?? false,
                    ),
                    Text('Recordar mi usuario', style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 8),
                DetroitButton(
                  text: 'INICIAR SESIÓN',
                  isLoading: authState.isLoading,
                  onPressed: onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FeatureItem(icon: Icons.verified_user_outlined, label: 'TU VEHÍCULO\nEN BUENAS MANOS'),
        _FeatureItem(icon: Icons.water_drop_outlined, label: 'CALIDAD\nEN CADA SERVICIO'),
        _FeatureItem(icon: Icons.star_border_rounded, label: 'EXPERIENCIA\nQUE SE NOTA'),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
