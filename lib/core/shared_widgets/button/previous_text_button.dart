import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';

class PreviousTextButton extends StatelessWidget {
  
  final String text;
  final bool disabled;
  final void Function()? onPressed;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const PreviousTextButton(
    this.text,
    {
      super.key,
      this.onPressed,
      this.disabled = false,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.crossAxisAlignment = CrossAxisAlignment.center,
    }
  );

  @override
  Widget build(BuildContext context) {
    
    final color = Theme.of(context).primaryColor;

    return SizedBox(
      width: 120,
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0)
            )
          ),
        ),
        onPressed: disabled || onPressed == null ? null : () {
          if( onPressed != null ) {
            onPressed!();
          }
        },
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: color,
            ),
            const SizedBox(width: 5),
            CustomBodyText(
              text, 
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}