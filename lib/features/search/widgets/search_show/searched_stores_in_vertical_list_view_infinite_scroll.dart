
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../stores/widgets/store_cards/store_card/primary_section_content/logo.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../rating/widgets/rating_show_using_stars.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../repositories/search_repository.dart';
import '../../providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchedStoresInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final String searchWord;
  final Function(bool) onSearching;
  final Function(ShoppableStore) onSelectedStore;

  const SearchedStoresInVerticalListViewInfiniteScroll({
    super.key,
    required this.searchWord,
    required this.onSearching,
    required this.onSelectedStore,
  });

  @override
  State<SearchedStoresInVerticalListViewInfiniteScroll> createState() => _SearchedStoresInVerticalListViewInfiniteScrollState();
}

class _SearchedStoresInVerticalListViewInfiniteScrollState extends State<SearchedStoresInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  Function(bool) get onSearching => widget.onSearching;
  Function(ShoppableStore) get onSelectedStore => widget.onSelectedStore;
  SearchRepository get searchRepository => searchProvider.searchRepository;
  SearchProvider get searchProvider => Provider.of<SearchProvider>(context, listen: false);

  Widget onRenderItem(store, int index, List stores, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => StoreItem(
    store: (store as ShoppableStore),
    onSelectedStore: onSelectedStore
  );
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<http.Response> requestSearch(int page, String searchWord) {
    return searchRepository.searchStores(
      searchWord: searchWord,
      page: page
    );
  }

  @override
  Widget build(BuildContext context) {

    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      showSearchBar: false,
      showNoMoreContent: false,
      onSearching: onSearching,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      searchWord: widget.searchWord,
      catchErrorMessage: 'Can\'t show stores',
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestSearch(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class StoreItem extends StatefulWidget {
  
  final ShoppableStore store;
  final Function(ShoppableStore) onSelectedStore;

  const StoreItem({
    super.key, 
    required this.store,
    required this.onSelectedStore,
  });

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {

  ShoppableStore get store => widget.store;
  bool get hasRating => store.rating != null;
  Function(ShoppableStore) get onSelectedStore => widget.onSelectedStore;

  int get totalReviews => store.reviewsCount!;
  String get totalReviewsText => '$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}';

  int get totalOrders => store.ordersCount!;
  String get totalOrdersText => '$totalOrders ${totalOrders == 1 ? 'Order' : 'Orders'}';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(widget.store.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) { 
        if(direction == DismissDirection.startToEnd) {

          /// Select this store item
          onSelectedStore(store);

        }

        /// Do not dismiss this store item
        return Future.delayed(Duration.zero).then((value) => false);

      },
      child: ListTile(
        dense: true,

        onTap: () {

          /// Select this store item
          onSelectedStore(store);

        },

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
      
            //  Store Logo
            StoreLogo(store: store),

            /// Spacer
            const SizedBox(width: 8,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Store Name
                CustomTitleSmallText(store.name),

                /// Spacer
                const SizedBox(height: 4,),

                Row(
                  children: [

                    //  Rating
                    if(hasRating) RatingShowUsingStars(rating: store.rating!),

                    /// Spacer
                    const SizedBox(width: 8,),
          
                    //  Total Orders
                    CustomBodyText(totalOrdersText, lightShade: true,),

                    /// Spacer
                    const SizedBox(width: 8,),
          
                    //  Total Orders
                    CustomBodyText(totalReviewsText, lightShade: true,),

                  ],
                ),

              ],
            )

          ],
        ),
      
      ),
    );
  }
}