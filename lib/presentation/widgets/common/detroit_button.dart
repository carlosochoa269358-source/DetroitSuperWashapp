import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum DetroitButtonType { primary, secondary, danger }

class DetroitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final DetroitButtonType type;
  final bool fullWidth;

  const DetroitButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = DetroitButtonType.primary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    switch (type) {
      case DetroitButtonType.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.background;
        break;
      case DetroitButtonType.secondary:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        break;
      case DetroitButtonType.danger:
        bgColor = AppColors.error;
        fgColor = AppColors.onBackground;
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Text(
            text,
            style: AppTextStyles.label.copyWith(color: fgColor),
          );

    Widget button;
    if (type == DetroitButtonType.secondary) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        ),
        child: content,
      );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
