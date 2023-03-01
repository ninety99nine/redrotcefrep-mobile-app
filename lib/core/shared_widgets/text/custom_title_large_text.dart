import 'package:flutter/material.dart';

class CustomTitleLargeText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextOverflow? overflow;

  const CustomTitleLargeText(this.text, {
    super.key,
    this.color,
    this.margin,
    this.padding,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        text,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: color,
        )
      ),
    );
  }
}