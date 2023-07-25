import 'package:bonako_demo/core/shared_models/money.dart';
import 'package:bonako_demo/core/shared_models/name_and_description.dart';
import 'package:bonako_demo/core/shared_models/status.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transaction_filters.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OrderTransactionsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final Order order;
  final String transactionFilter;
  final Function(Transaction) onSelectedTransaction;
  final GlobalKey<OrderTransactionFiltersState> orderTransactionFiltersState;

  const OrderTransactionsInVerticalListViewInfiniteScroll({
    super.key,
    required this.order,
    required this.onSelectedTransaction,
    required this.transactionFilter,
    required this.orderTransactionFiltersState,
  });

  @override
  State<OrderTransactionsInVerticalListViewInfiniteScroll> createState() => _OrderTransactionsInVerticalListViewInfiniteScrollState();
}

class _OrderTransactionsInVerticalListViewInfiniteScrollState extends State<OrderTransactionsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  Order get order => widget.order;
  String get transactionFilter => widget.transactionFilter;
  Function(Transaction) get onSelectedTransaction => widget.onSelectedTransaction;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  GlobalKey<OrderTransactionFiltersState> get orderTransactionFiltersState => widget.orderTransactionFiltersState;
  TransactionProvider get transactionProvider => Provider.of<TransactionProvider>(context, listen: false);

  /// Render each request item as an TransactionItem
  Widget onRenderItem(transaction, int index, List transactions, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => TransactionItem(
    onSelectedTransaction: onSelectedTransaction,
    transaction: (transaction as Transaction), 
    order: order,
    index: index
  );
  
  /// Render each request item as an Transaction
  Transaction onParseItem(transaction) => Transaction.fromJson(transaction);
  Future<http.Response> requestStoreTransactions(int page, String searchWord) {
    return orderProvider.setOrder(order).orderRepository.showTransactions(
      /// Filter by the transaction filter specified (transactionFilter)
      withRequestingUser: true,
      filter: transactionFilter,
      searchWord: searchWord,
      withPayingUser: true,
      page: page
    ).then((response) {

      /*
      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        /// If the response transaction count does not match the order transaction count
        if(transactionFilter == 'All' && order.transactionsCount != responseBody['total']) {

          order.transactionsCount = responseBody['total'];
          order.runNotifyListeners();

        }

      }
      */

      return response;

    });
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
    return const CustomMessageAlert('Tap on any transaction to pay or share the payment link with your friend, family or co-workers', margin: EdgeInsets.only(bottom: 16),);
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
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class TransactionItem extends StatelessWidget {
  
  final int index;
  final Order order;
  final Transaction transaction;
  final Function(Transaction) onSelectedTransaction;

  const TransactionItem({
    super.key,
    required this.index,
    required this.order,
    required this.transaction,
    required this.onSelectedTransaction,
  });

  Money get amount => transaction.amount;
  DateTime get createdAt => transaction.createdAt;
  String get number => transaction.attributes.number;
  NameAndDescription get status => transaction.paymentStatus;
  User get payingUser => transaction.relationships.payingUser!;
  

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      onTap: () {
        OrderServices().showTransactionDialog(transaction, order, context);
      }, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              //  Payer Name
              Expanded(
                child: CustomBodyText(
                  payingUser.attributes.name, 
                  fontWeight: FontWeight.bold,
                ),
              ),

              Column(
                children: [
            
                  //  Transaction Amount
                  CustomBodyText(transaction.amount.amountWithCurrency, fontWeight: FontWeight.bold,)
            
                ],
              ),

            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              //  Transaction Status
              TransactionStatus(transaction: transaction),

              //  Transaction Created Date & Time Ago
              CustomBodyText(timeago.format(transaction.createdAt), lightShade: true),

            ],
          ),
          
        ],
      )
    );
  }
}