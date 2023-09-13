import 'dart:convert';

import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/delete_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/edit_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/tags/custom_tag.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_field_tags/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/undo_icon_button.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/core/shared_models/variant_attribute.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class CreateOrUpdateProductVariationsForm extends StatefulWidget {
  
  final Product product;
  final Function(bool)? onSubmitting;
  final Function(List<Product>)? onCreatedProductVariations;

  const CreateOrUpdateProductVariationsForm({
    super.key,
    this.onSubmitting,
    required this.product,
    this.onCreatedProductVariations,
  });

  @override
  State<CreateOrUpdateProductVariationsForm> createState() => CreateOrUpdateProductVariationsFormState();
}

class CreateOrUpdateProductVariationsFormState extends State<CreateOrUpdateProductVariationsForm> {

  Map serverErrors = {};
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> variantAttributesForm = [];
  List<Map<String, dynamic>> originalVariantAttributesForm = [];
  
  Product get product => widget.product;
  late TextfieldTagsController _textfieldTagController;
  Function(bool)? get onSubmitting => widget.onSubmitting;
  bool get hasVariantAttributes => variantAttributesForm.isNotEmpty;
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  bool get doesntHaveVariantAttributes => variantAttributesForm.isEmpty;
  List<VariantAttribute> get variantAttributes => product.variantAttributes;
  bool get isEditingExistingVariantAttributes => product.totalVariations != null;
  Function(List<Product>)? get onCreatedProductVariations => widget.onCreatedProductVariations;
  ProductProvider get productProvider => Provider.of<ProductProvider>(context, listen: false);
  
  bool get variantAttributesFormHasChanged {

    /**
     *  DeepCollectionEquality() helps us to deeply compare lists that might contain other collections
     * 
     *  Reference: https://stackoverflow.com/questions/10404516/how-can-i-compare-lists-for-equality-in-dart 
     */
    Function deepEq = const DeepCollectionEquality().equals;
    
    //  Check if the two lists are the same or different (Return true if they are different)
    final bool hasChanged = deepEq(originalVariantAttributesForm, variantAttributesForm) == false;
    
    return hasChanged;

  }

  @override
  void initState() {
    super.initState();
    _textfieldTagController = TextfieldTagsController();

    if(variantAttributes.isNotEmpty) {
      variantAttributesForm = variantAttributes.map((variantAttribute) => variantAttribute.toJson()).toList();
      originalVariantAttributesForm = variantAttributes.map((variantAttribute) => variantAttribute.toJson()).toList();
    }
  }

  void resetVariantAttributes() {

    setState(() {

      /// Note that jsonDecode(jsonEncode(()) simply creates a deep clone
      /// of the originalVariantAttributesForm. This is because we don't
      /// want to have a reference to the originalVariantAttributesForm
      /// as this would cause the variantAttributesForm to change when 
      /// the originalVariantAttributesForm changes.
      variantAttributesForm = List<Map<String, dynamic>>.from(jsonDecode(jsonEncode((originalVariantAttributesForm))));
    
    });

  }

  void resetOriginalVariantAttributes() {

    setState(() {

      /// Note that jsonDecode(jsonEncode(()) simply creates a deep clone
      /// of the variantAttributesForm. This is because we don't
      /// want to have a reference to the variantAttributesForm
      /// as this would cause the originalVariantAttributesForm
      /// to change when the variantAttributesForm changes.
      originalVariantAttributesForm = List<Map<String, dynamic>>.from(jsonDecode(jsonEncode((variantAttributesForm))));
    
    });

  }

  requestCreateProductVariations() {

    if(isSubmitting && hasVariantAttributes) return;

    _resetServerErrors();

    _startSubmittionLoader();
    
    /// Notify parent that we are loading
    if(onSubmitting != null) onSubmitting!(true);

    productProvider.setProduct(product).productRepository.createVariations(
      variantAttributes: variantAttributesForm
    ).then((response) {

      if(response.statusCode == 201) {

        resetOriginalVariantAttributes();

        final List<Product> createdProductVariations = (response.data['data'] as List).map((productVariation) {
          return Product.fromJson(productVariation);
        }).toList();

        /**
         *  This method must come before the SnackbarUtility.showSuccessMessage()
         *  in case this method executes a Get.back() to close a bottom modal
         *  sheet for instance. If we execute this after showSuccessMessage()
         *  then we will close the showSuccessMessage() Snackbar instead
         *  of the bottom modal sheet
         */
        if(onCreatedProductVariations != null) onCreatedProductVariations!(createdProductVariations);

        SnackbarUtility.showSuccessMessage(message: 'Created successfully');

      }
      
    }).onError((dio.DioException exception, stackTrace) {

      ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Can\'t create product');

    }).whenComplete(() {

      _stopSubmittionLoader();
    
      /// Notify parent that we are not loading
      if(onSubmitting != null) onSubmitting!(false);

    });

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

