import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/orders/models/order.dart';
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
  final bool showFirstRequestLoader;
  final Function(Order)? onCreatedOrder;
  final UserAssociation? userAssociation;
  final Function(dio.Response)? onResponse;
  final ScrollController? scrollController;
  final Widget Function(bool, int)? contentBeforeSearchBar;

  const StoreCards({
    Key? key,
    this.storesUrl,
    this.onResponse,
    this.friendGroup,
    this.onCreatedOrder,
    this.userAssociation,
    this.scrollController,
    this.contentBeforeSearchBar,
    this.showFirstRequestLoader = true,
  }) : super(key: key);

  @override
  State<StoreCards> createState() => StoreCardsState();
}

class StoreCardsState extends State<StoreCards> {

  late StoreProvider storeProvider;

  String? get storesUrl => widget.storesUrl;
  bool get hasFriendGroup => friendGroup != null;
  FriendGroup? get friendGroup => widget.friendGroup;
  Function(dio.Response)? get onResponse => widget.onResponse;
  Function(Order)? get onCreatedOrder => widget.onCreatedOrder;
  UserAssociation? get userAssociation => widget.userAssociation;
  bool get showFirstRequestLoader => widget.showFirstRequestLoader;
  ScrollController? get scrollController => widget.scrollController;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  Widget Function(bool, int)? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  @override
  void initState() {
    super.initState();

    /// We need to register the storeProvider from here so that we can unset the refreshStores
    /// and updateStore() methods when disposing this widget otherwise we would get the 
    /// following error:
    /// 
    /// ════════ Exception caught by widgets library ═════════════════════════════════════════════════
    /// The following assertion was thrown while finalizing the widget tree:
    /// Looking up a deactivated widget's ancestor is unsafe.
    /// 
    /// At this point the state of the widget's element tree is no longer stable.
    /// To safely refer to a widget's ancestor in its dispose() method, save a reference to the ancestor
    /// by calling dependOnInheritedWidgetOfExactType() in the widget's didChangeDependencies() method.
    /// 
    /// ═══════════════════════════════════════════════════════════════════════════════════════════════
    /// 
    /// We can avoid this issue by setting the storeProvider from within the initState()
    storeProvider = Provider.of<StoreProvider>(context, listen: false);

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
  void dispose() {
    super.dispose();

    storeProvider.refreshStores = null;
    storeProvider.updateStore = null;
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

      print('stage #1');

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
      ).then((response) {

        /// Notify parent widget on response
        if(onResponse != null) onResponse!(response);

        return response;

      });

    }else{

      print('stage #2');

      return storeProvider.storeRepository.showStores(
        userAssociation: userAssociation,
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
      ).then((response) {

        /// Notify parent widget on response
        if(onResponse != null) onResponse!(response);

        return response;

      });

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
      scrollController: scrollController,
      catchErrorMessage: 'Can\'t show stores',
      key: customVerticalListViewInfiniteScrollState,
      contentBeforeSearchBar: contentBeforeSearchBar,
      showFirstRequestLoader: showFirstRequestLoader,
      onRequest: (page, searchWord) => requestShowStores(page, searchWord),
    );
  }

  @override
  Widget build(BuildContext context) {
    return storeCards;
  }
}