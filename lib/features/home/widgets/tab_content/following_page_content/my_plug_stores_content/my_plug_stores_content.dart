import 'package:bonako_demo/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../../stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import '../../../../../stores/enums/store_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class MyPlugStoresContent extends StatefulWidget {
  const MyPlugStoresContent({super.key});

  @override
  State<MyPlugStoresContent> createState() => MyPlugStoresContentState();
}

class MyPlugStoresContentState extends State<MyPlugStoresContent> {

  bool isLoading = false;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _requestAddStoreToFriendGroups(ShoppableStore store) {
    
    /// If we are already following
    if(StoreServices.isFollowingStore(store)) {

      SnackbarUtility.showSuccessMessage(message: 'You are already following ${store.name}');

    /// If we are not already following
    }else{
    
      _startLoader();

      storeProvider.setStore(store).storeRepository.updateFollowing(
        status: 'Following'   //  Always make sure that we follow (i.e never unfollow)
      ).then((response) {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message']);
          refreshStores();

        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to add to group');

      }).whenComplete((){

        _stopLoader();

      });

    }
  }

  void refreshStores() {
    if(storeCardsState.currentState != null) {
      storeCardsState.currentState!.refreshStores();
    }
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Spacer
        const SizedBox(height: 24,),

        /// Add Store Button
        if(totalStores > 0) Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: addStoreButton
        ),
        
        /// No Stores
        if(totalStores == 0) noStores

      ],
    );
  }
  
  Widget get noStores {
      
    return Column(
      children: [

        //  Image
        SizedBox(
          height: 300,
          child: Image.asset('assets/images/following/my-plugs-bg.png'),
        ),

        /// Spacer
        const SizedBox(height: 20,),

        /// Instruction
        const CustomBodyText(
          'Looking for your plug? Keep them in sight by following their store. It makes it easy to catch up with the latest in stock and best deals.',
          padding: EdgeInsets.symmetric(horizontal: 32),
          textAlign: TextAlign.center,
        ),

        /// Spacer
        const SizedBox(height: 16,),

        /// Add Store Button
        addStoreButton,

        /// Spacer
        const SizedBox(height: 100,),

      ],
    );

  }

  Widget get addStoreButton {

    return SearchModalBottomSheet(
      showFilters: false,
      showExpandIconButton: false,
      onSelectedStore: _requestAddStoreToFriendGroups,
      trigger: (openBottomModalSheet) => CustomElevatedButton(
        'Add Store',
        disabled: isLoading,
        isLoading: isLoading,
        alignment: Alignment.center,
        onPressed: () => openBottomModalSheet(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return StoreCards(
      key: storeCardsState,
      userAssociation: UserAssociation.follower,
      contentBeforeSearchBar: contentBeforeSearchBar,
    );
  }
}
