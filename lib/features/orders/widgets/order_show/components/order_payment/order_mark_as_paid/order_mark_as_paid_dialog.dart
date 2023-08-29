import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class MarkAsPaidDialog extends StatefulWidget {

  final Order order;
  final Function()? onMarkedAsPaid;

  const MarkAsPaidDialog({
    super.key,
    this.onMarkedAsPaid,
    required this.order
  });

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {

  bool isLoading = false;
  bool isSubmitting = false;
  late PayableAmount payableAmount;
  PaymentMethod? supportedPaymentMethod;
  List<PaymentMethod> supportedPaymentMethods = [];

  Order get order => widget.order;
  ShoppableStore get store => order.relationships.store!;
  Function()? get onMarkedAsPaid => widget.onMarkedAsPaid;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _requestSupportedPaymentMethods();
    payableAmount = order.attributes.payableAmounts.first;
  }

  void _requestSupportedPaymentMethods() async {

    _startLoader();

    storeProvider.setStore(store).storeRepository.showAvailablePaymentMethods().then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {
        setState(() {
          supportedPaymentMethods = (responseBody['data'] as List).map((paymentMethod) {
            return PaymentMethod.fromJson(paymentMethod);
          }).toList();

          /// If we have supported payment methods
          if(supportedPaymentMethods.isNotEmpty) {

            /// If the customer selected a preffered payment method
            if(order.paymentMethodId != null) {

              /// Select this preffered payment method if it exists
              supportedPaymentMethod = supportedPaymentMethods.firstWhereOrNull((supportedPaymentMethod) => supportedPaymentMethod.id == order.paymentMethodId);

            }

            /// Select the first payment method if we still have no payment method selected
            supportedPaymentMethod ??= supportedPaymentMethods.first;

          }
        });
      }

    }).whenComplete(() {

      _stopLoader();
    
    });

  }

  void _requestMarkAsUnverifiedPayment() async {

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.markAsUnverifiedPayment(
      paymentMethodId: supportedPaymentMethod!.id,
      percentage: payableAmount.percentage,
      amount: '100'
    ).then((response) {
      if(response.statusCode == 200) {

        /// Close the Dialog
        Get.back();
        if(onMarkedAsPaid != null) onMarkedAsPaid!();
        SnackbarUtility.showSuccessMessage(message: 'Marked as paid');
        
      }
    }).whenComplete(() {
      _stopSubmittionLoader();
    });

  }

  Widget get paymentChoices {        
    return Row(
      children: [

        const CustomBodyText('Payment', fontWeight: FontWeight.bold,),

        /// Spacer
        const SizedBox(width: 8),

        /// Dropdown
        DropdownButton(
          value: supportedPaymentMethod,
          items: [

            ...supportedPaymentMethods.map((supportedPaymentMethod) {

              return DropdownMenuItem(
                value: supportedPaymentMethod,
                child: CustomBodyText(supportedPaymentMethod.name),
              );

            })

          ],
          onChanged: (value) {
            if(!isSubmitting && value != null) {
              setState(() => supportedPaymentMethod = value);
            }
          },
        ),
      ],
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

  Widget get finalAmount {        
    return CustomTitleLargeText(payableAmount.amount.amountWithCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Title
        const CustomTitleMediumText(
          margin: EdgeInsets.symmetric(vertical: 8),
          'Mark As Paid'
        ),

        /// Description
        const CustomBodyText(
          margin: EdgeInsets.symmetric(vertical: 8),
          'Mark this order as paid if you received payment from the customer via cash, ewallet, card swipping or any other way'
        ),

        SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: isLoading 
                ? const CustomCircularProgressIndicator(strokeWidth: 2, margin: EdgeInsets.symmetric(vertical: 16))
                : Column(
                  children: [
          
                    /// Payable Amount Choices
                    payableAmountChoices,
          
                    /// Payment Choices
                    paymentChoices,
          
                    /// Spacer
                    const SizedBox(height: 16),

                    finalAmount,
          
                    /// Spacer
                    const SizedBox(height: 16),
          
                    /// Mark As Paid Button
                    CustomElevatedButton(
                      width: 120,
                      fontSize: 12,
                      'Mark As Paid',
                      color: Colors.green,
                      isLoading: isSubmitting,
                      alignment: Alignment.center,
                      prefixIcon: Icons.check_circle_sharp,
                      onPressed: _requestMarkAsUnverifiedPayment,
                    ),
          
                  ],
                ),
            ),
          ),
        ),

      ],
    );
  }
}