import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool hasGoldBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 16.0,
    this.color,
    this.border,
    this.onTap,
    this.width,
    this.height,
    this.hasGoldBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color ?? AppColors.glassWhite,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: hasGoldBorder
                      ? AppColors.glassBorderGold
                      : AppColors.glassBorder,
                  width: hasGoldBorder ? 1.5 : 1.0,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (hasGoldBorder)
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: 0.12),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AppColors.goldPrimary.withValues(alpha: 0.2),
          highlightColor: AppColors.wineAccent.withValues(alpha: 0.15),
          child: content,
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: content);
    }
    return content;
  }
}
