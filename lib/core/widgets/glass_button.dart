import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum GlassButtonVariant {
  primaryGold,
  primaryWine,
  frosted,
  outline,
  whatsapp,
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final GlassButtonVariant variant;
  final double? width;
  final double height;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = GlassButtonVariant.primaryGold,
    this.width,
    this.height = 50.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Gradient? gradient;
    Color? backgroundColor;
    Color textColor = Colors.white;
    Border? border;

    switch (variant) {
      case GlassButtonVariant.primaryGold:
        gradient = AppColors.goldGradient;
        textColor = const Color(0xFF2A1502);
        break;
      case GlassButtonVariant.primaryWine:
        gradient = AppColors.wineGradient;
        textColor = Colors.white;
        break;
      case GlassButtonVariant.whatsapp:
        backgroundColor = AppColors.whatsappGreen;
        textColor = Colors.white;
        break;
      case GlassButtonVariant.frosted:
        backgroundColor = AppColors.glassWhiteStrong;
        border = Border.all(color: AppColors.glassBorderGold, width: 1.2);
        textColor = AppColors.goldLight;
        break;
      case GlassButtonVariant.outline:
        backgroundColor = Colors.transparent;
        border = Border.all(color: AppColors.goldPrimary, width: 1.5);
        textColor = AppColors.goldPrimary;
        break;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (variant == GlassButtonVariant.primaryGold)
            BoxShadow(
              color: AppColors.goldPrimary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          if (variant == GlassButtonVariant.primaryWine)
            BoxShadow(
              color: AppColors.wineAccent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          if (variant == GlassButtonVariant.whatsapp)
            BoxShadow(
              color: AppColors.whatsappGreen.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isLoading ? null : onPressed,
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (icon != null) ...[
                                icon!,
                                const SizedBox(width: 8),
                              ],
                              Text(
                                label,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
