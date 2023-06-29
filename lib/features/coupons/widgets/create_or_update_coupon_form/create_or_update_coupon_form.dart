import 'package:bonako_demo/core/shared_widgets/datetime_picker/custom_datetime_picker.dart';
import 'package:bonako_demo/core/shared_widgets/multi_select_form_field/custom_multi_select_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_field_tags/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_money_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/coupons/repositories/coupon_repository.dart';
import 'package:bonako_demo/features/stores/repositories/store_repository.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/features/coupons/providers/coupon_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/coupons/enums/coupon_enums.dart';
import 'package:bonako_demo/features/coupons/models/coupon.dart';
import 'package:collection/collection.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import 'package:textfield_tags/textfield_tags.dart';

class CreateOrUpdateCouponForm extends StatefulWidget {
  
  final Coupon? coupon;
  final ShoppableStore store;
  final Function(bool) onDeleting;
  final Function(bool) onSubmitting;
  final Function(Coupon)? onDeletedCoupon;
  final Function(Coupon)? onUpdatedCoupon;
  final Function(Coupon)? onCreatedCoupon;

  const CreateOrUpdateCouponForm({
    super.key,
    this.coupon,
    required this.store,
    this.onDeletedCoupon,
    this.onUpdatedCoupon,
    this.onCreatedCoupon,
    required this.onDeleting,
    required this.onSubmitting,
  });

  @override
  State<CreateOrUpdateCouponForm> createState() => CreateOrUpdateCouponFormState();
}

class CreateOrUpdateCouponFormState extends State<CreateOrUpdateCouponForm> {

  Map couponForm = {};
  Map serverErrors = {};
  bool isDeleting= false;
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> hoursOfDay = [
    '00:00', '01:00', '02:00', '03:00', '04:00', '05:00',
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];

  final List<String> daysOfTheWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> daysOfTheMonth = [
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
    '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
    '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
    '31'
  ];

