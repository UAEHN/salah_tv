import 'package:flutter/material.dart';

class MobileFloatingOrb extends StatefulWidget {
  final double size;
  final Color color;
  final Alignment initialAlignment;
  final int delaySeconds;

  const MobileFloatingOrb({
    super.key,
    required this.size,
    required this.color,
    required this.initialAlignment,
    required this.delaySeconds,
  });

  @override
  State<MobileFloatingOrb> createState() => _MobileFloatingOrbState();
}

class _MobileFloatingOrbState extends State<MobileFloatingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _slide =
        Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: const Offset(0, 0.08),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );

    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    Future.delayed(Duration(seconds: widget.delaySeconds), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.initialAlignment,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
