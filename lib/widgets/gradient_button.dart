import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rounded gradient call-to-action button with a press scale animation.
class GradientButton extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final List<BoxShadow>? shadow;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.colors,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.radius = 18,
    this.shadow,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: enabled ? (_) => setState(() => _scale = 1) : null,
      onTapCancel: enabled ? () => setState(() => _scale = 1) : null,
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: double.infinity,
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.colors,
              ),
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: widget.shadow,
            ),
            child: DefaultTextStyle.merge(
              style: AppText.sans(size: 16, weight: FontWeight.w500, color: Colors.white),
              child: IconTheme.merge(
                data: const IconThemeData(color: Colors.white, size: 18),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
