import 'package:bonako_demo/core/shared_models/money.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/switch/custom_switch.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
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
  final TextfieldTagsController _pickupDestinationsController = TextfieldTagsController();
  final TextfieldTagsController _deliveryDestinationsController = TextfieldTagsController();
  
  ShoppableStore get store => widget.store;
  Function(bool) get onSubmitting => widget.onSubmitting;
  StoreRepository get storeRepository => storeProvider.storeRepository;
  Function(ShoppableStore)? get onUpdatedStore => widget.onUpdatedStore;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get allowFreeDelivery => storeForm.isEmpty ? false : storeForm['allowFreeDelivery'];
  bool get hasPickupDestinations => storeForm.isEmpty ? false : (storeForm['pickupDestinations'] as List).isNotEmpty;
  bool get hasDeliveryDestinations => storeForm.isEmpty ? false : (storeForm['deliveryDestinations'] as List).isNotEmpty;
  bool get hasDeliveryFlatFee => storeForm.isEmpty ? false : ['', '0', '0.0', '0.00'].contains(storeForm['deliveryFlatFee']) == false;

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
    _pickupDestinationsController.dispose();
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
        'deliveryFlatFee': store.deliveryFlatFee.amountWithoutCurrency,
        'deliveryDestinations': store.deliveryDestinations.map((deliveryDestination) {
          return deliveryDestination.toJson();
        }).toList(),

        /// Pickup
        'pickupNote': store.pickupNote,
        'allowPickup': store.allowPickup,
        'pickupDestinations': store.pickupDestinations.map((pickupDestination) {
          return pickupDestination.toJson();
        }).toList(),

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

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  /// Store Logo
                  StoreLogo(
                    radius: 32,
                    store: store,
                    canChangeLogo: true,
                  ),
                  
                  /// Spacer
                  const SizedBox(height: 8),

                  /// Online Checkbox
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      child: CustomCheckbox(
                        value: storeForm['online'],
                        disabled: isSubmitting,
                        text: 'We are open for business',
                        checkBoxMargin: const EdgeInsets.only(left: 8, right: 8),
                        onChanged: (value) {
                          setState(() => storeForm['online'] = value ?? false); 
                        }
                      ),
                    ),
                  ),

                ],
              ),

              /// Offline Message
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: storeForm['online']
                  ? Container()
                  : Column(
                    children: [
              
                      /// Spacer
                      const SizedBox(height: 16),

                      CustomTextFormField(
                        errorText: serverErrors.containsKey('offlineMessage') ? serverErrors['offlineMessage'] : null,
                        enabled: !isSubmitting,
                        hintText: 'Closed for the holidays',
                        borderRadiusAmount: 16,
                        labelText: 'Offline Message',
                        initialValue: storeForm['offlineMessage'],
                        prefixIcon: const Icon(Icons.info_rounded, color: Colors.orange,),
                        onChanged: (value) {
                          setState(() => storeForm['offlineMessage'] = value); 
                        },
                        onSaved: (value) {
                          setState(() => storeForm['offlineMessage'] = value ?? ''); 
                        },
                      ),
                    
                      /// Spacer
                      const SizedBox(height: 16),
                    
                      /// Spacer
                      const Divider()

                    ]
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

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
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: storeForm['allowDelivery']
                  ? Column(
                    children: [

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
                        minLines: 2,
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

                      /// Delivery Destinations
                      CustomTextFieldTags(
                        borderRadiusAmount: 16,
                        enabled: !isSubmitting,
                        hintText: 'Add one or more destinations',
                        validatorOnDuplicateText: 'Destination already exists',
                        textfieldTagsController: _deliveryDestinationsController,
                        initialTags: List<String>.from(storeForm['deliveryDestinations'].map((e) => e['name']).toList()),
                        errorText: serverErrors.containsKey('deliveryDestinations') ? serverErrors['deliveryDestinations'] : null,
                        onSubmitted: (value) {
                          setState(() {
                            (storeForm['deliveryDestinations'] as List).add({
                              'cost': '0.00',
                              'name': value.trim(),
                              'allow_free_delivery': false,
                            });
                          }); 
                        },
                        onRemovedTag: (String tag) {
                          setState(() => (storeForm['deliveryDestinations'] as List).removeWhere((deliveryDestination) => deliveryDestination['name'] == tag)); 
                        }
                      ),
                    
                      /// Spacer
                      const SizedBox(height: 16),

                      /// Allow Free Delivery Checkbox & Flat Fee
                      Row(
                        children: [

                          /// Allow Free Delivery Checkbox
                          Flexible(
                            child: CustomCheckbox(
                              disabled: isSubmitting,
                              text: 'Allow Free Delivery',
                              value: storeForm['allowFreeDelivery'],
                              checkBoxMargin: const EdgeInsets.only(left: 8, right: 8),
                              onChanged: (value) {
                                setState(() => storeForm['allowFreeDelivery'] = value ?? false); 
                              }
                            ),
                          ),

                          /// Flat Fee
                          if(!storeForm['allowFreeDelivery']) Flexible(
                            child: CustomTextFormField(
                              hintText: '100.00',
                              labelText: 'Flat Fee',
                              enabled: !isSubmitting,
                              borderRadiusAmount: 16,
                              initialValue: storeForm['deliveryFlatFee'],
                              errorText: serverErrors.containsKey('deliveryFlatFee') ? serverErrors['deliveryFlatFee'] : null,
                              onChanged: (value) {
                                setState(() {
                                  if(double.tryParse(value) == null) {
                                    storeForm['deliveryFlatFee'] = '0.00';
                                  }else{
                                    storeForm['deliveryFlatFee'] = double.parse(value).toStringAsFixed(2);
                                  }

                                  print(storeForm['deliveryFlatFee']);
                                });
                              },
                            ),
                          ),

                        ],
                      ),

                      if(allowFreeDelivery) ... [
                      
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Allow Free Delivery Instructions
                        const CustomMessageAlert('Delivery to all destinations is Free'),

                      ],

                      if(!allowFreeDelivery && hasDeliveryFlatFee) ... [
                      
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Flat Fee Delivery Instructions
                        CustomMessageAlert('Delivery to all destinations is charged ${storeForm['deliveryFlatFee']}'),

                      ],

                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        child: allowFreeDelivery || hasDeliveryFlatFee || !hasDeliveryDestinations 
                        ? Container()
                        : Column(
                            children: [

                              /// Spacer
                              const SizedBox(height: 8),
                    
                              /// Delivery Table Instructions
                              const CustomMessageAlert('Adjust the delivery fee for each destination below'),
                            
                              /// Spacer
                              const SizedBox(height: 8),
                    
                              /// Delivery Destinations Table
                              Table(  
                                //  defaultColumnWidth: FixedColumnWidth(120.0),  
                                border: TableBorder.all(  
                                  color: Colors.grey,  
                                  style: BorderStyle.solid,  
                                  width: 1
                                ),  
                                children: [  
                    
                                  /// Table Header
                                  TableRow( 
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CustomTitleSmallText('Destinations'),
                                      ),  
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CustomTitleSmallText('Delivery Fees'),
                                      ),
                                    ]
                                  ),
                    
                                  /// Table Rows (Delivery Destinations)
                                  ...(storeForm['deliveryDestinations'] as List).map((deliveryDestination) {
                    
                                    return TableRow(
                                      children: [
                    
                                        /// Destination Name
                                        TableCell(
                                          child: TextFormField(
                                            enabled: !isSubmitting,
                                            initialValue: deliveryDestination['name'],
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.black
                                            ),
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.all(8.0),
                                              border: InputBorder.none
                                            ),
                                            onChanged: (value) {
                                              setState(() => deliveryDestination['name'] = value);
                                            },
                                          ),
                                        ),
                    
                                        TableCell(
                                          child: Row(
                                            children: [
                                          
                                              /// Destination Cost
                                              Expanded(
                                                child: deliveryDestination['allow_free_delivery'] 
                                                  ? Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                                                      child: Text(deliveryDestination['cost'].toString(), style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12, color: Colors.grey)),
                                                    )
                                                  : TextFormField(
                                                    keyboardType: TextInputType.number,
                                                    initialValue: deliveryDestination['cost'],
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.black
                                                    ),
                                                    enabled: !isSubmitting && !deliveryDestination['allow_free_delivery'],
                                                    decoration: const InputDecoration(
                                                      contentPadding: EdgeInsets.all(8.0),
                                                      border: InputBorder.none
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if(double.tryParse(value) == null) {
                                                          deliveryDestination['cost'] = '0.00';
                                                        }else{
                                                          deliveryDestination['cost'] = double.parse(value).toStringAsFixed(2);
                                                        }
                                                      });
                                                    },
                                                  ),
                                              ),
                                          
                                              /// Allow Free Delivery Checkbox
                                              Flexible(
                                                child: CustomCheckbox(
                                                  text: Text(
                                                    'Free', 
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.black)
                                                  ),
                                                  disabled: isSubmitting,
                                                  value: deliveryDestination['allow_free_delivery'],
                                                  onChanged: (value) {
                                                    setState(() => deliveryDestination['allow_free_delivery'] = value ?? false); 
                                                  }
                                                ),
                                              ),
                                              
                                            ],
                                          ),
                                        )
                    
                                      ]
                                    );
                    
                                  }).toList()
                                ],  
                              ),

                            ],
                        )
                      ),
                      
                      /// Spacer
                      const SizedBox(height: 8),

                    ]
                  )
                  : Container()
              ),

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
              AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: storeForm['allowPickup']
                   ? Column(
                      children: [

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
                          minLines: 2,
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
              
                        /// Spacer
                        const SizedBox(height: 8),

                        /// Pickup Destinations
                        CustomTextFieldTags(
                          borderRadiusAmount: 16,
                          enabled: !isSubmitting,
                          hintText: 'Add one or more destinations',
                          validatorOnDuplicateText: 'Destination already exists',
                          textfieldTagsController: _pickupDestinationsController,
                          initialTags: List<String>.from(storeForm['pickupDestinations'].map((e) => e['name']).toList()),
                          errorText: serverErrors.containsKey('pickupDestinations') ? serverErrors['pickupDestinations'] : null
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          child: !hasPickupDestinations 
                          ? Container()
                          : Column(
                              children: [

                                /// Spacer
                                const SizedBox(height: 8),
                      
                                /// Pickup Table Instructions
                                const CustomMessageAlert('Add the addresses for pickup locations (Optional)'),
                              
                                /// Spacer
                                const SizedBox(height: 8),
                      
                                /// Pickup Destinations Table
                                Table(  
                                  //  defaultColumnWidth: FixedColumnWidth(120.0),  
                                  border: TableBorder.all(  
                                    color: Colors.grey,  
                                    style: BorderStyle.solid,  
                                    width: 1
                                  ),  
                                  children: [  
                      
                                    /// Table Header
                                    TableRow( 
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CustomTitleSmallText('Destinations'),
                                        ),  
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CustomTitleSmallText('Addresses'),
                                        ),
                                      ]
                                    ),
                      
                                    /// Table Rows (Pickup Destinations)
                                    ...(storeForm['pickupDestinations'] as List).map((pickupDestination) {
                      
                                      return TableRow(
                                        children: [
                      
                                          /// Destination Name
                                          TableCell(
                                            child: TextFormField(
                                              enabled: !isSubmitting,
                                              initialValue: pickupDestination['name'],
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.black
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.all(8.0),
                                                border: InputBorder.none
                                              ),
                                              onChanged: (value) {
                                                setState(() => pickupDestination['name'] = value);
                                              },
                                            ),
                                          ),
                      
                                          /// Destination Address
                                          TableCell(
                                            child: TextFormField(
                                              enabled: !isSubmitting,
                                              initialValue: pickupDestination['address'],
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.black
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.all(8.0),
                                                border: InputBorder.none
                                              ),
                                              onChanged: (value) {
                                                setState(() => pickupDestination['address'] = value);
                                              },
                                            ),
                                          ),
                      
                                        ]
                                      );
                      
                                    }).toList()
                                  ],  
                                ),
                              ],
                          )
                        ),
                        
                      ]
                    )
                  : Container()
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