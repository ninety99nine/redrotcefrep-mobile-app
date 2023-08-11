import 'package:bonako_demo/core/shared_models/money.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/multi_select_form_field/custom_multi_select_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/switch/custom_switch.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_field_tags/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_money_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/products/repositories/product_repository.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import 'package:bonako_demo/features/stores/repositories/store_repository.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_cover_photo.dart';
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
  bool isLoadingPaymentMethods = false;
  final _formKey = GlobalKey<FormState>();
  List<String> supportedPaymentMethods = [];
  final TextfieldTagsController _pickupDestinationsController = TextfieldTagsController();
  final TextfieldTagsController _deliveryDestinationsController = TextfieldTagsController();
  
  ShoppableStore get store => widget.store;
  Function(bool) get onSubmitting => widget.onSubmitting;
  StoreRepository get storeRepository => storeProvider.storeRepository;
  Function(ShoppableStore)? get onUpdatedStore => widget.onUpdatedStore;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get allowFreeDelivery => storeForm.isEmpty ? false : storeForm['allowFreeDelivery'];
  bool get hasPickupDestinations => storeForm.isEmpty ? false : (storeForm['pickupDestinations'] as List<Map>).isNotEmpty;
  bool get hasDeliveryDestinations => storeForm.isEmpty ? false : (storeForm['deliveryDestinations'] as List<Map>).isNotEmpty;
  bool get hasSupportedPaymentMethods => storeForm.isEmpty ? false : (storeForm['supportedPaymentMethods'] as List<Map>).isNotEmpty;
  bool get hasDeliveryFlatFee => storeForm.isEmpty ? false : ['', '0', '0.0', '0.00'].contains(storeForm['deliveryFlatFee']) == false;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  void _startPaymentMethodsLoader() => setState(() => isLoadingPaymentMethods = true);
  void _stopPaymentMethodsLoader() => setState(() => isLoadingPaymentMethods = false);

  @override
  void initState() {
    super.initState();
    
    setStoreForm();
    requestPaymentMethods();
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
        'deliveryFlatFee': store.deliveryFlatFee.amount.toStringAsFixed(2),
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
        'supportedPaymentMethods': store.supportedPaymentMethods.map((paymentMethod) {
          return paymentMethod.toJson();
        }).toList(),

      };

    });

  }

  requestPaymentMethods() {

      _startPaymentMethodsLoader();

      apiProvider.apiRepository.get(url: store.links.showAvailablePaymentMethods.href).then((response) async {

        if(response.statusCode == 200) {
          
          /// Get the payment methods
          final paymentMethods = List<String>.from(jsonDecode(response.body));

          /// Sort the payment methods alphabetically
          paymentMethods.sort();

          /// Set the payment methods
          setState(() => supportedPaymentMethods = paymentMethods);

        }else if(response.statusCode == 422) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t get payment methods');
          
        }

      }).catchError((error) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t show payment methods');

      }).whenComplete((){

        _stopPaymentMethodsLoader();

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

          /// Set the non editable fields
          updatedStore.activeSubscriptionsCount = store.activeSubscriptionsCount;
          updatedStore.teamMembersCount = store.teamMembersCount;
          updatedStore.followersCount = store.followersCount;
          updatedStore.relationships = store.relationships;
          updatedStore.productsCount = store.productsCount;
          updatedStore.reviewsCount = store.reviewsCount;
          updatedStore.couponsCount = store.couponsCount;
          updatedStore.ordersCount = store.ordersCount;

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
              const SizedBox(height: 16),

              /// Store Cover Photo
              StoreCoverPhoto(
                store: store,
                canChangeCoverPhoto: true,
              ),
                  
              /// Spacer
              const SizedBox(height: 16),

              /// Online Checkbox
              CustomCheckbox(
                value: storeForm['online'],
                disabled: isSubmitting,
                text: 'We are open for business',
                checkBoxMargin: const EdgeInsets.only(left: 8, right: 8),
                onChanged: (value) {
                  setState(() => storeForm['online'] = value ?? false); 
                }
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
                        prefixIcon: const Icon(Icons.info_rounded, color: Colors.orange,),
                        initialValue: storeForm['offlineMessage'],
                        hintText: 'Closed for the holidays',
                        labelText: 'Offline Message',
                        enabled: !isSubmitting,
                        borderRadiusAmount: 16,
                        maxLength: 120,
                        onChanged: (value) {
                          setState(() => storeForm['offlineMessage'] = value); 
                        }
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
                initialValue: storeForm['name'],
                hintText: 'Baby Cakes 🧁',
                borderRadiusAmount: 16,
                enabled: !isSubmitting,
                labelText: 'Name',
                maxLength: 25,
                onChanged: (value) {
                  setState(() => storeForm['name'] = value); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Description
              CustomTextFormField(
                errorText: serverErrors.containsKey('description') ? serverErrors['description'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: 'The sweetest and softed cakes in the world 🍰',
                initialValue: storeForm['description'],
                labelText: 'Description',
                enabled: !isSubmitting,
                borderRadiusAmount: 16,
                maxLength: 120,
                minLines: 1,
                onChanged: (value) {
                  setState(() => storeForm['description'] = value); 
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
                        maxLength: 120,
                        minLines: 2,
                        onChanged: (value) {
                          setState(() => storeForm['deliveryNote'] = value); 
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
                            child: CustomMoneyTextFormField(
                              hintText: '100.00',
                              labelText: 'Flat Fee',
                              enabled: !isSubmitting,
                              initialValue: storeForm['deliveryFlatFee'],
                              errorText: serverErrors.containsKey('deliveryFlatFee') ? serverErrors['deliveryFlatFee'] : null,
                              onChanged: (value) {
                                setState(() {
                                  if(double.tryParse(value) == null) {
                                    storeForm['deliveryFlatFee'] = '0.00';
                                  }else{
                                    storeForm['deliveryFlatFee'] = double.parse(value).toStringAsFixed(2);
                                  }
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
                                      key: ValueKey(deliveryDestination['name']),
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
                          maxLength: 120,
                          minLines: 2,
                          onChanged: (value) {
                            setState(() => storeForm['pickupNote'] = value); 
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
                                        key: ValueKey(pickupDestination['name']),
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
              const SizedBox(height: 16),

              /// Loader
              if(isLoadingPaymentMethods) const CustomCircularProgressIndicator(),

              /// Payment Method Settings
              if(!isLoadingPaymentMethods) ...[

                /// Supported Payment Methods
                CustomMultiSelectFormField(
                  title: 'Payment Methods',
                  hintText: 'Select supported payment methods',
                  key: ValueKey(storeForm['supportedPaymentMethods'].length),
                  initialValue: (storeForm['supportedPaymentMethods'] as List<Map>)
                    .where((supportedPaymentMethod) => supportedPaymentMethod['active'])
                    .map((supportedPaymentMethod) => supportedPaymentMethod['name']).toList(),
                  dataSource: List<dynamic>.from(supportedPaymentMethods.map((supportedPaymentMethod) => {
                    'display': supportedPaymentMethod,
                    'value': supportedPaymentMethod,
                  })),
                  onSaved: (value) {
                    if (value != null) {
                      
                      List<String> selectedPaymentMethods = List<String>.from(value);

                      setState(() {
                        
                        List<Map> existingPaymentMethods = storeForm['supportedPaymentMethods'];
                        List<Map> newPaymentMethods = [];

                        for (var sortedPaymentMethod in selectedPaymentMethods) {

                          // Check if payment method already exists
                          int existingIndex = existingPaymentMethods.indexWhere((existingMethod) => existingMethod['name'] == sortedPaymentMethod);
                          
                          if (existingIndex != -1) {
                            
                            // Payment method already exists, mark as active
                            existingPaymentMethods[existingIndex]['active'] = true;
                            newPaymentMethods.add(existingPaymentMethods[existingIndex]);
                          
                          } else {
                            
                            // Payment method is new, add to list
                            newPaymentMethods.add({
                              'active': true,
                              'name': sortedPaymentMethod,
                              'instructions': '',
                            });
                          
                          }

                        }

                        // Mark all other payment methods as inactive
                        for (var existingMethod in existingPaymentMethods) {
                          if (!selectedPaymentMethods.contains(existingMethod['name'])) {
                            existingMethod['active'] = false;
                            newPaymentMethods.add(existingMethod);
                          }
                        }

                        /// Sort the payment methods alphabetically
                        newPaymentMethods.sort((a, b) => a['name'].compareTo(b['name']));

                        storeForm['supportedPaymentMethods'] = newPaymentMethods;

                      });
                    }
                  },
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: !hasSupportedPaymentMethods 
                  ? Container()
                  : Column(
                      children: [

                        /// Spacer
                        const SizedBox(height: 8),
              
                        /// Payment Methods Table Instructions
                        const CustomMessageAlert('Add instructions for your payment methods so that customers understand how to pay (Optional)'),
                      
                        /// Spacer
                        const SizedBox(height: 8),
              
                        /// Payment Methods Table
                        Table(   
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
                                  child: CustomTitleSmallText('Payment Method'),
                                ),  
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CustomTitleSmallText('Instruction'),
                                ),
                              ]
                            ),
              
                            /// Table Rows (Payment Methods)
                            ...(storeForm['supportedPaymentMethods'] as List<Map>)
                              .where((supportedPaymentMethod) => supportedPaymentMethod['active'])
                              .map((supportedPaymentMethod) {
              
                              return TableRow(
                                key: ValueKey(supportedPaymentMethod['name']),
                                children: [
              
                                  /// Payment Method Name
                                  TableCell(
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: supportedPaymentMethod['name'],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.black
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8.0),
                                        border: InputBorder.none
                                      )
                                    ),
                                  ),
              
                                  /// Payment Method Instruction
                                  TableCell(
                                    child: TextFormField(
                                      enabled: !isSubmitting,
                                      initialValue: supportedPaymentMethod['instruction'],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.black
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8.0),
                                        border: InputBorder.none
                                      ),
                                      onChanged: (value) {
                                        setState(() => supportedPaymentMethod['instruction'] = value);
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