import 'package:flutter/material.dart';

class AnimatedThemeWrapper extends StatelessWidget {
  final ThemeData theme;
  final Widget child;
  final Duration duration;

  const AnimatedThemeWrapper({
    super.key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: theme,
      duration: duration,
      child: AnimatedDefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        duration: duration,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: theme.scaffoldBackgroundColor,
            end: theme.scaffoldBackgroundColor,
          ),
          duration: duration,
          builder: (context, color, child) => Container(
            color: color,
            child: child,
          ),
          child: child,
        ),
      ),
    );
  }
} 