import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: cardWidget);
    }

    return cardWidget;
  }
}
