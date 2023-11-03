import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class CustomPasswordTextFormField extends StatefulWidget {
  
  final bool enabled;
  final String? errorText;
  final String? labelText;
  final String? initialValue;
  final String? matchPassword;
  final String validatorOnEmptyText;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String validatorOnDoesNotMatchText;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  const CustomPasswordTextFormField( 
    {
      super.key,
      this.onSaved,
      this.labelText,
      this.errorText,
      this.onChanged,
      this.initialValue,
      this.matchPassword,
      this.enabled = true,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.validatorOnEmptyText = 'Enter your password',
      this.validatorOnDoesNotMatchText = 'Password does not match'
    }
  );

  @override
  State<CustomPasswordTextFormField> createState() => _CustomPasswordTextFormFieldState();
}

class _CustomPasswordTextFormFieldState extends State<CustomPasswordTextFormField> {
  
  String? initialValue;
  bool obscureText = true;

  @override
  void initState() {
    
    super.initState();

    /**
     *  We need to save the initialValue as a widget state
     *  property so that when the toggleShowPassword()
     *  function is run and the 
     * 
     */
    initialValue = widget.initialValue;
  }

  void toggleShowPassword() {
    setState(() {
      obscureText = !obscureText;
    }); 
  }

  @override
  Widget build(BuildContext context) {

    return CustomTextFormField(
      suffixIcon: GestureDetector(
        onTap: () => toggleShowPassword(),
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(
            obscureText 
              ? Icons.visibility_off
              : Icons.visibility,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        )
      ),
      maxLines: 1,
      enabled: widget.enabled,
      onSaved: widget.onSaved,
      obscureText: obscureText,
      initialValue: initialValue,
      onChanged: widget.onChanged,
      labelText: widget.labelText,
      errorText: widget.errorText,
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
      validatorOnEmptyText: widget.validatorOnEmptyText,
      validator: (value, originalValidator) {
        
        if(value == null || value.isEmpty){
          return widget.validatorOnEmptyText;
        }else if(widget.matchPassword != null && value != widget.matchPassword ){
          return widget.validatorOnDoesNotMatchText;
        }else if(widget.errorText != null){
          return widget.errorText;
        }else{
          return null;
        }
        
      },
    );
    
  }
}