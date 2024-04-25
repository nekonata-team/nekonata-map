import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BouncingScaleAnimationOnTap extends HookWidget {
  const BouncingScaleAnimationOnTap({
    required this.onTap, required this.child, super.key,
    this.alignment = Alignment.center,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final animation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    return GestureDetector(
      onTap: onTap != null
          ? () {
              onTap!();
              controller
                  .forward(from: 0)
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
