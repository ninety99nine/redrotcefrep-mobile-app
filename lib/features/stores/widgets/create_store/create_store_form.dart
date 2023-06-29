import 'package:bonako_demo/features/stores/models/shoppable_store.dart';

import '../../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../repositories/store_repository.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CreateStoreForm extends StatefulWidget {

  final Function(ShoppableStore)? onCreatedStore;

  const CreateStoreForm({
    super.key,
    this.onCreatedStore
  });

  @override
  State<CreateStoreForm> createState() => _CreateStoreFormState();
}

class _CreateStoreFormState extends State<CreateStoreForm> {
  
  String name = '';
  Map serverErrors = {};
  String description = '';
  bool isSubmitting = false;
  String callToAction = 'Buy';
  bool acceptedGoldenRules = false;
  final _formKey = GlobalKey<FormState>();

  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;
  StoreRepository get storeRepository => friendGroupProvider.storeRepository;
  StoreProvider get friendGroupProvider => Provider.of<StoreProvider>(context, listen: false);
  String? get nameErrorText => serverErrors.containsKey('name') ? serverErrors['name'] : null;
  String? get descriptionErrorText => serverErrors.containsKey('description') ? serverErrors['description'] : null;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  void _requestCreateStore() {

    _resetServerErrors().then((value) {

      if(_formKey.currentState!.validate()) {

        _startSubmittionLoader();

        storeRepository.createStore(
          name: name,
          description: description,
          callToAction: callToAction,
          acceptedGoldenRules: acceptedGoldenRules
        ).then((response) async {

          final responseBody = jsonDecode(response.body);

          if(response.statusCode == 201) {

            _resetForm();

            ShoppableStore createdStore = ShoppableStore.fromJson(responseBody);

            if(onCreatedStore != null) onCreatedStore!(createdStore);

            SnackbarUtility.showSuccessMessage(message: 'Store created');

          }else if(response.statusCode == 422) {

            handleServerValidation(responseBody['errors']);
            
          }

        }).catchError((error) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t create store');

        }).whenComplete((){

          _stopSubmittionLoader();

        });

      }else{

        SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

      }

    });

  }

  /// Reset the server errors
  void _resetForm() {
    setState(() {
      name = '';
      acceptedGoldenRules = false;

      Future.delayed(const Duration(milliseconds: 100)).then((value) {

        if(_formKey.currentState != null) {
          
          _formKey.currentState!.reset();

        }
      
      });
    });
  }

  /// Reset the server errors
  Future _resetServerErrors() {

    setState(() => serverErrors = {});

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     */
    return Future.delayed(const Duration(milliseconds: 100));
    
  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    name: [The name must be more than 3 characters]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  Widget get acceptedGoldenRulesCheckbox {
    return CustomCheckbox(
      disabled: isSubmitting,
      text: 'Accept Golden Rules',
      value: acceptedGoldenRules,
      onChanged: (status) {
        
        setState(() => acceptedGoldenRules = status ?? false);
        
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [

            /// Store Name
            CustomTextFormField(
              hintText: 'Baby Cakes 🧁',
              errorText: nameErrorText,
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              initialValue: name,
              labelText: 'Name',
              maxLength: 25,
              onChanged: (value) {
                setState(() => name = value); 
              },
            ),
              
            /// Spacer
            const SizedBox(height: 16),

            /// Description
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: 'The sweetest and softed cakes in the world 🍰',
              errorText: descriptionErrorText,
              initialValue: description,
              labelText: 'Description',
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              maxLength: 120,
              minLines: 2,
              onChanged: (value) {
                setState(() => description = value); 
              }
            ),

            /// Spacer
            const SizedBox(height: 16,),

            /// Accepted Golden Rules Checkbox
            acceptedGoldenRulesCheckbox,

            /// Spacer
            const SizedBox(height: 16,),

            /// Add Button
            CustomElevatedButton(
              width: 120,
              'Create Store',
              isLoading: isSubmitting,
              alignment: Alignment.center,
              onPressed: _requestCreateStore,
              disabled: name.isEmpty || !acceptedGoldenRules,
            )

          ]
        )
    );
  }
}