  final List<String> monthsOfTheYear = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];
  
  bool get isEditing => coupon != null;
  bool get isCreating => coupon == null;
  Coupon? get coupon => widget.coupon;
  ShoppableStore get store => widget.store;
  Function(bool) get onDeleting => widget.onDeleting;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function(Coupon)? get onDeletedCoupon => widget.onDeletedCoupon;
  Function(Coupon)? get onUpdatedCoupon => widget.onUpdatedCoupon;
  Function(Coupon)? get onCreatedCoupon => widget.onCreatedCoupon;
  StoreRepository get storeRepository => storeProvider.storeRepository;
  CouponRepository get couponRepository => couponProvider.couponRepository;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  CouponProvider get couponProvider => Provider.of<CouponProvider>(context, listen: false);

  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    
    /// Future.delayed() is used so that we can wait for the
    /// variables to be set e.g The "coupon" getter property
    Future.delayed(Duration.zero).then((value) {
      
      setCouponForm();

    });
  }

  setCouponForm() {

    setState(() {

      final String randomCode = '${Random().nextInt(900000) + 100000}';
      
      couponForm = {
        'name': isEditing ? coupon!.name : '',
        'active': isEditing ? coupon!.active.status : true,
        'description': isEditing ? coupon!.description : '',
        
        /// Offer Discount Information
        'offerDiscount': isEditing ? coupon!.offerDiscount.status : false,
        'discountType': isEditing ? coupon!.discountType : DiscountType.percentage,
        'discountPercentageRate': isEditing ? coupon!.discountPercentageRate.value.toString() : '50',
        'discountFixedRate': isEditing ? coupon!.discountFixedRate.amount.toStringAsFixed(2) : '50.00',
      
        /// Offer Delivery Information
        'offerFreeDelivery': isEditing ? coupon!.offerFreeDelivery.status : false,

        /// Code Activation Information
        'activateUsingCode': isEditing ? coupon!.activateUsingCode.status : false,
        'code': isEditing ? coupon!.code ?? randomCode : randomCode,
      
        /// Grand Total Activation Information
        'activateUsingMinimumGrandTotal': isEditing ? coupon!.activateUsingMinimumGrandTotal.status : false,
        'minimumGrandTotal': isEditing ? coupon!.minimumGrandTotal.amount.toStringAsFixed(2) : '50.00',

        /// Minimum Total Products Activation Information
        'activateUsingMinimumTotalProducts': isEditing ? coupon!.activateUsingMinimumTotalProducts.status : false,
        'minimumTotalProducts': isEditing ? coupon!.minimumTotalProducts.toString() : '2',

        /// Minimum Total Product Quantities Activation Information
        'activateUsingMinimumTotalProductQuantities': isEditing ? coupon!.activateUsingMinimumTotalProductQuantities.status : false,
        'minimumTotalProductQuantities': isEditing ? coupon!.minimumTotalProductQuantities.toString() : '2',

        /// Start Datetime Activation Information
        'activateUsingStartDatetime': isEditing ? coupon!.activateUsingStartDatetime.status : false,
        'startDatetime': isEditing ? coupon!.startDatetime : DateTime.now(),

        /// End Datetime Activation Information
        'activateUsingEndDatetime': isEditing ? coupon!.activateUsingEndDatetime.status : false,
        'endDatetime': isEditing ? coupon!.endDatetime : DateTime.now().add(const Duration(days: 14)),

        /// Hours Of Day Activation Information
        'activateUsingHoursOfDay': isEditing ? coupon!.activateUsingHoursOfDay.status : false,
        'hoursOfDay': isEditing ? coupon!.hoursOfDay : [],

        /// Days Of The Week Activation Information
        'activateUsingDaysOfTheWeek': isEditing ? coupon!.activateUsingDaysOfTheWeek.status : false,
        'daysOfTheWeek': isEditing ? coupon!.daysOfTheWeek : [],

        /// Days Of The Month Activation Information
        'activateUsingDaysOfTheMonth': isEditing ? coupon!.activateUsingDaysOfTheMonth.status : false,
        'daysOfTheMonth': isEditing ? coupon!.daysOfTheMonth : [],

        /// Months Of The Year Activation Information
        'activateUsingMonthsOfTheYear': isEditing ? coupon!.activateUsingMonthsOfTheYear.status : false,
        'monthsOfTheYear': isEditing ? coupon!.monthsOfTheYear : [],

        /// Usage Activation Information
        'activateUsingUsageLimit': isEditing ? coupon!.activateUsingUsageLimit.status : false,
        'remainingQuantity': isEditing ? coupon!.remainingQuantity.toString() : '100',

        /// Customer Activation Information
        'activateForExistingCustomer': isEditing ? coupon!.activateForExistingCustomer.status : false,
        'activateForNewCustomer': isEditing ? coupon!.activateForNewCustomer.status : false,

      };

    });

  }

  requestCreateCoupon() {

    if(isDeleting || isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      storeProvider.setStore(store).storeRepository.createCoupon(
        name: couponForm['name'],
        active: couponForm['active'],
        description: couponForm['description'],

        /// Offer Discount Information
        discountType: couponForm['discountType'],
        offerDiscount: couponForm['offerDiscount'],
        discountFixedRate: couponForm['discountFixedRate'],
        discountPercentageRate: couponForm['discountPercentageRate'],

        /// Offer Delivery Information
        offerFreeDelivery: couponForm['offerFreeDelivery'],

        /// Code Activation Information
        activateUsingCode: couponForm['activateUsingCode'],
        code: couponForm['code'],

        /// Grand Total Activation Information
        activateUsingMinimumGrandTotal: couponForm['activateUsingMinimumGrandTotal'],
        minimumGrandTotal: couponForm['minimumGrandTotal'],

        /// Minimum Total Products Activation Information
        activateUsingMinimumTotalProducts: couponForm['activateUsingMinimumTotalProducts'],
        minimumTotalProducts: couponForm['minimumTotalProducts'],

        /// Minimum Total Product Quantities Activation Information
        activateUsingMinimumTotalProductQuantities: couponForm['activateUsingMinimumTotalProductQuantities'],
        minimumTotalProductQuantities: couponForm['minimumTotalProductQuantities'],

        /// Start Datetime Activation Information
        activateUsingStartDatetime: couponForm['activateUsingStartDatetime'],
        startDatetime: couponForm['startDatetime'],

        /// End Datetime Activation Information
        activateUsingEndDatetime: couponForm['activateUsingEndDatetime'],
        endDatetime: couponForm['endDatetime'],

        /// Hours Of Day Activation Information
        activateUsingHoursOfDay: couponForm['activateUsingHoursOfDay'],
        hoursOfDay: couponForm['hoursOfDay'],

        /// Days Of The Week Activation Information
        activateUsingDaysOfTheWeek: couponForm['activateUsingDaysOfTheWeek'],
        daysOfTheWeek: couponForm['daysOfTheWeek'],

        /// Days Of The Month Activation Information
        activateUsingDaysOfTheMonth: couponForm['activateUsingDaysOfTheMonth'],
        daysOfTheMonth: couponForm['daysOfTheMonth'],

        /// Months Of The Year Activation Information
        activateUsingMonthsOfTheYear: couponForm['activateUsingMonthsOfTheYear'],
        monthsOfTheYear: couponForm['monthsOfTheYear'],

        /// Usage Activation Information
        activateUsingUsageLimit: couponForm['activateUsingUsageLimit'],
        remainingQuantity: couponForm['remainingQuantity'],

        /// Customer Activation Information
        activateForNewCustomer: couponForm['activateForNewCustomer'],
        activateForExistingCustomer: couponForm['activateForExistingCustomer'],

      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 201) {

          final Coupon createdCoupon = Coupon.fromJson(responseBody);

          /**
           *  This method must come before the SnackbarUtility.showSuccessMessage()
           *  in case this method executes a Get.back() to close a bottom modal
           *  sheet for instance. If we execute this after showSuccessMessage()
           *  then we will close the showSuccessMessage() Snackbar instead
           *  of the bottom modal sheet
           */
          if(onCreatedCoupon != null) onCreatedCoupon!(createdCoupon);

          SnackbarUtility.showSuccessMessage(message: 'Created successfully');

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t create coupon');

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  requestUpdateCoupon() {

    if(isDeleting || isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      couponProvider.setCoupon(coupon!).couponRepository.updateCoupon(
        name: couponForm['name'],
        active: couponForm['active'],
        description: couponForm['description'],

        /// Offer Discount Information
        discountType: couponForm['discountType'],
        offerDiscount: couponForm['offerDiscount'],
        discountFixedRate: couponForm['discountFixedRate'],
        discountPercentageRate: couponForm['discountPercentageRate'],

        /// Offer Delivery Information
        offerFreeDelivery: couponForm['offerFreeDelivery'],

        /// Code Activation Information
        activateUsingCode: couponForm['activateUsingCode'],
        code: couponForm['code'],

        /// Grand Total Activation Information
        activateUsingMinimumGrandTotal: couponForm['activateUsingMinimumGrandTotal'],
        minimumGrandTotal: couponForm['minimumGrandTotal'],

        /// Minimum Total Products Activation Information
        activateUsingMinimumTotalProducts: couponForm['activateUsingMinimumTotalProducts'],
        minimumTotalProducts: couponForm['minimumTotalProducts'],

        /// Minimum Total Product Quantities Activation Information
        activateUsingMinimumTotalProductQuantities: couponForm['activateUsingMinimumTotalProductQuantities'],
        minimumTotalProductQuantities: couponForm['minimumTotalProductQuantities'],

        /// Start Datetime Activation Information
        activateUsingStartDatetime: couponForm['activateUsingStartDatetime'],
        startDatetime: couponForm['startDatetime'],

        /// End Datetime Activation Information
        activateUsingEndDatetime: couponForm['activateUsingEndDatetime'],
        endDatetime: couponForm['endDatetime'],

        /// Hours Of Day Activation Information
        activateUsingHoursOfDay: couponForm['activateUsingHoursOfDay'],
        hoursOfDay: couponForm['hoursOfDay'],

        /// Days Of The Week Activation Information
        activateUsingDaysOfTheWeek: couponForm['activateUsingDaysOfTheWeek'],
        daysOfTheWeek: couponForm['daysOfTheWeek'],

        /// Days Of The Month Activation Information
        activateUsingDaysOfTheMonth: couponForm['activateUsingDaysOfTheMonth'],
        daysOfTheMonth: couponForm['daysOfTheMonth'],

        /// Months Of The Year Activation Information
        activateUsingMonthsOfTheYear: couponForm['activateUsingMonthsOfTheYear'],
        monthsOfTheYear: couponForm['monthsOfTheYear'],

        /// Usage Activation Information
        activateUsingUsageLimit: couponForm['activateUsingUsageLimit'],
        remainingQuantity: couponForm['remainingQuantity'],

        /// Customer Activation Information
        activateForNewCustomer: couponForm['activateForNewCustomer'],
        activateForExistingCustomer: couponForm['activateForExistingCustomer'],
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final Coupon updatedCoupon = Coupon.fromJson(responseBody);
          
          /**
           *  This method must come before the SnackbarUtility.showSuccessMessage()
           *  in case this method executes a Get.back() to close a bottom modal
           *  sheet for instance. If we execute this after showSuccessMessage()
           *  then we will close the showSuccessMessage() Snackbar instead
           *  of the bottom modal sheet
           */
          if(onUpdatedCoupon != null) onUpdatedCoupon!(updatedCoupon);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');


        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update coupon');

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  void _requestDeleteCoupon() async {

    if(isDeleting || isSubmitting) return;

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _startDeleteLoader();

      /// Notify parent that we are starting the deleting process
      onDeleting(true);

      couponProvider.setCoupon(coupon!).couponRepository.deleteCoupon().then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          /// Notify parent that the coupon has been deleted
          if(onDeletedCoupon != null) onDeletedCoupon!(coupon!);

          SnackbarUtility.showSuccessMessage(message: responseBody['message']);

        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to delete groups');

      }).whenComplete((){

        _stopDeleteLoader();

        /// Notify parent that we are ending the deleting process
        onDeleting(false);

      });

    }

  }

  /// Confirm delete coupon
  Future<bool?> confirmDelete() {

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete ${coupon!.name}?',
      context: context
    );

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
            children: couponForm.isEmpty ? [] : [
              
              /// Spacer
              const SizedBox(height: 8),

              /// Visible Checkbox
              CustomCheckbox(
                value: couponForm['active'],
                disabled: isSubmitting,
                text: 'Active',
                onChanged: (value) {
                  setState(() => couponForm['active'] = value ?? false); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Name
              CustomTextFormField(
                errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                enabled: !isSubmitting && !isDeleting,
                borderRadiusAmount: 16,
                hintText: '10% off',
                maxLength: 60,
                initialValue: couponForm['name'],
                labelText: 'Name',
                onChanged: (value) {
                  setState(() => couponForm['name'] = value); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Description
              CustomTextFormField(
                errorText: serverErrors.containsKey('description') ? serverErrors['description'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: 'Offer 10% discount',
                initialValue: couponForm['description'],
                enabled: !isSubmitting && !isDeleting,
                labelText: 'Description',
                borderRadiusAmount: 16,
                maxLength: 120,
                minLines: 1,
                onChanged: (value) {
                  setState(() => couponForm['description'] = value); 
                },
                validator: (value) {
                  return null;
                }
              ),

              /// Offers
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
              
                    /// Offers Title
                    CustomTitleSmallText('Offers'),
              
                    /// Spacer
                    SizedBox(height: 4),
                    
                    /// Offers Description
                  CustomBodyText('Set the offers that this coupon will apply'),
                    
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Offer Discount Checkbox
                  Flexible(
                    child: CustomCheckbox(
                      value: couponForm['offerDiscount'],
                      disabled: isSubmitting,
                      text: 'Offer Discount',
                      onChanged: (value) {
                        setState(() => couponForm['offerDiscount'] = value ?? false);
                      }
                    ),
                  ),
                  
                  if(couponForm['offerDiscount']) DropdownButton(
                    value: couponForm['discountType'],
                    items: [

                      /// Fixed Discount
                      DropdownMenuItem(
                        value: DiscountType.fixed,
                        child: CustomBodyText(DiscountType.fixed.name.capitalize),
                      ),

                      /// Percentage Discount
                      DropdownMenuItem(
                        value: DiscountType.percentage,
                        child: CustomBodyText(DiscountType.percentage.name.capitalize),
                      )

                    ],
                    onChanged: (value) {
                      setState(() => couponForm['discountType'] = value); 
                    },
                  ),

                ],
              ),
              
              /// Fixed Discount Rate & Percentage Discount Rate
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['offerDiscount'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Fixed Discount Rate
                        if(couponForm['discountType'] == DiscountType.fixed) CustomMoneyTextFormField(
                          errorText: serverErrors.containsKey('discountFixedRate') ? serverErrors['discountFixedRate'] : null,
                          initialValue: couponForm['discountFixedRate'],
                          key: const ValueKey('discountFixedRate'),
                          enabled: !isSubmitting && !isDeleting,
                          labelText: 'Fixed Rate',
                          hintText: '50.00',
                          onChanged: (value) {
                            setState(() => couponForm['discountFixedRate'] = value); 
                          }
                        ),

                        /// Percentage Discount Rate
                        if(couponForm['discountType'] == DiscountType.percentage) CustomTextFormField(
                          errorText: serverErrors.containsKey('discountPercentageRate') ? serverErrors['discountPercentageRate'] : null,
                          initialValue: couponForm['discountPercentageRate'],
                          key: const ValueKey('discountPercentageRate'),
                          enabled: !isSubmitting && !isDeleting,
                          keyboardType: TextInputType.number,
                          labelText: 'Percentage Rate',
                          borderRadiusAmount: 16,
                          hintText: '50',
                          onChanged: (value) {
                            setState(() => couponForm['discountPercentageRate'] = value); 
                          }
                        ),

                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Offer Free Delivery Checkbox
              CustomCheckbox(
                value: couponForm['offerFreeDelivery'],
                disabled: isSubmitting,
                text: 'Offer Free Delivery',
                onChanged: (value) {
                  setState(() => couponForm['offerFreeDelivery'] = value ?? false);
                }
              ),

              /// Activation
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
              
                    /// Activation Title
                    CustomTitleSmallText('Activation'),
              
                    /// Spacer
                    SizedBox(height: 4),
                    
                    /// Activation Description
                    CustomBodyText('Set how this coupon will be activated'),
                    
                  ],
                ),
              ),

              /// Activate Using Code Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingCode'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on code'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingCode']) const CustomBodyText('The customer must provide this code', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingCode'] = value ?? false);
                }
              ),

              /// Fixed Discount Rate & Percentage Discount Rate
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingCode'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Activation Code
                        CustomTextFormField(
                          errorText: serverErrors.containsKey('code') ? serverErrors['code'] : null,
                          enabled: !isSubmitting && !isDeleting,
                          initialValue: couponForm['code'],
                          labelText: 'Activation Code',
                          borderRadiusAmount: 16,
                          maxLength: 10,
                          hintText: '10off',
                          onChanged: (value) {
                            setState(() => couponForm['code'] = value); 
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Minimum Grand Total Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingMinimumGrandTotal'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on minimum grand total'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingMinimumGrandTotal']) const CustomBodyText('The customer must order worth so much or more', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingMinimumGrandTotal'] = value ?? false);
                }
              ),

              /// Activate Using Minimum Grand Total Text Form Field
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingMinimumGrandTotal'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Minimum Grand Total Text Form Field
                        CustomMoneyTextFormField(
                          errorText: serverErrors.containsKey('minimumGrandTotal') ? serverErrors['minimumGrandTotal'] : null,
                          initialValue: couponForm['minimumGrandTotal'],
                          enabled: !isSubmitting && !isDeleting,
                          labelText: 'Grand Total',
                          hintText: '10off',
                          onChanged: (value) {
                            setState(() => couponForm['minimumGrandTotal'] = value); 
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Minimum Total Products Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingMinimumTotalProducts'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on minimum total products'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingMinimumTotalProducts']) CustomBodyText('The customer must order ${couponForm['minimumTotalProducts']} ${couponForm['minimumTotalProducts'] == '1' ? 'product': 'different products'}', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingMinimumTotalProducts'] = value ?? false);
                }
              ),

              /// Activate Using Minimum Total Products Text Form Field
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingMinimumTotalProducts'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Minimum Total Products Text Form Field
                        CustomTextFormField(
                          errorText: serverErrors.containsKey('minimumTotalProducts') ? serverErrors['minimumTotalProducts'] : null,
                          initialValue: couponForm['minimumTotalProducts'],
                          enabled: !isSubmitting && !isDeleting,
                          keyboardType: TextInputType.number,
                          labelText: 'Minimum Products',
                          borderRadiusAmount: 16,
                          maxLength: 6,
                          hintText: '10off',
                          onChanged: (value) {
                            setState(() => couponForm['minimumTotalProducts'] = value); 
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Minimum Total Products Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingMinimumTotalProductQuantities'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on minimum total product quantities'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingMinimumTotalProductQuantities']) CustomBodyText('The customer must order a total of ${couponForm['minimumTotalProductQuantities']} ${couponForm['minimumTotalProductQuantities'] == '1' ? 'quantity': 'quantities'} of any products combined', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingMinimumTotalProductQuantities'] = value ?? false);
                }
              ),

              /// Activate Using Minimum Total Product Quantities Text Form Field
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingMinimumTotalProductQuantities'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Minimum Total Product Quantities
                        CustomTextFormField(
                          errorText: serverErrors.containsKey('minimumTotalProductQuantities') ? serverErrors['minimumTotalProductQuantities'] : null,
                          initialValue: couponForm['minimumTotalProductQuantities'],
                          enabled: !isSubmitting && !isDeleting,
                          keyboardType: TextInputType.number,
                          labelText: 'Minimum Quantities',
                          borderRadiusAmount: 16,
                          hintText: '10off',
                          maxLength: 6,
                          onChanged: (value) {
                            setState(() => couponForm['minimumTotalProductQuantities'] = value); 
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Start Datetime Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingStartDatetime'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate from start datetime'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingStartDatetime']) const CustomBodyText('The customer must place their order On or After this date and time', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingStartDatetime'] = value ?? false);
                }
              ),

              /// Activate Using Start Datetime Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingStartDatetime'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Start Date Time Picker
                        CustomDatetimePicker(
                          lastDate: (couponForm['startDatetime'] ?? DateTime.now()).add(const Duration(days: 365)),
                          firstDate: couponForm['startDatetime'] ?? DateTime.now(),
                          initialValue: couponForm['startDatetime']?.toString(),
                          type: DateTimePickerType.dateTimeSeparate,
                          dateLabelText: 'Start Date',
                          timeLabelText: 'Start Time',
                          borderRadiusAmount: 16,
                          dateMask: 'MMM d, yyyy',
                          onChanged: (value) {
                            setState(() => couponForm['startDatetime'] = DateTime.parse(value));
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using End Datetime Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingEndDatetime'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate until end datetime'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingEndDatetime']) const CustomBodyText('The customer must place their order Before this date and time', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingEndDatetime'] = value ?? false);
                }
              ),

              /// Activate Using End Datetime Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingEndDatetime']
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// End Date Time Picker
                        CustomDatetimePicker(
                          lastDate: (couponForm['endDatetime'] ?? DateTime.now()).add(const Duration(days: 365)),
                          firstDate: couponForm['endDatetime'] ?? DateTime.now(),
                          initialValue: couponForm['endDatetime']?.toString(),
                          type: DateTimePickerType.dateTimeSeparate,
                          dateLabelText: 'End Date',
                          timeLabelText: 'End Time',
                          borderRadiusAmount: 16,
                          dateMask: 'MMM d, yyyy',
                          onChanged: (value) {
                            setState(() => couponForm['endDatetime'] = DateTime.parse(value));
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Hours Of The Day Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingHoursOfDay'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on hours of the day'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingHoursOfDay']) const CustomBodyText('The customer must place their order on these specific hours of the day', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingHoursOfDay'] = value ?? false);
                }
              ),

              /// Activate Using Hours Of The Day Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingHoursOfDay']
                      ? [
                    
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Hours Of The Day Picker
                        CustomMultiSelectFormField(
                          title: 'Hours Of The Day',
                          hintText: 'Select hours of the day',
                          initialValue: couponForm['hoursOfDay'],
                          key: ValueKey(couponForm['hoursOfDay'].length),
                          dataSource: List<dynamic>.from(hoursOfDay.map((hourOfDay) => {
                            'display': hourOfDay,
                            'value': hourOfDay,
                          })),
                          onSaved: (value) {
                            if (value != null) {
                              List<String> sortedHours = List<String>.from(value);
                              sortedHours.sort();
                              setState(() => couponForm['hoursOfDay'] = sortedHours); 
                            }
                          },
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Days Of The Week Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingDaysOfTheWeek'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on days of the week'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingDaysOfTheWeek']) const CustomBodyText('The customer must place their order on these specific days of the week', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingDaysOfTheWeek'] = value ?? false);
                }
              ),

              /// Activate Using Days Of The Week Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingDaysOfTheWeek']
                      ? [
                    
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Days Of The Week Picker
                        CustomMultiSelectFormField(
                          title: 'Days Of The Week',
                          hintText: 'Select days of the week',
                          initialValue: couponForm['daysOfTheWeek'],
                          key: ValueKey(couponForm['daysOfTheWeek'].length),
                          dataSource: List<dynamic>.from(daysOfTheWeek.map((dayOfTheWeek) => {
                            'display': dayOfTheWeek,
                            'value': dayOfTheWeek,
                          })),
                          onSaved: (value) {
                            if (value != null) {
                              List<String> sortedDaysOfTheWeek = List<String>.from(value);
                              sortedDaysOfTheWeek.sort((a, b) => daysOfTheWeek.indexOf(a).compareTo(daysOfTheWeek.indexOf(b)));
                              setState(() => couponForm['daysOfTheWeek'] = sortedDaysOfTheWeek);
                            }
                          },
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Days Of The Month Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingDaysOfTheMonth'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on days of the month'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingDaysOfTheMonth']) const CustomBodyText('The customer must place their order on these specific days of the month', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingDaysOfTheMonth'] = value ?? false);
                }
              ),

              /// Activate Using Days Of The Month Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingDaysOfTheMonth']
                      ? [
                    
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Days Of The Month Picker
                        CustomMultiSelectFormField(
                          title: 'Days Of The Month',
                          hintText: 'Select days of the month',
                          initialValue: couponForm['daysOfTheMonth'],
                          key: ValueKey(couponForm['daysOfTheMonth'].length),
                          dataSource: List<dynamic>.from(daysOfTheMonth.map((dayOfTheMonth) => {
                            'display': dayOfTheMonth,
                            'value': dayOfTheMonth,
                          })),
                          onSaved: (value) {
                            if (value != null) {
                              List<String> sortedDaysOfTheMonth = List<String>.from(value);
                              sortedDaysOfTheMonth.sort((a, b) => daysOfTheMonth.indexOf(a).compareTo(daysOfTheMonth.indexOf(b)));
                              setState(() => couponForm['daysOfTheMonth'] = sortedDaysOfTheMonth);
                            }
                          },
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Months Of The Year Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingMonthsOfTheYear'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on months of the year'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingMonthsOfTheYear']) const CustomBodyText('The customer must place their order on these specific months of the year', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingMonthsOfTheYear'] = value ?? false);
                }
              ),

              /// Activate Using Months Of The Year Picker
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: couponForm['activateUsingMonthsOfTheYear']
                      ? [
                    
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Months Of The Year Picker
                        CustomMultiSelectFormField(
                          title: 'Months Of The Year',
                          hintText: 'Select days of the month',
                          initialValue: couponForm['monthsOfTheYear'],
                          key: ValueKey(couponForm['monthsOfTheYear'].length),
                          dataSource: List<dynamic>.from(monthsOfTheYear.map((monthOfTheYear) => {
                            'display': monthOfTheYear,
                            'value': monthOfTheYear,
                          })),
                          onSaved: (value) {
                            if (value != null) {
                              List<String> sortedMonthsOfTheYear = List<String>.from(value);
                              sortedMonthsOfTheYear.sort((a, b) => monthsOfTheYear.indexOf(a).compareTo(monthsOfTheYear.indexOf(b)));
                              setState(() => couponForm['monthsOfTheYear'] = sortedMonthsOfTheYear);
                            }
                          },
                        ),
                        
                      ]
                    : []
                  )
                )
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Activate Using Usage Limit Checkbox
              CustomCheckbox(
                value: couponForm['activateUsingUsageLimit'],
                disabled: isSubmitting,
                text: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomBodyText('Activate on usage limit'),
                    const SizedBox(height: 4,),
                    if(couponForm['activateUsingUsageLimit']) CustomBodyText('The customer must place their order before this limited coupon runs out. Currently we have ${couponForm['remainingQuantity']} ${couponForm['remainingQuantity'] == 1 ? 'coupon' : 'coupons'} remaining', lightShade: true,),
                  ],
                ),
                onChanged: (value) {
                  setState(() => couponForm['activateUsingUsageLimit'] = value ?? false);
                }
              ),

              /// Activate Using Usage Limit Text Form Field
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: couponForm['activateUsingUsageLimit'] 
                      ? [
              
                        /// Spacer
                        const SizedBox(height: 16),

                        /// Remaining Quantity Text Form Field
                        CustomTextFormField(
                          errorText: serverErrors.containsKey('remainingQuantity') ? serverErrors['remainingQuantity'] : null,
                          initialValue: couponForm['remainingQuantity'],
                          enabled: !isSubmitting && !isDeleting,
                          borderRadiusAmount: 16,
                          labelText: 'Remaining',
                          hintText: '100',
                          maxLength: 6,
                          onChanged: (value) {
                            setState(() => couponForm['remainingQuantity'] = value); 
                          }
                        ),
                        
                      ]
                    : []
                  )
                )
              ),

              /// Divider
              const SizedBox(height: 40,),

              if(isEditing) Container(
                padding: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    /// Title
                    const CustomTitleMediumText('Summary', margin: EdgeInsets.only(bottom: 4),),

                    /// Spacer
                    const SizedBox(height: 4),

                    /// Subtitle
                    const CustomBodyText('How this coupon works'),

                    /// Divider
                    const Divider(),
              
                    /// Counpon Summary
                    ...coupon!.attributes.instructions.mapIndexed((index, instruction) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Spacer
                        if(index != 0) const SizedBox(height: 8,),

                        /// Instruction
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.green.shade400, size: 16,),
                            const SizedBox(width: 8),
                            Expanded(child: CustomBodyText(instruction)),
                          ],
                        ),

                      ],
                    )).toList(),

                    /// Divider
                    const Divider(),

                    /// Subtitle
                    const CustomBodyText('Save changes to update this summary'),

                  ],
                ),
              ),

              /// Divider
              const SizedBox(height: 40,),

              if(isEditing) Container(
                padding: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.red.shade50
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    /// Title
                    const CustomTitleMediumText('Delete', margin: EdgeInsets.only(bottom: 4),),

                    /// Divider
                    const Divider(),
              
                    /// Remove Team Member Instructions
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          height: 1.4
                        ),
                        text: 'Permanently delete ',
                        children: [
                          TextSpan(text: couponForm['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: '. Once this coupon is deleted you will not be able to recover it.'),
                        ]
                      ),
                    ),

                    /// Spacer
                    const SizedBox(height: 8,),

                    /// Remove Button
                    CustomElevatedButton(
                      'Delete',
                      width: 180,
                      isError: true,
                      isLoading: isDeleting,
                      alignment: Alignment.center,
                      onPressed: _requestDeleteCoupon,
                      disabled: isDeleting || isSubmitting,
                    ),

                  ],
                ),
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