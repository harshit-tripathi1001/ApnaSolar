import 'package:flutter/material.dart';

/// Smooth slide & fade page transitions matching Stitch app micro-interactions.
class AppTransitions {
  AppTransitions._();

  static const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _SmoothSlideFadeTransitionBuilder(),
      TargetPlatform.iOS: _SmoothSlideFadeTransitionBuilder(),
      TargetPlatform.windows: _SmoothSlideFadeTransitionBuilder(),
      TargetPlatform.macOS: _SmoothSlideFadeTransitionBuilder(),
      TargetPlatform.linux: _SmoothSlideFadeTransitionBuilder(),
    },
  );
}

class _SmoothSlideFadeTransitionBuilder extends PageTransitionsBuilder {
  const _SmoothSlideFadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeOutCubic;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.06, 0.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}
