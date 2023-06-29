import 'package:bonako_demo/core/shared_widgets/tags/custom_tag.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class CustomTextFieldTags extends StatelessWidget {
  
  final bool enabled;
  final String? hintText;
  final String? errorText;
  final String? labelText;
  final String? helperText;
  final bool allowDuplicates;
  final List<String>? initialTags;
  final double borderRadiusAmount;
  final EdgeInsets contentPadding;
  final TextInputType? keyboardType;
  final String validatorOnEmptyText;
  final Function(String)? onChanged;
  final List<String>? textSeparators;
  final Function(String)? onSubmitted;
  final Function(String)? onRemovedTag;
  final String validatorOnDuplicateText;
  final Function(String)? onSelectedTag;
  final String? Function(String?)? validator;
  final TextfieldTagsController? textfieldTagsController;

  const CustomTextFieldTags( 
    {
      super.key,
      this.errorText,
      this.labelText,
      this.validator,
      this.onChanged,
      this.helperText,
      this.initialTags,
      this.onSubmitted,
      this.onRemovedTag,
      this.onSelectedTag,
      this.enabled = true,
      this.textSeparators,
      this.hintText = 'Enter tag',
      this.allowDuplicates = false,
      this.borderRadiusAmount = 50.0,
      this.validatorOnEmptyText = '',
      required this.textfieldTagsController,
      this.keyboardType = TextInputType.text,
      this.validatorOnDuplicateText = 'Already exists',
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
      textfieldTagsController: textfieldTagsController,
      validator: validator ?? (String tag) {

        if (
          allowDuplicates == false && 
          textfieldTagsController != null && 
          textfieldTagsController!.getTags != null && 
          textfieldTagsController!.getTags!.contains(tag)
        ) {
          
          /// Duplicate tag error
          return validatorOnDuplicateText;

        }else if(
            validatorOnEmptyText.isNotEmpty && 
            textfieldTagsController != null && 
            textfieldTagsController!.getTags != null && 
            textfieldTagsController!.getTags!.isEmpty
          ) {
          
          /// Empty tag error
          return validatorOnEmptyText;

        }else{

          return null;

        }
      },
      inputfieldBuilder: (context, tec, fn, error, onChangedCallback, onSubmittedCallback) {
        return ((context, sc, tags, onTagDelete) {
          return TextField(
            focusNode: fn,
            controller: tec,
            enabled: enabled,
            keyboardType: keyboardType,
            style: bodyLarge.copyWith(
              color: enabled ? Colors.black : Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            onChanged: (value) {

              /// Internal action
              if(onChangedCallback != null) onChangedCallback(value);

              /// Notify parent widget
              if(onChanged != null) onChanged!(value);

            },
            onSubmitted: (value) {

              /// Internal action
              if(onSubmittedCallback != null) onSubmittedCallback(value);

              /// Notify parent widget
              if(onSubmitted != null) onSubmitted!(value);

            },
            decoration: InputDecoration(
              filled: true,
              errorMaxLines: 2,
              errorText: error ?? errorText,
              prefixIconConstraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              hintText: textfieldTagsController == null ? hintText : (textfieldTagsController!.hasTags ? '  Add' : hintText),
              prefixIcon: tags.isNotEmpty
                /// Tags in a horizontal scrollable list
                ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  child: SingleChildScrollView(
                    controller: sc,
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                          children: tags.map((String tag) {
                            return CustomTag(
                              tag,
                              onTap: () {
                                if(onSelectedTag != null) onSelectedTag!(tag);
                              },
                              onCancel: () {
                                onTagDelete(tag);
                                if(onRemovedTag != null) onRemovedTag!(tag);
                              },
                            );
                        }).toList()),
                    ),
                  ),
                )
                : null,
              label: labelText == null ? null : Text(labelText!),
              labelStyle: TextStyle(
                color: bodyLarge.color,
                fontWeight: FontWeight.normal
              ),
              hintStyle: bodyLarge.copyWith(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
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