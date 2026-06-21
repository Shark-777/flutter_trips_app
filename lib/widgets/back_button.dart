import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Кнопка "Назад" - еле заметный фиолетовый фон с серым текстом
class AppBackButton extends StatelessWidget {
  final String? customRoute;
  final VoidCallback? onPressed;
  
  const AppBackButton({
    super.key,
    this.customRoute,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: onPressed ?? () {
            if (customRoute != null) {
              context.go(customRoute!);
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Назад',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
