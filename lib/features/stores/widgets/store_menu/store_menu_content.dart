import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/stores/widgets/update_store/update_store_modal_bottom_sheet/update_store_modal_bottom_sheet.dart';

import '../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../store_cards/store_card/primary_section_content/store_logo.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../add_store_to_group/add_to_group_button.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import '../../../../core/utils/dialog.dart';
import '../../services/store_services.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class StoreMenuContent extends StatefulWidget {

  final ShoppableStore store;

  const StoreMenuContent({
    super.key,
    required this.store,
  });

  @override
  State<StoreMenuContent> createState() => _StoreMenuContentState();
}

class _StoreMenuContentState extends State<StoreMenuContent> {
  
  bool isLoading = false;

  List<Map> menus = [];

  ShoppableStore get store => widget.store;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);

  bool get isFollower => StoreServices.isFollower(store);
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get isSuperAdmin => authProvider.user!.isSuperAdmin ?? false;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    
    menus.add({
      'icon': Icons.directions_walk_rounded,
      'name': isFollower ? 'Unfollow' : 'Follow',
    });
    
    menus.add({
      'icon': Icons.group_add_outlined,
      'name': 'Add To Group',
    });
    
    if(friendGroupProvider.friendGroup != null) {
      menus.add({
        'icon': Icons.group_remove_outlined,
        'name': 'Remove From Group',
      });
    }
    
    if(StoreServices.isTeamMemberAsCreatorOrAdmin(store)) {
      menus.add({
        'icon': Icons.mode_edit_outlined,
        'name': 'Edit Store',
      });
    }
    
    if(isTeamMemberWhoHasJoined && !canAccessAsTeamMember) {
      menus.add({
        'icon': Icons.sensor_door_outlined,
        'name': 'Subscribe',
      });
    }
    
    menus.add({
      'icon': Icons.arrow_forward,
      'name': 'Visit Store',
    });
    
    if(isSuperAdmin) {

      menus.add({
        'icon': store.isBrandStore ? Icons.remove_circle : Icons.add_circle,
        'name': '${store.isBrandStore ? 'Remove from' : 'Add to'} brand stores'
      });
      
      menus.add({
        'icon': store.isInfluencerStore ? Icons.remove_circle : Icons.add_circle,
        'name': '${store.isInfluencerStore ? 'Remove from' : 'Add to'} influencer stores'
      });

    }
    
    
    if(StoreServices.isTeamMemberAsCreator(store)) {
      menus.add({
        'icon': Icons.delete_outline_rounded,
        'name': 'Delete Store',
      });
    }
  }

  /// Content to show based on the specified view
  Widget get content {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading 
        ? const CustomCircularProgressIndicator() 
        : ListView.separated(
        itemCount: menus.length,
        separatorBuilder: (_, __) => const Divider(height: 0,), 
        itemBuilder: (context, index) {

          final String name = menus[index]['name'];
          final IconData icon = menus[index]['icon'];
          Widget title = Row(
            children: [
              
              /// Icon
              Icon(icon, size: 24, color: name == 'Delete Store' ? Colors.red: null),

              /// Spacer
              const SizedBox(width: 8,),

              /// Name
              CustomBodyText(name, color: name == 'Delete Store' ? Colors.red: null),

            ],
          );

          final Widget listItem = Material(                                                                                                                                           
            color: Colors.transparent,                                                                                                                                        
            child: InkWell(                                                                                                                                          
              child: ListTile(
                onTap: canTap(name) ? () => onTap(name) : null,
                title: title
              ),
            ),
          );

          if(name == 'Add To Group') {
            
            /// Return the modal bottom sheet to select groups with this list item as the trigger
            return AddStoreToGroupButton(
              store: store,
              canShowLoader: false,
              trigger: (openBottomModalSheet) => listItem,
            );
          
          }else if(name == 'Subscribe') {
            
            /// Return the modal bottom sheet to subscribe with this list item as the trigger
            return SubscribeToStoreModalBottomSheet(
              store: store,
              trigger: listItem,
              onDial: () => Get.back()
            );
          
          }else if(name == 'Edit Store') {
            
            /// Return the modal bottom sheet to edit the store with this list item as the trigger
            return UpdateStoreModalBottomSheet(
              store: store,
              trigger: listItem,
              onUpdatedStore: (_) => Get.back()
            );
          
          }else{

            /// Return this list item
            return listItem;

          }

        }, 
      ),
    );
    
  }

  bool canTap(String name) {
    return [
      'Visit Store', 'Delete Store', 'Remove From Group', 'Follow', 'Unfollow',
      'Add to brand stores', 'Remove from brand stores', 'Add to influencer stores', 'Remove from influencer stores',
    ].contains(name);
  }

  void onTap(String name) async {
    
    if(name == 'Visit Store') {
      
      visitStore();

    }else if(name == 'Delete Store') {
      
      confirmDeleteStore();
    
    }else if(name == 'Remove From Group') {
      
      confirmRemoveFromGroup();
    
    }else if(name == 'Follow' || name == 'Unfollow') {
      
      requestUpdateFollowing();
      
    }else if(['Add to brand stores', 'Remove from brand stores'].contains(name)) {

      addOrRemoveFromBrandStores();

    }else if(['Add to influencer stores', 'Remove from influencer stores'].contains(name)) {

      addOrRemoveFromInfluencerStores();

    }
  }

  void requestUpdateFollowing() {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.updateFollowing().then((response) {

      if(response.statusCode == 200) {

        setState(() {
          
          //  Set the updated follower status
          store.attributes.userStoreAssociation!.followerStatus = response.data['followerStatus'];

          //  Refresh the stores
          storeProvider.refreshStores!();

        });

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to ${isFollower ? 'unfollow' : 'follow'}');

    }).whenComplete(() {
  
      _stopLoader();

    });
    
  }

  void addOrRemoveFromBrandStores() {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.addOrRemoveFromBrandStores().then((response) {

      if(response.statusCode == 200) {

        setState(() {
          
          //  Set the updated brand store status
          store.isBrandStore = response.data['isBrandStore'];

          //  Refresh the stores
          storeProvider.refreshStores!();

        });

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to ${store.isBrandStore ? 'remove from brand stores' : 'add to brand stores'}');

    }).whenComplete(() {
  
      _stopLoader();

    });
    
  }

  void addOrRemoveFromInfluencerStores() {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.addOrRemoveFromInfluencerStores().then((response) {

      if(response.statusCode == 200) {

        setState(() {
          
          //  Set the updated influencer store status
          store.isInfluencerStore = response.data['isInfluencerStore'];

          //  Refresh the stores
          storeProvider.refreshStores!();

        });

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to ${store.isBrandStore ? 'remove from influencer stores' : 'add to influencer stores'}');

    }).whenComplete((){

      _stopLoader();

    });
  }

  void requestAddStoreToFriendGroups(List<FriendGroup> friendGroups) {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.addStoreToFriendGroups(
      friendGroups: friendGroups,
    ).then((response) {

      if(response.statusCode == 200) {

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to add to group');

    }).whenComplete((){

      _stopLoader();

    });
  }

  /// Confirm remove the store from group
  confirmRemoveFromGroup() {
    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to remove ${store.name} from this group?',
      context: context
    ).then((confirmation) {

      if(confirmation == true) requestRemoveStoreFromFriendGroups();

    });
  }

  void requestRemoveStoreFromFriendGroups() {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.removeStoreFromFriendGroups(
      friendGroupIds: [friendGroupProvider.friendGroup!.id]
    ).then((response) {

      if(response.statusCode == 200) {

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

        /// Refresh the stores
        if(storeProvider.refreshStores != null) storeProvider.refreshStores!();

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to remove from group');

    }).whenComplete((){

      _stopLoader();

    });
  }

  /// Visit the store
  void visitStore() {

    /// Close the modal bottom sheet
    Get.back();
    
    /// Navigate to the store page
    StoreServices.navigateToStorePage(store);
    
  }

  /// Confirm remove the store from group
  void confirmDeleteStore() {

    void onDeleted() {

      /**
       *  Close the modal bottom sheet
       * 
       *  This must be placed before the SnackbarUtility.showSuccessMessage()
       *  since placing it after will hide the Snackbar message instead of
       *  the modal bottom sheet
       */
      Get.back();

      /// Navigate out of the store page
      if(isShowingStorePage) Get.back();

      /// Refresh the stores
      if(storeProvider.refreshStores != null) storeProvider.refreshStores!();

    }

    DialogUtility.showConfirmDeleteApiResourceDialog(
      confirmDeleteUrl: store.links.confirmDeleteStore.href,
      deleteUrl: store.links.deleteStore.href,
      resourceName: store.name,
      onDeleted: onDeleted,
      context: context
    );

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
                padding: const EdgeInsets.only(top: 20, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //  Store Logo
                        StoreLogo(store: store, radius: 24),

                        /// Spacer
                        const SizedBox(width: 8,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
              
                            /// Title
                            CustomTitleMediumText(store.name, overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 4, bottom: 4),),
                            
                            /// Subtitle
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: CustomBodyText('How can we help you?'),
                            )

                          ],
                        )

                      ],
                    )
                    
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
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          )

        ],
      ),
    );
  }
}