import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_left_side/store_name.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:get/get.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class AssociatedStoresInVerticalListViewInfiniteScroll extends StatefulWidget {

  const AssociatedStoresInVerticalListViewInfiniteScroll({
    super.key,
  });

  @override
  State<AssociatedStoresInVerticalListViewInfiniteScroll> createState() => AssociatedStoresInVerticalListViewInfiniteScrollState();
}

class AssociatedStoresInVerticalListViewInfiniteScrollState extends State<AssociatedStoresInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  User get authUser => authProvider.user!;
  String get mobileNumberShortcode => authUser.attributes.mobileNumberShortcode;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Render each request item as an StoreItem
  Widget onRenderItem(store, int index, List stores, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => StoreItem(
    store: (store as ShoppableStore),
    refreshStores: refreshStores,
    index: index
  );
  
  /// Render each request item as an Store
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<dio.Response> requestAssociatedStores(int page, String searchWord) {
    return storeProvider.storeRepository.showUserStores(
      userAssociation: UserAssociation.assigned,
      user: authProvider.user!,
      searchWord: searchWord,
      page: page
    );
  }

  void onReorder(int oldIndex, int newIndex) {

    CustomVerticalInfiniteScrollState? currentState = customVerticalListViewInfiniteScrollState.currentState;

    if(currentState != null) {

      /**
       *  Fix on reorder issue:
       * 
       *  When we remove an item from the list, the indices of the remaining items in the list 
       *  are shifted down by one. When we insert the same item at the new index, the item is 
       *  inserted at the new index position, and the remaining items are shifted down by one.
       *  This causes the index of the item that was inserted to be off by one when dragging 
       *  downwards.
       * 
       *  To fix this, you can add a check to adjust the new index if the old index is 
       *  less than the new index, like this: 
       */
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final List<ShoppableStore> originalData = List.from(currentState.data);
      final ShoppableStore store = currentState.getItemAt(oldIndex);
      currentState.removeItemAt(oldIndex);
      currentState.insetItemAt(newIndex, store);

      storeProvider.setStore(store).storeRepository.updateAssignedStoresArrangement(
        storeIds: List<ShoppableStore>.from(currentState.data).map((ShoppableStore store) => store.id).toList()
      ).then((response) {

        /// If the response is 200
        if(response.statusCode == 200) {
          
          /// Success

        }else{

            /// Revert the product arrangement
            currentState.setData(originalData);

        }

      });

    }

  }

  void refreshStores() {

    /// Refresh the list of stores
    customVerticalListViewInfiniteScrollState.currentState?.startRequest();

  }

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {

    if(totalStores > 0) {

      return CustomMessageAlert(
        'Add stores here and ask customers to dial $mobileNumberShortcode to access and place orders',
        margin: const EdgeInsets.only(top: 40, bottom: 16, left: 16, right: 16),
        
      );

    }else{

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Promote stores by adding them on your Bonako number. Everytime people dial\n\n ',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  /// Second text must have a normal weight
                  TextSpan(
                    text: mobileNumberShortcode,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).primaryColor
                    )
                  ),
                  /// Second text must have a normal weight
                  TextSpan(
                    text: '\n\nThey can easily access these stores',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    )
                  )
                ]
              ),
            ),
          )

        ],
      );

    }

  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      canReorder: true,
      onReorder: onReorder,
      debounceSearch: true,
      showNoContent: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      headerPadding: EdgeInsets.zero,
      listPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show stores',
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestAssociatedStores(page, searchWord),
    );
  }
}

class StoreItem extends StatefulWidget {
  
  final int index;
  final ShoppableStore store;
  final Function refreshStores;

  const StoreItem({
    super.key,
    required this.index,
    required this.store,
    required this.refreshStores,
  });

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {

  bool isDeleting = false;

  int get index => widget.index;
  ShoppableStore get store => widget.store;
  Function get refreshStores => widget.refreshStores;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void onDeleting(status) {
    setState(() => isDeleting = status);
  }

  void _requestRemoveFromAssignedStores() {
    
    onDeleting(true);

    storeProvider.setStore(store).storeRepository.removeFromAssignedStores().then((response) {

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

        refreshStores();

      }

    }).catchError((error) {

      printError(info: error.toString());
      
      SnackbarUtility.showErrorMessage(message: 'Failed to remove store');

    }).whenComplete(() {

      onDeleting(false);

    });
    
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// Name
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    StoreLogo(store: store),
                    const SizedBox(width: 8.0,),
                    Expanded(child: StoreName(store: store, storeNameSize: StoreNameSize.small,))
                  ],
                )
                
              ],
            )
          ),
      
          /// Spacer
          const SizedBox(width: 8),
      
          /// Remove
          isDeleting 
            ? const CustomCircularProgressIndicator(size: 16, alignment: Alignment.centerLeft,)
            : GestureDetector(
            onTap: _requestRemoveFromAssignedStores, 
            child: const Icon(Icons.delete_outline_rounded)
          ),
      
          /// Spacer
          const SizedBox(width: 8),
      
          /// Drag Handle
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle_rounded)
          )

        ],
      )
      
    );
  }
}