import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../order_for_users_content.dart';

class OrderForUsersPage extends StatefulWidget {

  static const routeName = 'OrderForUsersPage';

  const OrderForUsersPage({super.key});

  @override
  State<OrderForUsersPage> createState() => _OrderForUsersPageState();
}

class _OrderForUsersPageState extends State<OrderForUsersPage> {

  ShoppableStore get store => storeProvider.store!;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrderForUsersContent(
        store: store,
        showingFullPage: true,
      ),
    );
  }
}