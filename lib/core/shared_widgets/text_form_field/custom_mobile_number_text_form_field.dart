import '../../utils/mobile_number.dart';
import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class CustomMobileNumberTextFormField extends StatelessWidget {
  
  final bool enabled;
  final String? errorText;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const CustomMobileNumberTextFormField( 
    {
      super.key,
      this.onSaved,
      this.errorText,
      this.onChanged,
      this.initialValue,
      this.enabled = true,
      this.onFieldSubmitted,
      required this.supportedMobileNetworkNames
    }
  );

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;

    return CustomTextFormField(
      enabled: enabled,
      hintText: 'XXXXXXXX',
      errorText: errorText,
      initialValue: initialValue,
      keyboardType: TextInputType.phone,
      prefixIcon: Container(
        width: 80,
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        child: Chip(
          backgroundColor: primaryColor.withOpacity(0.2),
          label: Text(
            '+267',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold
            ),
          )
        ),
      ),
      onSaved: onSaved,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if(value == null || value.isEmpty){
          return 'Please enter the mobile number';
        }

        final bool isValid = MobileNumberUtility.isValidMobileNumber(value);
        final MobileNetworkName? mobileNetworkName = MobileNumberUtility.getMobileNetworkName(value);
        final List<String> supportedMobileNetworksByName = supportedMobileNetworkNames.map((supportedMobileNetworkName) => supportedMobileNetworkName.name).toList();
        final supportedMobileNetworksText = supportedMobileNetworksByName.join(', ');

        bool isSupportedMobileNetworksByName = false;

        if(mobileNetworkName != null) {

          for (String supportedMobileNetworkByName in supportedMobileNetworksByName) {

            if(mobileNetworkName.name == supportedMobileNetworkByName) {

              isSupportedMobileNetworksByName = true;

            }
            
          }

        }
        
        if(isValid == false){
          return 'Please enter a valid 8 digit mobile number e.g 72000000';
        }else if(errorText != null){
          return errorText;
        }else if(isSupportedMobileNetworksByName == false){
          return 'Please enter a $supportedMobileNetworksText mobile number';
        }else{
          return null;
        }
      },
    );

  }
}