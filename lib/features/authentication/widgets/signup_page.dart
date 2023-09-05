import 'package:bonako_demo/core/utils/error_utility.dart';

import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../core/shared_widgets/button/previous_text_button.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/api/models/api_home.dart';
import '../../introduction/widgets/landing_page.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_form_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../enums/auth_enums.dart';
import 'package:get/get.dart';
import 'auth_scaffold.dart';

class SignupPage extends StatefulWidget {

  static const routeName = 'SignupPage';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupPage> {
  
  AuthFormService authForm = AuthFormService(AuthFormType.signup, SignupStage.enterInfo);

  @override
  void initState() {
    
    super.initState();

    /**
     *  Set this Scaffold setState function to update the state 
     *  whenever the action floating button must appear or 
     *  disappear. The floating action button appears as
     *  a prompt for the user to tap and get redirected 
     *  to the device keypad where the verification
     *  shortcode is pasted so that the user can
     *  quickly dial. Its a convinient approach
     *  of quickly navigating to the dialer
     *  and dialing the verification
     *  shortcode.
     */
    authForm.scaffoldSetState = setState;

  }
  @override
  Widget build(BuildContext context) {
    
    /// The AuthScaffold is a wrapper around the SignupForm
    return AuthScaffold(
      title: 'Sign Up',
      authForm: authForm,
      imageUrl: 'assets/images/auth/11.png',
      form: SignupForm(
        authForm: authForm
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  
  final AuthFormService authForm;

  const SignupForm({ super.key, required this.authForm });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {

  int _animatedSwitcherKey = 1;
  
  void _startSubmittionLoader() => setState(() => authForm.isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => authForm.isSubmitting = false);

  ApiHome get apiHome => apiProvider.apiHome!;
  AuthFormService get authForm => widget.authForm;
  AuthRepository get authRepository => authProvider.authRepository;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  void initState() {
    
    super.initState();

    /**
     *  Check if we have an incomplete Form, then set the
     *  saved form data and the last recorded SignupStage
     */
    authForm.setIncompleteFormData(authProvider).then((_) {

      /// Check if the last recorded SignupStage index is set
      if( authForm.lastRecordedStageIndex != null ) {

        /**
         *  Set the last recorded SignupStage.
         *  This will change the UI to the matching stage so
         *  that the user can continue from where they left of 
         */
        _changeSignupStage(SignupStage.values[authForm.lastRecordedStageIndex!]);

        /// If the last recorded SignupStage was the verification code stage
        if( SignupStage.values[authForm.lastRecordedStageIndex!] == SignupStage.enterVerificationCode ) {

          /// Show the floating action button
          authForm.toggleShowFloatingButton(apiHome.mobileVerificationShortcode, context);

        }

      }else{
        
        /// Save the form on the device
        authForm.saveFormOnDevice();
            
      }

    });

  }

  void _onSignup() {

    if(authForm.isSubmitting) return;

    authForm.resetServerValidationErrors(setState: setState);

    ErrorUtility.validateForm(authForm.formKey).then((status) async {

      if( status ) {

        authForm.saveForm();

        if(authForm.lastRecordedStage == SignupStage.enterInfo) {

          await _requestValidateSignup();

        }else if (authForm.lastRecordedStage == SignupStage.enterVerificationCode) {
          
          await _requestSignup();
          return;

        }
        
        /// Save the form on the device - We must save after the _changeSignupStage.
        /// Only save after the _requestValidateSignup() since the _requestSignin() 
        /// will unsave the form once the signup is successful.
        authForm.saveFormOnDevice();

      }

    });

  }

  Future<void> _requestValidateSignup() async {

    _startSubmittionLoader();

    /**
     *  Run the validateSignup() method to ensure that we 
     *  do not have any validation errors on the fields
     *  before proceeding.
     */
    await authRepository.validateSignup(
      passwordConfirmation: authForm.passwordConfirmation,
      mobileNumber: authForm.mobileNumberWithExtension,
      firstName: authForm.firstName!,
      lastName: authForm.lastName!,
      password: authForm.password!,
    ).then((response) async {

      if(response.statusCode == 200) {

        _changeSignupStage(SignupStage.enterVerificationCode);

        /// Save the form on the device
        authForm.saveFormOnDevice();

        /// Show the floating action button
        authForm.toggleShowFloatingButton(apiHome.mobileVerificationShortcode, context);

      }

    }).onError((dio.DioException exception, stackTrace) {

      ErrorUtility.setServerValidationErrors(setState, authForm.serverErrors, exception);

    }).catchError((error) {

      printError(info: error.toString());

      authForm.showSnackbarUnknownError();

    }).whenComplete((){

      _stopSubmittionLoader();

    });
    
  }

  Future<void> _requestSignup() async {

    _startSubmittionLoader();

    await authRepository.signup(
      passwordConfirmation: authForm.passwordConfirmation,
      mobileNumber: authForm.mobileNumberWithExtension,
      verificationCode: authForm.verificationCode!,
      firstName: authForm.firstName!,
      lastName: authForm.lastName!,
      password: authForm.password!,
    ).then((response) async {

      if(response.statusCode == 201) {

        authForm.showSnackbarSigninSuccess(response);

        Get.offAndToNamed(LandingPage.routeName);

        /// Remove the forms from the device
        await authForm.unsaveFormOnDevice();

      }

    }).onError((dio.DioException exception, stackTrace) {

      ErrorUtility.setServerValidationErrors(setState, authForm.serverErrors, exception);

    }).catchError((error) {

      printError(info: error.toString());

      authForm.showSnackbarUnknownError();

    }).whenComplete((){

      _stopSubmittionLoader();

    });

  }

  void _changeSignupStage(SignupStage currSignupStage) {
    setState(() {
      authForm.lastRecordedStage = currSignupStage;
      _animatedSwitcherKey += 1;
    });
  }

  Widget _getPreviousTextButton() {

    String text = 'Back';

    if( authForm.lastRecordedStage == SignupStage.enterInfo ) {
      text = 'Sign In';
    }

    return PreviousTextButton(
      text,
      disabled: authForm.isSubmitting,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: () {

        if( authForm.lastRecordedStage == SignupStage.enterInfo ) {

          /// Remove the forms from the device
          authForm.unsaveFormOnDevice().whenComplete(() {
            
            Get.back();
            
          });

        }else if( authForm.lastRecordedStage == SignupStage.enterVerificationCode ) {
          
          _changeSignupStage(SignupStage.enterInfo);

          /// Hide the floating action button
          authForm.toggleShowFloatingButton(null, context);

          /// Save the form on the device
          authForm.saveFormOnDevice();

        }

      },
    );
  }

  Widget _getSubmitButton() {

    String text = 'Continue';

    if( authForm.lastRecordedStage == SignupStage.enterVerificationCode ) {
      text = 'Sign Up';
    }

    return CustomElevatedButton(
      text,
      onPressed: _onSignup,
      isLoading: authForm.isSubmitting,
      //  disabled: authForm.isSubmitting,
      suffixIcon: Icons.arrow_forward_rounded,
    );
  }

  List<Widget> getAuthForm() {

    List<Widget> formFields = [];

    final enterVerificationCode = authForm.lastRecordedStage == SignupStage.enterVerificationCode;
    final enterInfo = authForm.lastRecordedStage == SignupStage.enterInfo;

    if( enterInfo ) {

      formFields.addAll([
        authForm.getFirstNameField(setState),
        const SizedBox(height: 16),
        authForm.getLastNameField(setState),
        const SizedBox(height: 16),
        authForm.getMobileNumberField(setState),
        const SizedBox(height: 16),
        authForm.getPasswordField(setState, _onSignup),
        const SizedBox(height: 16),
        authForm.getPasswordConfirmationField(setState, _onSignup),
      ]);

    }else if( enterVerificationCode ) {

      formFields.addAll([
        authForm.getVerificationCodeMessage(apiHome.mobileVerificationShortcode, authForm.mobileNumber!, context),
        const SizedBox(height: 16),
        authForm.getMobileVerificationField(setState)
      ]);

    }

    Widget submitAndPreviousTextButton = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getPreviousTextButton(),
        _getSubmitButton()
      ],
    );

    formFields.addAll([      
      const SizedBox(height: 16),
      submitAndPreviousTextButton,
    ]);

    return formFields;

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: authForm.formKey,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          
          /**
           *  AnimatedSize helps to animate the sizing of the
           *  form from a bigger height to a smaller height.
           *  When adding or removing some form fields, the
           *  transition will be jumpy since the height is
           *  not the same. This helps animate those
           *  height differences
           */
          AnimatedSize(
            clipBehavior: Clip.none,
            duration: const Duration(milliseconds: 500),
            /**
             *  AnimatedSwitcher helps to animate the fading of the
             *  form as the form fields are swapped and the form
             *  transitions from one stage to another
             */
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: ValueKey(_animatedSwitcherKey),
                children: <Widget>[
                  ...getAuthForm()
                ],
              ),
            ),
          ),
          
          //  if(authForm.isSubmitting) const CustomCircularProgressIndicator()
        ],
      ),
    );
  }
}
