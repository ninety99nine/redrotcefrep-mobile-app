import 'package:bonako_demo/features/transactions/widgets/transaction_proof_of_payment_photo.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderTransactionContent extends StatefulWidget {
  
  final Order order;
  final Transaction transaction;
  final Function(bool)? onDeleting;
  final Function(String)? onSubmittedFile;
  final Function(Transaction)? onDeletedTransaction;
  final Function(Transaction)? onUpdatedTransaction;

  const OrderTransactionContent({
    Key? key,
    this.onDeleting,
    required this.order,
    this.onSubmittedFile,
    this.onDeletedTransaction,
    this.onUpdatedTransaction,
    required this.transaction,
  }) : super(key: key);

  @override
  State<OrderTransactionContent> createState() => OrderTransactionContentState();
}

class OrderTransactionContentState extends State<OrderTransactionContent> {
  
  Map serverErrors = {};
  bool isLoading = false;
  bool isDeleting= false;
  Transaction? transaction;

  Order get order => widget.order;
  bool get hasPaymentMethod => paymentMethod != null;
  bool? get isPaid => transaction?.attributes.isPaid;
  Function(bool)? get onDeleting => widget.onDeleting;
  bool get hasVerifyingUser => verifiedByUser != null;
  bool get hasRequestingUser => requestedByUser != null;
  ShoppableStore get store => order.relationships.store!;
  User? get paidByUser => transaction?.relationships.paidByUser;
  bool get isPayingUser => paidByUser?.id == requestedByUser?.id;
  Function(String)? get onSubmittedFile => widget.onSubmittedFile;
  User? get verifiedByUser => transaction?.relationships.verifiedByUser;
  bool get hasDpoPaymentUrlExpiresAt => dpoPaymentUrlExpiresAt != null;
  User? get requestedByUser => transaction?.relationships.requestedByUser;
  bool? get isPendingPayment => transaction?.attributes.isPendingPayment;
  bool get hasProofOfPaymentPhoto => transaction?.proofOfPaymentPhoto != null;
  DateTime? get dpoPaymentUrlExpiresAt => transaction?.dpoPaymentUrlExpiresAt;
  PaymentMethod? get paymentMethod => transaction?.relationships.paymentMethod;
  Function(Transaction)? get onUpdatedTransaction => widget.onUpdatedTransaction;
  Function(Transaction)? get onDeletedTransaction => widget.onDeletedTransaction;
  TransactionProvider get transactionProvider => Provider.of<TransactionProvider>(context, listen: false);

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  
  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);

  @override
  void initState() {
    super.initState();
    _requestShowTransaction();
  }

  void _requestShowTransaction() async {

    if(isLoading) return; 

    _startLoader();

    transactionProvider.setTransaction(widget.transaction).transactionRepository.showTransaction(
      withPayingUser: true,
      withVerifyingUser: true,
      withPaymentMethod: true,
      withRequestingUser: true,
    ).then((response) {

      if(response.statusCode == 200) {

        setState(() {
          transaction = Transaction.fromJson(response.data);
          if(onUpdatedTransaction != null) onUpdatedTransaction!(transaction!);
        });

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  void _requestDeleteTransaction() async {

    if(isDeleting) return;

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _startDeleteLoader();

      /// Notify parent that we are starting the deleting process
      if(onDeleting != null) onDeleting!(true);

      transactionProvider.setTransaction(transaction!).transactionRepository.deleteTransaction().then((response) async {

        if(response.statusCode == 200) {

          /// Notify parent that the transaction has been deleted
          if(onDeletedTransaction != null) onDeletedTransaction!(transaction!);

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to delete transaction');

      }).whenComplete(() {

        _stopDeleteLoader();

        /// Notify parent that we are ending the deleting process
        if(onDeleting != null) onDeleting!(false);

      });

    }

  }

  /// Confirm delete transaction
  Future<bool?> confirmDelete() {

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete this transaction?',
      context: context
    );

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: isLoading 
          ? const CustomCircularProgressIndicator(margin: EdgeInsets.symmetric(vertical: 100),)
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Customer Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Paid By
                  Row(
                    children: [
                      const CustomBodyText('Paid By:', margin: EdgeInsets.only(right: 4),),
                      CustomBodyText(paidByUser!.attributes.name, fontWeight: FontWeight.bold,)
                    ],
                  ),
                    
                  /// Spacer
                  const SizedBox(height: 4,),

                  /// Verified By
                  if(hasVerifyingUser) ...[
                    
                    Row(
                      children: [
                        const CustomBodyText('Verified By:', margin: EdgeInsets.only(right: 4),),
                        CustomBodyText(verifiedByUser!.attributes.name, fontWeight: FontWeight.bold,)
                      ],
                    ),
                    
                    /// Spacer
                    const SizedBox(height: 16,)

                  ],
                  
                  /// Requested By
                  if(hasRequestingUser) ...[

                    Row(
                      children: [
                        const CustomBodyText('Requested By:', margin: EdgeInsets.only(right: 4),),
                        CustomBodyText(requestedByUser!.attributes.name, fontWeight: FontWeight.bold,)
                      ],
                    ),
                    
                    /// Spacer
                    const SizedBox(height: 16,)

                  ],

                  /// Date Paid
                  if(isPaid!) ...[

                    Row(
                      children: [
                        const CustomBodyText('Date Paid:', margin: EdgeInsets.only(right: 4),),
                        CustomBodyText(DateFormat('dd MMM yyyy HH:mm').format(transaction!.updatedAt), fontWeight: FontWeight.bold)
                      ],
                    ),
                    
                    /// Spacer
                    const SizedBox(height: 4,)

                  ],

                  /// Payment Method
                  if(hasPaymentMethod) ...[
                    
                    Row(
                      children: [
                        const CustomBodyText('Payment Method:', margin: EdgeInsets.only(right: 4),),
                        CustomBodyText(paymentMethod!.name, fontWeight: FontWeight.bold)
                      ],
                    ),
                    
                    /// Spacer
                    const SizedBox(height: 4,)

                  ],

                  /// Status
                  Row(
                    children: [

                      const CustomBodyText('Status:', margin: EdgeInsets.only(right: 8),),
                      TransactionStatus(transaction: transaction!)
                    
                    ],
                  ),

                  /// Spacer
                  const SizedBox(height: 16,),

                  /// Amount
                  CustomTitleLargeText(transaction!.amount.amountWithCurrency),

                  /// Divider
                  const Divider(),
                    
                  /// Spacer
                  const SizedBox(height: 4,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      if(isPaid! || isPendingPayment!) ...[

                        /// Checkmark Icon
                        if(isPaid!) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 40,),

                        /// Time Icon
                        if(isPendingPayment!) const Icon(Icons.access_time_filled_rounded, color: Colors.orange, size: 40,),
                      
                        /// Spacer
                        const SizedBox(width: 8,),

                      ],

                      /// Description
                      Expanded(child: CustomBodyText(transaction!.description)),
                      
                    ],
                  ),

                ],
              ),

              /// Collection Code Expiry Countdown
              if(hasDpoPaymentUrlExpiresAt) ...[

                /// Spacer
                const SizedBox(height: 16,),

                /// Countdown Timer
                CountdownTimer(
                  endTime: dpoPaymentUrlExpiresAt!.millisecondsSinceEpoch,
                  onEnd: () {

                  },
                  widgetBuilder: (context, time) {

                    final String minutes = (time == null || time.min == null) ? '00' : '${time.min! < 10 ? '0' : ''}${time.min}';
                    final String seconds = (time == null || time.sec == null) ? '00' : '${time.sec! < 10 ? '0' : ''}${time.sec}';

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        const CustomBodyText('Expires in', margin: EdgeInsets.symmetric(horizontal: 8)),
                        CustomTitleLargeText('$minutes:$seconds'),

                      ],
                    );

                  },
                ),

              ],

              if(transaction!.attributes.isVerifiedByUser) ...[

                /// Divider
                const Divider(),

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
                  transaction: transaction,
                  onSubmittedFile: onSubmittedFile,
                  changePhotoType: ChangePhotoType.editIconONextToImage,
                  photoShape: PhotoShape.rectangle,
                ),

                /// Spacer
                const SizedBox(height: 16,),

                /// Delete Transaction
                Container(
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
                
                      /// Delete Transaction Instructions
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            height: 1.4
                          ),
                          text: 'Permanently delete ',
                          children: [
                            TextSpan(text: 'transaction #${transaction!.attributes.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: '. Once this transaction is deleted you will not be able to recover it.'),
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
                        onPressed: _requestDeleteTransaction,
                      ),

                    ],
                  ),
                ),

              ],

              if(isPendingPayment!) ...[

                /// Divider
                const Divider(),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    if(isPayingUser) ...[

                      /// Pay For Me
                      CustomElevatedButton('Pay For Me', 
                        color: Colors.grey,
                        suffixIcon: Icons.share_rounded,
                        onPressed: () {
                          Get.back(closeOverlays: true);
                          OrderServices().sharePaymentLink(order, transaction!);
                        },
                      ),

                      /// Spacer
                      const SizedBox(width: 8,),

                      /// Pay Now
                      CustomElevatedButton(
                        'Pay Now',
                        onPressed: () {
                          Get.back(closeOverlays: true);
                          OrderServices().launchPaymentLink(transaction!, context);
                        }
                      ),

                    ],

                    if(!isPayingUser) ...[

                      /// Pay Yourself
                      CustomElevatedButton(
                        'Pay Yourself', 
                        color: Colors.grey,
                        onPressed: () {
                          Get.back(closeOverlays: true);
                          OrderServices().launchPaymentLink(transaction!, context);
                        },
                      ),

                      /// Spacer
                      const SizedBox(width: 8,),

                      /// Share
                      CustomElevatedButton('Share', 
                        suffixIcon: Icons.share_rounded,
                        onPressed: () {
                          Get.back(closeOverlays: true);
                          OrderServices().sharePaymentLink(order, transaction!);
                        }
                      )
                    ],

                  ],
                )

              ],

              /// Spacer
              const SizedBox(height: 100),

            ],
          )
      )
    );
  }
}