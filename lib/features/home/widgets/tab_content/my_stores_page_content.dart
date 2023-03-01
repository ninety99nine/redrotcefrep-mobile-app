import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/widgets/create_store/create_store_card.dart';
import '../../../stores/widgets/store_cards/store_cards.dart';
import '../../../../features/stores/enums/store_enums.dart';
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
   *  to swipe between the My Stores, Following and Recent Visits. The natural
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

  Widget get header {
    return const CustomBodyText(
      'Check out your stores',
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8)
    );
  }

  Widget get contentBeforeSearchBar {
    return Column(
      children: [

        /// Header
        //  header,

        /// Spacer
        const SizedBox(height: 8,),

        /// Add Store
        CreateStoreCard(
          onCreatedStore: startRequest
        )

      ],
    );
  }

  void startRequest() {

    if(storeCardsState.currentState != null) {

      storeCardsState.currentState!.startRequest();

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
