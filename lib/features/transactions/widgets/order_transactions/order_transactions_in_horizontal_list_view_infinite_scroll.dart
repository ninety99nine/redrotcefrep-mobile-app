import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_modal_bottom_sheet/order_transactions_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_page_view_infinite_scroll.dart';
import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class OrderTransactionsInHorizontalListViewInfiniteScroll extends StatefulWidget {

  final Order order;
  final ShoppableStore store;
  final String? transactionFilter;

  const OrderTransactionsInHorizontalListViewInfiniteScroll({
    Key? key,
    required this.order,
    required this.store,
    this.transactionFilter,
  }) : super(key: key);

  @override
  State<OrderTransactionsInHorizontalListViewInfiniteScroll> createState() => OrderTransactionsInHorizontalListViewInfiniteScrollState();

}

class OrderTransactionsInHorizontalListViewInfiniteScrollState extends State<OrderTransactionsInHorizontalListViewInfiniteScroll> {

  int totalTransactions = 0;

  /// This allows us to access the state of CustomHorizontalPageViewInfiniteScrollState widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomHorizontalPageViewInfiniteScrollState> _customHorizontalPageViewInfiniteScrollState = GlobalKey<CustomHorizontalPageViewInfiniteScrollState>();

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  String? get transactionFilter => widget.transactionFilter;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  /// Render each request item as an OrderTransactionItem
  Widget onRenderItem(transaction, int index, List transactions) => PayerAvatar(
    customHorizontalPageViewInfiniteScrollState: _customHorizontalPageViewInfiniteScrollState,
    isLastItem: index == (transactions.length - 1),
    transaction: (transaction as Transaction),
    order: order,
    index: index,
  );

  /// Render each request item as a Transaction
  Transaction onParseItem(transaction) => Transaction.fromJson(transaction);
  Future<dio.Response> requestOrderTransactions(int page, String searchWord) {
    
    /// Request the order transactions
    return orderProvider.setOrder(order).orderRepository.showTransactions(
      filter: transactionFilter,
      withRequestingUser: true,
      searchWord: searchWord,
      withPayingUser: true,
      page: page
    ).then((response) {

      if(response.statusCode == 200) {

        setState(() => totalTransactions = response.data['total']);

      }

      return response;

    });

  }

  Widget get contentBeforeFirstItem {
    return Row(
      children: [
        AddPayerAvatar(order: order),
        const SizedBox(width: 16)
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomHorizontalListViewInfiniteScroll(
      height: 90,
      debounceSearch: true,
      showSearchBar: false,
      showNoMoreContent: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      headerPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show transactions',
      onRequest: (page, searchWord) => requestOrderTransactions(page, searchWord),
      contentBeforeFirstItem: order.attributes.isPaid ? null : contentBeforeFirstItem,
    );
  }
}

class AddPayerAvatar extends StatelessWidget {

  final Order order;

  const AddPayerAvatar({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return OrderTransactionsModalBottomSheet(
      order: order,
      transactionContentView: TransactionContentView.requestPayment,
      trigger: (openBottomModalSheet) => Column(
        children: [

          /// Add Avatar
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey.shade400),
              borderRadius: const BorderRadius.all(Radius.circular(32))
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person_add_alt_1_outlined, color: Colors.grey.shade400),
              ),
            ),
          ),

        ],
      )
    );
  }
}

class PayerAvatar extends StatelessWidget {

  final int index;
  final Order order;
  final bool isLastItem;
  final Transaction transaction;
  final GlobalKey<CustomHorizontalPageViewInfiniteScrollState>? customHorizontalPageViewInfiniteScrollState;

  const PayerAvatar({
    super.key,
    required this.index,
    required this.order,
    required this.isLastItem,
    required this.transaction,
    this.customHorizontalPageViewInfiniteScrollState,
  });

  bool get isPaid => transaction.attributes.isPaid;
  User get payingUser => transaction.relationships.payingUser!;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isLastItem ? 0 : 16),
      child: GestureDetector(
        onTap: () {
          OrderServices().showTransactionDialog(transaction, order, context);
        },
        child: Column(
          children: [
      
            /// User Avatar
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: isPaid ? Colors.green.shade300 : Colors.orange.shade400),
                borderRadius: const BorderRadius.all(Radius.circular(32))
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: isPaid ? Colors.green.shade400 : Colors.orange.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
      
            /// Spacer
            const SizedBox(height: 4,),
      
            /// User Name
            CustomBodyText(payingUser.firstName),
      
            /// Spacer
            const SizedBox(height: 4,),
      
            /// Transaction Amount
            CustomBodyText(transaction.amount.amountWithCurrency, fontWeight: FontWeight.w300)
      
          ],
        ),
      ),
    );
  }
}