import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final String? hintText;
  final bool obscureText;
  final String? errorText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final double borderRadiusAmount;
  final EdgeInsets contentPadding;
  final TextInputType? keyboardType;
  final String validatorOnEmptyText;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const CustomTextFormField( 
    {
      super.key,
      this.onSaved,
      this.hintText,
      this.minLines,
      this.maxLines,
      this.errorText,
      this.labelText,
      this.validator,
      this.onChanged,
      this.prefixIcon,
      this.suffixIcon,
      this.initialValue,
      this.enabled = true,
      this.onFieldSubmitted,
      this.obscureText = false,
      this.borderRadiusAmount = 50.0,
      this.keyboardType = TextInputType.text,
      this.validatorOnEmptyText = 'This field is required',
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20)
    }
  );

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;

    return TextFormField(
      autofocus: false,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: primaryColor,
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: bodyLarge.copyWith(
        color: enabled ? Colors.black : Colors.grey.shade400,
        fontWeight: FontWeight.normal,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        errorMaxLines: 2,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        label: labelText == null ? null : Text(labelText!),
        labelStyle: TextStyle(
          color: bodyLarge.color,
          fontWeight: FontWeight.normal
        ),
        hintStyle: bodyLarge.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.normal
        ),
        contentPadding: contentPadding,
        fillColor: primaryColor.withOpacity(0.05),
        
        //  Border disabled (i.e enabled = false)
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),

        //  Border enabled (i.e enabled = true)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border focused (i.e while typing - onFocus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(1),
            width: 1.0,
          ),
        ),

        //  Border error onfocused (i.e validation error showing while not typing - onblur)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusAmount),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border error focused (i.e validation error showing while typing - onFocus)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusAmount),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
      ),
      validator: validator ?? (value) {
        
        if(value == null || value.isEmpty){
          return validatorOnEmptyText;
        }else if(errorText != null){
          return errorText;
        }
        
        return null;

      },
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      onSaved: onSaved,
    );
    
  }
}