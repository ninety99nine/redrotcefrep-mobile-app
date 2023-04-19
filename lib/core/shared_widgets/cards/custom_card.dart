

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {

  final double elevation;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? backgroundColor;

  const CustomCard({
    Key? key,
    this.borderColor,
    required this.child,
    this.elevation = 2.0,
    this.backgroundColor,
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
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: borderColor ?? Colors.grey.shade200,
        ),
      ),
      child: Container(
        width: double.infinity,
        color: backgroundColor,
        padding: padding,
        child: child,
      )
    );
  }
}