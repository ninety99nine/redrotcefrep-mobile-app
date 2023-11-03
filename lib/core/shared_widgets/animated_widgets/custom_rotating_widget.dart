import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class CustomRotatingWidget extends StatefulWidget {
  final Widget child;
  final bool rotateOnLoad;
  final int? maxRotations;
  final Duration delayDuration;
  final Duration animationDuration;

  const CustomRotatingWidget({
    Key? key,
    this.maxRotations,
    required this.child,
    this.rotateOnLoad = true,
    this.delayDuration = const Duration(seconds: 5),
    this.animationDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  CustomRotatingWidgetState createState() => CustomRotatingWidgetState();
}

class CustomRotatingWidgetState extends State<CustomRotatingWidget> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late int _totalRotations = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    //  Check if we should rotate immediately
    if(widget.rotateOnLoad) rotate();

    //  Setup periodic rotation
    startPeriodicRotation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Rotate e.g every 10 seconds
  void startPeriodicRotation() {

    /// If we have reached the maximum number of allowed rotations then do not proceed any further
    if(widget.maxRotations != null && (_totalRotations == widget.maxRotations)) return;
      
    _timer = Timer.periodic(widget.delayDuration, (Timer timer) {
      rotate();
    });

  }

  // Rotate
  void rotate() {
    _totalRotations += 1;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: widget.child,
        );
      },
    );
  }
}
