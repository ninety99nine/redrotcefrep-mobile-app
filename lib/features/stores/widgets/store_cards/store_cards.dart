import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../enums/store_enums.dart';
import 'package:dio/dio.dart' as dio;
import 'store_card/store_card.dart';

class StoreCards extends StatefulWidget {

  final String? storesUrl;
  final FriendGroup? friendGroup;
  final Function(Order)? onCreatedOrder;
  final UserAssociation? userAssociation;
  final Widget Function(bool, int)? contentBeforeSearchBar;

  const StoreCards({
    Key? key,
    this.storesUrl,
    this.friendGroup,
    this.onCreatedOrder,
    this.userAssociation,
    required this.contentBeforeSearchBar,
  }) : super(key: key);

  @override
  State<StoreCards> createState() => StoreCardsState();
}

class StoreCardsState extends State<StoreCards> {

  String? get storesUrl => widget.storesUrl;
  bool get hasFriendGroup => friendGroup != null;
  FriendGroup? get friendGroup => widget.friendGroup;
  Function(Order)? get onCreatedOrder => widget.onCreatedOrder;
  UserAssociation? get userAssociation => widget.userAssociation;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Widget Function(bool, int)? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  @override
  void initState() {
    super.initState();

    /// Set the refresh method on the store provider so that we can easily refresh the
    /// stores from anyway in the application. This way we don't have to keep passing
    /// the refreshStores() method on multiple nested child widgets.
    storeProvider.refreshStores = refreshStores;

    /// Set the update store method on the store provider so that we can easily update any
    /// store from anyway in the application. This way we don't have to keep passing
    /// the refreshStores() method on multiple nested child widgets.
    storeProvider.updateStore = updateStore;

  }

  @override
  void didUpdateWidget(covariant StoreCards oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the friend group id has changed.
    /// This happends if we are switching the friend group
    if(friendGroup?.id != oldWidget.friendGroup?.id) {

      /// Start a new request (so that we can filter stores by the specified friend group id)
      refreshStores();

    }

  }

  Widget onRenderItem(store, int index, List stores, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {

    if(hasFriendGroup) {

      /// Indicate that we want to place an order for Me And Friends 
      (store as ShoppableStore).orderFor = 'Me And Friends';

      /// Set the friend group on the list of store friend groups so that we can place an order there
      store.friendGroups.add(friendGroup!);

    }

    /// Check if the onCreatedOrder method is provided
    if(onCreatedOrder != null) {

      final bool onCreatedOrderCallbackDoesNotExist = (store as ShoppableStore).onCreatedOrderCallbacks.contains(onCreatedOrder!) == false;

      if(onCreatedOrderCallbackDoesNotExist) {

        /**
         *  Set the onCreatedOrder method on this store.
         *  Whenever an order is created, we can then call this method to pass the created order
         *  so that the parent widget can be notified of the created order.
         */
        store.onCreatedOrderCallbacks.add(onCreatedOrder!);

      }

    }

    return StoreCard(
      store: store
    );

  }

  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<dio.Response> requestShowStores(int page, String searchWord) {

    if(storesUrl == null) {

      return storeProvider.storeRepository.showUserStores(
        userAssociation: userAssociation,
        withCountTeamMembers: true,
        withVisibleProducts: true,
        withVisitShortcode: true,
        friendGroup: friendGroup,
        withCountFollowers: true,
        user: authProvider.user!,
        withCountProducts: true,
        withCountReviews: true,
        searchWord: searchWord,
        withCountCoupons: true,
        withCountOrders: true,
        withRating: true,
        page: page
      );

    }else{

      return storeProvider.storeRepository.showStores(
        withCountTeamMembers: true,
        withVisibleProducts: true,
        withVisitShortcode: true,
        withCountFollowers: true,
        withCountProducts: true,
        withCountReviews: true,
        searchWord: searchWord,
        withCountCoupons: true,
        withCountOrders: true,
        withRating: true,
        url: storesUrl,
        page: page
      );

    }
  }

  void refreshStores() {
    if(customVerticalListViewInfiniteScrollState.currentState != null) {
      customVerticalListViewInfiniteScrollState.currentState!.startRequest();
    }
  }

  void updateStore(ShoppableStore updatedStore) {

    final List stores = customVerticalListViewInfiniteScrollState.currentState!.data;

    for (var i = 0; i < stores.length; i++) {

      if(stores[i].id == updatedStore.id) {

        final currentStore = customVerticalListViewInfiniteScrollState.currentState!.data[i];

        /// Set the current store properties on the updated store so that we don't have to load
        /// this information from the server side. This helps us improve performance by pulling
        /// the information that we already have and that we don't have to request from the
        /// server side.
        updatedStore.activeSubscriptionsCount = currentStore.activeSubscriptionsCount;
        updatedStore.teamMembersCount = currentStore.teamMembersCount;
        updatedStore.followersCount = currentStore.followersCount;
        updatedStore.relationships = currentStore.relationships;
        updatedStore.couponsCount = currentStore.couponsCount;
        updatedStore.reviewsCount = currentStore.reviewsCount;
        updatedStore.ordersCount = currentStore.ordersCount;
        updatedStore.attributes = currentStore.attributes;

        setState(() {
          /// Update the matching store
          customVerticalListViewInfiniteScrollState.currentState!.data[i] = updatedStore;
          customVerticalListViewInfiniteScrollState.currentState!.forceRenderListView++;
        });

      }
      
    }

  }

  Widget get storeCards {
    return CustomVerticalListViewInfiniteScroll(
      showSeparater: false,
      debounceSearch: true,
      showNoContent: false,
      showNoMoreContent: false,
      onParseItem: onParseItem,
      onRenderItem: onRenderItem,
      headerPadding: EdgeInsets.zero,
      catchErrorMessage: 'Can\'t show stores',
      key: customVerticalListViewInfiniteScrollState,
      contentBeforeSearchBar: contentBeforeSearchBar,
      onRequest: (page, searchWord) => requestShowStores(page, searchWord),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        
        /// Store cards
        Expanded(
          child: storeCards
        ),

      ],
    );
  }
}