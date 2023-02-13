import 'package:flutter/material.dart';

class CustomTitleLargeText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CustomTitleLargeText(this.text, {
    super.key,
    this.color,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: color,
        )
      ),
    );
  }
}