import 'package:perfect_order/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:perfect_order/features/addresses/widgets/address_cards_in_vertical_view.dart';
import 'package:perfect_order/features/authentication/repositories/auth_repository.dart';
import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/core/utils/error_utility.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

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
        'lastName': user.lastName,
        'aboutMe': user.aboutMe,
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
        firstName: userForm['firstName'],
        lastName: userForm['lastName'],
        aboutMe: userForm['aboutMe'],
      ).then((response) async {

        if(response.statusCode == 200) {

          final User updatedUser = User.fromJson(response.data);

          /// Notify parent on update user
          if(onUpdatedUser != null) onUpdatedUser!(updatedUser);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }


      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t update profile');

      }).whenComplete(() {

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: userForm.isEmpty ? [] : [

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
              child: Column(
                children: [
            
                  /// Spacer
                  const SizedBox(height: 16),

                  /// First Name
                  CustomTextFormField(
                    errorText: serverErrors.containsKey('firstName') ? serverErrors['firstName'] : null,
                    initialValue: userForm['firstName'],
                    labelText: 'First Name',
                    borderRadiusAmount: 16,
                    enabled: !isSubmitting,
                    hintText: 'Katlego',
                    maxLength: 20,
                    onChanged: (value) {
                      setState(() => userForm['firstName'] = value); 
                    }
                  ),
                  
                  /// Spacer
                  const SizedBox(height: 16),

                  /// Last Name
                  CustomTextFormField(
                    errorText: serverErrors.containsKey('lastName') ? serverErrors['lastName'] : null,
                    initialValue: userForm['lastName'],
                    enabled: !isSubmitting,
                    borderRadiusAmount: 16,
                    labelText: 'Last Name',
                    hintText: 'Warona',
                    maxLength: 20,
                    onChanged: (value) {
                      setState(() => userForm['lastName'] = value); 
                    }
                  ), 
                  
                  /// Spacer
                  const SizedBox(height: 16),

                  /// About Me
                  CustomTextFormField(
                    errorText: serverErrors.containsKey('aboutMe') ? serverErrors['aboutMe'] : null,
                    hintText: 'Hi there 😊, I\'m ${userForm['firstName']} and i sell the freshest vegetables in town. Check out what i have in store and place your order today!',
                    initialValue: userForm['aboutMe'],
                    enabled: !isSubmitting,
                    borderRadiusAmount: 16,
                    labelText: 'About Me',
                    isRequired: false,
                    maxLength: 200,
                    minLines: 4,
                    onChanged: (value) {
                      setState(() => userForm['aboutMe'] = value); 
                    }
                  ), 

                ],
              )
            ),

            /// Address Cards
            AddressCardsInVerticalView(
              user: user
            ),

            /// Spacer
            const SizedBox(height: 100)
            
          ]
        ),
      ),
    );
  }
}