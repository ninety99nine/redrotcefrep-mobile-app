import '../loader/custom_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class CustomSearchTextFormField extends StatelessWidget {
  
  final bool enabled;
  final bool isLoading;
  final String? hintText;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;

  const CustomSearchTextFormField(
    {
      super.key,
      this.onSaved,
      this.onChanged,
      this.initialValue,
      this.enabled = true,
      this.isLoading = true,
      this.hintText = 'Search'
    }
  );

  Widget get loader {
    return const CustomCircularProgressIndicator(
      size: 16, 
      strokeWidth: 2,
    );
  }

  Widget get searchIcon {
    return const Icon(Icons.search);
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        CustomTextFormField(
          suffixIcon: isLoading ? null : searchIcon,
          keyboardType: TextInputType.text,
          initialValue: initialValue,
          onChanged: onChanged,
          hintText: hintText,
          enabled: enabled,
          onSaved: onSaved,
        ),
        if(isLoading) Positioned(
          top: 16,
          right: 16,
          child: loader
        )
      ],
    );

  }
}