
import 'package:bonako_demo/features/cart/widgets/cart/cart_details.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/order_content.dart';
import 'package:bonako_demo/features/transactions/repositories/transaction_repository.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/repositories/store_repository.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class RequestPaymentForOrderForm extends StatefulWidget {
  
  final Order order;
  final ShoppableStore store;
  final Transaction? transaction;
  final Function(bool) onSubmitting;
  final Function(Transaction)? onCreatedTransaction;

  const RequestPaymentForOrderForm({
    super.key,
    this.transaction,
    required this.order,
    required this.store,
    this.onCreatedTransaction,
    required this.onSubmitting,
  });

  @override
  State<RequestPaymentForOrderForm> createState() => RequestPaymentForOrderFormState();
}

class RequestPaymentForOrderFormState extends State<RequestPaymentForOrderForm> {

  Map serverErrors = {};
  Map transactionForm = {};
  String whoIsPaying = 'Me';
  bool isSubmitting = false;
  int depositPercentage = 50;
  String? cannotRequestPaymentDeclaimer;
  final _formKey = GlobalKey<FormState>();

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  bool get isEditing => transaction != null;
  bool get isPaid => order.attributes.isPaid;
  bool get isCreating => transaction == null;
  bool get payingByMyself => whoIsPaying == 'Me';
  Transaction? get transaction => widget.transaction;
  bool get payingUsingFriend => whoIsPaying == 'Friend';
  bool get isDeposit => howMuchAreYouPaying == 'Deposit';
  Function(bool) get onSubmitting => widget.onSubmitting;
  bool get isPartiallyPaid => order.attributes.isPartiallyPaid;
  int get percentage => isFullPayment ? 100 : depositPercentage;
  bool get isFullPayment => howMuchAreYouPaying == 'Full Payment';
  bool get payingUsingSplitPayment => whoIsPaying == 'Split Payment';
  StoreRepository get storeRepository => storeProvider.storeRepository;
  Function(Transaction)? get onCreatedTransaction => widget.onCreatedTransaction;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  TransactionRepository get transactionRepository => transactionProvider.transactionRepository;
  TransactionProvider get transactionProvider => Provider.of<TransactionProvider>(context, listen: false);
  String? get percentageErrorText => serverErrors.containsKey('percentage') ? serverErrors['percentage'] : null;

  List<String> whoIsPayingOptions = [
    'Me', 'Friend', 'Split Payment'
  ];

  late String howMuchAreYouPaying;
  List<Map<String, dynamic>> howMuchAreYouPayingOptions = [];

  final Map<String, dynamic> fullPaymentPercentage = {
    'name': 'Full Payment', 
    'percentage': 100,
  };

  final Map<String, dynamic> threeQuartersDepositPercentage = {
    'name': '75% Deposit', 
    'percentage': 75,
  };

  final Map<String, dynamic> halfDepositPercentage = {
    'name': '50% Deposit', 
    'percentage': 50,
  };

  final Map<String, dynamic> quarterDepositPercentage = {
    'name': '25% Deposit', 
    'percentage': 25,
  };

  final Map<String, dynamic> threeQuartersBalancePercentage = {
    'name': '75% Remaining Balance', 
    'percentage': 75,
  };

  final Map<String, dynamic> halfBalancePercentage = {
    'name': '50% Remaining Balance', 
    'percentage': 50,
  };

  final Map<String, dynamic> quarterBalancePercentage = {
    'name': '25% Remaining Balance', 
    'percentage': 25,
  };
  

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();

    if(order.attributes.isPaid) {
      
      cannotRequestPaymentDeclaimer = 'This order has been fully paid';

    }else if((order.amountPaidPercentage.value + order.amountPendingPercentage.value) == order.amountOutstandingPercentage.value) {
      
      cannotRequestPaymentDeclaimer = 'This order has other pending payments amounting up to ${order.amountPending.amountWithCurrency}. Please settle those payments or cancel them before requesting anymore payments.';

    }else{

      /// Calculate the total requested paid and pending payment percentages
      final int paidAndPendingPaymentPercentage = order.amountPaidPercentage.value + order.amountPendingPercentage.value;

      /// If its exactly 75%
      if(paidAndPendingPaymentPercentage == 75) {

        quarterBalancePercentage['name'] = 'Remaining Balance (25%)';
        howMuchAreYouPayingOptions.addAll([quarterBalancePercentage]);

      /// If its exactly 50%
      }else if(paidAndPendingPaymentPercentage == 50) {

        halfBalancePercentage['name'] = 'Remaining Balance (50%)';
        quarterBalancePercentage['name'] = 'Installment (25%)';
        howMuchAreYouPayingOptions.addAll([halfBalancePercentage, quarterBalancePercentage]);

      /// If its exactly 25%
      }else if(paidAndPendingPaymentPercentage == 25) {

        threeQuartersBalancePercentage['name'] = 'Remaining Balance (75%)';
        halfBalancePercentage['name'] = 'Installment (50%)';
        quarterBalancePercentage['name'] = 'Installment (25%)';
        howMuchAreYouPayingOptions.addAll([threeQuartersBalancePercentage, halfBalancePercentage, quarterBalancePercentage]);

      }else if(paidAndPendingPaymentPercentage == 0) {
        
        howMuchAreYouPayingOptions.addAll([fullPaymentPercentage, threeQuartersDepositPercentage, halfDepositPercentage, quarterDepositPercentage]);

      }
        
      howMuchAreYouPaying = howMuchAreYouPayingOptions.first['name'];

    }
    
