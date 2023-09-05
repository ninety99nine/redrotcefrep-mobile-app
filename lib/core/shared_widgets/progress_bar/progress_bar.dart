import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {

  final int percentage;
  final Color? backgroundColor;
  
  const CustomProgressBar({
    super.key,
    this.percentage = 0,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      child: LinearProgressIndicator(
        minHeight: 8,
        color: Colors.green,
        value: (percentage / 100),
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
      ),
    );
  }
}