import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/constants/app_colors.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class DetroitTextField extends HookWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final bool uppercase;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const DetroitTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.uppercase = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final obscureText = useState(isPassword);

    return TextFormField(
      controller: controller,
      obscureText: obscureText.value,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
      inputFormatters: uppercase ? [_UpperCaseTextFormatter()] : null,
      style: const TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText.value ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  obscureText.value = !obscureText.value;
                },
              )
            : null,
      ),
    );
  }
}
