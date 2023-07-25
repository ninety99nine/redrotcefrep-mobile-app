import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../../../stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class JoinedStoresContent extends StatefulWidget {

  final Function? onJoined;

  const JoinedStoresContent({
    super.key,
    this.onJoined
  });

  @override
  State<JoinedStoresContent> createState() => JoinedStoresContentState();
}

class JoinedStoresContentState extends State<JoinedStoresContent> {

  Map serverErrors = {};
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  User get authUser => authProvider.user!;
  Function? get onJoined => widget.onJoined;
  Map joinForm = {'teamMemberJoinCode': null};
  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  bool get joinCodeIsExactlySixCharacters => joinForm['teamMemberJoinCode']?.length == 6;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  _requestJoinStore() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();

      userProvider.setUser(authUser).userRepository.joinStore(
        teamMemberJoinCode: joinForm['teamMemberJoinCode']
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message']);

          if(onJoined != null) onJoined!();

          refreshStores();

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t join store');

      }).whenComplete((){

        _stopSubmittionLoader();

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    team_member_join_code: [The team member join code must be more than 3 characters]
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

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    /// Create Store Card
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
      
                  /// Join Code Form Field
                  Expanded(
                    child: CustomTextFormField(
                      errorText: serverErrors.containsKey('teamMemberJoinCode') ? serverErrors['teamMemberJoinCode'] : null,
                      initialValue: joinForm['teamMemberJoinCode'],
                      enabled: !isSubmitting,
                      borderRadiusAmount: 16,
                      labelText: 'Join Code',
                      hintText: '123456',
                      maxLength: 6,
                      onChanged: (value) {
                        setState(() => joinForm['teamMemberJoinCode'] = value); 
                      }
                    ),
                  ),
      
                  /// Spacer
                  const SizedBox(width: 8),
      
                  /// Join Code Form Button
                  CustomElevatedButton(
                    'Join',
                    isLoading: isSubmitting,
                    alignment: Alignment.center,
                    onPressed: _requestJoinStore,
                    disabled: !joinCodeIsExactlySixCharacters || isSubmitting,
                  ),
      
                ],
              ),
      
            ]
          )
        ),
      ),
    );  
  }

  void refreshStores() {
    if(storeCardsState.currentState != null) {
      storeCardsState.currentState!.refreshStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreCards(
      key: storeCardsState,
      contentBeforeSearchBar: contentBeforeSearchBar,
      userAssociation: UserAssociation.teamMemberJoinedAsNonCreator,
    );
  }
}
