import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transaction_filters.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_proof_of_payment_photo.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/core/shared_models/name_and_description.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/money.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class OrderTransactionsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final Order order;
  final User? paidByUser;
  final String transactionFilter;
  final Function(Transaction) onSelectedTransaction;
  final Function(Transaction, String)? onSubmittedFile;
  final GlobalKey<OrderTransactionFiltersState> orderPayingUserTransactionFiltersState;

  const OrderTransactionsInVerticalListViewInfiniteScroll({
    super.key,
    this.paidByUser,
    required this.order,
    this.onSubmittedFile,
    required this.transactionFilter,
    required this.onSelectedTransaction,
    required this.orderPayingUserTransactionFiltersState,
  });

  @override
  State<OrderTransactionsInVerticalListViewInfiniteScroll> createState() => _OrderTransactionsInVerticalListViewInfiniteScrollState();
}

class _OrderTransactionsInVerticalListViewInfiniteScrollState extends State<OrderTransactionsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  Order get order => widget.order;
  User? get paidByUser => widget.paidByUser;
  bool get isPaid => order.attributes.isPaid;
  String get transactionFilter => widget.transactionFilter;
  Function(Transaction, String)? get onSubmittedFile => widget.onSubmittedFile;
  Function(Transaction) get onSelectedTransaction => widget.onSelectedTransaction;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  GlobalKey<OrderTransactionFiltersState> get orderPayingUserTransactionFiltersState => widget.orderPayingUserTransactionFiltersState;
  TransactionProvider get transactionProvider => Provider.of<TransactionProvider>(context, listen: false);

  /// Render each request item as an TransactionItem
  Widget onRenderItem(transaction, int index, List transactions, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => TransactionItem(
    onSelectedTransaction: onSelectedTransaction,
    transaction: (transaction as Transaction),
    onSubmittedFile: onSubmittedFile,
    order: order,
    index: index
  );
  
  /// Render each request item as an Transaction
  Transaction onParseItem(transaction) => Transaction.fromJson(transaction);
  Future<dio.Response> requestStoreTransactions(int page, String searchWord) {

    if(paidByUser == null) {

      return orderProvider.setOrder(order).orderRepository.showTransactions(
        /// Filter by the transaction filter specified (transactionFilter)
        filter: transactionFilter,
        withRequestingUser: true,
        withPaymentMethod: true,
        searchWord: searchWord,
        withPayingUser: true,
        page: page
      );

    }else{

      return orderProvider.setOrder(order).orderRepository.showTransactions(
        /// Filter by the transaction filter specified (transactionFilter)
        filter: transactionFilter,
        withRequestingUser: true,
        withPaymentMethod: true,
        paidByUser: paidByUser!,
        searchWord: searchWord,
        withPayingUser: false,
        page: page
      );

    }
  }

  @override
  void didUpdateWidget(covariant OrderTransactionsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the transaction filter changed
    if(transactionFilter != oldWidget.transactionFilter) {

      /// Start a new request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalTransactions) {
    return CustomMessageAlert(
      isPaid ? 'Tap transaction for more information'
             : 'Tap on any transaction to pay or share the payment link with your friend, family or co-workers',
      margin: const EdgeInsets.only(bottom: 16),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      listPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show transactions',
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestStoreTransactions(page, searchWord),
      headerPadding: EdgeInsets.only(top: isPaid ? 20 : 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class TransactionItem extends StatefulWidget {
  
  final int index;
  final Order order;
  final Transaction transaction;
  final Function(Transaction) onSelectedTransaction;
  final Function(Transaction, String)? onSubmittedFile;

  const TransactionItem({
    super.key,
    required this.index,
    required this.order,
    this.onSubmittedFile,
    required this.transaction,
    required this.onSelectedTransaction,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {

  late Transaction transaction;

  Order get order => widget.order;
  Money get amount => transaction.amount;
  DateTime get createdAt => transaction.createdAt;
  String get number => transaction.attributes.number;
  ShoppableStore get store => order.relationships.store!;
  NameAndDescription get status => transaction.paymentStatus;
  User get payedByUser => transaction.relationships.payedByUser!;
  PaymentMethod get paymentMethod => transaction.relationships.paymentMethod!;
  Function(Transaction, String)? get onSubmittedFile => widget.onSubmittedFile;

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;
  }

  void _onSubmittedFile(String photoUrl) {
    setState(() {
      transaction.proofOfPaymentPhoto = photoUrl;
      if(onSubmittedFile != null) onSubmittedFile!(transaction, photoUrl);
    });
  }

  void onUpdatedTransaction(Transaction updatedTransaction) {
    /// The updatedTransaction is simply the same transaction but with relationships loaded e.g
    /// payedByUser, verifiedByUser, requestedByUser, e.t.c. We are just updating this local state
    /// of the transaction incase we might want to do anything with those relationships once
    /// they have been loaded.
    setState(() => transaction = updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      onTap: () {
        OrderServices().showOrderTransactionDialog(
          order: order,
          context: context,
          transaction: transaction,
          onSubmittedFile: _onSubmittedFile,
          onUpdatedTransaction: onUpdatedTransaction
        );
      }, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [

          TransactionProofOfPaymentPhoto(
            store: store,
            transaction: transaction,
            onSubmittedFile: _onSubmittedFile,
          ),
      
          const SizedBox(width: 16,),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          
                    //  Payer Name
                    CustomBodyText(
                      payedByUser.attributes.name, 
                      fontWeight: FontWeight.bold,
                    ),

                    /// Spacer
                    const SizedBox(height: 4,),
                  
                    //  Payment Method
                    CustomBodyText(paymentMethod.name.toLowerCase(), lightShade: true),
                
                    //  Transaction Status
                    TransactionStatus(transaction: transaction),
          
                  ],
                ),
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  
                    //  Transaction Amount
                    CustomBodyText(transaction.amount.amountWithCurrency, fontWeight: FontWeight.bold,),

                    /// Spacer
                    const SizedBox(height: 4,),
                  
                    //  Transaction Number
                    CustomBodyText('#${transaction.attributes.number}', lightShade: true),
          
                    //  Transaction Created Date & Time Ago
                    CustomBodyText(timeago.format(transaction.createdAt), lightShade: true),
          
                  ],
                ),
                
              ],
            ),
          ),
        ],
      )
    );
  }
}