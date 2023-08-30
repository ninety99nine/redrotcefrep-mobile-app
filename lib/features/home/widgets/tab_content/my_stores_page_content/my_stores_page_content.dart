import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/stores/widgets/show_associated_stores/associated_stores_modal_bottom_sheet/associated_stores_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/store_invite_icon_button.dart';
import 'package:bonako_demo/features/stores/widgets/create_store/create_store_card.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool? hasStores;
  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();
  
  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated hasStores state
    final bool updatedHasStores = Provider.of<AuthProvider>(context, listen: false).hasStores;

    /// If the local hasStores state does not match the updatedHasStores state
    if(hasStores != updatedHasStores) {

      /// Update the local hasStores
      setState(() => hasStores = updatedHasStores);

    }
    
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    return Stack(
      children: [
                  
        /// Create Store Card
        Container(
          margin: EdgeInsets.only(top: hasStores == true ? 0 : 32),
          child: CreateStoreCard(
            totalStores: totalStores,
            onCreatedStore: onCreatedStore
          ),
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
      hasStores = true;
    });

  }

  void refreshStores() {
    if(storeCardsState.currentState != null) {
      storeCardsState.currentState!.refreshStores();
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Listen to changes on the AuthProvider so that we can know when
    /// the authProvider.resourceTotals have been updated. Once the
    /// authProvider.resourceTotals have been updated by the
    /// HomePage Widget, we can then use getter such as
    /// authProvider.hasStores to know whether this
    /// authenticated user has stores.
    /// 
    /// Once these changes occur, we can use the didChangeDependencies() change 
    /// to capture and set the  
    Provider.of<AuthProvider>(context, listen: true);

    return StoreCards(
      key: storeCardsState,
      contentBeforeSearchBar: contentBeforeSearchBar,
      userAssociation: UserAssociation.teamMemberJoined,
    );
  }
}