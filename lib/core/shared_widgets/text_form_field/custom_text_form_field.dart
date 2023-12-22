import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  
  final Color? color;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool isRequired;
  final String? hintText;
  final bool obscureText;
  final String? errorText;
  final String? labelText;
  final Color? cursorColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final FocusNode? focusNode;
  final bool validateOnEmptyText;
  final double borderRadiusAmount;
  final EdgeInsets contentPadding;
  final bool hideCharacterCounter;
  final TextInputType? keyboardType;
  final String validatorOnEmptyText;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?, String? Function(String?))? validator;

  const CustomTextFormField( 
    {
      super.key,
      this.color,
      this.onSaved,
      this.hintText,
      this.minLines,
      this.maxLines,
      this.maxLength,
      this.errorText,
      this.labelText,
      this.validator,
      this.onChanged,
      this.focusNode,
      this.prefixIcon,
      this.controller,
      this.suffixIcon,
      this.cursorColor,
      this.initialValue,
      this.enabled = true,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.isRequired = true,
      this.obscureText = false,
      this.borderRadiusAmount = 50.0,
      this.validateOnEmptyText = true,
      this.hideCharacterCounter = false,
      this.keyboardType = TextInputType.text,
      this.validatorOnEmptyText = 'This field is required',
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20)
    }
  );

  @override
  State<CustomTextFormField> createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {

  late TextEditingController controller;
  
  @override
  void initState() {
    super.initState();

    if(widget.controller == null) {
      controller = TextEditingController(text: widget.initialValue);
    }else{
      controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(widget.controller == null) controller.dispose();
  }

  String? originalValidator(String? value) {
        
    if(widget.isRequired && widget.validateOnEmptyText && (value == null || value.isEmpty)) {
      return widget.validatorOnEmptyText;
    }else if(widget.errorText != null){
      return widget.errorText;
    }
    
    return null;

  }

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;

    return TextFormField(
      autofocus: false,
      controller: controller,
      enabled: widget.enabled,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      cursorColor: widget.cursorColor ?? primaryColor,
      style: bodyLarge.copyWith(
        color: widget.enabled ? (widget.color ?? Colors.black) : Colors.grey.shade400,
        fontWeight: FontWeight.normal,
      ),
      maxLength: controller.text.isNotEmpty ? widget.maxLength : null,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        filled: true,
        errorMaxLines: 2,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        counterText: widget.hideCharacterCounter ? "" : null,
        label: widget.labelText == null ? null : Text(widget.labelText!),
        labelStyle: TextStyle(
          color: bodyLarge.color,
          fontWeight: FontWeight.normal
        ),
        hintStyle: bodyLarge.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.normal
        ),
        contentPadding: widget.contentPadding,
        //  fillColor: primaryColor.withOpacity(0.05),
        
        //  Border disabled (i.e enabled = false)
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),

        //  Border enabled (i.e enabled = true)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border focused (i.e while typing - onFocus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(1),
            width: 1.0,
          ),
        ),

        //  Border error onfocused (i.e validation error showing while not typing - onblur)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border error focused (i.e validation error showing while typing - onFocus)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
      ),
      validator: (value) {
        if(widget.validator != null) {
          return widget.validator!(value, originalValidator);
        }else{
          return originalValidator(value);
        }
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
    );
    
  }
}