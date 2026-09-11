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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.png', width: 200),
                  const SizedBox(height: 32),
                  if (authState.hasError) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
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
                    label: 'Correo Electrónico',
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  DetroitTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    isPassword: true,
                    validator: Validators.validateRequired,
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
                  const SizedBox(height: 16),
                  DetroitButton(
                    text: 'INICIAR SESIÓN',
                    isLoading: authState.isLoading,
                    onPressed: () async {
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
