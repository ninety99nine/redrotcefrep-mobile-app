import '../../constants/constants.dart' as constants;
import 'package:flutter/material.dart';

class CustomCircleRainbow extends StatefulWidget {
  
  final Widget child;
  final double? size;
  final double thickness;

  const CustomCircleRainbow({
    super.key,
    this.size,
    this.thickness = 2,
    required this.child,
  });

  @override
  State<CustomCircleRainbow> createState() => _CustomCircleRainbowState();
}

class _CustomCircleRainbowState extends State<CustomCircleRainbow> {

  List<Color> rainbowColors = constants.rainbowColors;
  double get thickness => widget.thickness;
  Widget get child => widget.child;
  double? get size => widget.size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(thickness), /// Adjust the padding as needed for the width of the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: rainbowColors,  /// Apply the rainbow colors
        ),
      ),
      child: child,
    );
  }
}