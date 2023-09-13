import 'package:flutter/material.dart';

class CustomTitleLargeText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final int? maxLines;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextOverflow? overflow;

  const CustomTitleLargeText(this.text, {
    super.key,
    this.color,
    this.margin,
    this.height,
    this.padding,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: color,
          height: height
        )
      ),
    );
  }
}