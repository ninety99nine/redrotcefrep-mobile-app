import '../loader/custom_circular_progress_indicator.dart';
import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  
  final String text;
  final Color? color;
  final double width;
  final bool isError;
  final double height;
  final bool disabled;
  final bool isLoading;
  final bool isSuccess;
  final double? fontSize;
  final EdgeInsets padding;
  final Alignment alignment;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final double? prefixIconSize;
  final double? suffixIconSize;
  final BorderRadius? borderRadius;
  final void Function()? onPressed;

  const CustomElevatedButton(
    this.text, 
    {
      super.key,
      this.color,
      this.fontSize,
      this.onPressed,
      this.suffixIcon,
      this.prefixIcon,
      this.height = 36,
      this.width = 100,
      this.borderRadius,
      this.isError = false,
      this.disabled = false,
      this.isSuccess = false,
      this.isLoading = false,
      this.prefixIconSize = 16,
      this.suffixIconSize = 16,
      this.alignment = Alignment.centerRight,
      this.padding = const EdgeInsets.symmetric(vertical: 10),
    }
  );

  @override
  Widget build(BuildContext context) {
    
    Color backgroundColor = Theme.of(context).primaryColor;
    Color? loaderColor;

    if(isSuccess) {

      backgroundColor = Colors.green;

    }else if(isError) {

      backgroundColor = Colors.red;

    }else if(color != null) {

      backgroundColor = color!;

    }

    loaderColor = backgroundColor;
    
    return Align(
      alignment: alignment,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(18.0)
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold)
        ),
        onPressed: disabled ? null : () {
          if( onPressed != null ) {
            onPressed!();
          }
        },
        /**
         *  The AnimatedSize() and AnimatedSwitcher() help animated 
         *  the width and widget swapping transitions while showing 
         *  the loading icon
         */
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Container(
              height: height,
              width: isLoading ? 60 : width,
              padding: padding,
              child: Row(
                key: ValueKey(isLoading),
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(isLoading) CustomCircularProgressIndicator(
                    size: 16, 
                    strokeWidth: 2,
                    color: loaderColor,
                  ),
                  if(!isLoading) ...[
        
                    if(prefixIcon != null) Icon(prefixIcon, size: prefixIconSize, color: disabled ? Colors.white : null,),
                    if(text.isNotEmpty && prefixIcon != null) const SizedBox(width: 5),
                    CustomBodyText(
                      text,
                      fontSize: fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    if(text.isNotEmpty && suffixIcon != null) const SizedBox(width: 5),
                    if(suffixIcon != null) Icon(suffixIcon, size: suffixIconSize, color: disabled ? Colors.white : null,)
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  
}