import 'dart:convert';

import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/friend_groups/enums/friend_group_enums.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/widgets/store_card/primary_section_content/logo.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class MenuContent extends StatefulWidget {

  final ShoppableStore store;
  final Function? onRefreshStores;

  const MenuContent({
    super.key,
    required this.store,
    this.onRefreshStores,
  });

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {
  
  bool isLoading = false;

  List<Map> menus = [];

  ShoppableStore get store => widget.store;
  Function? get onRefreshStores => widget.onRefreshStores;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    
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
              Icon(icon, size: 24,),

              /// Spacer
              const SizedBox(width: 8,),

              /// Name
              CustomBodyText(name),

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
            return FriendGroupsModalBottomSheet(
              trigger: listItem,
              enableBulkSelection: true,
              purpose: Purpose.addStoreToFriendGroups,
              onDoneSelectingFriendGroups: requestAddStoreToFriendGroups,
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
    return ['Remove From Group'].contains(name);
  }

  void onTap(String name) async {
    if(name == 'Remove From Group') {
      bool? confirmation = await confirmRemoveFromGroup();
      if(confirmation == true) requestRemoveStoreFromFriendGroups(); 
    }
  }

  /// Confirm remove the store from group
  Future<bool?> confirmRemoveFromGroup() {
    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to remove ${store.name} from this group?',
      context: context
    );

  }

  void requestAddStoreToFriendGroups(List<FriendGroup> friendGroups) {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.addStoreToFriendGroups(
      friendGroups: friendGroups,
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: responseBody['message']);

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to add to group');

    }).whenComplete((){

      _stopLoader();

    });
  }

  void requestRemoveStoreFromFriendGroups() {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.removeStoreFromFriendGroups(
      friendGroup: friendGroupProvider.friendGroup!
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: responseBody['message']);

        /// Refresh the stores
        if(onRefreshStores != null) onRefreshStores!();

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to remove from group');

    }).whenComplete((){

      _stopLoader();

    });
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
                            CustomTitleLargeText(store.name, padding: const EdgeInsets.only(bottom: 4),),
                            
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          )

        ],
      ),
    );
  }
}