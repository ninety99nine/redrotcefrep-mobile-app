import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../core/shared_widgets/button/previous_text_button.dart';
import 'package:perfect_order/features/api/providers/api_provider.dart';
import 'package:perfect_order/features/api/models/api_home.dart';
import 'package:perfect_order/core/utils/error_utility.dart';
import '../../introduction/widgets/landing_page.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_form_service.dart';
import '../models/account_existence.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../enums/auth_enums.dart';
import 'package:get/get.dart';
import 'auth_scaffold.dart';

class ResetPasswordPage extends StatefulWidget {

  static const routeName = 'ResetPasswordPage';

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  
  AuthFormService authForm = AuthFormService(AuthFormType.resetPassword, ForgotPasswordStage.setNewPassword);

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
    
    /// The AuthScaffold is a wrapper around the ForgotPasswordForm
    return AuthScaffold(
      title: 'Forgot Your Password?',
      imageWidth: 180,
      authForm: authForm,
      imageUrl: 'assets/images/forgot-password.png',
      imageMargin: const EdgeInsets.only(top: 100, bottom: 16),
      form: ForgotPasswordForm(
        authForm: authForm
      ),
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  
  final AuthFormService authForm;

  const ForgotPasswordForm({ super.key, required this.authForm });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {

  int _animatedSwitcherKey = 1;
  ApiHome get apiHome => apiProvider.apiHome!;
  AuthFormService get authForm => widget.authForm;
  AuthRepository get authRepository => authProvider.authRepository;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  
  void _startSubmittionLoader() => setState(() => authForm.isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => authForm.isSubmitting = false);

  @override
  void initState() {

    super.initState();

        /// We use this delayed Future to access the BuildContext while in this initState() method
        Future.delayed(Duration.zero).then((value) {

          /**
           *  Check if this route has any data that was passed by navigating 
           *  from the Signinscreen. This data is  passed when coming from
           *  the Signinscreen, but sometimes it does not exist if we push
           *  to this screen from the AppHome screen after realising that
           *  we have an incomplete reset password form.
           */
          if( ModalRoute.of(context)!.settings.arguments != null ) {

            setState(() {

              /**
               *  Set the mobile number and the accountExistence that
               *  is shared by the Signinscreen
               */
              final Map arguments = ModalRoute.of(context)!.settings.arguments! as Map;
              authForm.mobileNumber = arguments['mobileNumber'] as String;
              authForm.accountExistence = arguments['accountExistence'] as AccountExistence;

            });
        
            /**
             *  Save the form on the device. We save the form with the
             *  default data that was shared by the Signinscreen. We
             *  start from the first stage.
             */
            authForm.saveFormOnDevice();

          }else{

            /**
             *  Check if we have an incomplete Form, then set the
             *  saved form data and the last recorded ForgotPasswordStage
             */
            authForm.setIncompleteFormData(authProvider).then((_) {

              /// Check if the last recorded ForgotPasswordStage index is set
              if( authForm.lastRecordedStageIndex != null ) {

                /**
                 *  Set the last recorded ForgotPasswordStage.
                 *  This will change the UI to the matching stage so
                 *  that the user can continue from where they left of 
                 */
                _changeForgotPasswordStage(ForgotPasswordStage.values[authForm.lastRecordedStageIndex!]);

                /// If the last recorded ForgotPasswordStage was the verification code stage
                if( ForgotPasswordStage.values[authForm.lastRecordedStageIndex!] == ForgotPasswordStage.enterVerificationCode ) {

                  /// Show the floating action button
                  authForm.toggleShowFloatingButton(apiHome.mobileVerificationShortcode, context);

                }

              }else{
                
                /**
                 *  Save the form on the device. We save the form with the
                 *  default data of AuthFormService. This means that we start
                 *  from the first stage and the form fields are empty
                 */
                  authForm.saveFormOnDevice();

              }

            });

          }

        });
    
  }

  void _onResetPassword() {

    if(authForm.isSubmitting) return;

    authForm.resetServerValidationErrors(setState: setState);

    ErrorUtility.validateForm(authForm.formKey).then((status) {

      if( status ) {

        authForm.saveForm();

        if (authForm.lastRecordedStage == ForgotPasswordStage.setNewPassword) {

          _requestValidateResetPassword();

        }else if (authForm.lastRecordedStage == ForgotPasswordStage.enterVerificationCode) {
          
          _requestResetPassword();

        }

      }

    });

  }

  Future<void> _requestValidateResetPassword() async {

    _startSubmittionLoader();

    /**
     *  Run the validateResetPassword() method to ensure that we 
     *  do not have any validation errors on the password and 
     *  the password confirmation fields before proceeding.
     */
    await authRepository.validateResetPassword(
      passwordConfirmation: authForm.passwordConfirmation,
      password: authForm.password!,
    ).then((response) async {

      if(response.statusCode == 200) {

        _changeForgotPasswordStage(ForgotPasswordStage.enterVerificationCode);

        /// Save the form on the device - We must save after the _changeForgotPasswordStage.
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

  Future<void> _requestResetPassword() async {

    _startSubmittionLoader();

    await authRepository.resetPassword(
      passwordConfirmation: authForm.passwordConfirmation!,
      mobileNumber: authForm.mobileNumberWithExtension,
      verificationCode: authForm.verificationCode!,
      password: authForm.password!,
    ).then((response) async {

      if(response.statusCode == 200) {

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

  void _changeForgotPasswordStage(ForgotPasswordStage currForgotPasswordStage) {
    setState(() {
      authForm.lastRecordedStage = currForgotPasswordStage;
      _animatedSwitcherKey += 1;
    });
  }

  Widget _getPreviousTextButton() {

    String text = 'Back';

    if( authForm.lastRecordedStage == ForgotPasswordStage.setNewPassword ) {
      text = 'Sign In';
    }

    return PreviousTextButton(
      text,
      disabled: authForm.isSubmitting,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: () async {

        if( authForm.lastRecordedStage == ForgotPasswordStage.setNewPassword ) {

          /// Remove the forms from the device
          authForm.unsaveFormOnDevice().whenComplete(() {
            
            Get.back();

          });

        }else if( authForm.lastRecordedStage == ForgotPasswordStage.enterVerificationCode ) {
          
          _changeForgotPasswordStage(ForgotPasswordStage.setNewPassword);

          /// Save the form on the device
          authForm.saveFormOnDevice();

          /// Hide the floating action button
          authForm.toggleShowFloatingButton(null, context);

        }

      },
    );
  }

  Widget _getSubmitButton() {

    String text = '';

    if( authForm.lastRecordedStage == ForgotPasswordStage.setNewPassword ) {
      text = 'Continue';
    }else if( authForm.lastRecordedStage == ForgotPasswordStage.enterVerificationCode ) {
      text = 'Verify';
    }

    return CustomElevatedButton(
      text,
      onPressed: _onResetPassword,
      isLoading: authForm.isSubmitting,
      //  disabled: authForm.isSubmitting,
      suffixIcon: Icons.arrow_forward_rounded,
    );
  }

  List<Widget> getAuthFormService() {

    List<Widget> formFields = [];

    final enterVerificationCode = authForm.lastRecordedStage == ForgotPasswordStage.enterVerificationCode;
    final setNewPassword = authForm.lastRecordedStage == ForgotPasswordStage.setNewPassword;

    if( setNewPassword ) {

      formFields.addAll([
        authForm.getAccountMobileNumberChip(),
        const SizedBox(height: 16),
        authForm.setNewPasswordInstruction(),
        const SizedBox(height: 16),
        authForm.getPasswordField(setState),
        const SizedBox(height: 16),
        authForm.getPasswordConfirmationField(setState, onSubmit: _onResetPassword)
      ]);

    }else if( enterVerificationCode ) {

      formFields.addAll([
        authForm.getAccountMobileNumberChip(),
        const SizedBox(height: 16),
        authForm.getVerificationCodeMessage(apiHome.mobileVerificationShortcode, authForm.mobileNumber!, context),
        const SizedBox(height: 16),
        authForm.getMobileVerificationField(setState, onSubmit: _onResetPassword)
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
      submitAndPreviousTextButton
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
                  ...getAuthFormService()
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
