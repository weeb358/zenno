import 'dart:async';

import 'package:flutter/material.dart';

/// Simple staggered fade/slide-in wrapper.
class FadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const FadeIn({required this.child, this.index = 0, this.duration = const Duration(milliseconds: 350), super.key});

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Staggered start based on index
    final delay = Duration(milliseconds: 60 * widget.index);
    Timer(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        duration: widget.duration,
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