    /// Future.delayed() is used so that we can wait for the
    /// variables to be set e.g The "transaction" getter property
    Future.delayed(Duration.zero).then((value) {
      
      setTransactionForm();
      updateTransactionFormPercentage();

    });
  }

  setTransactionForm() {

    setState(() {
      
      transactionForm = {
        'percentage': null,
        'paymentMethodId': 6
      };

    });

  }

  void updateTransactionFormPercentage () {
    transactionForm['percentage'] = howMuchAreYouPayingOptions.firstWhere((option) => option['name'] == howMuchAreYouPaying)['percentage'];
  }

  requestPayment() {

    if(isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      orderProvider.setOrder(order).orderRepository.requestPayment(
        percentage: transactionForm['percentage'],
        paymentMethodId: transactionForm['paymentMethodId'],
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final Transaction createdTransaction = Transaction.fromJson(responseBody);
          
          /// Notify parent widget on created transaction
          if(onCreatedTransaction != null) onCreatedTransaction!(createdTransaction);

          /// If paying by myself
          if(payingByMyself) {

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

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t create transaction');

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

  Widget get howMuchAreYouPayingChoices {        
    return Row(
      children: [

        const CustomBodyText('Pay', fontWeight: FontWeight.bold,),

        /// Spacer
        const SizedBox(width: 8),

        /// Dropdown
        DropdownButton(
          value: howMuchAreYouPaying,
          items: [

            ...howMuchAreYouPayingOptions.map((option) {

              return DropdownMenuItem(
                value: option['name'],
                child: CustomBodyText(option['name']),
              );

            })

          ],
          onChanged: (value) {
            if(!isSubmitting && value != null) {
              setState(() {
                howMuchAreYouPaying = (value as String);
                updateTransactionFormPercentage();
              });
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

    return CustomBodyText(
      instruction
    );
  }

  Widget get payNowButton {        
    return CustomElevatedButton(
      'Pay Now',
      isLoading: isSubmitting,
      prefixIcon: Icons.payment,
      onPressed: requestPayment,
      alignment: Alignment.center,
    );
  }

  Widget get createPaymentLinkButton {        
    return CustomElevatedButton(
      width: 200,
      'Create Payment Link',
      isLoading: isSubmitting,
      onPressed: requestPayment,
      alignment: Alignment.center,
      prefixIcon: Icons.link_rounded,
    );
  }

  Widget get splitPaymentButton {        
    return CustomElevatedButton(
      width: 140,
      'Split Payment',
      isLoading: isSubmitting,
      onPressed: requestPayment,
      alignment: Alignment.center,
      prefixIcon: Icons.call_split_rounded,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: transactionForm.isEmpty ? [] : [
        
              /// Order Content
              CartDetails(
                boldTotal: true,
                showTopDivider: false,
                cart: order.relationships.cart!,
              ),

              if(cannotRequestPaymentDeclaimer != null) CustomMessageAlert(
                cannotRequestPaymentDeclaimer!,
                margin: const EdgeInsets.only(top: 16)
              ),

              if(cannotRequestPaymentDeclaimer == null) ...[
              
                /// Overview Instruction
                CustomMessageAlert(
                  showIcon: false,
                  padding: const EdgeInsets.all(16),
                  bgColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  'Pay hassle-free with your Credit/Debit Card - Choose from 3 options:\n\n1. Pay yourself\n2. Friends pay for you\n3. Split the bill with friends.'
                ),
                
                /// Spacer
                const Divider(height: 24,),

                if(percentageErrorText != null) ...[

                  /// Percentage error text
                  CustomBodyText(percentageErrorText, isError: true),

                  /// Spacer
                  const SizedBox(height: 16),

                ],

                /// Who is paying choices
                const CustomTitleSmallText('How are you paying'),

                /// Spacer
                const SizedBox(height: 16),

                /// Who is paying choices
                whoIsPayingChoices,

                /// Spacer
                const SizedBox(height: 16),

                /// How much are you paying
                howMuchAreYouPayingChoices,

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
              
            ]
          ),
        ),
      ),
    );
  }
}