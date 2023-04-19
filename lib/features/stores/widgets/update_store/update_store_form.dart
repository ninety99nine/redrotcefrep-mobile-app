import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/switch/custom_switch.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_field_tags/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/products/repositories/product_repository.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import 'package:bonako_demo/features/stores/repositories/store_repository.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class UpdateStoreForm extends StatefulWidget {
  
  final ShoppableStore store;
  final Function(bool) onSubmitting;
  final Function(ShoppableStore)? onUpdatedStore;

  const UpdateStoreForm({
    super.key,
    required this.store,
    this.onUpdatedStore,
    required this.onSubmitting,
  });

  @override
  State<UpdateStoreForm> createState() => UpdateStoreFormState();
}

class UpdateStoreFormState extends State<UpdateStoreForm> {

  Map storeForm = {};
  Map serverErrors = {};
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final TextfieldTagsController _deliveryDestinationsController = TextfieldTagsController();
  
  ShoppableStore get store => widget.store;
  Function(bool) get onSubmitting => widget.onSubmitting;
  StoreRepository get storeRepository => storeProvider.storeRepository;
  Function(ShoppableStore)? get onUpdatedStore => widget.onUpdatedStore;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    setStoreForm();
  }

  @override
  void dispose() {
    super.dispose();
    _deliveryDestinationsController.dispose();
  }

  setStoreForm() {

    setState(() {
      
      storeForm = {

        /// Store
        'name': store.name,
        'online': store.online,
        'description': store.description,
        'offlineMessage': store.offlineMessage,

        /// Delivery
        'deliveryNote': store.deliveryNote,
        'allowDelivery': store.allowDelivery,
        'allowFreeDelivery': store.allowFreeDelivery,
        'deliveryDestinations': store.deliveryDestinations,
        'deliveryFlatFee': store.deliveryFlatFee.amountWithoutCurrency,

        /// Pickup
        'pickupNote': store.pickupNote,
        'allowPickup': store.allowPickup,
        'pickupDestinations': store.pickupDestinations,

        /// Payment
        'supportedPaymentMethods': store.supportedPaymentMethods,

      };

    });

  }

  requestUpdateStore() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      storeProvider.setStore(store).storeRepository.updateStore(
        name: storeForm['name'],
        online: storeForm['online'],
        pickupNote: storeForm['pickupNote'],
        allowPickup: storeForm['allowPickup'],
        description: storeForm['description'],
        deliveryNote: storeForm['deliveryNote'],
        allowDelivery: storeForm['allowDelivery'],
        offlineMessage: storeForm['offlineMessage'],
        deliveryFlatFee: storeForm['deliveryFlatFee'],
        allowFreeDelivery: storeForm['allowFreeDelivery'],
        pickupDestinations: storeForm['pickupDestinations'],
        deliveryDestinations: storeForm['deliveryDestinations'],
        supportedPaymentMethods: storeForm['supportedPaymentMethods'],
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final ShoppableStore updatedStore = ShoppableStore.fromJson(responseBody);

          /// Notify parent on update store
          if(onUpdatedStore != null) onUpdatedStore!(updatedStore);

          /// Update the store on the store on the store cards, store page, e.t.c
          if(storeProvider.updateStore != null) storeProvider.updateStore!(updatedStore);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update store');

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
     *    comment: [The comment must be more than 10 characters]
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
            children: storeForm.isEmpty ? [] : [

              /// Store Logo
              StoreLogo(
                radius: 32,
                store: store,
                canChangeLogo: true,
              ),
              
              /// Spacer
              const SizedBox(height: 24),

              /// Name
              CustomTextFormField(
                errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                enabled: !isSubmitting,
                hintText: 'Baby Cakes',
                borderRadiusAmount: 16,
                initialValue: storeForm['name'],
                labelText: 'Name',
                onChanged: (value) {
                  setState(() => storeForm['name'] = value); 
                },
                onSaved: (value) {
                  setState(() => storeForm['name'] = value ?? ''); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Description
              CustomTextFormField(
                errorText: serverErrors.containsKey('description') ? serverErrors['description'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: 'The sweetest and softed cakes in the world',
                initialValue: storeForm['description'],
                labelText: 'Description',
                enabled: !isSubmitting,
                borderRadiusAmount: 16,
                minLines: 1,
                onChanged: (value) {
                  setState(() => storeForm['description'] = value); 
                },
                onSaved: (value) {
                  setState(() => storeForm['description'] = value ?? ''); 
                },
                validator: (value) {
                  return null;
                }
              ),
              
              /// Spacer
              const SizedBox(height: 8),

              /// Offline Message
              if(!storeForm['online']) CustomTextFormField(
                errorText: serverErrors.containsKey('offlineMessage') ? serverErrors['offlineMessage'] : null,
                enabled: !isSubmitting,
                hintText: 'Closed for the holidays',
                borderRadiusAmount: 16,
                labelText: 'Offline Message',
                initialValue: storeForm['offlineMessage'],
                onChanged: (value) {
                  setState(() => storeForm['offlineMessage'] = value); 
                },
                onSaved: (value) {
                  setState(() => storeForm['offlineMessage'] = value ?? ''); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 8),

              Row(
                children: [

                  /// Allow Delivery Switch
                  CustomSwitch(
                    value: storeForm['allowDelivery'],
                    onChanged: (value) {
                      setState(() => storeForm['allowDelivery'] = value); 
                    },
                  ),

                  /// Spacer
                  const SizedBox(width: 8),

                  //// Allow Delivery Text
                  const CustomBodyText('Allow Delivery'),

                ],
              ),

              /// Delivery Settings
              if(storeForm['allowDelivery']) ...[

                /// Spacer
                const SizedBox(height: 8),

                /// Delivery Note
                CustomTextFormField(
                  errorText: serverErrors.containsKey('deliveryNote') ? serverErrors['deliveryNote'] : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  hintText: 'We deliver only on weekends',
                  initialValue: storeForm['deliveryNote'],
                  labelText: 'Delivery Note',
                  enabled: !isSubmitting,
                  borderRadiusAmount: 16,
                  minLines: 1,
                  onChanged: (value) {
                    setState(() => storeForm['deliveryNote'] = value); 
                  },
                  onSaved: (value) {
                    setState(() => storeForm['deliveryNote'] = value ?? ''); 
                  },
                  validator: (value) {
                    return null;
                  }
                ),
              
                /// Spacer
                const SizedBox(height: 16),

                Row(
                  children: [

                    /// Allow Free Delivery Checkbox
                    Flexible(
                      child: CustomCheckbox(
                        value: storeForm['allowFreeDelivery'],
                        disabled: isSubmitting,
                        text: 'Allow Free Delivery',
                        onChanged: (value) {
                          setState(() => storeForm['allowFreeDelivery'] = value ?? false); 
                        }
                      ),
                    ),

                    /// Unit Regular Price
                    if(!storeForm['allowFreeDelivery']) Flexible(
                      child: CustomTextFormField(
                        errorText: serverErrors.containsKey('deliveryFlatFee') ? serverErrors['deliveryFlatFee'] : null,
                        initialValue: storeForm['deliveryFlatFee'],
                        labelText: 'Flat Fee',
                        enabled: !isSubmitting,
                        borderRadiusAmount: 16,
                        hintText: '100.00',
                        onChanged: (value) {
                          setState(() => storeForm['deliveryFlatFee'] = value); 
                        },
                        onSaved: (value) {
                          setState(() => storeForm['deliveryFlatFee'] = value ?? '0'); 
                        },
                      ),
                    ),

                  ],
                ),
                
                /// Spacer
                const SizedBox(height: 8),

                /// Delivery Destinations
                CustomTextFieldTags(
                  borderRadiusAmount: 16,
                  hintText: 'Add one or more destinations',
                  textfieldTagsController: _deliveryDestinationsController,
                  errorText: serverErrors.containsKey('deliveryDestinations') ? serverErrors['deliveryDestinations'] : null,
                  initialTags: ['one', 'two', 'three'],   //  (storeForm['deliveryDestinations'] as List<DeliveryDestination>).map((destination) => destination.name).toList()
                ),
                
                /// Spacer
                const SizedBox(height: 8),

              ],

              Row(
                children: [

                  /// Allow Pickup Switch
                  CustomSwitch(
                    value: storeForm['allowPickup'],
                    onChanged: (value) {
                      setState(() => storeForm['allowPickup'] = value); 
                    },
                  ),

                  /// Spacer
                  const SizedBox(width: 8),

                  //// Allow Pickup Text
                  const CustomBodyText('Allow Pickup'),

                ],
              ),

              /// Pickup Settings
              if(storeForm['allowPickup']) ...[

                /// Spacer
                const SizedBox(height: 8),

                /// Pickup Note
                CustomTextFormField(
                  errorText: serverErrors.containsKey('pickupNote') ? serverErrors['pickupNote'] : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  hintText: 'Pickups are only before 6pm',
                  initialValue: storeForm['pickupNote'],
                  labelText: 'Pickup Note',
                  enabled: !isSubmitting,
                  borderRadiusAmount: 16,
                  minLines: 1,
                  onChanged: (value) {
                    setState(() => storeForm['pickupNote'] = value); 
                  },
                  onSaved: (value) {
                    setState(() => storeForm['pickupNote'] = value ?? ''); 
                  },
                  validator: (value) {
                    return null;
                  }
                ),

              ],
              
              /// Spacer
              const SizedBox(height: 8),

              /// Online Checkbox
              CustomCheckbox(
                value: storeForm['online'],
                disabled: isSubmitting,
                text: 'We are open for business',
                onChanged: (value) {
                  setState(() => storeForm['online'] = value ?? false); 
                }
              ),

              /// Spacer
              const SizedBox(height: 100)
              
            ]
          ),
        ),
      ),
    );
  }
}