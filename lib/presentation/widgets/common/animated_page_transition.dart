import 'package:flutter/material.dart';

/// Smooth page transition animations
class AnimatedPageTransition {
  /// Fade transition
  static Widget fade(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Slide from right transition
  static Widget slideFromRight(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Slide from bottom transition
  static Widget slideFromBottom(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Scale transition
  static Widget scale(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const curve = Curves.easeInOut;

    var tween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: curve),
    );

    return ScaleTransition(
      scale: animation.drive(tween),
      child: child,
    );
  }

  /// Fade and slide transition
  static Widget fadeAndSlide(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 0.3);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      ),
    );
  }
}

/// Animated container with smooth transitions
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Staggered list animation
class StaggeredListAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;

  const StaggeredListAnimation({
    Key? key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final delayedValue = (value - (index * 0.1)).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - delayedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
