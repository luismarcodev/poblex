import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

/// A single placeholder block that pulses between `skeletonBase` and
/// `skeletonHighlight` (design-system.md §8.9) while content is loading.
///
/// This is the one primitive every feature composes its own skeleton from —
/// see `NewsCardSkeleton` for an example that mirrors a real card's geometry.
/// Excluded from the semantics tree: the loading announcement belongs to the
/// container around the whole skeleton, not to each individual block.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    required this.height,
    this.width,
    this.borderRadius = AppRadius.xsAll,
    super.key,
  });

  final double height;

  /// Null fills the available width — use inside a `Column` with
  /// `CrossAxisAlignment.stretch`, or pass an explicit value otherwise.
  final double? width;

  final BorderRadius borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.skeletonSweep,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A-43: reduce-motion freezes the pulse at the base tone instead of
    // stopping mid-animation, which would leave a random highlighted frame.
    if (AppMotion.prefersReducedMotion(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppSemanticColors semantic = context.semantic;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              semantic.skeletonBase,
              semantic.skeletonHighlight,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
