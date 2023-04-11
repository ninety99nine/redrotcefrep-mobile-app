import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class CustomOneTimePinField extends StatelessWidget {

  final int length;
  final bool enabled;
  final String? errorText;
  final void Function(String) onChanged;
  final void Function(String?)? onSaved;
  final AutovalidateMode autovalidateMode;
  final void Function(String)? onCompleted;
  final void Function(String)? onSubmitted;

  const CustomOneTimePinField( 
    {
      super.key,
      this.onSaved,
      this.errorText,
      this.length = 6,
      this.onCompleted,
      this.onSubmitted,
      this.enabled = true,
      required this.onChanged,
      this.autovalidateMode = AutovalidateMode.onUserInteraction
    }
  );

  @override
  Widget build(BuildContext context) {
    
    final primaryColor = Theme.of(context).primaryColor;
    final titleLarge = Theme.of(context).textTheme.titleLarge!.copyWith(
      color: primaryColor
    );

    return PinCodeTextField(

      length: length,
      readOnly: false,
      enabled: enabled,
      errorTextSpace: 24,
      obscureText: false,
      appContext: context,
      enableActiveFill: true,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      autovalidateMode: autovalidateMode,
      animationDuration: const Duration(milliseconds: 300),

      cursorColor: primaryColor,
      textStyle: titleLarge,
      pinTheme: PinTheme(

        activeColor: primaryColor.withOpacity(0.5),
        activeFillColor: primaryColor.withOpacity(0.1),

        selectedColor: primaryColor.withOpacity(0.1),
        selectedFillColor: primaryColor.withOpacity(0.1),

        inactiveColor: primaryColor.withOpacity(0.1),
        inactiveFillColor: primaryColor.withOpacity(0.1),

        disabledColor: Colors.grey.shade200,

        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),

      ),

      validator: (value) {
        if(value == null || value.isEmpty){
          return 'Enter the $length digit code';
        }else if(errorText != null){
          return errorText;
        }else{
          return null;
        }
      },

      onSaved: onSaved,

      /// returns the current typed text in the fields
      onChanged: onChanged,

      /// returns the typed text when all pins are set
      onCompleted: onCompleted,

      /// returns the typed text when user presses done/next action on the keyboard
      onSubmitted: onSubmitted
    );
    
  }
}