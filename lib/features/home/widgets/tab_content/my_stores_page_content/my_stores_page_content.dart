import 'package:bonako_demo/features/stores/widgets/show_associated_stores/associated_stores_modal_bottom_sheet/associated_stores_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/store_invite_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/mobile_phone_icon_button.dart';
import 'package:bonako_demo/features/stores/widgets/create_store/create_store_card.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:flutter/material.dart';

class MyStoresPageContent extends StatefulWidget {
  const MyStoresPageContent({super.key});

  @override
  State<MyStoresPageContent> createState() => _MyStoresPageContentState();
}

class _MyStoresPageContentState extends State<MyStoresPageContent> with SingleTickerProviderStateMixin /*, AutomaticKeepAliveClientMixin */ {

  /*
   *  Reason for using AutomaticKeepAliveClientMixin
   * 
   *  We want to preserve the state of this Widget when using the TabBarView()
   *  to swipe between the Profile, Following, My Stores, e.t.c. The natural
   *  Flutter behaviour when swipping between these tabs is to destroy the
   *  current tab content while switching to the new tab content. By using
   *  the AutomaticKeepAliveClientMixin, we can preserve the state so that
   *  the current state data is not destroyed. When switching back to this
   *  tab, the content will be exactly as it was before switching away.
   * 
   *  Reference: https://stackoverflow.com/questions/55850686/why-is-flutter-disposing-my-widget-state-object-in-a-tabbed-interface
   * 
   *  @override
   *  bool wantKeepAlive = true;
  */

  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    return Stack(
      children: [
                  
        /// Create Store Card
        CreateStoreCard(
          totalStores: totalStores,
          onCreatedStore: onCreatedStore
        ),
          
        /// Check List Icon Button
        Positioned(
          top: 20,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              /// Store Invitation Icon Button
              StoreInviteIconButton(
                size: 20,
                onTap: () {}
              ),

              /// Spacer
              const SizedBox(width: 16,),

              /// Associated Stores Icon Button
              const AssociatedStoresModalBottomSheet()

            ],
          ),
        ),

      ],
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
      contentBeforeSearchBar: contentBeforeSearchBar,
      userAssociation: UserAssociation.teamMemberJoined,
    );
  }
}