  void _addOption(Map<String, dynamic> variantAttributeForm) {
    variantAttributesForm.add(variantAttributeForm);
  }

  /// Confirm delete address
  void confirmDelete(Map variantAttributeForm, int index) async {

    bool? confirmation = await DialogUtility.showConfirmDialog(
      title: 'Delete ${variantAttributeForm['name']}',
      content: RichText(
        text: TextSpan(
          text: 'Are you sure you want to delete the ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: variantAttributeForm['name'],
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.red
              ),
            ),
            TextSpan(
              text: ' option?\n\nOnce this option is deleted, all your variations will be changed',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ]
        ),
      ),
      yesColor: Colors.red,
      yesText: 'Delete',
      noText: 'Cancel',
      context: context
    );

    if(confirmation == true) {
      setState(() {
        variantAttributesForm.removeAt(index);

        /// Automatically request the creation of the new product variations 
        /// as soon as we delete variant attributes while this product has 
        /// existing variations
        if(isEditingExistingVariantAttributes && variantAttributesFormHasChanged && hasVariantAttributes) {
          requestCreateProductVariations();
        }

      });
    }

  }

  void updateSelectedTags(variantAttributeForm) {
    /// The Future.delayed() helps us to capture the latest updated tags once the values have been captured.
    /// I noticed that when we type a new tag value and hit "enter" or "done" without the need of this
    /// Future.delayed() hack, the tags are picked up. However when i type a new tag and hit the
    /// separator, the tag is created and shows up but it is not picked up as a value when we
    /// call _textfieldTagController.getTags without the Future.delayed(). Future.delayed()
    /// helps us to have the delay that always the value to be available so that when we
    /// call "_textfieldTagController.getTags", we are also able to pick up the typed
    /// tag that was entered after hitting the comma character "," since we have set
    /// the following: textSeparators: const [',']
    Future.delayed(const Duration(milliseconds: 100)).then((_) {  
      setState(() => variantAttributeForm['values'] = _textfieldTagController.getTags);
    });
  }
  
  void _showCreateOrUpdateVariantAttributeDialog({ int? index }) async {

    bool isEditing= index != null;

    /// Note that jsonDecode(jsonEncode(()) simply creates a deep clone
    /// of the variantAttributesForm[index]. This is because we don't
    /// want to update the original copy as we change the values. We
    /// only update when we click the "Update" button.
    final Map<String, dynamic> variantAttributeForm = isEditing 
      ? jsonDecode(jsonEncode((variantAttributesForm[index])))
      : {
        'name': '',
        'values': [],
        'instruction': ''
      };

    await DialogUtility.showContentDialog(
      context: context,
      title: index == null ? 'Add' : 'Edit',
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            /// Name
            CustomTextFormField(
              errorText: serverErrors.containsKey('variantAttributes${index}Name') ? serverErrors['variantAttributes${index}Name'] : null,
              initialValue: variantAttributeForm['name'],
              hintText: 'Color',
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              labelText: 'Name',
              maxLength: 20,
              onChanged: (value) {
                setState(() => variantAttributeForm['name'] = value); 
              },
            ),
      
            /// Spacer
            const SizedBox(height: 8),
      
            /// Instruction
            CustomTextFormField(
              errorText: serverErrors.containsKey('variantAttributes${index}Instruction') ? serverErrors['variantAttributes${index}Instruction'] : null,
              initialValue: variantAttributeForm['instruction'],
              hintText: 'Select a color',
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              labelText: 'Instruction',
              maxLength: 120,
              onChanged: (value) {
                setState(() => variantAttributeForm['instruction'] = value); 
              }
            ),
      
            /// Spacer
            const SizedBox(height: 16),
      
            /// Hint
            const CustomBodyText('Separate your options with commas', lightShade: true,),
      
            /// Spacer
            const SizedBox(height: 8),
      
            /// Values
            CustomTextFieldTags(
              maxLength: 40,
              borderRadiusAmount: 16,
              enabled: !isSubmitting,
              hintText: 'Blue, Red, Green',
              textfieldTagsController: _textfieldTagController,
              validatorOnDuplicateText: 'Option already exists',
              initialTags: List<String>.from(variantAttributeForm['values']),
              textSeparators: const [','],  /// This is optional, we can just hit "Done" on the keyboard
              errorText: serverErrors.containsKey('variantAttributes${index}Values') ? serverErrors['variantAttributes${index}Values'] : null,
              onEditingComplete: () {  /// Triggered when we hit "Done" or "Enter"
                updateSelectedTags(variantAttributeForm);
              },
              onChanged: (value) {  /// Triggered as we are typing
                updateSelectedTags(variantAttributeForm);
              },
              onRemovedTag: (String tag) {
                setState(() => (variantAttributeForm['values'] as List).removeWhere((value) => value == tag)); 
              },
            )
          ],
        ),
      ),
      actions: [

        /// Add Option
        CustomElevatedButton(
          isEditing ? 'Update' : 'Add Option',
          onPressed: () async {

            await ErrorUtility.validateForm(_formKey).then((status) {
              
              if(status) {

                Get.back(closeOverlays: true);

                setState(() {
                  if(isEditing) {

                    variantAttributesForm[index] = variantAttributeForm;

                  }else{

                    _addOption(variantAttributeForm);

                  }
                });

              }
            });
          }
        ),

      ]
    );

    /// Everytime that we close this dialog, let us clear out the information
    /// and any errors so that when its opened again we don't see those errors
    _formKey.currentState?.reset();
    _textfieldTagController.clearTags();
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: EdgeInsets.only(top: (hasVariantAttributes ? 16 : 0), bottom: hasVariantAttributes ? 8 : 0, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Wrap(
            runSpacing: 8,
            children: [
              ...variantAttributesForm.mapIndexed((index, variantAttributeForm) {
      
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            /// Name
                            CustomTitleSmallText(variantAttributeForm['name']),
                        
                            /// Instruction
                            CustomBodyText(variantAttributeForm['instruction']),
                        
                            /// Spacer
                            const SizedBox(height: 8,),

                            /// Value Tags      
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  ...(variantAttributeForm['values']).map((value) {
                                    
                                    /// Value Tag
                                    return CustomTag(value, showCancelIcon: false,);
                            
                                  }).toList(),
                                ],
                              ),
                            )
                                        
                          ]
                        ),
                      ),

                      DeleteIconButton(
                        onTap: () {
                          confirmDelete(variantAttributeForm, index);
                        },
                      ),

                      EditIconButton(
                        onTap: () {
                          _showCreateOrUpdateVariantAttributeDialog(index: index);
                        },
                      )
                    
                    ],
                  ),
                );
      
              }),
            ]
          ),
    
          /// Spacer
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  key: ValueKey('$doesntHaveVariantAttributes'),
                  children: [
                    if(doesntHaveVariantAttributes) ...[

                      /// Instruction
                      const CustomBodyText(
                        'Add variations of this product if you have different options of the same product',
                        margin: EdgeInsets.symmetric(horizontal: 16),
                      ),
                
                      /// Spacer
                      const SizedBox(height: 16),

                    ],
                  ],
                )
              )
            )
          ),

          /// Add Option Button
          CustomTextButton(
            '+ Add Option',
            alignment: Alignment.center,
            onPressed: _showCreateOrUpdateVariantAttributeDialog
          ),
      
          /// Spacer
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: 
                  Column(
                    key: ValueKey('$variantAttributesFormHasChanged'),
                    children: [
                      
                      Row(
                        mainAxisAlignment: isEditingExistingVariantAttributes && variantAttributesFormHasChanged ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                        children: [
                          
                          /// Undo Changes Button
                          if(isEditingExistingVariantAttributes && variantAttributesFormHasChanged) CustomTextButton('Undo', prefixIcon: Icons.undo_rounded, onPressed: resetVariantAttributes),
            
                          if(hasVariantAttributes && variantAttributesFormHasChanged) ...[

                            /// Divider
                            const Divider(height: 16,),
                
                            CustomElevatedButton(
                              'Create Variations',
                              width: 200,
                              isLoading: isSubmitting,
                              alignment: Alignment.center,
                              prefixIcon: Icons.call_split_rounded,
                              onPressed: requestCreateProductVariations
                            ),
                          
                          ],

                        ],
                      ),
                
                      /// Spacer
                      if(variantAttributesFormHasChanged) const SizedBox(height: 16),

                    ],
                  ),
              )
            )
          ),
          
        ]
      ),
    );
  }
}