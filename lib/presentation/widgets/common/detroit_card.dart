import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DetroitCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const DetroitCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: accentColor != null 
            ? Border(left: BorderSide(color: accentColor!, width: 4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
