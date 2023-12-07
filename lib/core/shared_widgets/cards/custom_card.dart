

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {

  final double? width;
  final double elevation;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    this.borderColor,
    this.borderRadius,
    required this.child,
    this.elevation = 2.0,
    this.backgroundColor,
    this.width = double.infinity,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 10),
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16.0),
        side: BorderSide(
          color: borderColor ?? Colors.grey.shade200,
        ),
      ),
      child: Container(
        color: backgroundColor,
        padding: padding,
        width: width,
        child: child,
      )
    );
  }
}