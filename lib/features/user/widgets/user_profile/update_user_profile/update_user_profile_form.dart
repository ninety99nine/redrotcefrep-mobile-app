import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/authentication/repositories/auth_repository.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import 'package:bonako_demo/features/user/repositories/user_repository.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class UpdateUserProfileForm extends StatefulWidget {
  
  final User user;
  final Function(bool) onSubmitting;
  final Function(User)? onUpdatedUser;

  const UpdateUserProfileForm({
    super.key,
    required this.user,
    this.onUpdatedUser,
    required this.onSubmitting,
  });

  @override
  State<UpdateUserProfileForm> createState() => UpdateUserProfileFormState();
}

class UpdateUserProfileFormState extends State<UpdateUserProfileForm> {

  Map userForm = {};
  Map serverErrors = {};
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  
  User get user => widget.user;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function(User)? get onUpdatedUser => widget.onUpdatedUser;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    setUserForm();
  }

  setUserForm() {

    setState(() {
      
      userForm = {
        'firstName': user.firstName,
        'anonymous': user.anonymous,
        'lastName': user.lastName,
        'nickName': user.nickName,
      };

    });

  }

  requestUpdateUser() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      authProvider.setUser(user).authRepository.updateUser(
        anonymous: userForm['anonymous'],
        firstName: userForm['firstName'],
        lastName: userForm['lastName'],
        nickName: userForm['nickName'],
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final User updatedUser = User.fromJson(responseBody);

          /// Notify parent on update user
          if(onUpdatedUser != null) onUpdatedUser!(updatedUser);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update profile');

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    firstName: [The first name must be more than 3 characters]
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
            children: userForm.isEmpty ? [] : [
              
              /// Spacer
              const SizedBox(height: 16),

              /// First Name
              CustomTextFormField(
                errorText: serverErrors.containsKey('firstName') ? serverErrors['firstName'] : null,
                enabled: !isSubmitting,
                hintText: 'Katlego',
                borderRadiusAmount: 16,
                initialValue: userForm['firstName'],
                labelText: 'First Name',
                onChanged: (value) {
                  setState(() => userForm['firstName'] = value); 
                },
                onSaved: (value) {
                  setState(() => userForm['firstName'] = value ?? ''); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Last Name
              CustomTextFormField(
                errorText: serverErrors.containsKey('lastName') ? serverErrors['lastName'] : null,
                enabled: !isSubmitting,
                hintText: 'Warona',
                borderRadiusAmount: 16,
                initialValue: userForm['lastName'],
                labelText: 'Last Name',
                onChanged: (value) {
                  setState(() => userForm['lastName'] = value); 
                },
                onSaved: (value) {
                  setState(() => userForm['lastName'] = value ?? ''); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 8),

              /// Online Checkbox
              CustomCheckbox(
                value: userForm['anonymous'],
                disabled: isSubmitting,
                text: 'Make me anonymous',
                onChanged: (value) {
                  setState(() => userForm['anonymous'] = value ?? false); 
                }
              ),

              if(userForm['anonymous']) ...[

                /// Instructions
                const CustomMessageAlert('You are anonymous, your name will not be shown to other users except shopkeepers. We will use your nick name instead.'),
                
                /// Spacer
                const SizedBox(height: 16),

                /// Nick Name
                CustomTextFormField(
                  errorText: serverErrors.containsKey('nickName') ? serverErrors['nickName'] : null,
                  enabled: !isSubmitting,
                  hintText: 'Kat',
                  borderRadiusAmount: 16,
                  initialValue: userForm['nickName'],
                  labelText: 'Nick Name',
                  onChanged: (value) {
                    setState(() => userForm['nickName'] = value); 
                  },
                  onSaved: (value) {
                    setState(() => userForm['nickName'] = value ?? ''); 
                  },
                ),

              ],   

              /// Spacer
              const SizedBox(height: 100)
              
            ]
          ),
        ),
      ),
    );
  }
}