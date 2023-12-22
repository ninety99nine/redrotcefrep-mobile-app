import 'package:bonako_demo/core/utils/error_utility.dart';

import '../../../core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_password_text_form_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_one_time_pin_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import '../../../core/shared_widgets/chips/custom_mobile_number_chip.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/mobile_number.dart';
import '../models/account_existence.dart';
import '../../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/dialer.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../enums/auth_enums.dart';
import 'dart:convert';

class AuthFormService {

  /// formKey - The global key required by the Form widget
  GlobalKey<FormState> formKey = GlobalKey();

  /// serverErrors - A map of validation errors from the server side
  Map<String, String> serverErrors = {};

  /// floatingButtonAction - Floating action button Function that
  /// launches the mobile verification shortcode on the device 
  /// keypad so that the user can conveniently dial and view 
  /// the verification code on their mobile device
  void Function()? floatingButtonAction;

  /// scaffoldSetState - Reference to the setState function on the
  /// SigninPage, SignupPage and the ResetPasswordPage. This allows
  /// us to run the setState on that element of the widget tree
  Function? scaffoldSetState;

  /// accountExistence - Reference to the account existence information 
  /// that is set after searching for a user account matching the 
  /// given mobile number.
  AccountExistence? accountExistence;

  /// isSubmitting - Whether or not the form is being submitted
  /// at any point in time during the SigninStage, SignupStage 
  /// or ForgotPasswordStage stage.
  bool isSubmitting = false;

  /// lastRecordedStageIndex - Reference to the index of the auth Enums
  /// that are used to know exactly which stage of the process the user 
  /// is on. These Enums are the SigninStage, SignupStage and the
  /// ForgotPasswordStage. It is not possible to JSON jsonEncode
  /// and save an Enum, therefore we save the Enum index value so 
  /// that we can then use that Enum index value to retrieve the
  /// last recorded SigninStage, SignupStage or 
  /// ForgotPasswordStage.
  int? lastRecordedStageIndex;

  /// lastRecordedStage - Reference to the auth Enums that are used to 
  /// know exactly which stage of the process the user is on. These 
  /// Enums are the SigninStage, SignupStage and the
  /// ForgotPasswordStage.
  Enum lastRecordedStage;

  /// type - Reference to the to the AuthFormType Enum. This is the
  /// type of form that is being displayed. These Enums are the
  /// signin, signup and resetPassword
  AuthFormType type;

  /// The following are the data payloads required to capture the
  /// auth data required for signin, signup or resetPassword
  String? passwordConfirmation;
  String? verificationCode;
  String? mobileNumber;
  String? firstName;
  String? lastName;
  String? password;

  /// This is the Constructor - It requires the type of form
  /// that is displayed and the initial starting stage
  AuthFormService(this.type, this.lastRecordedStage);

  /// This is a getter of the mobile number with the extension
  String get mobileNumberWithExtension {
    if(mobileNumber == null) return '';
    return MobileNumberUtility.addMobileNumberExtension(mobileNumber!);
  }

  /// Get the data payloads as a Map of values
  Map getForm() {
    return {
      'password_confirmation': passwordConfirmation,
      'verification_code': verificationCode,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,

      'lastRecordedStageIndex': lastRecordedStage.index,
      'account_existence': accountExistence == null ? null : accountExistence!.toJson(),
    };
  }

  showSnackbarUnknownError() {
    SnackbarUtility.showErrorMessage(message: 'Sorry, something went wrong');
  }

  showSnackbarSigninSuccess(dio.Response response) {
    final message = response.data['message'];

    SnackbarUtility.showSuccessMessage(message: message);
  }

  Widget enterMobileNumberToSigninInstruction() {
    return const CustomBodyText('Enter your Orange mobile number to sign in');
  }

  Widget enterPasswordToSigninInstruction() {
    return const CustomBodyText('Enter your account password to sign in');
  }

  Widget setNewPasswordInstruction() {
    return const CustomBodyText('Set a new password for your account');
  }

  Widget floatingActionButton() {
    
    /// Return the floating action button with the icon and label
    return FloatingActionButton.extended(
      icon: const Icon(Icons.phone),
      onPressed: floatingButtonAction,
      label: const Text('Tap to dial'),
    );

  }

