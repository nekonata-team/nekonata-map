import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BouncingScaleAnimationOnTap extends HookWidget {
  const BouncingScaleAnimationOnTap({
    super.key,
    required this.onTap,
    this.alignment = Alignment.center,
    required this.child,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final animation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    return GestureDetector(
      onTap: onTap != null
          ? () {
              onTap!();
              controller
                  .forward(from: 0.0)
                  .then((value) => controller.reverse());
            }
          : null,
      child: ScaleTransition(
        scale: animation,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
