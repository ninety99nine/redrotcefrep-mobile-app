import 'package:bonako_demo/features/products/models/product.dart';
import 'package:get/get.dart';

import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../products_content.dart';

class ProductsPage extends StatefulWidget {

  static const routeName = 'ProductsPage';

  const ProductsPage({
    super.key,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  @override
  Widget build(BuildContext context) {

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "product" (if provided)
    Product? product = arguments['product'] as Product?;

    /// Set the "store" (if provided)
    ShoppableStore store = arguments['store'] as ShoppableStore;

    /// Set the "onUpdatedProduct" (if provided)
    Function(Product)? onUpdatedProduct = arguments['onUpdatedProduct'] as Function(Product)?;

    return Scaffold(
      body: ProductsContent(
        store: store,
        product: product,
        showingFullPage: true,
        onUpdatedProduct: onUpdatedProduct,
      ),
    );
  }
}