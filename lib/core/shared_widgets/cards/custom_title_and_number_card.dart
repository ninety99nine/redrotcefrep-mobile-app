import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:flutter/material.dart';

class CustomTitleAndNumberCard extends StatelessWidget {

  final int? number;
  final String title;
  final double? width;
  final bool isLoading;
  final double elevation;
  final Function()? onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const CustomTitleAndNumberCard({
    Key? key,
    this.onTap,
    this.width = 150,
    this.borderRadius,
    required this.title,
    required this.number,
    this.elevation = 4.0,
    this.isLoading = false,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: width,
            margin: margin,
            padding: padding,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_4.png'),
                opacity: 0.1, 
                fit: BoxFit.cover
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSwitcher(
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                    child: number == null || isLoading 
                      ? const CustomCircularProgressIndicator(size: 8, strokeWidth: 1, margin: EdgeInsets.only(bottom: 4),)
                      : CustomTitleSmallText('$number', color: Colors.black),
                  )
                ),
                const SizedBox(height: 5),
                CustomBodyText(title, color: Colors.black, fontSize: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}