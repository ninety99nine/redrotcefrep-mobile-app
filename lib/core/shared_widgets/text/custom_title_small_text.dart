import 'package:flutter/material.dart';

class CustomTitleSmallText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final TextStyle? style;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CustomTitleSmallText(this.text, {
    super.key,
    this.color,
    this.style,
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
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: color,
        ).merge(style)
      ),
    );
  }
}