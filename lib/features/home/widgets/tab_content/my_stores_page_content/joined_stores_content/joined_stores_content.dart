import 'package:bonako_demo/features/stores/widgets/create_store/create_store_card.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../../../stores/widgets/store_cards/store_cards.dart';
import 'package:flutter/material.dart';

class JoinedStoresContent extends StatefulWidget {
  const JoinedStoresContent({super.key});

  @override
  State<JoinedStoresContent> createState() => JoinedStoresContentState();
}

class JoinedStoresContentState extends State<JoinedStoresContent> {

  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    /// Create Store Card
    return CreateStoreCard(
      totalStores: totalStores,
      onCreatedStore: onCreatedStore
    );
  }

  void onCreatedStore(ShoppableStore createdStore) {

    /// Set the current store properties on the created store so that we don't have to load
    /// this information from the server side. This helps us improve performance by setting
    /// the information that we already know so that we don't have to request from the
    /// server side.
    createdStore.activeSubscriptionsCount = 0;
    createdStore.teamMembersCount = 0;
    createdStore.followersCount = 0;
    createdStore.couponsCount = 0;
    createdStore.reviewsCount = 0;
    createdStore.ordersCount = 0;

    setState(() {
      /// Add the created store
      storeCardsState.currentState!.customVerticalListViewInfiniteScrollState.currentState!.data.insert(0, createdStore);
      storeCardsState.currentState!.customVerticalListViewInfiniteScrollState.currentState!.forceRenderListView++;
    });

  }

  void refreshStores() {
    if(storeCardsState.currentState != null) {
      storeCardsState.currentState!.refreshStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreCards(
      key: storeCardsState,
      userAssociation: UserAssociation.teamMember,
      contentBeforeSearchBar: contentBeforeSearchBar,
    );
  }
}
