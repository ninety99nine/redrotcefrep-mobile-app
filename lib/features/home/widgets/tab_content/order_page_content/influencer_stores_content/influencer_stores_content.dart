import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import 'package:get/get.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/api/providers/api_provider.dart';
import '../../../../../stores/widgets/store_cards/store_cards.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class InfluencerStoresContent extends StatefulWidget {
  const InfluencerStoresContent({super.key});

  @override
  State<InfluencerStoresContent> createState() => InfluencerStoresContentState();
}

class InfluencerStoresContentState extends State<InfluencerStoresContent> {

  bool isLoading = false;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get isSuperAdmin => authProvider.user!.isSuperAdmin ?? false;
  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _requestAddStoreToInfluencerStores(ShoppableStore store) {

    if(isLoading) return;
    
    /// If this store is already a brand store
    if(store.isInfluencerStore) {

      SnackbarUtility.showSuccessMessage(message: '${store.name} is already an influencer store');

    /// If we are not already following
    }else{
    
      _startLoader();

      storeProvider.setStore(store).storeRepository.addToInfluencerStores().then((response) {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);
          refreshStores();

        }

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to add to influencer stores');

      }).whenComplete(() {

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
        if(isSuperAdmin && totalStores > 0) Container(
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
          child: Image.asset('assets/images/following/influencers-bg.png'),
        ),

        /// Spacer
        const SizedBox(height: 20,),

        /// Instruction
        const CustomBodyText(
          'Influencers are your locally known influencers. Its your quick and easy space to check out the latest brand offers and best deals from the people you know.',
          padding: EdgeInsets.symmetric(horizontal: 32),
          textAlign: TextAlign.center,
        ),

        if(isSuperAdmin) ...[

          /// Spacer
          const SizedBox(height: 16,),

          /// Add Store Button
          addStoreButton,

        ], 

        /// Spacer
        const SizedBox(height: 100,),

      ],
    );

  }

  Widget get addStoreButton {

    return SearchModalBottomSheet(
      showFilters: false,
      showExpandIconButton: false,
      onSelectedStore: _requestAddStoreToInfluencerStores,
      trigger: (openBottomModalSheet) => CustomElevatedButton(
        '+ Add Store',
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
      contentBeforeSearchBar: contentBeforeSearchBar,
      storesUrl: apiProvider.apiHome!.links.showInfluencerStores,
    );
  }
}
