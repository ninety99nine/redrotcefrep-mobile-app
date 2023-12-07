import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_cart_details.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

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
  bool isLoading = false;
  String whoIsPaying = 'Me';
  bool isSubmitting = false;
  late PayableAmount payableAmount;
  final _formKey = GlobalKey<FormState>();
  final CarouselController carouselController = CarouselController();
  List<String> whoIsPayingOptions = ['Me', 'Friend', 'Split Payment'];
  final bankCards = ['orange_money', 'myzaka', 'smega', 'absa', 'fnb', 'stanbic', 'standard_chartered'];
  
  PaymentMethod? selectedPaymentMethod;
  List<PaymentMethod> paymentMethods = [];
  bool get hasSelectedPaymentMethodThatSupportsPerfectPay => selectedPaymentMethod != null;
  bool get isPayingUsingDpoCard => hasSelectedPaymentMethodThatSupportsPerfectPay && selectedPaymentMethod!.attributes.isDpoCard;
  bool get isPayingUsingOrangeMoney => hasSelectedPaymentMethodThatSupportsPerfectPay && selectedPaymentMethod!.attributes.isOrangeMoney;

  Order get order => widget.order;
  bool get payingByMyself => whoIsPaying == 'Me';
  bool get payingUsingFriend => whoIsPaying == 'Friend';
  ShoppableStore get store => order.relationships.store!;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get payingUsingSplitPayment => whoIsPaying == 'Split Payment';
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  Function(Transaction)? get onRequestPayment => widget.onRequestPayment;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
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
    _requestShowRequestPaymentPaymentMethods();
    payableAmount = order.attributes.payableAmounts.first;
  }

  void _requestShowRequestPaymentPaymentMethods() async {

    if(isLoading) return;

    _startLoader();

    orderProvider.setOrder(order).orderRepository.showRequestPaymentPaymentMethods().then((response) {

      if(response.statusCode == 200) {

        setState(() {

          paymentMethods = (response.data['data'] as List).map((paymentMethod) {
            return PaymentMethod.fromJson(paymentMethod);
          }).toList();

          /// If we have payment methods
          if(paymentMethods.isNotEmpty) {

            /// If the customer selected a preffered payment method
            if(order.paymentMethodId != null) {

              /// Select this preffered payment method if it exists
              selectedPaymentMethod = paymentMethods.firstWhereOrNull((selectedPaymentMethod) => selectedPaymentMethod.id == order.paymentMethodId);

            }

            /// Select the first payment method if we still have no payment method selected
            selectedPaymentMethod ??= paymentMethods.first;

          }

        });

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show payment methods');

    }).whenComplete(() {

      _stopLoader();

    });

  }

  void _requestPayment() async {

    if(isSubmitting) return;

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.requestPayment(
      percentage: payableAmount.percentage,
      paymentMethodId: selectedPaymentMethod!.id
    ).then((response) {

      if(response.statusCode == 200) {
        

        final Transaction createdTransaction = Transaction.fromJson(response.data);
        
        /// Notify parent widget on created transaction
        if(onRequestPayment != null) onRequestPayment!(createdTransaction);

        /// Close the Dialog
        Get.back();

        if(requestingPayment) {

          /// Notify the user that they can share the payment link with their customer
          SnackbarUtility.showSuccessMessage(message: 'Share payment link with your customer');

          if(isPayingUsingDpoCard) OrderServices().sharePaymentLink(order, createdTransaction);

        /// If paying by myself
        }else if(payingByMyself) {

          /// Notify the user that we are preparing payment
          SnackbarUtility.showSuccessMessage(message: 'Preparing payment');

          /// Launch Direct Pay Online
          if(isPayingUsingDpoCard) OrderServices().launchPaymentLink(createdTransaction, context);

        /// If paying using friend
        }else if(payingUsingFriend) {

          /// Notify the user that they can share the payment link with their friend
          SnackbarUtility.showSuccessMessage(message: 'Share payment link with your friend');

          if(isPayingUsingDpoCard) OrderServices().sharePaymentLink(order, createdTransaction);

        /// If paying using split payment
        }else if(payingUsingSplitPayment) {

          /// Notify the user that they can share the payment links with their friends
          SnackbarUtility.showSuccessMessage(message: 'Share payment links with your friends');

        }

      }

    }).onError((dio.DioException exception, stackTrace) {

      ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to prepare payment');

    }).whenComplete(() {

      _stopSubmittionLoader();

    });

  }
  
  Widget get paymentMethodChoices {
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
            ...paymentMethods.map((option) {
      
              final selected = option.id == selectedPaymentMethod!.id;

              /// Return this choice chip option
              return CustomChoiceChip(
                label: option.name,
                selected: selected,
                selectedColor: Colors.green.shade700,
                onSelected: (_) {
                  if(!isSubmitting) {
                    setState(() => selectedPaymentMethod = option);
                  }
                }
              );
      
            })
          ],
        ),
      ),
    );
  }

  Widget get bankCardSlider {
    return CarouselSlider.builder(
        carouselController: carouselController,
        options: CarouselOptions(
          height: 140,
          padEnds: true,
          autoPlay: true,
          viewportFraction: 0.6,
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

  Widget get orangeMoneyLogo {

    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      child: Image.asset('assets/images/payment_method_logos/orange_money.png'),
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
              children: [
                
                

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: requestingPayment 
                    ? [
        
                      /// Order Cart Details
                      OrderCartDetails(order: order, showTopDivider: false),
    
                      /// Spacer
                      const SizedBox(height: 16),

                      if(isLoading) ...[

                        const CustomCircularProgressIndicator(),

                      ],

                      if(!isLoading) ...[

                        paymentMethodChoices,
    
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
                        
                      ],
    
                      /// Spacer
                      const SizedBox(height: 100)

                    ]
                    : [
        
                    /// Order Cart Details
                    OrderCartDetails(order: order, showTopDivider: false),

                    if(isLoading) ...[
    
                      /// Spacer
                      const SizedBox(height: 16),

                      const CustomCircularProgressIndicator(),

                    ],

                    if(!isLoading) ...[

                      paymentMethodChoices,

                      SizedBox(
                        width: double.infinity,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          child: AnimatedSwitcher(
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              key: ValueKey(isPayingUsingDpoCard),
                              children: [
                                      
                                /// Spacer
                                const Divider(height: 24,),
                                    
                                /// Orange Money Logo
                                if(isPayingUsingOrangeMoney) orangeMoneyLogo,
                                    
                                /// Bank Card Slider
                                if(isPayingUsingDpoCard) bankCardSlider,
                      
                              ],
                            )
                          ),
                        ),
                      ),
                    
                      /// Spacer
                      const Divider(height: 24,),
      
                      if(percentageErrorText != null) ...[
      
                        /// Percentage error text
                        CustomBodyText(percentageErrorText, isError: true),
      
                        /// Spacer
                        const SizedBox(height: 16),
      
                      ],
      
                      /// Who is paying title
                      const CustomTitleSmallText('Who is paying paying'),
      
                      /// Spacer
                      const SizedBox(height: 16),
        
                      /// Who is paying choices
                      whoIsPayingChoices,
      
                      /// Spacer
                      const SizedBox(height: 16),
                      
                      /// Payment Instruction
                      paymentInstruction,
      
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

                    ],
  
                    /// Spacer
                    const SizedBox(height: 100)
                  
                  ]
                ),
              ],
            )
          )
        ),
          
      ]
    );

  }
}