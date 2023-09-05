import 'dart:convert';

import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:get/get.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'associated_stores_in_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'associated_stores_page/associated_stores_page.dart';
import '../../providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AssociatedStoresContent extends StatefulWidget {
  
  final bool showingFullPage;

  const AssociatedStoresContent({
    super.key,
    this.showingFullPage = false,
  });

  @override
  State<AssociatedStoresContent> createState() => _AssociatedStoresContentState();
}

class _AssociatedStoresContentState extends State<AssociatedStoresContent> {

  bool isDeleting = false;
  bool isSubmitting = false;
  bool disableFloatingActionButton = false;

  User get authUser => authProvider.user!;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  String get mobileNumber => authUser.mobileNumber!.withoutExtension;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<AssociatedStoresInVerticalListViewInfiniteScrollState> _associatedStoresInVerticalListViewInfiniteScrollState = GlobalKey<AssociatedStoresInVerticalListViewInfiniteScrollState>();

  /// Content to show based on the specified view
  Widget get content {

    /// Show associated stores
    return AssociatedStoresInVerticalListViewInfiniteScroll(
      key: _associatedStoresInVerticalListViewInfiniteScrollState
    );
    
  }

  void onSubmitting(status) {
    setState(() {
      isSubmitting = status;
      disableFloatingActionButton = status;
    });
  }

  void onDeleting(status) {
    setState(() {
      isDeleting = status;
      disableFloatingActionButton = status;
    });
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return SearchModalBottomSheet(
      showFilters: false,
      showExpandIconButton: false,
      onSelectedStore: _requestAddToAssignedStores,
      trigger: (openBottomModalSheet) => CustomElevatedButton(
        '+ Add Store',
        disabled: isSubmitting,
        isLoading: isSubmitting,
        alignment: Alignment.center,
        onPressed: () => openBottomModalSheet(),
        color: isDeleting ? Colors.grey : null,
      ),
    );

  }

  void _requestAddToAssignedStores(ShoppableStore store) {
    
    /// If this store is already a brand store
    if(StoreServices.isAssigned(store)) {

      SnackbarUtility.showSuccessMessage(message: 'Store added');

    /// If we are not already following
    }else{
    
      onSubmitting(true);

      storeProvider.setStore(store).storeRepository.addToAssignedStores().then((response) {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

          /// Refresh the list of stores
          _associatedStoresInVerticalListViewInfiniteScrollState.currentState?.refreshStores();

        }

      }).catchError((error) {

        printError(info: error.toString());
        
        SnackbarUtility.showErrorMessage(message: 'Failed to add store');

      }).whenComplete(() {

        onSubmitting(false);

      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    const CustomTitleMediumText('Mobile Stores', padding: EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText('Stores on $mobileNumber'),
                    ),
                    
                  ],
                ),
              ),
          
              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();
                
                /// Navigate to the page
                Get.toNamed(AssociatedStoresPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            top: 54 + topPadding,
            duration: const Duration(milliseconds: 500),
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}