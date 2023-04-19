import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/addresses/enums/address_enums.dart';
import 'package:bonako_demo/features/addresses/providers/address_provider.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../models/address.dart';
import 'dart:convert';

class CreateOrUpdateAddressForm extends StatefulWidget {
  
  final User user;
  final Address? address;
  final Function(bool) onDeleting;
  final Function(bool) onSubmitting;
  final Function()? onDeletedAddress;
  final Function(Address)? onCreatedAddress;
  final Function(Address)? onUpdatedAddress;

  const CreateOrUpdateAddressForm({
    super.key,
    this.address,
    required this.user,
    this.onCreatedAddress,
    this.onUpdatedAddress,
    this.onDeletedAddress,
    required this.onDeleting,
    required this.onSubmitting,
  });

  @override
  State<CreateOrUpdateAddressForm> createState() => CreateOrUpdateAddressFormState();
}

class CreateOrUpdateAddressFormState extends State<CreateOrUpdateAddressForm> {

  Map addressForm = {};
  Map serverErrors = {};
  bool isRemoving = false;
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  
  User get user => widget.user;
  bool get isEditing => address != null;
  Address? get address => widget.address;
  Function(bool) get onDeleting => widget.onDeleting;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function()? get onDeletedAddress => widget.onDeletedAddress;
  Function(Address)? get onCreatedAddress => widget.onCreatedAddress;
  Function(Address)? get onUpdatedAddress => widget.onUpdatedAddress;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  AddressProvider get addressProvider => Provider.of<AddressProvider>(context, listen: false);

  void _startDeleteLoader() => setState(() => isRemoving = true);
  void _stopDeleteLoader() => setState(() => isRemoving = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    setAddressForm();
  }

  void setAddressForm() {

    setState(() {
      
      addressForm = {
        'type': address?.type ?? AddressType.home,
        'addressLine': address?.addressLine
      };

    });

  }

  void submit() {
    isEditing ? requestUpdateAddress() : requestCreateAddress();
  }

  void requestCreateAddress() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      userProvider.setUser(user).userRepository.createAddress(
        type: addressForm['type'],
        addressLine: addressForm['addressLine']
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 201) {

          final Address updatedAddress = Address.fromJson(responseBody);

          /// Notify parent on created address
          if(onCreatedAddress != null) onCreatedAddress!(updatedAddress);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t create address');

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  void requestUpdateAddress() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      addressProvider.setAddress(address!).addressRepository.updateAddress(
        type: addressForm['type'],
        addressLine: addressForm['addressLine']
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final Address updatedAddress = Address.fromJson(responseBody);

          /// Notify parent on update address
          if(onUpdatedAddress != null) onUpdatedAddress!(updatedAddress);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update address');

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  void requestDeleteAddress() async {

    if(isSubmitting) return;

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _resetServerErrors();

      _startDeleteLoader();
      
      /// Notify parent that we are loading
      onDeleting(true);

      addressProvider.setAddress(address!).addressRepository.deleteAddress().then((response) async {

        if(response.statusCode == 200) {

          /// Notify parent on deleted address
          if(onDeletedAddress != null) onDeletedAddress!();

          SnackbarUtility.showSuccessMessage(message: 'Removed successfully');

        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update address');

      }).whenComplete((){

        _stopDeleteLoader();
      
        /// Notify parent that we are not loading
        onDeleting(false);

      });

    }

  }

  /// Confirm delete address
  Future<bool?> confirmDelete() {

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete this address?',
      context: context
    );

  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    addressLine: [The address line must be more than 3 characters]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: addressForm.isEmpty ? [] : [

              /// Address Type Label
              if(isEditing) CustomTitleSmallText(
                '${address!.type.name.capitalize} address',
                margin: const EdgeInsets.only(top: 16, left: 8, bottom: 8),
              ),

              /// Address Type Dropdown
              if(!isEditing) Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  
                  /// Address Type Label
                  const CustomBodyText('Address for'),
                  
                  /// Spacer
                  const SizedBox(width: 8),

                  /// Address Type Dropdown
                  DropdownButton(
                    value: addressForm['type'],
                    items: [
                      
                      /// Address Type Dropdown Items
                      ...AddressType.values.map((addressType) {
                        return DropdownMenuItem(
                          value: addressType,
                          child: CustomBodyText(addressType.name),
                        );
                      })
                      
                    ],
                    onChanged: (value) {
                      setState(() => addressForm['type'] = value); 
                    },
                  ),

                ],
              ),
                
              /// Spacer
              const SizedBox(height: 16),

              /// Address Line Text Form Field
              CustomTextFormField(
                errorText: serverErrors.containsKey('addressLine') ? serverErrors['addressLine'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                enabled: !isSubmitting,
                hintText: 'Block 3, Plot 1234, house with white wall and black gate',
                borderRadiusAmount: 16,
                initialValue: addressForm['addressLine'],
                labelText: 'Address',
                minLines: 2,
                onChanged: (value) {
                  setState(() => addressForm['addressLine'] = value); 
                },
                onSaved: (value) {
                  setState(() => addressForm['addressLine'] = value ?? ''); 
                },
              ),
                
              /// Spacer
              const SizedBox(height: 40),

              /// Remove Button
              if(isEditing) CustomElevatedButton(
                width: 180,
                'Remove Address',
                isError: true,
                isLoading: isRemoving,
                alignment: Alignment.center,
                onPressed: requestDeleteAddress,
                disabled: isSubmitting || isRemoving,
              ),

              /// Spacer
              const SizedBox(height: 100)
              
            ]
          ),
        ),
      ),
    );
  }
}