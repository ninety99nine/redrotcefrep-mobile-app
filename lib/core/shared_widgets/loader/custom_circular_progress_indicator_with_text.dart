import 'custom_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

class CustomCircularProgressIndicatorWithText extends StatelessWidget {

  final String text;
  final double? size;
  final double strokeWidth;
  final EdgeInsets? loaderMargin;
  final EdgeInsets? wrapperMargin;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomCircularProgressIndicatorWithText(
    this.text,
    {
      super.key, 
      this.size = 20,
      this.wrapperMargin,
      this.strokeWidth = 2,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.loaderMargin = const EdgeInsets.only(right: 15),
    }
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: wrapperMargin,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          CustomCircularProgressIndicator(
            size: size,
            margin: loaderMargin,
            strokeWidth: strokeWidth,
          ),
          Flexible(
            child: Text(
              text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold
              ),
            )
          ),
        ],
      ),
    );
  }
}