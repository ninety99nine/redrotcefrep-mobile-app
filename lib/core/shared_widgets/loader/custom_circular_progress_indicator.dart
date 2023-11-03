import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {

  final double? size;
  final Color? color;
  final double strokeWidth;
  final EdgeInsets? margin;
  final Alignment alignment;
  final Color? backgroundColor;

  const CustomCircularProgressIndicator({
    super.key, 
    this.color,
    this.margin,
    this.size = 24, 
    this.strokeWidth = 2,
    this.backgroundColor,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        margin: margin,
        child: CircularProgressIndicator(
          backgroundColor: backgroundColor ?? Colors.grey.shade100,
          color: color ?? Colors.black,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}