  void toggleShowFloatingButton(String? shortcode, BuildContext context) {
    /**
     *  Hide or show the floating action button based on whether
     *  or not the shortcode was provided. If the shortcode was 
     *  provided then show the floating action button, 
     *  otherwise if the shortcode is null, then hide 
     *  the floating action button
     */
    if( scaffoldSetState != null ) {

      /**
       *  This will fire setState on the Scaffold of the SigninStage,
       *  SignupStage or the ForgotPasswordStage. This will cause
       *  a widget rebuild of the AuthScaffold. Once the rebuild
       *  occurs, the floating action button can be shown or
       *  hidden. Thats the main purpose of 
       *  scaffoldSetState((){ ... })
       */
      scaffoldSetState!(() {

        /**
         *  Inside scaffoldSetState((){ ... }), we want to change the
         *  value of the floatingButtonAction so that this can set
         *  the onPressed() value of FloatingActionButton. If null
         *  this will hide FloatingActionButton, otherwise if the
         *  shortcode is present, it will show.
         */
        floatingButtonAction = shortcode == null ? null : () {
          DialerUtility.dial(
            number: shortcode
          );
        };
      });
    }
  }

  Widget getAccountMobileNumberChip() {
    final mobileNumberWithoutExtension = accountExistence == null ? '' : accountExistence!.existingAccount.mobileNumber.withoutExtension;
    return CustomMobileNumberChip(name: mobileNumberWithoutExtension);
  }

