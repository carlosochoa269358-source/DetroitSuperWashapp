import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DetroitAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final String? userName;

  const DetroitAppBar({
    super.key,
    required this.title,
    this.onLogout,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
      actions: [
        if (userName != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(userName!, style: AppTextStyles.body2),
            ),
          ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: onLogout,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.primary,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
