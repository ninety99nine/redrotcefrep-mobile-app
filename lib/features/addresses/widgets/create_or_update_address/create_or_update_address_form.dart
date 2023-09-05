import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/features/addresses/providers/address_provider.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/addresses/widgets/address_card.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/debouncer.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/address.dart';
import 'package:get/get.dart';
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

  Map serverErrors = {};
  bool isRemoving = false;
  bool isSubmitting = false;
  Address? dummySharedAddress;
  Map<String, dynamic> addressForm = {};
  final _formKey = GlobalKey<FormState>();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  
  User get user => widget.user;
  bool get isCreating => !isEditing;
  bool get isEditing => address != null;
  Address? get address => widget.address;
  Function(bool) get onDeleting => widget.onDeleting;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function()? get onDeletedAddress => widget.onDeletedAddress;
  Function(Address)? get onCreatedAddress => widget.onCreatedAddress;
  Function(Address)? get onUpdatedAddress => widget.onUpdatedAddress;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  AddressProvider get addressProvider => Provider.of<AddressProvider>(context, listen: false);
  bool get showDummyDeliveryAddress => addressForm.isNotEmpty && addressForm['shareAddress'] && dummySharedAddress != null;

  void _startDeleteLoader() => setState(() => isRemoving = true);
  void _stopDeleteLoader() => setState(() => isRemoving = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    setAddressForm();
    if(addressForm['shareAddress']) updateDeliveryAddress();
  }

  void setAddressForm() {

    setState(() {
      
      addressForm = {
        'name': address?.name,
        'addressLine': address?.addressLine,
        'shareAddress': address?.shareAddress ?? true,
      };

    });

  }

  void updateDeliveryAddress() {
    debouncerUtility.run(() {

      setState(() {

        if(hasValue(addressForm['name'])) {

          final Map<String, dynamic> dummySharedAddressMap = {
            ...{
              'id': 1,
              'createdAt': DateTime.now().toString(),
              'updatedAt': DateTime.now().toString()
            },
            ...addressForm,
          };

          //  Remove the address line
          dummySharedAddressMap.remove('addressLine');

          //  Set the dummy shared address
          dummySharedAddress = Address.fromJson(dummySharedAddressMap);

        }else{

          //  Unset the dummy shared address
          dummySharedAddress = null;


        }
        
      });

    });
  }

  bool hasValue(value) {
    return value != null && value != '';
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
        name: addressForm['name'],
        addressLine: addressForm['addressLine']
      ).then((response) async {

        if(response.statusCode == 201) {

          final Address updatedAddress = Address.fromJson(response.data);

          /// Notify parent on created address
          if(onCreatedAddress != null) onCreatedAddress!(updatedAddress);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t create address');

      }).whenComplete(() {

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
        name: addressForm['name'],
        addressLine: addressForm['addressLine']
      ).then((response) async {

        if(response.statusCode == 200) {

          final Address updatedAddress = Address.fromJson(response.data);

          /// Notify parent on update address
          if(onUpdatedAddress != null) onUpdatedAddress!(updatedAddress);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t update address');

      }).whenComplete(() {

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

        SnackbarUtility.showErrorMessage(message: 'Can\'t delete address');

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

              if(isCreating) const CustomMessageAlert(
                'Give your address an easy name to remember like Home, Work, Grannys House, e.t.c',
                margin: EdgeInsets.symmetric(vertical: 16),
              ),

              /// Spacer
              if(isEditing) const SizedBox(height: 16),

              /// Address Name Form Field
              CustomTextFormField(
                errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                initialValue: addressForm['name'],
                hintText: 'Grannys House',
                enabled: !isSubmitting,
                borderRadiusAmount: 16,
                labelText: 'Name',
                maxLength: 20,
                minLines: 1,
                onChanged: (value) {
                  setState(() => addressForm['name'] = value);
                  updateDeliveryAddress();
                },
                onSaved: (value) {
                  setState(() => addressForm['name'] = value ?? '');
                  updateDeliveryAddress();
                },
              ),
                
              /// Spacer
              const SizedBox(height: 16),

              /// Address Line Text Form Field
              CustomTextFormField(
                errorText: serverErrors.containsKey('addressLine') ? serverErrors['addressLine'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: 'Block 3, Plot 1234, house with white wall and black gate',
                initialValue: addressForm['addressLine'],
                enabled: !isSubmitting,
                borderRadiusAmount: 16,
                labelText: 'Address',
                maxLength: 200,
                minLines: 2,
                onChanged: (value) {
                  setState(() => addressForm['addressLine'] = value); 
                  updateDeliveryAddress();
                },
                onSaved: (value) {
                  setState(() => addressForm['addressLine'] = value ?? ''); 
                  updateDeliveryAddress();
                },
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Share Address Checkbox
              CustomCheckbox(
                crossAxisAlignment: CrossAxisAlignment.start,
                value: addressForm['shareAddress'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomBodyText('Share this address'),
                    SizedBox(height: 8,),
                    CustomBodyText('This allows other people to place orders to this address for delivery purposes. For privacy reasons, we will only show the address name and hide other details.', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => addressForm['shareAddress'] = value ?? false);
                }
              ),

              SizedBox(
                width: double.infinity,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSwitcher(
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                    child: showDummyDeliveryAddress ? Column(
                      children: [
                  
                        /// Spacer
                        const SizedBox(height: 16),
              
                        AddressCard(
                          user: user,
                          isSummarized: true,
                          address: dummySharedAddress!,
                        ),
              
                      ],
                    ) : null
                  
                  )
                ),
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