import '../../../core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_password_text_form_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_one_time_pin_field.dart';
import '../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import '../../../core/shared_widgets/chips/custom_mobile_number_chip.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/mobile_number.dart';
import '../models/account_existence_user.dart';
import '../../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/dialer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

  /// user - Reference to the user that is set after searching for
  /// a user account matching the given mobile number. This is the
  /// instance of that user that was found
  AccountExistenceUser? user;

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
      'user': user == null ? null : user!.toJson(),
    };
  }

  showSnackbarUnknownError(BuildContext context) {
    SnackbarUtility.showErrorMessage(message: 'Sorry, something went wrong');
  }

  showSnackbarValidationError(BuildContext context) {
    SnackbarUtility.showErrorMessage(message: 'We found some mistakes');
  }

  showSnackbarSigninSuccess(http.Response response, BuildContext context) {
    final responseBody = jsonDecode(response.body);
    final message = responseBody['message'];

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
    final mobileNumberWithoutExtension = user == null ? '' : user!.mobileNumber.withoutExtension;
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

  Widget getFirstNameField(Function setState) {

    void update(value) => setState(() => firstName = value);
    
    return CustomTextFormField(
      errorText: serverErrors.containsKey('firstName') ? serverErrors['firstName'] : null,
      initialValue: firstName,
      labelText: 'First Name',
      enabled: !isSubmitting,
      hintText: 'Katlego',
      onChanged: update,
      onSaved: update,
      maxLength: 20,
    );
      
  }

  Widget getLastNameField(Function setState) {

    void update(value) => setState(() => lastName = value);
    
    return CustomTextFormField(
      errorText: serverErrors.containsKey('lastName') ? serverErrors['lastName'] : null,
      enabled: !isSubmitting,
      initialValue: lastName,
      labelText: 'Last Name',
      hintText: 'Warona',
      onChanged: update,
      onSaved: update,
      maxLength: 20,
    );
      
  }

  Widget getMobileNumberField(Function setState) {

    void update(value) => setState(() => mobileNumber = value);

    return CustomMobileNumberTextFormField(
      errorText: serverErrors.containsKey('mobileNumber') ? serverErrors['mobileNumber'] : null,
      supportedMobileNetworkNames: const [
        MobileNetworkName.orange
      ],
      initialValue: mobileNumber,
      enabled: !isSubmitting,
      onChanged: update,
      onSaved: update
    );
      
  }

  Widget getPasswordField(Function setState, void Function() onSubmit) {

    void update(value) => setState(() => password = value);
    
    return CustomPasswordTextFormField(
      errorText: serverErrors.containsKey('password') ? serverErrors['password'] : null,
      onFieldSubmitted: (_) => onSubmit,
      enabled: !isSubmitting,
      initialValue: password,
      labelText: 'Password',
      onChanged: update,
      onSaved: update
    );
    
  }

  Widget getPasswordConfirmationField(Function setState, void Function() onSubmit) {

    void update(value) => setState(() => passwordConfirmation = value);
    
    return CustomPasswordTextFormField(
      errorText: serverErrors.containsKey('password') ? serverErrors['password'] : null,
      validatorOnEmptyText: 'Confirm password',
      initialValue: passwordConfirmation,
      onFieldSubmitted: (_) => onSubmit,
      labelText: 'Confirm Password',
      matchPassword: password,
      enabled: !isSubmitting,
      onChanged: update,
      onSaved: update
    );
    
  }

  Widget getMobileVerificationField(Function setState) {

    void update(value) => setState(() => verificationCode = value);
    
    return CustomOneTimePinField(
      errorText: serverErrors.containsKey('verificationCode') ? serverErrors['verificationCode'] : null,
      enabled: !isSubmitting,
      onCompleted: update,
      onSubmitted: update,
      onChanged: update,
      onSaved: update,
    );
    
  }

  Future<void> handleServerValidation(http.Response response, BuildContext context) async {

    if( response.statusCode == 422 ) {

      final responseBody = jsonDecode(response.body);
      final Map<String, dynamic> validationErrors = responseBody['errors'];

      /**
       *  validationErrors = {
       *    "mobileNumber": ["Enter a valid mobile number containing only digits e.g 26771234567"],
       *    "verificationCode": ["The verification code is not valid"],
       *  }
       */
      validationErrors.forEach((key, value){
        serverErrors[key] = value[0];
      });

      /// Validate the form but do not show the snackbar validation error message
      /// because the server validation message is shown using the Api Service
      /// handleRequestFailure() method.
      validateForm(context, canShowSnackbarValidationError: false);

    }

  }

  Future<bool> validateForm(BuildContext context, { bool canShowSnackbarValidationError = true }) {

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     */
    return Future.delayed(const Duration(milliseconds: 100)).then((value) {
      if( formKey.currentState!.validate() == true ) {
        return true;
      }else{
        if(canShowSnackbarValidationError) showSnackbarValidationError(context);
        return false;
      }
    });
    
  }

  void resetServerValidationErrors({ required Function setState }){
    setState(() {
      serverErrors = {};
    });
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

    if(data.containsKey('user')) user = (data['user'] == null ? null : AccountExistenceUser.fromJson(data['user']));
    if(data.containsKey('lastRecordedStageIndex')) lastRecordedStageIndex = data['lastRecordedStageIndex'];
  }

}