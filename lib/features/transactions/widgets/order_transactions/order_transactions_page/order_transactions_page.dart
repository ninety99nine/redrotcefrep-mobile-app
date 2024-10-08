import 'package:perfect_order/features/transactions/widgets/order_transactions/order_transactions_content.dart';
import 'package:perfect_order/features/transactions/models/transaction.dart';
import 'package:perfect_order/features/reviews/enums/review_enums.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import '../../../../stores/providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTransactionsPage extends StatefulWidget {

  static const routeName = 'OrderTransactionsPage';

  const OrderTransactionsPage({
    super.key,
  });

  @override
  State<OrderTransactionsPage> createState() => _OrderTransactionsPageState();
}

class _OrderTransactionsPageState extends State<OrderTransactionsPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  late UserReviewAssociation userReviewAssociation;
  bool canShowFloatingActionButton = true;
  Transaction? transaction;
  late User paidByUser;
  late Order order;

  @override
  void initState() {
    
    super.initState();

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "order" (if provided)
    order = arguments['order'] as Order;

    /// Set the "paidByUser" (if provided)
    paidByUser = arguments['paidByUser'] as User;

    /// Set the "transaction" (if provided)
    transaction = arguments['transaction'] as Transaction;

    /// Get the "canShowFloatingActionButton" (if provided)
    if(arguments.containsKey('canShowFloatingActionButton')) canShowFloatingActionButton = arguments['canShowFloatingActionButton'] as bool;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Content of the page
      body: OrderTransactionsContent(
        order: order,
        showingFullPage: true,
        paidByUser: paidByUser,
        transaction: transaction,
        //  canShowFloatingActionButton: canShowFloatingActionButton
      ),
    );
  }
}