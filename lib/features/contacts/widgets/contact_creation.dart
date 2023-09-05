import 'package:get/get.dart';

import '../../../core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/utils/mobile_number.dart';
import '../../../core/utils/snackbar.dart';
import 'package:flutter/material.dart';

class ContactCreation extends StatefulWidget {
  
  final void Function(Contact) onCreated;

  const ContactCreation({
    super.key,
    required this.onCreated,
  });

  @override
  State<ContactCreation> createState() => _FollowersModalBottomSheetState();
}

class _FollowersModalBottomSheetState extends State<ContactCreation> {
  
  String lastName = '';
  String firstName = '';
  bool isLoading = false;
  String mobileNumber = '';
  GlobalKey<FormState> formKey = GlobalKey();
  
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  //// This is a getter of the mobile number with the extension
  String get mobileNumberWithExtension {
    return MobileNumberUtility.addMobileNumberExtension(mobileNumber);
  }

  void _createContact() async {

    if(formKey.currentState!.validate()) {

      _startLoader();

      /// Set a new contact
      final newContact = Contact()
        ..name.first = firstName
        ..name.last = lastName
        ..phones = [Phone(mobileNumberWithExtension)];

      /// Insert a new contact
      await newContact.insert().then((value) {

        SnackbarUtility.showSuccessMessage(message: 'Contact created successfully');
        widget.onCreated(newContact);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t create contact');

      }).whenComplete(() {

        _stopLoader();

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.only(top: 32.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [

                Row(
                  children: [
              
                    //// First Name Field
                    Expanded(
                      child: CustomTextFormField(
                        initialValue: firstName,
                        hintText: 'First name',
                        enabled: !isLoading,
                        maxLength: 20,
                        onChanged: (value) {
                          firstName = value;
                        },
                        validator: (value) {
                          if(value == null || value == '') {
                            return 'Please enter the contacts first name';
                          }else if(value.length < 3) {
                            return 'Please enter 3 or more characters e.g Neo';
                          }
                          return null;
                        },
                        //// onSaved: update
                      ),
                    ),
              
                    const SizedBox(width: 16,),
                  
                    //// Last Name Field
                    Expanded(
                      child: CustomTextFormField(
                        initialValue: lastName,
                        hintText: 'Last name',
                        enabled: !isLoading,
                        maxLength: 20,
                        onChanged: (value) {
                          lastName = value;
                        },
                        validator: (value) {
                          if(value != null && value != '') {
                            if(value.length < 3) {
                              return 'Please enter 3 or more characters e.g Warona';
                            }
                          }
                          return null;
                        },
                        //// onSaved: update
                      ),
                    ),

                  ],
                ),
          
                const SizedBox(height: 16,),
              
                //// Mobile Number Field
                CustomMobileNumberTextFormField(
                  supportedMobileNetworkNames: const [
                    MobileNetworkName.orange,
                  ],
                  initialValue: mobileNumber,
                  enabled: !isLoading,
                  onChanged: (value) {
                    mobileNumber = value;
                  },
                  //// onSaved: update
                ),
          
                const SizedBox(height: 16,),
          
                //// Create Contact Button
                CustomElevatedButton(
                  width: 120,
                  'Create Contact',
                  isLoading: isLoading,
                  alignment: Alignment.center,
                  onPressed: _createContact,
                ),
          
                //// Spacer
                const SizedBox(height: 100,)
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}