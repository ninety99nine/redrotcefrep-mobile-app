import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../coupons_content.dart';

class CouponsPage extends StatefulWidget {

  static const routeName = 'CouponsPage';

  const CouponsPage({
    super.key,
  });

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ShoppableStore get store => storeProvider.store!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CouponsContent(
        store: store,
        showingFullPage: true
      ),
    );
  }
}