  Widget getVerificationCodeMessage(String shortcode, String $mobileNumber, BuildContext context) {
    final bodyMedium = Theme.of(context).textTheme.bodyMedium!;

    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Text(
            'Dial $shortcode on $mobileNumber to verify that you own this mobile',
            style: bodyMedium.copyWith(
              height: 1.6
            )
          ),
        ),
      ],
    );
  }

  Widget getFirstNameField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() => firstName = value);
    
    return CustomTextFormField(
      errorText: serverErrors.containsKey('firstName') ? serverErrors['firstName'] : null,
      onFieldSubmitted: (_) => onSubmit?.call(),
      initialValue: firstName,
      labelText: 'First Name',
      enabled: !isSubmitting,
      onChanged: onChanged,
      hintText: 'Katlego',
      maxLength: 20,
    );
      
  }

  Widget getLastNameField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() => lastName = value);
    
    return CustomTextFormField(
      errorText: serverErrors.containsKey('lastName') ? serverErrors['lastName'] : null,
      onFieldSubmitted: (_) => onSubmit?.call(),
      enabled: !isSubmitting,
      initialValue: lastName,
      labelText: 'Last Name',
      onChanged: onChanged,
      hintText: 'Warona',
      maxLength: 20,
    );
      
  }

  Widget getMobileNumberField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() {
      mobileNumber = value;
      if(mobileNumber?.length == 8 && onSubmit != null) onSubmit();
    });

    return CustomMobileNumberTextFormField(
      errorText: serverErrors.containsKey('mobileNumber') ? serverErrors['mobileNumber'] : null,
      supportedMobileNetworkNames: const [
        MobileNetworkName.orange
      ],
      onFieldSubmitted: (_) => onSubmit?.call(),
      initialValue: mobileNumber,
      enabled: !isSubmitting,
      onChanged: onChanged
    );
      
  }

  Widget getPasswordField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() => password = value);
    
    return CustomPasswordTextFormField(
      errorText: serverErrors.containsKey('password') ? serverErrors['password'] : null,
      onFieldSubmitted: (_) => onSubmit?.call(),
      enabled: !isSubmitting,
      initialValue: password,
      labelText: 'Password',
      onChanged: onChanged
    );
    
  }

  Widget getPasswordConfirmationField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() => passwordConfirmation = value);
    
    return CustomPasswordTextFormField(
      errorText: serverErrors.containsKey('password') ? serverErrors['password'] : null,
      validatorOnEmptyText: 'Confirm password',
      initialValue: passwordConfirmation,
      onFieldSubmitted: (_) => onSubmit?.call(),
      labelText: 'Confirm Password',
      matchPassword: password,
      enabled: !isSubmitting,
      onChanged: onChanged
    );
    
  }

  Widget getMobileVerificationField(Function setState, { void Function()? onSubmit }) {

    void onChanged(value) => setState(() {
      verificationCode = value;
      if(verificationCode?.length == 6 && onSubmit != null) onSubmit();
    });
    
    return CustomOneTimePinField(
      errorText: serverErrors.containsKey('verificationCode') ? serverErrors['verificationCode'] : null,
      enabled: !isSubmitting,
      onChanged: onChanged
    );
    
  }

  void resetServerValidationErrors({ required Function setState }){
    setState(() => serverErrors = {});
  }

  void saveForm() {
    return formKey.currentState!.save();
  }

  /// Save the authentication form on the device storage.
  /// The authentication form contains information such
  /// as the user mobile number, first name, last name,
  /// e.t.c to use for signin, signup or reset password
  Future saveFormOnDevice() {
    
    return SharedPreferences.getInstance().then((prefs) async {

      /// Get the authentication form data
      Map data = getForm();
      
      /// Set the expiresAt date and time (10 minutes from now)
      data.addAll({
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)).toIso8601String()
      });

      /**
       *  Store the auth data on the device
       * 
       *  Note that "type.name" equals "signin", "signup" or "resetPassword"
       * 
       *  Refer to the AuthFormType enum
       */
      await prefs.setString(type.name, jsonEncode(data));

    });

  }

  /// Remove the authentication form saved on the device storage.
  /// The authentication form contains information such as the 
  /// user mobile number, first name, last name, e.t.c to use 
  /// for signin, signup or reset password
  Future unsaveFormOnDevice({ AuthFormType? type }) {
    
    return SharedPreferences.getInstance().then((prefs){

      /**
       *  Remove the auth data saved on the device
       * 
       *  Note that "type.name" equals "signin", "signup" or "resetPassword"
       * 
       *  Refer to the AuthFormType enum
       * 
       *  If the type is provided via the method constructor, then use this
       *  type (this works best for the unsaveFormsOnDevice() method), 
       *  otherwise use the current AuthFormService instance type. 
       */
      prefs.remove((type ?? this.type).name);

    });

  }

  /// Remove the authentication forms saved on the device storage.
  /// The authentication form contains information such as the 
  /// user mobile number, first name, last name, e.t.c to use 
  /// for signin, signup or reset password
  Future<void> unsaveFormsOnDevice() async {
    
    for (var type in [AuthFormType.signin, AuthFormType.signup, AuthFormType.resetPassword]) {
      await unsaveFormOnDevice(type: type);
    }

  }

  Future<AuthFormService> setIncompleteFormData(AuthProvider authProvider) {

    /// Check if the auth form data exists on the device storage
    return hasFormOnDevice(type).then((hasIncompleteForm) async {

      /// If the form data exists
      if( hasIncompleteForm ) {

        /// Get the auth signin data from the device storage
        await getFormOnDevice(type).then((data) {

          /// Get the form data
          setFromData(data!);

        });

      }

      return this;

    });

  }

  /// Check if the authentication form exists on the device storage.
  /// The authentication form contains information such as he user 
  /// mobile number, first name, last name, e.t.c  to use for
  /// signin, signup or reset password
  Future<bool> hasFormOnDevice(AuthFormType type) async {
    
    return await getFormOnDevice(type).then((data) {

      /// Return true if the data is not null
      return data != null;

    });

  }

  /// Get the authentication form saved on the device storage.
  /// The authentication form contains information such as 
  /// the user mobile number, first name, last name, e.t.c 
  /// to use for signin, signup or reset password
  Future<Map<String, dynamic>?> getFormOnDevice(AuthFormType type) {
    
    return SharedPreferences.getInstance().then((prefs) {

      /**
       *  Get the authentication form data stored on the device
       * 
       *  Note that "type.name" equals
       *  "signin", "signup" or "resetPassword"
       * 
       *  Refer to the AuthFormType enum
       */
      final data = jsonDecode( (prefs.getString(type.name)) ?? '{}' );

      /// Check if the data exists and has not expired
      final isValidData = data.isNotEmpty && DateTime.parse(data['expiresAt']).isAfter(DateTime.now());

      /// Return the valid data of null
      return isValidData ? data : null;

    });

  }

  void setFromData(Map<String, dynamic> data) {
    if(data.containsKey('password_confirmation')) passwordConfirmation = data['password_confirmation'];
    if(data.containsKey('verification_code')) verificationCode = data['verification_code'];
    if(data.containsKey('mobile_number')) mobileNumber = data['mobile_number'];
    if(data.containsKey('first_name')) firstName = data['first_name'];
    if(data.containsKey('last_name')) lastName = data['last_name'];
    if(data.containsKey('password')) password = data['password'];

    if(data.containsKey('account_existence')) accountExistence = (data['account_existence'] == null ? null : AccountExistence.fromJson(data['account_existence']));
    if(data.containsKey('lastRecordedStageIndex')) lastRecordedStageIndex = data['lastRecordedStageIndex'];
  }

}