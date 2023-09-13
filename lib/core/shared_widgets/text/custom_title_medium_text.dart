import 'package:flutter/material.dart';

class CustomTitleMediumText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final int? maxLines;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextOverflow? overflow;

  const CustomTitleMediumText(this.text, {
    super.key,
    this.color,
    this.margin,
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
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: color,
        )
      ),
    );
  }
}