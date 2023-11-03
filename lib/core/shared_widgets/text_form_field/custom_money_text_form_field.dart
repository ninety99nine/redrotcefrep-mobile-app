import '../../constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class CustomMoneyTextFormField extends StatelessWidget {
  
  final bool enabled;
  final String? hintText;
  final String? errorText;
  final String? labelText;
  final String? initialValue;
  final void Function(String)? onSaved;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  const CustomMoneyTextFormField( 
    {
      super.key,
      this.onSaved,
      this.labelText,
      this.errorText,
      this.onChanged,
      this.initialValue,
      this.enabled = true,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.hintText = '100.00'
    }
  );

  String formatValue(String? value) {
    
    double? decimalValue = double.tryParse(value ??= '0.00');

    if(decimalValue == null) {
      value = '0.00';
    }else{
      value = decimalValue.toString();
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;

    return CustomTextFormField(
      maxLength: 10,
      enabled: enabled,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      borderRadiusAmount: 16,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      prefixIcon: Container(
        width: 4,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          constants.currencySymbol,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      onEditingComplete: onEditingComplete,
      onSaved: (value) {
        value = formatValue(value); 
        if(onSaved != null) onSaved!(value);
      },
      onChanged: (value) {
        value = formatValue(value); 
        if(onChanged != null) onChanged!(value);
      },
      onFieldSubmitted: (value) {
        value = formatValue(value); 
        if(onFieldSubmitted != null) onFieldSubmitted!(value);
      },
      validator: (value, originalValidator) {
        if(value == null || value.isEmpty){
          return 'Please enter the amount';
        }

        return null;
      },
    );

  }
}