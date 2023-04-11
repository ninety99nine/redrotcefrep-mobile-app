import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class CustomTextFieldTags extends StatelessWidget {
  
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final String? hintText;
  final bool obscureText;
  final String? errorText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final bool allowDuplicates;
  final List<String>? initialTags;
  final double borderRadiusAmount;
  final EdgeInsets contentPadding;
  final TextInputType? keyboardType;
  final String validatorOnEmptyText;
  final List<String>? textSeparators;
  final String? Function(String?)? validator;
  final TextfieldTagsController? textfieldTagsController;

  const CustomTextFieldTags( 
    {
      super.key,
      this.hintText,
      this.minLines,
      this.maxLines,
      this.errorText,
      this.labelText,
      this.validator,
      this.helperText,
      this.prefixIcon,
      this.suffixIcon,
      this.initialTags,
      this.enabled = true,
      this.textSeparators,
      this.obscureText = false,
      this.textfieldTagsController,
      this.allowDuplicates = false,
      this.borderRadiusAmount = 50.0,
      this.validatorOnEmptyText = '',
      this.keyboardType = TextInputType.text,
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20)
    }
  );

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;

    return TextFieldTags(
      initialTags: initialTags,
      textSeparators: textSeparators,
      //textfieldTagsController: textfieldTagsController,
      validator: validator ?? (String tag) {
        if (
          !allowDuplicates && 
          textfieldTagsController != null && 
          textfieldTagsController!.getTags != null && 
          textfieldTagsController!.getTags!.contains(tag)
        ) {
          
          return 'Destination already exists';

        }else if(
            validatorOnEmptyText.isNotEmpty && 
            textfieldTagsController != null && 
            textfieldTagsController!.getTags != null && 
            textfieldTagsController!.getTags!.isEmpty
          ) {
          
          /// Enter a tag
          return validatorOnEmptyText;

        }else{

          return null;

        }
      },
      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
        return ((context, sc, tags, onTagDelete) {
          return TextField(
            focusNode: fn,
            controller: tec,
            enabled: enabled,
            minLines: minLines,
            maxLines: maxLines,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: bodyLarge.copyWith(
              color: enabled ? Colors.black : Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              filled: true,
              errorMaxLines: 2,
              hintText: hintText,
              errorText: errorText,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon ?? Icon(Icons.location_on_sharp, color: Colors.grey.shade400,),
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
          );
        });
      },
    );
    
  }
}