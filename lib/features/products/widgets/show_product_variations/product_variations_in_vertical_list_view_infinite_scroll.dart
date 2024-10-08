import 'package:perfect_order/features/products/widgets/shoppable_product_cards/components/total_variation_options.dart';
import 'package:perfect_order/features/products/widgets/show_products/products_modal_bottom_sheet/products_modal_bottom_sheet.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:perfect_order/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:perfect_order/features/products/providers/product_provider.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/tags/custom_tag.dart';
import 'package:perfect_order/features/products/models/product.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'product_variation_filters.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class ProductVariationsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final Product product;
  final ShoppableStore store;
  final String? productVariationFilter;
  final Function(Product)? onEditProduct;
  final ScrollController? scrollController;
  final GlobalKey<ProductVariationFiltersState>? productVariationFiltersState;

  const ProductVariationsInVerticalListViewInfiniteScroll({
    super.key,
    this.onEditProduct,
    required this.store,
    required this.product,
    this.scrollController,
    this.productVariationFilter,
    this.productVariationFiltersState,
  });

  @override
  State<ProductVariationsInVerticalListViewInfiniteScroll> createState() => ProductVariationsInVerticalListViewInfiniteScrollState();
}

class ProductVariationsInVerticalListViewInfiniteScrollState extends State<ProductVariationsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  bool? hasProductVariations;

  Product get product => widget.product;
  ShoppableStore get store => widget.store;
  Function(Product)? get onEditProduct => widget.onEditProduct;
  ScrollController? get scrollController => widget.scrollController;
  String? get productVariationFilter => widget.productVariationFilter;
  ProductProvider get productProvider => Provider.of<ProductProvider>(context, listen: false);
  GlobalKey<ProductVariationFiltersState>? get productVariationFiltersState => widget.productVariationFiltersState;
  
  @override
  void didUpdateWidget(covariant ProductVariationsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the product filter changed
    if(productVariationFilter != oldWidget.productVariationFilter) {

      /// Start a new request
      customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }

  /// Render each request item as an ProductVariationItem
  Widget onRenderItem(product, int index, List products, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => ProductVariationItem(
    customVerticalListViewInfiniteScrollState: customVerticalListViewInfiniteScrollState,
    product: (product as Product), 
    onEditProduct: onEditProduct,
    store: store,
    index: index
  );
  
  /// Render each request item as an Product
  Product onParseItem(product) => Product.fromJson(product);
  Future<dio.Response> requestProductVariations(int page, String searchWord) {
    return productProvider.setProduct(product).productRepository.showProductVariations(
      /// Filter by the product variation filter specified (productVariationFilter)
      filter: productVariationFilter,
      searchWord: searchWord,
      page: page
    ).then((response) {

      if(response.statusCode == 200) {

        setState(() => hasProductVariations = response.data['total'] > 0);

      }

      return response;

    });
  }


  void startRequest() {
    customVerticalListViewInfiniteScrollState.currentState?.startRequest();
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalProducts) {
    return totalProducts >= 1 ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        const CustomMessageAlert('Update your product variations during times when people are not shopping so that you don\'t disrupt their shopping experience.'),
                              
        /// Spacer
        const SizedBox(height: 16,),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Icon
            const Icon(Icons.call_split_rounded, size: 16,),

            /// Spacer
            const SizedBox(width: 4,),
            
            //  Total Variation Options
            TotalVariationOptions(product: product),

          ],
        ),

        /// Spacer
        const SizedBox(height: 8,),

      ],
    ) : const SizedBox();
  }
    
  Widget get noProductVariations {
      
    return Column(
      children: [

        //  Image
        SizedBox(
          height: 300,
          child: Image.asset('assets/images/products/choices.png'),
        ),

        /// Instruction
        const CustomBodyText(
          'You don\'t have any variations that customers can choose from',
          padding: EdgeInsets.symmetric(horizontal: 32),
          textAlign: TextAlign.center,
        ),

      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      scrollController: scrollController,
      listPadding: const EdgeInsets.all(0),
      noContentWidget: noProductVariations,
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: customVerticalListViewInfiniteScrollState,
      catchErrorMessage: 'Can\'t show product variations',
      onRequest: (page, searchWord) => requestProductVariations(page, searchWord),
      headerPadding: EdgeInsets.only(top: hasProductVariations == true ? 16 : 0, bottom: 0, left: 0, right: 0),
    );
  }
}

class ProductVariationItem extends StatelessWidget {
  
  final int index;
  final Product product;
  final ShoppableStore store;
  final Function(Product)? onEditProduct;
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const ProductVariationItem({
    super.key,
    this.onEditProduct,
    required this.index,
    required this.store,
    required this.product,
    required this.customVerticalListViewInfiniteScrollState
  });

  onUpdatedProduct(Product updatedProduct) {

    final int index = List<Product>.from(customVerticalListViewInfiniteScrollState.currentState?.data ?? []).indexWhere((Product currProduct) {
      return currProduct.id == updatedProduct.id;
    });

    if(index >= 0) {

      /// Update the product on the list of products
      customVerticalListViewInfiniteScrollState.currentState?.updateItemAt(index, updatedProduct);

    }

  }

  @override
  Widget build(BuildContext context) {
    return ProductsModalBottomSheet(
      onUpdatedProduct: onUpdatedProduct,
      product: product,       
      store: store,       
      trigger: (openBottomModalSheet) => ListTile(
        dense: false,
        onTap: () {
          openBottomModalSheet();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
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
    
                  /// Spacer
                  const SizedBox(height: 8,),
    
                  /// Value Tags      
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...(product.relationships.variables ?? []).map((variable) {
                        
                        /// Value Tag
                        return CustomTag(variable.value, textMaxLength: 20, showCancelIcon: false);
    
                      }).toList(),
                    ],
                  ),
                  
                ],
              )
            ),
                      
            /// Spacer
            const SizedBox(width: 8),
        
            /// Edit
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
    
                /// Unit Price
                CustomBodyText(product.unitPrice.amountWithCurrency, margin: const EdgeInsets.only(left: 8)),
                      
                /// Spacer
                const SizedBox(width: 16),
    
                /// Edit Icon
                GestureDetector(
                  onTap: () {

                    openBottomModalSheet();
                    if(onEditProduct != null) onEditProduct!(product);
    
                  }, 
                  child: const Icon(Icons.mode_edit_outline_outlined)
                ),
    
              ],
            ),
    
          ],
        )
        
      ),
    );
  }
}