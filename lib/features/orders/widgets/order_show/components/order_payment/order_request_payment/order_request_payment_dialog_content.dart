import 'package:bonako_demo/features/orders/widgets/order_show/components/order_cart_details.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrderRequestPaymentDialogContent extends StatefulWidget {

  final Order order;
  final Function(Transaction)? onRequestPayment;

  const OrderRequestPaymentDialogContent({
    super.key,
    this.onRequestPayment,
    required this.order
  });

  @override
  State<OrderRequestPaymentDialogContent> createState() => _OrderRequestPaymentDialogContentState();
}

class _OrderRequestPaymentDialogContentState extends State<OrderRequestPaymentDialogContent> {

  Map serverErrors = {};
  String whoIsPaying = 'Me';
  bool isSubmitting = false;
  late PayableAmount payableAmount;
  final _formKey = GlobalKey<FormState>();
  final CarouselController carouselController = CarouselController();
  List<String> whoIsPayingOptions = ['Me', 'Friend', 'Split Payment'];
  final bankCards = ['orange_money', 'myzaka', 'smega', 'absa', 'fnb', 'stanbic', 'standard_chartered'];

  Order get order => widget.order;
  bool get payingByMyself => whoIsPaying == 'Me';
  bool get payingUsingFriend => whoIsPaying == 'Friend';
  ShoppableStore get store => order.relationships.store!;
  bool get payingUsingSplitPayment => whoIsPaying == 'Split Payment';
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  Function(Transaction)? get onRequestPayment => widget.onRequestPayment;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  bool get isAssociatedAsAFriend => userOrderCollectionAssociation?.isAssociatedAsFriend ?? false;
  bool get isAssociatedAsACustomer => userOrderCollectionAssociation?.isAssociatedAsCustomer ?? false;
  bool get requestingPayment => canManageOrders && !(isAssociatedAsACustomer || isAssociatedAsAFriend);
  String? get percentageErrorText => serverErrors.containsKey('percentage') ? serverErrors['percentage'] : null;
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;

  @override
  void initState() {
    super.initState();
    payableAmount = order.attributes.payableAmounts.first;
  }

  void _requestPayment() async {

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.requestPayment(
      percentage: payableAmount.percentage
    ).then((response) {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final Transaction createdTransaction = Transaction.fromJson(responseBody);
          
          /// Notify parent widget on created transaction
          if(onRequestPayment != null) onRequestPayment!(createdTransaction);

          /// Close the Dialog
          Get.back();

          if(requestingPayment) {

            /// Notify the user that they can share the payment link with their customer
            SnackbarUtility.showSuccessMessage(message: 'Share payment link with your customer');

            OrderServices().sharePaymentLink(order, createdTransaction);

          /// If paying by myself
          }else if(payingByMyself) {

            /// Notify the user that we are preparing payment
            SnackbarUtility.showSuccessMessage(message: 'Preparing payment');

            /// Launch Direct Pay Online
            OrderServices().launchPaymentLink(createdTransaction, context);

          /// If paying using friend
          }else if(payingUsingFriend) {

            /// Notify the user that they can share the payment link with their friend
            SnackbarUtility.showSuccessMessage(message: 'Share payment link with your friend');

            OrderServices().sharePaymentLink(order, createdTransaction);

          /// If paying using split payment
          }else if(payingUsingSplitPayment) {

            /// Notify the user that they can share the payment links with their friends
            SnackbarUtility.showSuccessMessage(message: 'Share payment links with your friends');

          }

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }
        
    }).whenComplete(() {
      _stopSubmittionLoader();
    });

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

  Widget get payHustleFreeInstruction {
    return CustomMessageAlert(
      showIcon: false,
      padding: const EdgeInsets.all(16),
      bgColor: Theme.of(context).primaryColor.withOpacity(0.1),
      'Pay hassle-free with any card 😍 - Choose from 3 options:\n\n1. Pay yourself\n2. Friends pay for you\n3. Split the bill with friends.'
    );
  }

