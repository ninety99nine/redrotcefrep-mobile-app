import 'package:bonako_demo/features/transactions/widgets/transaction_proof_of_payment_photo.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarkAsPaidDialog extends StatefulWidget {

  final Order order;
  final Function()? onMarkedAsPaid;

  const MarkAsPaidDialog({
    super.key,
    required this.order,
    this.onMarkedAsPaid,
  });

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {

  User? selectedPaidByUser;
  bool isSubmitting = false;
  XFile? proofOfPaymentPhoto;
  bool isLoadingUsers = false;
  List<User> orderForUsers = [];
  late PayableAmount payableAmount;
  PaymentMethod? selectedPaymentMethod;
  bool isLoadingPaymentMethods = false;
  List<PaymentMethod> paymentMethods = [];

  Order get order => widget.order;
  User get customer => order.relationships.customer!;
  ShoppableStore get store => order.relationships.store!;
  Function()? get onMarkedAsPaid => widget.onMarkedAsPaid;
  bool get hasProofOfPaymentPhoto => proofOfPaymentPhoto != null;
  void _startUserLoader() => setState(() => isLoadingUsers = true);
  void _stopUserLoader() => setState(() => isLoadingUsers = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  void _startPaymentMethodsLoader() => setState(() => isLoadingPaymentMethods = true);
  void _stopPaymentMethodsLoader() => setState(() => isLoadingPaymentMethods = false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();

    if(order.attributes.isOrderingForMe) {

      selectedPaidByUser = customer;
      orderForUsers = [customer];

    }else{

      _requestShowOrderForUsers();

    }

    _requestShowMarkAsUnverifiedPaymentPaymentMethods();
    payableAmount = order.attributes.payableAmounts.first;
  }

  void _requestShowOrderForUsers() async {

    if(isLoadingUsers) return;

    _startUserLoader();

    orderProvider.setOrder(order).orderRepository.showOrderUsers(
      userType: UserType.friend,
    ).then((response) {

      if(response.statusCode == 200) {
        setState(() {

          ///  Add the customer first
          orderForUsers.add(customer);

          final List<User> friends = (response.data['data'] as List).map((orderForUser) {
            return User.fromJson(orderForUser);
          }).toList();

          ///  Add the friends next
          orderForUsers.addAll(friends);

          /// Select the first user (the customer)
          selectedPaidByUser = orderForUsers.first;

        });
      }

    }).whenComplete(() {

      _stopUserLoader();
    
    });

  }

  void _requestShowMarkAsUnverifiedPaymentPaymentMethods() async {

    if(isLoadingPaymentMethods) return;

    _startPaymentMethodsLoader();

    orderProvider.setOrder(order).orderRepository.showMarkAsUnverifiedPaymentPaymentMethods().then((response) {

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

    }).whenComplete(() {

      _stopPaymentMethodsLoader();
    
    });

  }

  void _requestMarkAsUnverifiedPayment() async {
    
    if(isSubmitting) return;

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.markAsUnverifiedPayment(
      paymentMethodId: selectedPaymentMethod!.id,
      proofOfPaymentPhoto: proofOfPaymentPhoto,
      percentage: payableAmount.percentage,
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

  Widget get paidByChoices {        
    return Row(
      children: [

        const CustomBodyText('Paid By', fontWeight: FontWeight.bold,),

        /// Spacer
        const SizedBox(width: 8),

        /// Dropdown
        DropdownButton(
          value: selectedPaidByUser,
          items: [

            ...orderForUsers.map((orderForUser) {

              return DropdownMenuItem(
                value: orderForUser,
                child: CustomBodyText(orderForUser.attributes.name),
              );

            })

          ],
          onChanged: (value) {
            if(!isSubmitting && value != null) {
              setState(() => selectedPaidByUser = value);
            }
          },
        ),
      ],
    );
  }

  Widget get paymentMethodChoices {        
    return Row(
      children: [

        const CustomBodyText('Method', fontWeight: FontWeight.bold,),

        /// Spacer
        const SizedBox(width: 8),

        /// Dropdown
        DropdownButton(
          value: selectedPaymentMethod,
          items: [

            ...paymentMethods.map((selectedPaymentMethod) {

              return DropdownMenuItem(
                value: selectedPaymentMethod,
                child: CustomBodyText(selectedPaymentMethod.name),
              );

            })

          ],
          onChanged: (value) {
            if(!isSubmitting && value != null) {
              setState(() => selectedPaymentMethod = value);
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
              child: isLoadingPaymentMethods || isLoadingUsers
                ? const CustomCircularProgressIndicator(strokeWidth: 2, margin: EdgeInsets.symmetric(vertical: 16))
                : Column(
                  children: [
                    
                    /// Paid By Choices
                    paidByChoices,
          
                    /// Payable Amount Choices
                    payableAmountChoices,
          
                    /// Payment Choices
                    paymentMethodChoices,
          
                    /// Spacer
                    const SizedBox(height: 16),

                    /// Final Amount
                    finalAmount,
          
                    /// Spacer
                    const SizedBox(height: 16),

                    /// Proof Of Payment Instruction
                    Align(
                      alignment: Alignment.center,
                      child: CustomBodyText(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        '${hasProofOfPaymentPhoto ? 'P' : 'Attach p'}roof of payment 👇',
                      ),
                    ),

                    /// Proof Of Payment Photo
                    TransactionProofOfPaymentPhoto(
                      store: store,
                      changePhotoType: ChangePhotoType.editIconONextToImage,
                      proofOfPaymentPhotoShape: ProofOfPaymentPhotoShape.rectangle,
                      onPickedFile: (file) {
                        setState(() => proofOfPaymentPhoto = file);
                      },
                    ),

          
                    /// Spacer
                    const SizedBox(height: 16),
          
                    /// Mark As Paid Button
                    CustomElevatedButton(
                      width: 120,
                      fontSize: 12,
                      'Mark As Paid',
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