import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_modal_bottom_sheet/order_transactions_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_proof_of_payment_photo.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderPayingUsers extends StatefulWidget {

  final Order order;
  final ShoppableStore store;
  final String? payedByUserFilter;
  final Function(Transaction)? onDeletedTransaction;

  const OrderPayingUsers({
    Key? key,
    required this.order,
    required this.store,
    this.payedByUserFilter,
    this.onDeletedTransaction
  }) : super(key: key);

  @override
  State<OrderPayingUsers> createState() => OrderPayingUsersState();

}

class OrderPayingUsersState extends State<OrderPayingUsers> {

  int totalPayingUsers = 0;
  List<User> payedByUsers = [];

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  String? get payedByUserFilter => widget.payedByUserFilter;
  Function(Transaction)? get onDeletedTransaction => widget.onDeletedTransaction;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    requestOrderPayingUsers();
  }

  requestOrderPayingUsers() {
    
    /// Request the order paying users
    return orderProvider.setOrder(order).orderRepository.showPayingUsers(
      withPaidTransactionsCount: true,
      withLatestTransaction: true,
      withTransactionsCount: true,
      filter: payedByUserFilter,
    ).then((response) {

      if(response.statusCode == 200) {

        setState(() {
          
          totalPayingUsers = response.data['total'];

          payedByUsers = (response.data['data'] as List).map((payedByUser) => User.fromJson(payedByUser)).toList();

        });

      }

      return response;

    });

  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        ...payedByUsers.map((payedByUser) {

          return PayingUserCard(store: store, order: order, payedByUser: payedByUser, onDeletedTransaction: onDeletedTransaction);

        })

      ],
    );
  }
}

class PayingUserCard extends StatefulWidget {

  final Order order;
  final User payedByUser;
  final ShoppableStore store;
  final Function(Transaction)? onDeletedTransaction;

  const PayingUserCard({
    super.key,
    required this.store,
    required this.order,
    this.onDeletedTransaction,
    required this.payedByUser,
  });

  @override
  State<PayingUserCard> createState() => _PayingUserCardState();
}

class _PayingUserCardState extends State<PayingUserCard> {
  
  late Transaction latestTransactionAsPayer;

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  User get payedByUser => widget.payedByUser;
  Function(Transaction)? get onDeletedTransaction => widget.onDeletedTransaction;

  @override
  void initState() {
    super.initState();
    latestTransactionAsPayer = payedByUser.relationships.latestTransactionAsPayer!;
  }

  void onSubmittedFile(Transaction transaction, String photoUrl) {
    setState(() {
      /// Since the onSubmittedFile can be called by the OrderTransactionsModalBottomSheet() widget
      /// or the OrderServices().showOrderTransactionDialog() service, we need to check if the
      /// transaction that was modified matches the current latestTransactionAsPayer, 
      /// particularly in the case that the transaction was modified by the 
      /// OrderTransactionsModalBottomSheet(). This is because the widget
      /// shows multiple transactions, therefore we need to make sure
      /// that we update the proofOfPaymentPhoto of the correct
      /// latestTransactionAsPayer.
      if(latestTransactionAsPayer.id == transaction.id) {
        latestTransactionAsPayer.proofOfPaymentPhoto = photoUrl;
      } 
    });
  }

  void onUpdatedTransaction(Transaction updatedTransaction) {
    /// The updatedTransaction is simply the same transaction but with relationships loaded e.g
    /// payedByUser, verifiedByUser, requestedByUser, e.t.c. We are just updating this local state
    /// of the transaction incase we might want to do anything with those relationships once
    /// they have been loaded.
    setState(() => latestTransactionAsPayer = updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return OrderTransactionsModalBottomSheet(
      order: order,
      paidByUser: payedByUser,
      onSubmittedFile: onSubmittedFile,
      transaction: latestTransactionAsPayer,
      trigger: (openBottomModalSheet) => GestureDetector(
        onTap: () {
          
          /// If we have one transaction
          if(payedByUser.transactionsAsPayerCount == 1) {
            
            OrderServices().showOrderTransactionDialog(
              order: order,
              context: context,
              transaction: latestTransactionAsPayer,
              onUpdatedTransaction: onUpdatedTransaction,
              onDeletedTransaction: onDeletedTransaction,
              onSubmittedFile: (photoUrl) => onSubmittedFile(latestTransactionAsPayer, photoUrl)
            );
    
          /// If we have more than one transaction
          }else if(payedByUser.transactionsAsPayerCount! > 1) {

            openBottomModalSheet();
    
          }
    
        },
        child: Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              width: 2,
              color: Colors.grey.shade300,
            ),
          ),
          child: Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
      
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
      
                    CustomBodyText(payedByUser.attributes.name),
      
                    const SizedBox(height: 4,),
      
                    TransactionStatus(transaction: latestTransactionAsPayer),
      
                  ],
                ),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
      
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
      
                        CustomBodyText(latestTransactionAsPayer.amount.amountWithCurrency, fontWeight: FontWeight.bold,),
      
                        const SizedBox(height: 4,),
      
                        CustomBodyText('${payedByUser.paidTransactionsAsPayerCount} ${payedByUser.paidTransactionsAsPayerCount == 1 ? 'payment' : 'payments'}', lightShade: true,),
                        
                      ],
                    ),

                    if(latestTransactionAsPayer.attributes.isVerifiedByUser) ...[
      
                      const SizedBox(width: 16,),

                      TransactionProofOfPaymentPhoto(
                        radius: 20,
                        store: store,
                        transaction: latestTransactionAsPayer,
                        onSubmittedFile: (photoUrl) => onSubmittedFile(latestTransactionAsPayer, photoUrl)
                      ),

                    ]
      
                  ],
                )
      
              ],
            ),
          )
        ),
      ),
    );
  }
}