  Widget get bankCardSlider {
    return CarouselSlider.builder(
        carouselController: carouselController,
        options: CarouselOptions(
          padEnds: true,
          autoPlay: true,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          clipBehavior: Clip.hardEdge,

          autoPlayInterval: const Duration(seconds: 10),
          autoPlayAnimationDuration: const Duration(seconds: 5),
        ),
        itemCount: bankCards.length,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          
          /// Slider Content
          return Image.asset('assets/images/bank_cards/${bankCards[itemIndex]}.png');

        }
      );
  }

  Widget get whoIsPayingChoices {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          spacing: 8,
          children: [
            ...whoIsPayingOptions.map((option) {
      
              final selected = whoIsPaying == option;

              /// Return this choice chip option
              return CustomChoiceChip(
                label: option,
                selected: selected,
                selectedColor: Colors.green.shade700,
                onSelected: (_) {
                  if(!isSubmitting) {
                    setState(() => whoIsPaying = option);
                  }
                }
              );
      
            })
          ],
        ),
      ),
    );
  }

  Widget get payableAmountChoices {        
    return Row(
      children: [

        const CustomBodyText('Amount', fontWeight: FontWeight.bold,),

        /// Spacer
        const SizedBox(width: 8),

        /// Dropdown
        DropdownButton(
          value: payableAmount,
          items: [

            ...order.attributes.payableAmounts.map((payableAmount) {

              return DropdownMenuItem(
                value: payableAmount,
                child: CustomBodyText(payableAmount.name),
              );

            })

          ],
          onChanged: (value) {
            if(!isSubmitting && value != null) {
              setState(() => payableAmount = value);
            }
          },
        ),
      ],
    );
  }


  Widget get paymentInstruction {

    String instruction;

    /// If paying by myself
    if(payingByMyself) {

      instruction = 'You will pay for this order yourself';

    /// If paying using friend
    }else if(payingUsingFriend) {

      instruction = 'Your friend, family or co-worker will help you pay for this order';

    /// If paying using split payment
    }else{

      instruction = 'You and your friends, family or co-workers will split the cost of this order';

    }

    return CustomBodyText(instruction);
  }

  Widget get payNowButton {        
    return CustomElevatedButton(
      isLoading: isSubmitting,
      prefixIcon: Icons.payment,
      onPressed: _requestPayment,
      alignment: Alignment.center,
      width: canManageOrders ? 160 : 100,
      requestingPayment ? 'Request Payment' : 'Pay Now',
    );
  }

  Widget get createPaymentLinkButton {        
    return CustomElevatedButton(
      width: 200,
      'Create Payment Link',
      isLoading: isSubmitting,
      onPressed: _requestPayment,
      alignment: Alignment.center,
      prefixIcon: Icons.link_rounded,
    );
  }

  Widget get splitPaymentButton {        
    return CustomElevatedButton(
      width: 140,
      'Split Payment',
      isLoading: isSubmitting,
      onPressed: _requestPayment,
      alignment: Alignment.center,
      prefixIcon: Icons.call_split_rounded,
    );
  }

  Widget get finalAmount {        
    return CustomTitleLargeText(payableAmount.amount.amountWithCurrency);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// Content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: requestingPayment 
                ? [
        
                  /// Order Cart Details
                  OrderCartDetails(order: order, showTopDivider: false),
    
                  /// Spacer
                  const SizedBox(height: 16),
    
                  /// Payable Amount Choices
                  payableAmountChoices,
    
                  /// Spacer
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// Final Amount
                      finalAmount,

                    ],
                  ),
    
                  /// Spacer
                  const SizedBox(height: 16),
    
                  /// Create Payment Link Button
                  createPaymentLinkButton,
    
                  /// Spacer
                  const SizedBox(height: 100)

                ]
                : [
        
                /// Order Cart Details
                OrderCartDetails(order: order, showTopDivider: false),
    
                /// Pay Hustle Free Instruction
                payHustleFreeInstruction,
              
                /// Spacer
                const Divider(height: 24,),
    
                /// Bank Card Slider
                bankCardSlider,
              
                /// Spacer
                const Divider(height: 24,),
    
                if(percentageErrorText != null) ...[
    
                  /// Percentage error text
                  CustomBodyText(percentageErrorText, isError: true),
    
                  /// Spacer
                  const SizedBox(height: 16),
    
                ],
    
                /// Who is paying title
                const CustomTitleSmallText('How are you paying'),
    
                /// Spacer
                const SizedBox(height: 16),
      
                /// Who is paying choices
                whoIsPayingChoices,
    
                /// Spacer
                const SizedBox(height: 16),
    
                /// Payable Amount Choices
                payableAmountChoices,
      
                /// Spacer
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// Final Amount
                    finalAmount,

                  ],
                ),
    
                /// Spacer
                const SizedBox(height: 16),
                
                /// Payment Instruction
                paymentInstruction,
      
                /// Spacer
                const SizedBox(height: 16),
    
                /// If paying by myself
                if(payingByMyself) ...[
    
                  /// Pay Now Button
                  payNowButton
    
                ],
    
                /// If paying using friend
                if(payingUsingFriend) ...[
    
                  /// Create Payment Link Button
                  createPaymentLinkButton
    
                ],
    
                /// If paying using split payment
                if(payingUsingSplitPayment) ...[
    
                  /// Split Payment Button
                  splitPaymentButton
    
                ],
    
                /// Spacer
                const SizedBox(height: 100)
              
              ]
            )
          )
        ),
          
      ]
    );

  }
}