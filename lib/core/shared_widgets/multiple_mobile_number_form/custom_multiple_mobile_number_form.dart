import '../../../../core/shared_widgets/text_form_fields/custom_mobile_number_text_form_field.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../features/contacts/widgets/contacts_modal_popup.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../core/utils/mobile_number.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class CustomMultipleMobileNumberForm extends StatefulWidget {
  
  final String? instruction;
  final bool Function()? onValidate;
  final void Function(bool)? onLoading;
  final Widget Function(bool)? contentAfterMobileNumbers;
  final Future<http.Response> Function(List<String>) onRequest;

  const CustomMultipleMobileNumberForm({
    super.key,
    this.onLoading,
    this.onValidate,
    this.instruction,
    required this.onRequest,
    this.contentAfterMobileNumbers
  });

  @override
  State<CustomMultipleMobileNumberForm> createState() => _FriendSendInvitationState();
}

class _FriendSendInvitationState extends State<CustomMultipleMobileNumberForm> {
  
  Map serverErrors = {};
  bool isLoading = false;
  int formFieldReRenderKey = 1;
  List<String> mobileNumbers = [''];
  GlobalKey<FormState> formKey = GlobalKey();

  String? get instruction => widget.instruction;
  int get totalMobileNumbers => mobileNumbers.length;
  bool Function()? get onValidate => widget.onValidate;
  void Function(bool)? get onLoading => widget.onLoading;
  bool get hasOneMobileNumber => totalMobileNumbers == 1;
  Future<http.Response> Function(List<String>) get onRequest => widget.onRequest;
  Widget Function(bool)? get contentAfterMobileNumbers => widget.contentAfterMobileNumbers;
  
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  /// Add mobile number field
  void addMobileNumberField() {
    if(!isLoading) {
      mobileNumbers.add('');
      _resetServerErrors();
    }
  }

  /// Remove mobile number field
  void removeMobileNumberField(int index) {
    if(mobileNumbers.length >= 2 && !isLoading) {
      mobileNumbers.removeAt(index);
      _resetServerErrors();
    }
  }

  /// Request to invite friends
  _startRequest() {

    _resetServerErrors();

    if(formKey.currentState!.validate()) {

      /// Check the parent widget validator before making this request
      final isValid = onValidate == null ? true : onValidate!();

      if(isValid) {

        _startLoader();
        
        /// Notify parent that we are loading
        if(onLoading != null) onLoading!(true);

        /// Make an Api Request
        onRequest(mobileNumbers).then((response) {

          final responseBody = jsonDecode(response.body);

          if(response.statusCode == 200) {

            _resetMobileNumbers();

          }else if(response.statusCode == 422) {

            handleServerValidation(responseBody['errors']);
            
          }

        }).whenComplete((){

          _stopLoader();
        
          /// Notify parent that we are not loading
          if(onLoading != null) onLoading!(false);

        });

      }

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  /// Handle server validation by setting the serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    mobileNumbers0: [The mobile number must start with one of the following: 267.]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  /// Reset the serverErrors
  void _resetServerErrors() {
    setState(() => serverErrors = {});
  }

  /// Reset the mobile numbers
  void _resetMobileNumbers() {
    setState(() => mobileNumbers = []);
  }

  /// Add mobile numbers of selected contacts
  void onContactSelection(List<Contact> contacts) {
    
    _resetServerErrors();

    if(contacts.isNotEmpty) {

      for (var x = 0; x < contacts.length; x++) {

        Contact currentContact = contacts[x];

        if( currentContact.phones.isNotEmpty ) {

          final selectedMobileNumber = MobileNumberUtility.simplify(currentContact.phones.first.number);

          for (var y = 0; y < mobileNumbers.length; y++) {

            /// If the mobile number does not already exist
            if(mobileNumbers.contains(selectedMobileNumber) == false) {
              
              //  Get an existing empty mobile number field value
              final index = mobileNumbers.indexWhere((existingMobileNumber) => existingMobileNumber.isEmpty);

              //  If we have an existing empty mobile number field value
              if(index >= 0) {

                //  Update this empty mobile number with the current value
                mobileNumbers[index] = selectedMobileNumber;

              }else{
          
                /// Add a new mobile number
                mobileNumbers.add(selectedMobileNumber);

              }

            }

          }

        }
        
      }

      /// Force a rebuild of the form fields
      setState(() => formFieldReRenderKey++);

    }

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 16.0),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// Contact Selector
              ContactsModalPopup(
                disabled: isLoading,
                enableBulkSelection: true,
                onSelection: onContactSelection,
                supportedMobileNetworkNames: const [
                  MobileNetworkName.orange
                ],
              ),
        
              /// Spacer
              const SizedBox(height: 8,),
              
              Row(
                children: [

                  /// Instructions
                  Expanded(
                    child: CustomBodyText(
                      'Enter the Orange mobile number of the ${hasOneMobileNumber ? 'person' : 'people'} ${instruction == null ? '' : instruction!}',
                      padding: const EdgeInsets.all(8.0),
                      height: 1.4,
                    ),
                  ),
        
                  /// Add More Mobile Numbers Button
                  CustomChoiceChip(
                    labelWidget: Icon(Icons.add, color: Theme.of(context).primaryColor),
                    onSelected: (_) => addMobileNumberField(),
                  )

                ],
              ),
        
              /// Spacer
              const SizedBox(height: 16,),

              /// Mobile Number Fields
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                  child: Form(
                    key: formKey,
                    child: Column(
                      key: ValueKey('$totalMobileNumbers $formFieldReRenderKey'),
                      children: [
                        
                        /// List the Mobile Number Fields
                        ...mobileNumbers.mapIndexed((index, mobileNumber) {
                          return Column(
                            children: [
                              Row(
                                children: [
                              
                                  /// Mobile Number Field
                                  Expanded(
                                    child: CustomMobileNumberTextFormField(
                                      supportedMobileNetworkNames: const [
                                        MobileNetworkName.orange
                                      ],
                                      initialValue: mobileNumber,
                                      errorText: serverErrors.containsKey('mobileNumbers$index') ? serverErrors['mobileNumbers$index'] : null,
                                      //enabled: !isSubmitting,
                                      onChanged: (value) {
                                        mobileNumbers[index] = value;
                                        if(serverErrors.isNotEmpty) _resetServerErrors();
                                      },
                                      //onSaved: update
                                    ),
                                  ),
                                  
                                  /// Spacer
                                  if(!hasOneMobileNumber) const SizedBox(width: 8,),
                              
                                  /// Remove Button
                                  if(!hasOneMobileNumber) IconButton(
                                    onPressed: () => removeMobileNumberField(index), 
                                    icon: const Icon(Icons.remove_circle, color: Colors.grey,)
                                  )
                              
                                ],
                              ),
                              const SizedBox(height: 16,)
                            ],
                          );
                        }).toList(),

                        /// Content After Mobile Number Fields
                        if(contentAfterMobileNumbers != null) contentAfterMobileNumbers!(isLoading)
                  
                      ],
                    ),
                  )
                )
              ),

              /// Spacer
              SizedBox(height: isLoading ? 16 : 0,),

              /// Invite Button
              isLoading 
                ? const CustomCircularProgressIndicator()
                : CustomElevatedButton(
                  'Invite',
                  isLoading: isLoading,
                  alignment: Alignment.center,
                  onPressed: _startRequest,
                ),

              /// Spacer
              const SizedBox(height: 100,)
              
            ],
          ),
        ),
      ),
    );
  }
}