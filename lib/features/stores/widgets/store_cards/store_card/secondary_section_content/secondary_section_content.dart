import 'package:bonako_demo/features/shopping_cart/widgets/shopping_cart_content.dart';

import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatelessWidget {

  final ShoppableStore store;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ShoppingCartContent(
      shoppingCartCurrentView: ShoppingCartCurrentView.storeCard
    );
  }
}