import 'dart:convert';

import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './product_filters.dart';

class ProductsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore store;
  final String productFilter;
  final Function(Product) onEditProduct;
  final GlobalKey<ProductFiltersState> productFiltersState;

  const ProductsInVerticalListViewInfiniteScroll({
    super.key,
    required this.store,
    required this.onEditProduct,
    required this.productFilter,
    required this.productFiltersState,
  });

  @override
  State<ProductsInVerticalListViewInfiniteScroll> createState() => _ProductsInVerticalListViewInfiniteScrollState();
}

class _ProductsInVerticalListViewInfiniteScrollState extends State<ProductsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  ShoppableStore get store => widget.store;
  String get productFilter => widget.productFilter;
  Function(Product) get onEditProduct => widget.onEditProduct;
  GlobalKey<ProductFiltersState> get productFiltersState => widget.productFiltersState;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ProductProvider get productProvider => Provider.of<ProductProvider>(context, listen: false);


  /// Render each request item as an ProductItem
  Widget onRenderItem(product, int index, List products, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => ProductItem(
    toggleVisibility: toggleVisibility,
    product: (product as Product), 
    onEditProduct: onEditProduct,
    index: index
  );
  
  /// Render each request item as an Product
  Product onParseItem(product) => Product.fromJson(product);
  Future<http.Response> requestStoreProducts(int page, String searchWord) {
    return storeProvider.setStore(store).storeRepository.showProducts(
      /// Filter by the product filter specified (productFilter)
      filter: productFilter,
      searchWord: searchWord,
      page: page
    );
  }

  void onReorder(int oldIndex, int newIndex) {

    CustomVerticalInfiniteScrollState? currentState = _customVerticalListViewInfiniteScrollState.currentState;

    if(currentState != null) {

      /**
       *  Fix on reorder issue:
       * 
       *  When we remove an item from the list, the indices of the remaining items in the list 
       *  are shifted down by one. When we insert the same item at the new index, the item is 
       *  inserted at the new index position, and the remaining items are shifted down by one.
       *  This causes the index of the item that was inserted to be off by one when dragging 
       *  downwards.
       * 
       *  To fix this, you can add a check to adjust the new index if the old index is 
       *  less than the new index, like this: 
       */
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final List<Product> originalData = List.from(currentState.data);
      final Product product = currentState.getItemAt(oldIndex);
      currentState.removeItemAt(oldIndex);
      currentState.insetItemAt(newIndex, product);

      storeProvider.setStore(store).storeRepository.updateProductArrangement(
        productIds: List<Product>.from(currentState.data).map((Product product) => product.id).toList()
      ).then((response) {

        /// If the response is 200
        if(response.statusCode == 200) {

          StoreServices.refreshProducts(store, storeProvider);

        }else{

            /// Revert the product arrangement
            currentState.setData(originalData);

        }

      });

    }

  }

  void toggleVisibility(int index, Product product) {

    /// Update the product visibility status
    product.visible.status = !product.visible.status;
    _customVerticalListViewInfiniteScrollState.currentState!.updateItemAt(index, product);

    /// Update the product visibility status on the server
    productProvider.setProduct(product).productRepository.updateProduct(
      visible: product.visible.status
    ).then((response) {

      /// If the response is 200
      if(response.statusCode == 200) {

        productFiltersState.currentState!.requestStoreProductFilters();
        StoreServices.refreshProducts(store, storeProvider);

      }else{
        
        /// Revert the product visibility status
        product.visible.status = !product.visible.status;
        _customVerticalListViewInfiniteScrollState.currentState!.updateItemAt(index, product);

      }

    });
    
  }

  @override
  void didUpdateWidget(covariant ProductsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the product filter changed
    if(productFilter != oldWidget.productFilter) {

      /// Start a new request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }

  Widget get contentBeforeSearchBar {
    return const CustomMessageAlert('Update your products during times when people are not shopping so that you don\'t disrupt their shopping experience.', margin: EdgeInsets.only(bottom: 16),);
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      canReorder: true,
      onReorder: onReorder,
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      listPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show products',
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestStoreProducts(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class ProductItem extends StatelessWidget {
  
  final int index;
  final Product product;
  final Function(Product) onEditProduct;
  final Function(int, Product) toggleVisibility;

  const ProductItem({
    super.key,
    required this.index,
    required this.product,
    required this.onEditProduct,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      onTap: () => toggleVisibility(index, product),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// Name
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// Name
                CustomTitleSmallText(product.name),

                if(product.showDescription.status) ...[

                  /// Spacer
                  const SizedBox(height: 4),

                  /// Description
                  CustomBodyText(product.description),

                ],

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    /// Spacer
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        
                        /// Unit Price
                        CustomBodyText(product.unitPrice.amountWithCurrency)
                      
                      ],
                    ),
                  ],
                )
                
              ],
            )
          ),
                    
          /// Spacer
          const SizedBox(width: 8),

          /// Checkbox
          SizedBox(
            width: 28,
            child: CustomCheckbox(
              text: '',
              value: product.visible.status,
              onChanged: (_) {
                toggleVisibility(index, product);
              }
            ),
          ), 
      
          /// Spacer
          const SizedBox(width: 8),
      
          /// Edit
          GestureDetector(
            onTap: () => onEditProduct(product), 
            child: const Icon(Icons.mode_edit_outline_outlined)
          ),
      
          /// Spacer
          const SizedBox(width: 8),
      
          /// Drag Handle
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle_rounded)
          )

        ],
      )
      
    );
  }
}