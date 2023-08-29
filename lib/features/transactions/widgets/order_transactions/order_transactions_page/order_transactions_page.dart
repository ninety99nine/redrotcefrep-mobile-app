import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_content.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderTransactionsPage extends StatefulWidget {

  static const routeName = 'OrderTransactionsPage';

  const OrderTransactionsPage({
    super.key,
  });

  @override
  State<OrderTransactionsPage> createState() => _OrderTransactionsPageState();
}

class _OrderTransactionsPageState extends State<OrderTransactionsPage> {

  TransactionProvider get transactionProvider => Provider.of<TransactionProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  Transaction get transaction => transactionProvider.transaction!;
  Order get order => orderProvider.order!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrderTransactionsContent(
        order: order,
        showingFullPage: true,
        transaction: transaction,
      ),
    );
  }
}