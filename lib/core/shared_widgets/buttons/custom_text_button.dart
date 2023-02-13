import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  
  final String text;
  final Color? color;
  final bool isError;
  final bool disabled;
  final String? normalText;
  final EdgeInsets padding;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final double? prefixIconSize;
  final double? suffixIconSize;
  final void Function()? onPressed;
  final AlignmentGeometry alignment;

  const CustomTextButton(
    this.text, 
    {
      super.key,
      this.color,
      this.onPressed,
      this.normalText,
      this.suffixIcon,
      this.prefixIcon,
      this.prefixIconSize,
      this.suffixIconSize,
      this.isError = false,
      this.disabled = false,
      this.padding = const EdgeInsets.all(8),
      this.alignment = Alignment.centerLeft,
    }
  );

  @override
  Widget build(BuildContext context) {
    
    final Color preferredColor = isError ? Colors.red : (color ?? Theme.of(context).primaryColor);

    return Align(
      alignment: alignment,
      child: TextButton(
        /**
         *  The minimumSize, padding and tapTargetSize help us Inner Padding
         *  that causes the Text Button to occupy too much space. We reduced
         *  the size and make the padding dynamic according to our needs.
         * 
         *  Reference: https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
         */
        
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: disabled ? null : () {
          if( onPressed != null ) {
            onPressed!();
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            /// Prefix Icon
            if(prefixIcon != null) Icon(prefixIcon, size: prefixIconSize, color: preferredColor),
            if(text.isNotEmpty && prefixIcon != null) const SizedBox(width: 5),
            
            /// Bolded text
            CustomBodyText(
              text, 
              fontWeight: FontWeight.bold,
              color: preferredColor,
            ),
            
            /// Spacer
            if(normalText != null) const SizedBox(width: 4,),

            /// Non Bolded text
            if(normalText != null) CustomBodyText(
              normalText!,
              color: preferredColor,
            ),

            /// Suffix Icon
            if(text.isNotEmpty && suffixIcon != null) const SizedBox(width: 5),
            if(suffixIcon != null) Icon(suffixIcon, size: suffixIconSize, color: preferredColor)
          
          ],
        ),
      ),
    );
  }
}