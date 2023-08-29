import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:get/get.dart';

import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../orders_content.dart';

class OrdersPage extends StatefulWidget {

  static const routeName = 'OrdersPage';

  const OrdersPage({
    super.key,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool canShowFloatingActionButton = true;
  ShoppableStore? store;

  @override
  void initState() {
    
    super.initState();

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "store" (if provided)
    store = arguments['store'] as ShoppableStore;

    /// Get the "canShowFloatingActionButton" (if provided)
    if(arguments.containsKey('canShowFloatingActionButton')) canShowFloatingActionButton = arguments['canShowFloatingActionButton'] as bool;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Content of the page
      body: OrdersContent(
        store: store,
        showingFullPage: true,
        canShowFloatingActionButton: canShowFloatingActionButton
      ),
    );
  }
}