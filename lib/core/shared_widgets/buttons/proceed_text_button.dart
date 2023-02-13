import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';

class ProceedTextButton extends StatelessWidget {
  
  final String text;
  final Color? color;
  final bool disabled;
  final void Function()? onPressed;
  final AlignmentGeometry alignment;

  const ProceedTextButton(
    this.text,
    {
      super.key,
      this.color,
      this.onPressed,
      this.disabled = false,
      this.alignment = Alignment.center
    }
  );

  @override
  Widget build(BuildContext context) {
    
    final currColor = color ?? Theme.of(context).primaryColor;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 120,
        child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)
              )
            ),
          ),
          onPressed: disabled ? null : () {
            if( onPressed != null ) {
              onPressed!();
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomBodyText(
                text, 
                height: 1, 
                color: currColor,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_rounded,
                color: currColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}